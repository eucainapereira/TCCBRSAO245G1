import { DynamoDBClient } from "@aws-sdk/client-dynamodb";
import { DynamoDBDocumentClient, UpdateCommand } from "@aws-sdk/lib-dynamodb";

const ddb = DynamoDBDocumentClient.from(new DynamoDBClient({}));
const TABLE_NAME = process.env.TABLE_NAME || "ContadorAcessos";
const COUNTER_ID = "cliques";

export const handler = async (event) => {
  const count = event.Records ? event.Records.length : 1;
  console.log(`Processing batch of ${count} click messages from SQS`);

  try {
    const result = await ddb.send(new UpdateCommand({
      TableName: TABLE_NAME,
      Key: { id: COUNTER_ID },
      UpdateExpression: "ADD contador :inc",
      ExpressionAttributeValues: { ":inc": count },
      ReturnValues: "UPDATED_NEW",
    }));
    console.log(`Updated contador to: ${result.Attributes.contador}`);
  } catch (err) {
    console.error("Error in SqsWorker:", err);
    throw err;
  }
};
