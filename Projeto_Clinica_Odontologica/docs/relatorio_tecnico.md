# Relatório técnico — Sorriso do Vale Odontologia

**Projeto Integrador de Modelagem de Banco de Dados**  
**Empresa:** Sorriso do Vale Odontologia (fictícia)  
**Porte e segmento:** microempresa de serviços odontológicos  
**SGBD escolhido:** PostgreSQL 14+  
**Natureza dos dados do projeto:** exclusivamente sintéticos

## 1. Introdução e objetivo

A Sorriso do Vale é uma clínica odontológica fictícia de pequeno porte, com quatro cirurgiões-dentistas, quatro salas de atendimento e uma equipe administrativa. A clínica agenda consultas, registra os procedimentos efetuados, acompanha pagamentos e compra materiais de fornecedores. A operação simulada usa planilhas independentes, causando agenda conflitante, histórico fragmentado, dificuldade para identificar inadimplência e falta de visibilidade sobre os materiais disponíveis.

O objetivo é projetar e implementar uma base relacional coerente, normalizada e verificável para apoiar essas rotinas. O banco fornece uma fonte única para agenda, atendimento, faturamento, compras e estoque, sem substituir prontuário clínico, sistema fiscal ou software de gestão completo.

## 2. Empresa, público e escopo

### 2.1 Caracterização

| Item | Definição |
|---|---|
| Nome | Sorriso do Vale Odontologia |
| Porte | Microempresa fictícia |
| Segmento | Serviços odontológicos |
| Público-alvo | Pessoas atendidas mediante agendamento |
| Processos principais | Cadastro, agenda, atendimento, faturamento, compras e estoque |
| Usuários previstos | Recepção, dentistas, responsável financeiro e gestor |

### 2.2 Dentro do escopo

- cadastro operacional mínimo de pacientes, profissionais, especialidades e salas;
- catálogo de procedimentos e preço praticado no atendimento;
- criação e acompanhamento de consultas;
- associação de um ou mais procedimentos a cada consulta;
- emissão de um registro de cobrança por consulta e registro de pagamentos;
- cadastro de fornecedores e materiais;
- ordens de compra, itens comprados e razão de movimentações do estoque;
- consultas gerenciais e verificações de consistência.

### 2.3 Fora do escopo

- prontuário clínico completo, imagens, receitas e anexos;
- diagnóstico clínico, prescrição ou recomendação automatizada;
- emissão de nota fiscal, convênio, repasse profissional e conciliação bancária;
- autenticação, interface de usuário, integração externa e implantação em nuvem;
- dados pessoais reais ou carga de produção.

O escopo exclui conteúdo clínico livre para reduzir a exposição de dados sensíveis no protótipo. A inclusão futura de prontuário exige análise específica de privacidade, segurança, acesso e retenção.

## 3. Processos do negócio

### 3.1 Agendamento e atendimento

1. A recepção localiza ou cadastra o paciente.
2. Seleciona profissional, sala, início e término previsto.
3. O banco impede intervalos sobrepostos para o mesmo profissional ou sala nos estados ativos.
4. A consulta passa por `agendada`, `confirmada`, `em_atendimento` e, ao final, `concluida`; também pode ser cancelada ou marcada como falta.
5. Na conclusão, a equipe registra os procedimentos efetuados e, quando aplicável, o consumo de materiais.
6. Uma consulta concluída pode receber uma cobrança com pagamentos parciais ou integrais.

### 3.2 Compras e estoque

1. O gestor cadastra fornecedor e materiais.
2. Abre uma ordem de compra com seus itens, quantidades e custos.
3. No recebimento, registra movimentações de entrada relacionadas aos itens comprados.
4. O consumo é registrado como saída vinculada a uma consulta.
5. O saldo é calculado a partir do livro de movimentações; movimentações são imutáveis e não podem deixar saldo negativo.

### 3.3 Fluxo resumido

`Paciente → Agendamento → Atendimento → Procedimentos → Cobrança → Pagamentos`

