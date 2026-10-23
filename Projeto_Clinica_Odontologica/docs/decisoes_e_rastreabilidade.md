# Decisões, rastreabilidade e organização

## Decisões de modelagem

| ID | Decisão | Justificativa |
|---|---|---|
| DEC-01 | PostgreSQL 14+ como SGBD | Suporta integridade relacional, ranges e exclusões GiST |
| DEC-02 | Um esquema `sorriso_clinica` | Mantém objetos do projeto organizados no banco |
| DEC-03 | Chaves substitutas `BIGINT IDENTITY` | Evita acoplar relacionamentos a dados mutáveis |
| DEC-04 | Não armazenar CPF nem dados clínicos | Minimiza dados sensíveis no protótipo |
| DEC-05 | Preço praticado salvo no item da consulta | Preserva histórico após atualização do catálogo |
| DEC-06 | Saldo de cobrança calculado em view | Evita duplicar total pago/saldo e inconsistência |
| DEC-07 | Estoque como livro imutável de movimentações | Mantém histórico e permite reconstruir saldo |
| DEC-08 | Movimentos de estoque não podem gerar saldo negativo | Protege consistência, inclusive em inserções concorrentes |
| DEC-09 | Agendas usam intervalo semiaberto `[)` | Permite atendimentos consecutivos sem falso conflito |
| DEC-10 | Cobrança única por consulta | Simplifica rastreabilidade no escopo acadêmico |
| DEC-11 | Todos os contatos são fictícios e `.example` | Evita incluir dados de pessoas reais |

## Matriz de rastreabilidade

| Requisito | Regra relacionada | Modelo / implementação | Evidência de validação |
|---|---|---|---|
| RF-01 | RN-01, RN-15 | `paciente` | FK e consulta de histórico |
| RF-02 | RN-02, RN-03 | `profissional`, `especialidade`, `profissional_especialidade` | `UNIQUE`, PK composta e consultas |
| RF-03 | RN-01 | `sala`, `procedimento` | PK, `UNIQUE`, `CHECK` |
| RF-04 | RN-04, RN-06 | `consulta` | `CHECK` de horário e estado |
| RF-05 | RN-05, RN-06 | Exclusões GiST em `consulta` | Casos de sobreposição em `04_validacao.sql` |
| RF-06 | RN-07 | `procedimento_consulta` | FK, preço e quantidade validados |
| RF-07 | RN-08, RN-09, RN-10 | `cobranca`, `pagamento`, `vw_saldo_cobranca` | `UNIQUE`, FK e verificações de saldo |
| RF-08 | RN-13 | `fornecedor`, `ordem_compra`, `item_ordem_compra` | FKs e unicidade do item por ordem |
| RF-09 | RN-11, RN-12, RN-14 | `movimentacao_estoque`, `vw_saldo_estoque`, trigger | Saldo negativo e imutabilidade em validação |
| RF-10 | RN-10, RN-11 | `03_consultas.sql` | Consultas de agenda, financeiro, compras e estoque |
| RF-11 | Todas | `04_validacao.sql` | Consultas de anomalias e instruções de teste |
| RNF-01 | RN-01 | PK/FK de todas as tabelas | Inserções inválidas falham |
| RNF-02 | RN-04, RN-12, RN-16 | `CHECK`, `EXCLUDE`, trigger | Casos inválidos bloqueados |
| RNF-03 | RN-07, RN-10, RN-11 | Entidades associativas e views derivadas | Relatório de normalização |
| RNF-04 | — | Índices do esquema | Índices em agenda, relações e transações |
| RNF-05 | — | `README.md` e scripts numerados | Execução sequencial documentada |
| RNF-06 | — | Dados de `02_dados_sinteticos.sql` | Uso de nomes e domínios demonstrativos |
| RNF-07 | — | `05_permissoes_exemplo.sql` e relatório | Papel de leitura e recomendações |
| RNF-08 | RN-14 | Trigger de movimentação | Tentativas de UPDATE/DELETE bloqueadas |

## Organização sugerida do repositório

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

## Responsabilidades recomendadas para uma equipe

| Frente | Entregável | Dependência |
|---|---|---|
| Negócio | Empresa, processos, escopo e requisitos | Nenhuma |
| Modelagem | MER, cardinalidades e normalização | Levantamento do negócio |
| Banco de dados | DDL, constraints, views e índices | Modelo lógico aprovado |
| Dados e consultas | Massa sintética e relatórios | Esquema criado |
| Qualidade | Casos de teste e validação | Esquema e dados carregados |
| Documentação | Relatório, README e decisões | Conteúdo das demais frentes |

## Decisões que exigem revisão antes de produção

- duração e regras de transição dos estados da consulta;
- permissões diferenciadas para recepção, dentistas e financeiro;
- retenção e auditoria de dados de pacientes e registros clínicos;
- emissão fiscal, convênios e política de estorno;
- cadastro de unidades, fusos horários e calendário de feriados;
- autorização para uso de BI ou modelos preditivos.
