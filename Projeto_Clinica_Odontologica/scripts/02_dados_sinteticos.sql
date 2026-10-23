-- Registros demonstrativos; nomes, CROs e contatos sao inteiramente ficticios.
SET search_path TO sorriso_clinica, public;
BEGIN;

INSERT INTO especialidade (especialidade_id, nome) VALUES
    (1, 'Clinica geral'),
    (2, 'Endodontia'),
    (3, 'Ortodontia'),
    (4, 'Odontopediatria')
ON CONFLICT DO NOTHING;

INSERT INTO profissional
    (profissional_id, codigo, nome_completo, cro_exemplo)
VALUES
    (1, 'PROF-001', 'Dra. Ana Exemplo', 'CRO-EX-0001'),
    (2, 'PROF-002', 'Dr. Bruno Modelo', 'CRO-EX-0002'),
    (3, 'PROF-003', 'Dra. Carla Ficticia', 'CRO-EX-0003'),
    (4, 'PROF-004', 'Dr. Diego Demonstracao', 'CRO-EX-0004')
ON CONFLICT DO NOTHING;

INSERT INTO profissional_especialidade (profissional_id, especialidade_id) VALUES
    (1, 1), (1, 2), (2, 1), (2, 3), (3, 3), (4, 4)
ON CONFLICT DO NOTHING;

INSERT INTO sala (sala_id, nome, descricao) VALUES
    (1, 'Consultorio A', 'Sala de atendimento geral'),
    (2, 'Consultorio B', 'Sala de atendimento e procedimentos'),
    (3, 'Sala de Imagem', 'Sala de avaliacao por imagem')
ON CONFLICT DO NOTHING;

INSERT INTO procedimento
    (procedimento_id, codigo, nome, duracao_minutos, preco_referencia)
VALUES
    (1, 'PROC-AVAL', 'Avaliacao odontologica', 30, 120.00),
    (2, 'PROC-LIMP', 'Profilaxia', 45, 180.00),
    (3, 'PROC-REST', 'Restauracao', 60, 250.00),
    (4, 'PROC-ENDO', 'Tratamento endodontico', 90, 850.00),
    (5, 'PROC-EXTR', 'Extracao simples', 60, 320.00),
    (6, 'PROC-ORTO', 'Ajuste ortodontico', 30, 160.00)
ON CONFLICT DO NOTHING;

INSERT INTO paciente
    (paciente_id, codigo, nome_completo, data_nascimento, telefone, email)
VALUES
    (1, 'PAC-001', 'Alex Pessoa Ficticia', '1990-04-12', '+55 11 5550-0101', 'paciente001@example.com'),
    (2, 'PAC-002', 'Beatriz Nome Inventado', '1985-09-23', '+55 11 5550-0102', 'paciente002@example.com'),
    (3, 'PAC-003', 'Caio Dados Sinteticos', '2001-02-05', '+55 11 5550-0103', 'paciente003@example.com'),
    (4, 'PAC-004', 'Dora Exemplo Academico', '1978-11-17', '+55 11 5550-0104', 'paciente004@example.com'),
    (5, 'PAC-005', 'Elias Cadastro Demonstrativo', '1995-06-30', '+55 11 5550-0105', 'paciente005@example.com'),
    (6, 'PAC-006', 'Flora Registro Ficticio', '2012-01-21', '+55 11 5550-0106', 'paciente006@example.com')
ON CONFLICT DO NOTHING;

INSERT INTO sala
    (sala_id, nome, descricao)
VALUES
    (4, 'Consultorio Infantil', 'Sala de atendimento pediatrico')
ON CONFLICT DO NOTHING;

INSERT INTO consulta
    (consulta_id, paciente_id, profissional_id, sala_id, inicio_em, fim_em, status, observacao_operacional)