`Fornecedor → Ordem de compra → Recebimento → Entrada de estoque → Consumo no atendimento`

## 4. Problemas observados e resposta do modelo

| Problema | Consequência | Resposta proposta |
|---|---|---|
| Agendas e salas controladas em planilhas distintas | Conflitos e retrabalho | Restrições de exclusão por profissional e por sala |
| Paciente repetido em várias planilhas | Histórico fragmentado | Chave própria e cadastro central de paciente |
| Preço do catálogo usado como histórico de cobrança | Alteração de preços distorce valores passados | Preço unitário registrado em cada procedimento da consulta |
| Pagamentos sem vínculo rastreável | Dificuldade de conciliar saldo | Pagamentos associados à cobrança e saldo calculado |
| Estoque atualizado manualmente | Falta ou saldo incorreto | Livro imutável de entradas, saídas e ajustes |
| Decisões sem rastreabilidade | Mudanças sem justificativa | Matriz de rastreabilidade e registro de decisões |

## 5. Requisitos

### 5.1 Requisitos funcionais

| ID | Requisito |
|---|---|
| RF-01 | Cadastrar, consultar e desativar pacientes sem apagar histórico |
| RF-02 | Cadastrar profissionais, especialidades e suas associações |
| RF-03 | Manter salas e procedimentos oferecidos |
| RF-04 | Agendar, confirmar, iniciar, concluir, cancelar e registrar falta em consulta |
| RF-05 | Impedir conflitos de horário por profissional e por sala |
| RF-06 | Registrar um ou mais procedimentos por consulta com quantidade, dente opcional e preço histórico |
| RF-07 | Registrar cobrança única por consulta e pagamentos parciais |
| RF-08 | Cadastrar fornecedores, materiais, ordens e itens de compra |
| RF-09 | Registrar movimentações de estoque e consultar saldo atual |
| RF-10 | Consultar agenda, histórico operacional, receita, saldos, consumo e compras |
| RF-11 | Executar verificações de integridade e de consistência financeira e operacional |

### 5.2 Requisitos não funcionais

| ID | Requisito |
|---|---|
| RNF-01 | Integridade referencial por PK e FK |
| RNF-02 | Valores, quantidades, horários e estados validados por restrições |
| RNF-03 | Modelo relacional normalizado até a 3FN para os atributos do escopo |
| RNF-04 | Consultas usuais apoiadas por índices de data, estado e relações |
| RNF-05 | Scripts legíveis, ordenados, documentados e executáveis em PostgreSQL |
| RNF-06 | Nenhum dado real de paciente no repositório |
| RNF-07 | Acesso real deve seguir privilégio mínimo e proteção de dados sensíveis |
| RNF-08 | Movimentações de estoque auditáveis e não editáveis após inserção |

### 5.3 Regras de negócio

| ID | Regra |
|---|---|
| RN-01 | Cada paciente, profissional, sala, procedimento, fornecedor e material possui identificador próprio |
| RN-02 | O CRO fictício do profissional é único no conjunto de exemplo |
| RN-03 | Um profissional pode possuir várias especialidades; a associação é única por par |
| RN-04 | O término de uma consulta deve ser posterior ao início |
| RN-05 | Consultas ativas não podem sobrepor horário do profissional nem da sala |
| RN-06 | Consultas canceladas ou com falta não bloqueiam a agenda |
| RN-07 | Uma consulta pode conter vários procedimentos; preço e quantidade praticados são preservados por linha |
| RN-08 | Uma consulta pode possuir no máximo uma cobrança; somente consultas concluídas devem ser faturadas |
| RN-09 | Uma cobrança pode receber vários pagamentos; somente pagamentos confirmados compõem o valor pago |
| RN-10 | O saldo da cobrança é calculado; não é armazenado como valor duplicado |
| RN-11 | Quantidade de estoque é derivada de movimentações: entrada soma, consumo/saída subtrai |
| RN-12 | Movimentação de estoque exige quantidade positiva e não pode reduzir o saldo abaixo de zero |
| RN-13 | Movimentação de entrada por compra deve apontar para item da ordem de compra; consumo deve apontar para consulta |
| RN-14 | Movimentações registradas não são alteradas ou apagadas; correção é feita com lançamento compensatório |
| RN-15 | Desativação preserva o histórico de consultas, cobranças e movimentos |
| RN-16 | Valores monetários usam `NUMERIC`, evitando arredondamento binário de ponto flutuante |

