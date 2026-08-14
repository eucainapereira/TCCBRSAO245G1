import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, GetCommand } from "@aws-sdk/lib-dynamodb";
import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const sqs = new SQSClient({});

const TABLE_NAME = process.env.TABLE_NAME || "ContadorAcessos";
const QUEUE_URL = process.env.QUEUE_URL;
const COUNTER_ID = "cliques";

const headers = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "Content-Type",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
};

export const handler = async (event) => {
  const method = event.requestContext?.http?.method || event.httpMethod;

  if (method === "OPTIONS") {
    return { statusCode: 200, headers, body: "" };
  }

  try {
    if (method === "POST") {
      // Envia mensagem para o SQS (processamento assíncrono)
      await sqs.send(new SendMessageCommand({
        QueueUrl: QUEUE_URL,
        MessageBody: JSON.stringify({ timestamp: Date.now() }),
      }));

      // Retorna o valor atual + 1 como estimativa
      const result = await ddb.send(new GetCommand({
        TableName: TABLE_NAME,
        Key: { id: COUNTER_ID },
      }));

      const current = (result.Item?.contador || 0) + 1;
      return { statusCode: 200, headers, body: JSON.stringify({ contador: current }) };
    }

    // GET: retorna o valor atual do contador
    const result = await ddb.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { id: COUNTER_ID },
    }));
    return { statusCode: 200, headers, body: JSON.stringify({ contador: result.Item?.contador || 0 }) };
  } catch (err) {
    console.error("Error in ApiHandler:", err);
    return { statusCode: 500, headers, body: JSON.stringify({ error: err.message }) };
  }
};