VALUES
    (1001, 1, 1, 1, '2026-09-02 09:00:00-03', '2026-09-02 10:15:00-03', 'concluida', 'Atendimento demonstrativo'),
    (1002, 2, 2, 2, '2026-09-02 09:00:00-03', '2026-09-02 09:30:00-03', 'concluida', NULL),
    (1003, 3, 1, 1, '2026-09-02 10:30:00-03', '2026-09-02 11:30:00-03', 'concluida', NULL),
    (1004, 4, 3, 3, '2026-11-05 09:00:00-03', '2026-11-05 10:00:00-03', 'agendada', NULL),
    (1005, 5, 2, 2, '2026-11-05 10:30:00-03', '2026-11-05 11:15:00-03', 'confirmada', NULL),
    (1006, 6, 4, 4, '2026-10-05 09:00:00-03', '2026-10-05 09:30:00-03', 'cancelada', 'Cancelamento demonstrativo'),
    (1007, 1, 1, 1, '2026-10-06 09:00:00-03', '2026-10-06 10:00:00-03', 'falta', NULL),
    (1008, 2, 3, 3, '2026-09-10 13:00:00-03', '2026-09-10 13:30:00-03', 'concluida', NULL),
    (1009, 4, 1, 1, '2026-09-19 09:00:00-03', '2026-09-19 10:30:00-03', 'concluida', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO procedimento_consulta
    (procedimento_consulta_id, consulta_id, procedimento_id, dente_fdi, quantidade, preco_unitario)
VALUES
    (2001, 1001, 1, NULL, 1, 120.00),
    (2002, 1001, 2, NULL, 1, 180.00),
    (2003, 1002, 1, NULL, 1, 120.00),
    (2004, 1003, 3, '16', 1, 250.00),
    (2005, 1008, 6, NULL, 1, 160.00),
    (2006, 1009, 4, '26', 1, 850.00)
ON CONFLICT DO NOTHING;

INSERT INTO cobranca (cobranca_id, consulta_id, emitida_em, status) VALUES
    (5001, 1001, '2026-09-02', 'paga'),
    (5002, 1002, '2026-09-02', 'parcial'),
    (5003, 1003, '2026-09-02', 'paga'),
    (5004, 1008, '2026-09-10', 'aberta'),
    (5005, 1009, '2026-09-19', 'paga')
ON CONFLICT DO NOTHING;

INSERT INTO pagamento
    (pagamento_id, cobranca_id, pago_em, valor, meio, status, referencia)
VALUES
    (6001, 5001, '2026-09-02 10:20:00-03', 300.00, 'pix', 'confirmado', 'DEMO-PG-001'),
    (6002, 5002, '2026-09-02 09:35:00-03', 60.00, 'cartao_debito', 'confirmado', 'DEMO-PG-002'),
    (6003, 5003, '2026-09-02 11:40:00-03', 250.00, 'cartao_credito', 'confirmado', 'DEMO-PG-003'),
    (6004, 5005, '2026-09-19 10:35:00-03', 500.00, 'pix', 'confirmado', 'DEMO-PG-004'),
    (6005, 5005, '2026-09-19 10:36:00-03', 350.00, 'pix', 'confirmado', 'DEMO-PG-005')
ON CONFLICT DO NOTHING;

INSERT INTO fornecedor
    (fornecedor_id, codigo, nome, telefone, email)
VALUES
    (1, 'FORN-001', 'Dental Exemplo Distribuidora', '+55 11 5550-0201', 'vendas1@example.com'),
    (2, 'FORN-002', 'Suprimentos Modelo Odonto', '+55 11 5550-0202', 'vendas2@example.com'),
    (3, 'FORN-003', 'Materiais Ficticios para Clinica', '+55 11 5550-0203', 'vendas3@example.com')
ON CONFLICT DO NOTHING;

INSERT INTO material
    (material_id, sku, nome, unidade, estoque_minimo)
VALUES
    (1, 'MAT-LUVA', 'Luvas descartaveis', 'caixa', 2),
    (2, 'MAT-MASC', 'Mascaras descartaveis', 'caixa', 2),
    (3, 'MAT-RESI', 'Resina restauradora', 'seringa', 2),
    (4, 'MAT-ANES', 'Anestesico odontologico', 'caixa', 1),
    (5, 'MAT-EJET', 'Ejetor de saliva', 'pacote', 1)
ON CONFLICT DO NOTHING;

INSERT INTO ordem_compra
    (ordem_compra_id, codigo, fornecedor_id, solicitada_em, prevista_para, status)
VALUES
    (7001, 'OC-DEMO-001', 1, '2026-08-20', '2026-08-27', 'recebida'),
    (7002, 'OC-DEMO-002', 2, '2026-08-22', '2026-08-29', 'recebida'),
    (7003, 'OC-DEMO-003', 3, '2026-10-15', '2026-10-30', 'solicitada')
ON CONFLICT DO NOTHING;

INSERT INTO item_ordem_compra
    (item_ordem_compra_id, ordem_compra_id, material_id, quantidade, custo_unitario)
VALUES
    (8001, 7001, 1, 10, 38.00),
    (8002, 7001, 2, 6, 24.00),
    (8003, 7002, 3, 5, 72.00),
    (8004, 7002, 4, 3, 48.00),
    (8005, 7003, 5, 8, 19.00)
ON CONFLICT DO NOTHING;

INSERT INTO movimentacao_estoque
    (movimentacao_estoque_id, material_id, item_ordem_compra_id, consulta_id, tipo, quantidade, custo_unitario, ocorrida_em)
VALUES
    (9001, 1, 8001, NULL, 'entrada_compra', 10, 38.00, '2026-08-27 12:00:00-03'),
    (9002, 2, 8002, NULL, 'entrada_compra', 6, 24.00, '2026-08-27 12:05:00-03'),
    (9003, 3, 8003, NULL, 'entrada_compra', 5, 72.00, '2026-08-29 12:00:00-03'),
    (9004, 4, 8004, NULL, 'entrada_compra', 3, 48.00, '2026-08-29 12:05:00-03'),
    (9005, 1, NULL, 1001, 'consumo', 1, 38.00, '2026-09-02 10:10:00-03'),
    (9006, 3, NULL, 1003, 'consumo', 1, 72.00, '2026-09-02 11:25:00-03'),
    (9007, 4, NULL, 1009, 'consumo', 1, 48.00, '2026-09-19 10:20:00-03')
ON CONFLICT DO NOTHING;

-- Avanca as sequences apos inserir identificadores fixos para a demonstracao.
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.paciente', 'paciente_id')::REGCLASS,
    (SELECT MAX(paciente_id) FROM paciente),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.especialidade', 'especialidade_id')::REGCLASS,
    (SELECT MAX(especialidade_id) FROM especialidade),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.profissional', 'profissional_id')::REGCLASS,
    (SELECT MAX(profissional_id) FROM profissional),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.sala', 'sala_id')::REGCLASS,
    (SELECT MAX(sala_id) FROM sala),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.procedimento', 'procedimento_id')::REGCLASS,
    (SELECT MAX(procedimento_id) FROM procedimento),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.consulta', 'consulta_id')::REGCLASS,
    (SELECT MAX(consulta_id) FROM consulta),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.procedimento_consulta', 'procedimento_consulta_id')::REGCLASS,
    (SELECT MAX(procedimento_consulta_id) FROM procedimento_consulta),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.cobranca', 'cobranca_id')::REGCLASS,
    (SELECT MAX(cobranca_id) FROM cobranca),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.pagamento', 'pagamento_id')::REGCLASS,
    (SELECT MAX(pagamento_id) FROM pagamento),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.fornecedor', 'fornecedor_id')::REGCLASS,
    (SELECT MAX(fornecedor_id) FROM fornecedor),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.material', 'material_id')::REGCLASS,
    (SELECT MAX(material_id) FROM material),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.ordem_compra', 'ordem_compra_id')::REGCLASS,
    (SELECT MAX(ordem_compra_id) FROM ordem_compra),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.item_ordem_compra', 'item_ordem_compra_id')::REGCLASS,
    (SELECT MAX(item_ordem_compra_id) FROM item_ordem_compra),
    TRUE
);
SELECT setval(
    pg_get_serial_sequence('sorriso_clinica.movimentacao_estoque', 'movimentacao_estoque_id')::REGCLASS,
    (SELECT MAX(movimentacao_estoque_id) FROM movimentacao_estoque),
    TRUE
);

COMMIT;
