# Oficina Database Infrastructure

Infraestrutura Terraform independente para o Amazon RDS for PostgreSQL.

## Responsabilidades

- DB subnet group em sub-redes privadas;
- RDS PostgreSQL por ambiente;
- Security Group aceitando 5432 apenas de EKS e Lambda;
- criptografia, backup, retenção e proteção contra exclusão;
- credenciais no AWS Secrets Manager;
- outputs não sensíveis para integração;
- alarmes operacionais e tags de custo.

## Ambientes

- ambos ficam na conta AWS Academy Learner Lab `982623100545`;
- `homolog`: Single-AZ, dados sintéticos e retenção reduzida;
- `production`: instância e backups independentes, proteção contra exclusão;
- Multi-AZ documentado como evolução para produção corporativa.

O uso de duas instâncias depende de saldo, quotas e classes liberadas pelo
laboratório. Secrets Manager, RDS e permissões IAM serão testados antes do
primeiro apply. Se Budgets não estiver disponível, o saldo será conferido
manualmente no início e no fim de cada sessão.

## Recursos provisionados

- RDS PostgreSQL privado e criptografado em repouso;
- `rds.force_ssl=1` para exigir TLS em transito;
- entrada em `5432` exclusivamente por security groups do EKS e da Lambda;
- credencial aleatoria no Secrets Manager;
- backups de 1 dia em `hml` e 7 dias em `prod`;
- protecao contra exclusao e snapshot final em `prod`;
- logs, Performance Insights e alarmes CloudWatch;
- autoscaling de armazenamento.

Os exemplos ficam em `environments/`. Os IDs de rede virao dos outputs da
infraestrutura Kubernetes. O bundle CA oficial do RDS deve ser injetado como
variavel sensivel e nunca commitado. O state tambem contem material sensivel e
devera usar backend remoto criptografado quando permitido pelo Learner Lab.

As migrations serao executadas por Job Kubernetes controlado, conforme
`docs/migrations.md`. O `postgres.yaml` permanece exclusivamente local.

## Arquitetura

```mermaid
flowchart LR
  Terraform["Terraform"] --> RDS["RDS PostgreSQL"]
  Terraform --> SG["Security Groups"]
  Terraform --> Secret["Secrets Manager"]
  Lambda["Lambda Auth"] --> SG
  EKS["EKS"] --> SG
  SG --> RDS
  Secret --> Lambda
  Secret --> EKS
```

O código de provisionamento será criado na etapa de banco gerenciado. Nenhuma
credencial ou estado Terraform deve ser versionado.
