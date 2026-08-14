# TCC - BRSAO245 - G1
Projeto Final do Curso AWS RE/START da Escola da Nuvem
Turma BRSAO245

---

## 📋 Sobre o Projeto

**CONTADOR DE ACESSOS SERVERLESS**

Uma startup de marketing está lançando uma campanha para um novo produto.
Eles criaram uma página "Em Breve" com um contador que mostra quantas pessoas já se interessaram.
A solução é 100% Serverless — barata e escala automaticamente.

---

## 🏗️ Arquitetura

```
Cliente (Browser)
    │
    ▼
┌──────────────┐
│ S3 Website   │  ← Página estática "Em Breve"
└──────┬───────┘
       │ HTTPS
       ▼
┌──────────────┐
│ API Gateway  │  ← HTTP API v2 (rota ANY /contador)
│  (HTTP API)  │
└──────┬───────┘
       │
       ├─── GET  → Lambda ApiHandler → DynamoDB (lê contador)
       │
       └─── POST → Lambda ApiHandler → SQS Queue
                                          │
                                          ▼
                                    Lambda SqsWorker
                                          │
                                          ▼
                                      DynamoDB
                                  (incrementa contador)
```

### Serviços AWS utilizados:

| Serviço | Recurso | Descrição |
|---------|---------|-----------|
| **S3** | `site-em-breve-027420445627` | Hospedagem do site estático |
| **API Gateway** | `ContadorApi` (HTTP API v2) | Porta de entrada HTTPS |
| **Lambda** | `ContadorApiHandler` | Recebe requests, envia ao SQS |
| **Lambda** | `ContadorSqsWorker` | Consome SQS, incrementa DynamoDB |
| **SQS** | `ContadorClicksQueue` | Fila para processamento assíncrono |
| **DynamoDB** | `ContadorAcessos` | Armazena o contador (chave: `cliques`) |
| **IAM** | `ContadorLambdaRole` | Permissões para as Lambdas |

---

## 🔒 Permissões IAM — Princípio do Menor Privilégio

A role `ContadorLambdaRole` segue o princípio do **menor privilégio (Least Privilege)**: cada serviço recebe apenas as permissões estritamente necessárias para executar sua função.

| Serviço | Permissão IAM (Action) | Motivo |
|---------|------------------------|--------|
| **SQS** | `sqs:SendMessage` | API Handler envia cliques para a fila |
| **SQS** | `sqs:ReceiveMessage` | SQS Worker consome mensagens da fila |
| **SQS** | `sqs:DeleteMessage` | SQS Worker remove mensagens processadas |
| **SQS** | `sqs:GetQueueAttributes` | Lambda lê metadados da fila (batch size, etc.) |
| **DynamoDB** | `dynamodb:PutItem` | Cria o registro inicial do contador |
| **DynamoDB** | `dynamodb:UpdateItem` | Incrementa o valor do contador atomicamente |
| **DynamoDB** | `dynamodb:GetItem` | Lê o valor atual do contador |
| **CloudWatch** | `logs:CreateLogGroup` | Cria o grupo de logs da Lambda |
| **CloudWatch** | `logs:CreateLogStream` | Cria o stream de logs por execução |
| **CloudWatch** | `logs:PutLogEvents` | Registra os logs de cada invocação |

> ⚠️ **Nenhuma permissão `*` (wildcard) é utilizada.** Cada action é restrita ao ARN específico do recurso alvo (tabela DynamoDB e fila SQS), nunca a `Resource: "*"`.

---

## 🚀 CI/CD com GitHub Actions

A infraestrutura é gerenciada 100% com **Terraform** e deployada automaticamente via **GitHub Actions**.

### Workflows disponíveis:

| Ação | Trigger | Descrição |
|------|---------|-----------|
| **Deploy** | Push na `main` | Executa `terraform apply` e atualiza o site no S3 |
| **Destroy** | Manual (`workflow_dispatch`) | Executa `terraform destroy` |
| **Cleanup Legacy** | Manual (`workflow_dispatch`) | Remove recursos antigos criados via AWS CLI |

### Secrets necessários no GitHub:

| Secret | Descrição |
|--------|-----------|
| `AWS_ACCESS_KEY_ID` | Access Key do IAM |
| `AWS_SECRET_ACCESS_KEY` | Secret Key do IAM |

---

## 📁 Estrutura do Repositório

```
├── .github/workflows/
│   └── deploy.yml          # CI/CD Pipeline
├── terraform/
│   ├── main.tf             # Provider + Backend S3
│   ├── variables.tf        # Variáveis
│   ├── dynamodb.tf         # Tabela DynamoDB
│   ├── sqs.tf              # Fila SQS
│   ├── iam.tf              # Role + Policies
│   ├── lambda.tf           # Funções Lambda
│   ├── apigateway.tf       # API Gateway HTTP API
│   ├── s3.tf               # Bucket S3 (website)
│   └── outputs.tf          # Outputs
├── lambda/
│   ├── api_handler/
│   │   └── index.mjs       # Lambda: API Handler
│   └── sqs_worker/
│       └── index.mjs       # Lambda: SQS Worker
├── frontend/
│   ├── index.html           # Página "Em Breve"
│   ├── diagrama_foto.jpg    # Foto do diagrama
│   └── slide/               # Slides da apresentação
└── README.md
```

---

## 🔧 Como usar

### Primeiro deploy (limpeza de recursos antigos):

1. Configure os secrets `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY` no GitHub
2. Vá em **Actions** → **Deploy Infraestrutura AWS com Terraform**
3. Clique em **Run workflow** → Selecione **cleanup-legacy** → **Run**
4. Após a limpeza, clique novamente → Selecione **deploy** → **Run**

### Deploys subsequentes:

Basta fazer push na branch `main` — o deploy é automático.

### Para destruir toda a infra:

Vá em **Actions** → **Run workflow** → Selecione **destroy** → **Run**

---

## 💰 Custo Estimado

≈ **USD 4,30/mês** (Free Tier pode zerar esse custo)

---

## 👥 Equipe

Turma BRSAO245 - Grupo 1 — Escola da Nuvem
