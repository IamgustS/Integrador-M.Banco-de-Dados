# Projeto de banco de dados — Sorriso do Vale Odontologia

Projeto acadêmico fictício de modelagem e implementação de um banco de dados relacional para uma clínica odontológica de pequeno porte. O material cobre o levantamento do negócio, requisitos, regras, modelos conceitual e relacional, normalização, implementação SQL, dados de teste, consultas, validações e proposta analítica, seguindo as etapas do roteiro fornecido.

## Escopo

O banco apoia:

- cadastro operacional de pacientes e profissionais;
- especialidades, salas e catálogo de procedimentos;
- agendamento, atendimento e procedimentos realizados;
- faturamento e registro de pagamentos;
- fornecedores, compras e movimentação de materiais odontológicos;
- consultas de gestão, conferência e validação.

Todos os nomes, contatos, registros profissionais, valores e eventos de exemplo são **fictícios**. O projeto não deve ser usado para armazenar dados reais de pacientes sem avaliação de segurança, privacidade e conformidade.

## Tecnologias e pré-requisitos

- PostgreSQL 14 ou superior;
- `psql` ou cliente PostgreSQL equivalente;
- permissão para criar a extensão `btree_gist`, necessária para impedir conflitos de horário de profissionais e salas.

O SQL usa o esquema `sorriso_clinica` dentro do banco selecionado. A criação do banco é separada do script de esquema para que os comandos sejam executados fora de uma transação.

### PostgreSQL portátil no Windows

Os binários oficiais do PostgreSQL 18.6 estão em `%LOCALAPPDATA%\Programs\PostgreSQL\18.6\pgsql\bin`. O pacote portátil não registra um serviço do Windows. Neste computador, o cluster permanente já foi criado em `%LOCALAPPDATA%\PostgreSQL\sorriso-clinica\data`, o banco `sorriso_clinica` foi carregado e o servidor está configurado para aceitar conexões somente de `127.0.0.1`. A senha administrativa aleatória está armazenada, criptografada para esta conta do Windows, no arquivo `%LOCALAPPDATA%\PostgreSQL\sorriso-clinica\postgres-password.dpapi`; ela não está no projeto.

Para iniciar ou se conectar ao banco em um novo terminal PowerShell:

```powershell
$pgBin = "$env:LOCALAPPDATA\Programs\PostgreSQL\18.6\pgsql\bin"
$pgData = "$env:LOCALAPPDATA\PostgreSQL\sorriso-clinica\data"
$env:Path = "$pgBin;$env:Path"

$securePassword = Get-Content "$env:LOCALAPPDATA\PostgreSQL\sorriso-clinica\postgres-password.dpapi" | ConvertTo-SecureString
$pgCredential = [System.Net.NetworkCredential]::new("", $securePassword)
$env:PGPASSWORD = $pgCredential.Password
$env:PGHOST = "127.0.0.1"
$env:PGPORT = "5432"
$env:PGUSER = "postgres"

& "$pgBin\pg_ctl.exe" -D $pgData status
if ($LASTEXITCODE -ne 0) {
    & "$pgBin\pg_ctl.exe" -D $pgData -l "$pgData\postgresql.log" -o "-h 127.0.0.1 -p 5432" -w start
}

& "$pgBin\psql.exe" -X -d sorriso_clinica
```

No prompt do `psql`, execute `SELECT COUNT(*) FROM sorriso_clinica.paciente;`. Para sair, digite `\q`. Depois, remova a senha da sessão PowerShell e, se desejar, pare o servidor:

```powershell
Remove-Item Env:PGPASSWORD
& "$pgBin\pg_ctl.exe" -D $pgData -m fast -w stop
```

Para preparar uma instalação nova em outro computador, crie o cluster apenas uma vez com `initdb.exe -W` e defina uma senha sua durante o processo; **não execute `initdb` de novo neste computador**, pois isso recria os arquivos do cluster.

## Estrutura

```text
Projeto_Clinica_Odontologica/
├── README.md
├── docs/
│   ├── decisoes_e_rastreabilidade.md
│   ├── modelo_er.mmd
│   └── relatorio_tecnico.md
└── scripts/
    ├── 00_criar_banco.sql
    ├── 01_esquema.sql
    ├── 02_dados_sinteticos.sql
    ├── 03_consultas.sql
    ├── 04_validacao.sql
    └── 05_permissoes_exemplo.sql
```

## Instalação e execução

Execute primeiro a criação do banco conectado ao banco administrativo `postgres`. Em seguida, conecte ao banco criado e aplique os scripts na ordem:

```text
psql -X -v ON_ERROR_STOP=1 -d postgres -f scripts/00_criar_banco.sql
psql -X -v ON_ERROR_STOP=1 -d sorriso_clinica -f scripts/01_esquema.sql
psql -X -v ON_ERROR_STOP=1 -d sorriso_clinica -f scripts/02_dados_sinteticos.sql
psql -X -v ON_ERROR_STOP=1 -d sorriso_clinica -f scripts/03_consultas.sql
psql -X -v ON_ERROR_STOP=1 -d sorriso_clinica -f scripts/04_validacao.sql
```

Execute os comandos a partir desta pasta ou ajuste os caminhos dos arquivos. O script de permissões é opcional e deve ser executado por um administrador:

```text
psql -X -v ON_ERROR_STOP=1 -d sorriso_clinica -f scripts/05_permissoes_exemplo.sql
```

O script de criação do banco deve ser executado uma vez. Os scripts de esquema e carga são destinados a um banco novo; eles não apagam dados nem recriam objetos existentes. Para repetir a execução do zero, crie outro banco de teste ou remova o banco anterior conscientemente antes de começar.

## O que verificar

- `03_consultas.sql` contém exemplos operacionais, financeiros, de estoque, compras e gestão.
- `04_validacao.sql` executa verificações de integridade. As consultas de anomalia devem retornar **zero linhas**; as consultas de inventário mostram saldos e itens abaixo do mínimo quando aplicável.
- `docs/relatorio_tecnico.md` registra o negócio, processos, escopo, requisitos, regras, normalização, decisões de modelagem, validação e evolução analítica.
- `docs/modelo_er.mmd` é a fonte do diagrama ER em Mermaid.
- `docs/decisoes_e_rastreabilidade.md` liga requisitos, regras, modelo, implementação e testes.

## Validação realizada

Scripts executados com PostgreSQL 18.6 no Windows. A criação do banco, o esquema, os dados sintéticos, as consultas, as verificações de integridade e o script opcional de permissões foram executados com sucesso. A massa produziu 6 pacientes, 9 consultas, 5 cobranças e 5 materiais; os testes automatizados confirmaram as restrições de agenda, estoque, cobranças, pagamentos e imutabilidade. As consultas de saldo negativo retornaram zero registros.

Os testes de integração usaram PostgreSQL 18.6; o cluster permanente acima também foi verificado com sucesso e o servidor está disponível em `127.0.0.1:5432`. Os binários portáteis ficam no perfil local do Windows; nenhum serviço do Windows foi instalado.

## Limites e uso responsável

Este é um protótipo acadêmico: não implementa prontuário clínico completo, emissão fiscal, integração bancária, autenticação de usuários, criptografia em repouso, política de retenção ou controles de acesso por paciente. O modelo evita texto clínico livre e usa apenas dados sintéticos. Antes de qualquer uso real, é necessário definir controles de acesso e auditoria, cópias de segurança, criptografia, retenção, base legal e procedimentos adequados à LGPD e às normas profissionais aplicáveis.
