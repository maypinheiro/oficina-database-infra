# Execucao controlada de migrations

O Terraform provisiona o banco, mas nao executa SQL. A evolucao do schema pertence
a versao da aplicacao e sera executada por um Job Kubernetes temporario usando a
mesma imagem imutavel que sera implantada.

Fluxo obrigatorio:

1. obter o segredo do banco pelo mecanismo de secrets do cluster;
2. executar `npm run prisma:migrate` uma unica vez;
3. aguardar sucesso do Job antes do rollout da API;
4. interromper o deploy em caso de falha;
5. registrar logs e versao da migration como evidencia da pipeline.

O Job deve usar uma ServiceAccount dedicada, possuir acesso de rede ao security
group do RDS e ser removido automaticamente apos a conclusao. Nao usar
`prisma db push` em homologacao ou producao e nao implantar o `postgres.yaml`
local no cluster AWS.