## 6. Modelo conceitual (MER/DER)

O diagrama fonte está em [`modelo_er.mmd`](modelo_er.mmd). Entidades principais:

- **Paciente**, **Profissional**, **Especialidade**, **Sala** e **Procedimento**;
- **Consulta** e **Procedimento da consulta**;
- **Cobrança** e **Pagamento**;
- **Fornecedor**, **Material**, **Ordem de compra**, **Item de compra** e **Movimentação de estoque**.

Relacionamentos e cardinalidades:

- paciente `1:N` consulta; profissional `1:N` consulta; sala `1:N` consulta;
- profissional `N:M` especialidade, resolvido por `profissional_especialidade`;
- consulta `1:N` procedimento da consulta; procedimento `1:N` procedimento da consulta;
- consulta `0:1` cobrança; cobrança `1:N` pagamento;
- fornecedor `1:N` ordem de compra; ordem `1:N` item de compra; material `1:N` item de compra;
- material `1:N` movimentação; consulta `0:N` movimentação de consumo; item de compra `0:N` movimentação de entrada.

As associações opcionais refletem estágios reais: uma consulta agendada ainda não tem procedimentos nem cobrança; um item comprado ainda não recebido não tem movimentação de entrada.

## 7. Modelo lógico e relacional

As tabelas estão no esquema `sorriso_clinica`. Identificadores são chaves substitutas `BIGINT GENERATED BY DEFAULT AS IDENTITY`; relações usam FKs com exclusão restrita por padrão.

| Tabela | Chave primária | Principais FKs / finalidade |
|---|---|---|
| `paciente` | `paciente_id` | Cadastro operacional mínimo |
| `especialidade` | `especialidade_id` | Vocabulário de especialidades |
| `profissional` | `profissional_id` | Dentistas fictícios e CRO de exemplo |
| `profissional_especialidade` | (`profissional_id`, `especialidade_id`) | Resolve N:M |
| `sala` | `sala_id` | Recursos de agenda |
| `procedimento` | `procedimento_id` | Catálogo e preço de referência |
| `consulta` | `consulta_id` | Paciente, profissional, sala, intervalo e estado |
| `procedimento_consulta` | `procedimento_consulta_id` | Procedimentos realizados e preço praticado |
| `cobranca` | `cobranca_id` | No máximo uma por consulta |
| `pagamento` | `pagamento_id` | Pagamentos associados à cobrança |
| `fornecedor` | `fornecedor_id` | Dados comerciais mínimos |
| `material` | `material_id` | Materiais e ponto de reposição |
| `ordem_compra` | `ordem_compra_id` | Pedido ao fornecedor |
| `item_ordem_compra` | `item_ordem_compra_id` | Material, quantidade e custo pedido |
| `movimentacao_estoque` | `movimentacao_estoque_id` | Livro de entradas, consumos e ajustes |

As views `vw_saldo_cobranca` e `vw_saldo_estoque` expõem valores derivados sem redundância.

## 8. Normalização

### 8.1 Primeira Forma Normal (1FN)

Cada campo contém um único valor atômico. Procedimentos de uma consulta não são armazenados como lista delimitada; cada procedimento tem sua linha em `procedimento_consulta`. Especialidades de um profissional são linhas em `profissional_especialidade`. Itens de uma compra são linhas em `item_ordem_compra`.

### 8.2 Segunda Forma Normal (2FN)

Todos os atributos não-chave dependem da chave completa. A associação N:M possui PK composta apenas pelos dois identificadores e não contém descrição de profissional ou especialidade. Atributos de procedimento, material e fornecedor permanecem nas respectivas tabelas.

### 8.3 Terceira Forma Normal (3FN)

Não há dependências transitivas intencionais entre atributos não-chave. Por exemplo, a descrição da especialidade não é repetida no profissional; o nome do material não é copiado para o item comprado; o nome do paciente não é replicado na consulta. Os preços e custos observados em transações são snapshots deliberados: preservam o valor histórico mesmo após alteração do catálogo.

Saldos de cobrança e estoque não são colunas armazenadas: são calculados por views sobre linhas de transação, evitando inconsistência de atualização.

## 9. Implementação e integridade

O script [`../scripts/00_criar_banco.sql`](../scripts/00_criar_banco.sql) cria o banco. O script [`../scripts/01_esquema.sql`](../scripts/01_esquema.sql) implementa:

- esquema, tabelas, PKs, FKs, `UNIQUE`, `CHECK` e índices;
- restrições de exclusão GiST para intervalos de agenda ativos;
- views de saldo financeiro e de estoque;
- trigger que serializa novas movimentações por material, impede saldo negativo e torna o livro imutável.

O script [`../scripts/02_dados_sinteticos.sql`](../scripts/02_dados_sinteticos.sql) insere uma massa pequena e coerente para demonstração. A carga inclui consultas concluídas, futuras, canceladas e faltas; pagamentos integrais e parciais; compras recebidas; e consumo de materiais.

### 9.1 Integridade referencial

FKs impedem consulta sem paciente, profissional ou sala; cobrança sem consulta; pagamento sem cobrança; compra sem fornecedor; item de compra sem ordem/material; e movimento sem material ou origem operacional válida.

### 9.2 Agenda sem conflito

`btree_gist` permite impor exclusão de intervalos `tstzrange(..., '[)')` por profissional e sala. O intervalo semiaberto permite que uma consulta comece exatamente quando a anterior termina. Consultas canceladas e faltas não participam das exclusões.

### 9.3 Estoque

O saldo é o total de entradas menos consumos e saídas. A função do trigger bloqueia saldo negativo com bloqueio da linha do material, tornando a verificação segura contra inserções concorrentes do mesmo item. Movimentos existentes são imutáveis; erros são corrigidos com movimentação compensatória.

## 10. Consultas e análises

O script [`../scripts/03_consultas.sql`](../scripts/03_consultas.sql) contém consultas de:

1. agenda por período com nomes e sala;
2. histórico operacional do paciente;
3. procedimentos mais executados e receita bruta;
4. receita e pagamentos confirmados por mês;
5. cobranças em aberto, pagas parcialmente ou com saldo inconsistente;
6. cancelamentos e faltas por profissional;
7. saldo atual e materiais abaixo do mínimo;
8. compras por fornecedor e status de recebimento;
9. consumo de materiais por período.

O script de validação contém consultas para duplicidade, referências ausentes, faturamento de consulta não concluída, inconsistência de pagamento, saldo negativo e compra recebida sem movimentação de entrada. Ausência de linhas nas verificações de anomalia representa o resultado esperado.

## 11. Massa de dados e testes

Todos os dados têm finalidade demonstrativa. Não há CPF, endereço residencial, prontuário, telefone real ou e-mail pessoal. Os endereços de e-mail usam o domínio reservado `.example`.

### Casos cobertos

| Caso | Resultado esperado |
|---|---|
| Criar consulta com término anterior ao início | Bloqueio por `CHECK` |
| Sobrepor consulta ativa do mesmo profissional | Bloqueio pela exclusão GiST |
| Sobrepor consulta ativa na mesma sala | Bloqueio pela exclusão GiST |
| Agendar depois de consulta cancelada ou falta | Permitido |
| Inserir pagamento negativo ou zero | Bloqueio por `CHECK` |
| Registrar consumo acima do saldo | Bloqueio pelo trigger |
| Atualizar ou apagar movimentação de estoque | Bloqueio pelo trigger |
| Associar pagamento a cobrança inexistente | Bloqueio por FK |
| Emitir segunda cobrança para mesma consulta | Bloqueio por `UNIQUE` |
| Inserir FK inexistente | Bloqueio por FK |

As verificações executáveis estão em `04_validacao.sql`. O script de consulta contém também exemplos de `UPDATE` e `DELETE` dentro de transações revertidas, sem deixar alterações no conjunto de demonstração.

## 12. Proposta de BI e IA

### BI

Um painel pode consolidar:

- consultas por período, estado, profissional e procedimento;
- taxa de ocupação por profissional e sala;
- cancelamento e ausência por período;
- receita faturada, valores pagos e saldo em aberto;
- consumo, cobertura estimada e itens abaixo do estoque mínimo;
- tempo entre pedido e recebimento de compras.

Cada indicador deve definir claramente numerador, denominador, período, fuso horário e regras de exclusão. Receita faturada e pagamento recebido são métricas distintas.

### IA — hipótese futura

Com dados suficientes, lícitos e devidamente governados, pode-se estudar previsão de procura por materiais e risco de falta a consultas. As saídas devem servir apenas como apoio à equipe; não devem diagnosticar, recomendar tratamentos nem substituir decisão profissional. É necessário avaliar qualidade, viés, explicabilidade, acesso e retenção antes de qualquer piloto. Este repositório não implementa nem treina modelo de IA.

## 13. Segurança, privacidade e governança

- Usar dados sintéticos em desenvolvimento, testes, capturas de tela e demonstrações.
- Aplicar menor privilégio; o script opcional cria um papel de leitura sem credenciais.
- Não salvar senhas, tokens ou dados identificáveis no repositório.
- Em produção, avaliar criptografia em trânsito e repouso, backup testado, trilha de auditoria, segregação por função, retenção e resposta a incidentes.
- Dados de saúde são sensíveis. Definir base legal, finalidade, transparência, direitos dos titulares e controles com responsáveis competentes antes de tratar dados reais.
- O protótipo não é um prontuário eletrônico nem uma declaração de conformidade legal.

## 14. Conclusão

O projeto transforma os processos descritos em entidades, relacionamentos, regras verificáveis, estruturas normalizadas e consultas executáveis. O modelo preserva histórico de preços e movimentos, evita conflitos de agenda, deriva saldos e inclui massa sintética para testar a integração. As principais limitações restantes são interface, autenticação, prontuário, emissão fiscal, implantação e governança para uso real.

## 15. Roteiro de trabalho concluído

1. Caracterizar a empresa fictícia e seu segmento.
2. Definir público-alvo, usuários e escopo.
3. Mapear os processos de agenda, atendimento, cobrança, compras e estoque.
4. Registrar problemas operacionais e suas consequências.
5. Escrever requisitos funcionais.
6. Escrever requisitos não funcionais e regras de negócio.
7. Identificar as entidades do domínio.
8. Definir atributos, domínios e obrigatoriedade.
9. Definir identificadores e chaves candidatas.
10. Estabelecer relacionamentos e cardinalidades.
11. Construir o modelo conceitual e seu diagrama.
12. Conferir o modelo com processos e requisitos.
13. Aplicar a primeira forma normal (1FN).
14. Verificar dependências parciais e aplicar a segunda forma normal (2FN).
15. Verificar dependências transitivas e aplicar a terceira forma normal (3FN).
16. Converter o modelo conceitual para o modelo relacional.
17. Escolher o SGBD, os tipos de dados e as chaves.
18. Implementar tabelas, restrições, índices, views e trigger.
19. Criar e carregar massa de dados sintéticos.
20. Elaborar consultas operacionais e gerenciais.
21. Executar verificações de integridade e testes negativos.
22. Definir indicadores de BI e uma hipótese de IA responsável.
23. Registrar decisões, riscos, segurança, responsabilidades e instruções.
24. Revisar os entregáveis e disponibilizar scripts reproduzíveis.
