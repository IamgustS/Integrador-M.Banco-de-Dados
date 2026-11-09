SET search_path TO sorriso_clinica, public;

-- 1. Agenda do periodo, com paciente, profissional e sala.
SELECT
    c.consulta_id,
    c.inicio_em,
    c.fim_em,
    c.status,
    pa.nome_completo AS paciente,
    pr.nome_completo AS profissional,
    sa.nome AS sala
FROM consulta AS c
JOIN paciente AS pa ON pa.paciente_id = c.paciente_id
JOIN profissional AS pr ON pr.profissional_id = c.profissional_id
JOIN sala AS sa ON sa.sala_id = c.sala_id
WHERE c.inicio_em >= TIMESTAMPTZ '2026-09-01 00:00:00-03'
  AND c.inicio_em < TIMESTAMPTZ '2026-12-01 00:00:00-03'
ORDER BY c.inicio_em;

-- 2. Historico operacional de um paciente (substitua o codigo conforme necessario).
SELECT
    pa.codigo AS codigo_paciente,
    pa.nome_completo AS paciente,
    c.inicio_em,
    c.status,
    pr.nome_completo AS profissional,
    proc.nome AS procedimento,
    pc.dente_fdi,
    pc.quantidade,
    pc.preco_unitario
FROM paciente AS pa
JOIN consulta AS c ON c.paciente_id = pa.paciente_id
JOIN profissional AS pr ON pr.profissional_id = c.profissional_id
LEFT JOIN procedimento_consulta AS pc ON pc.consulta_id = c.consulta_id
LEFT JOIN procedimento AS proc ON proc.procedimento_id = pc.procedimento_id
WHERE pa.codigo = 'PAC-001'
ORDER BY c.inicio_em DESC;

-- 3. Procedimentos realizados, quantidade e valor bruto por tipo.
SELECT
    p.codigo,
    p.nome,
    SUM(pc.quantidade) AS unidades_realizadas,
    SUM(pc.quantidade * pc.preco_unitario)::NUMERIC(12, 2) AS valor_bruto
FROM procedimento_consulta AS pc
JOIN procedimento AS p ON p.procedimento_id = pc.procedimento_id
JOIN consulta AS c ON c.consulta_id = pc.consulta_id
WHERE c.status = 'concluida'
GROUP BY p.codigo, p.nome
ORDER BY valor_bruto DESC;

-- 4. Valor faturado e valor efetivamente recebido por mes de emissao.
SELECT
    DATE_TRUNC('month', vc.emitida_em)::DATE AS mes,
    SUM(vc.total_cobrado)::NUMERIC(12, 2) AS total_faturado,
    SUM(vc.total_pago)::NUMERIC(12, 2) AS total_recebido,
    SUM(vc.saldo)::NUMERIC(12, 2) AS saldo_aberto
FROM vw_saldo_cobranca AS vc
WHERE vc.status <> 'anulada'
GROUP BY DATE_TRUNC('month', vc.emitida_em)
ORDER BY mes;

-- 5. Cobrancas abertas ou com saldo.
SELECT
    vc.cobranca_id,
    pa.codigo AS codigo_paciente,
    pa.nome_completo AS paciente,
    vc.emitida_em,
    vc.total_cobrado,
    vc.total_pago,
    vc.saldo,
    vc.status
FROM vw_saldo_cobranca AS vc
JOIN consulta AS c ON c.consulta_id = vc.consulta_id
JOIN paciente AS pa ON pa.paciente_id = c.paciente_id
WHERE vc.status <> 'anulada'
  AND vc.saldo > 0
ORDER BY vc.emitida_em, vc.cobranca_id;

-- 6. Taxa de faltas e cancelamentos por profissional.
SELECT
    pr.codigo,
    pr.nome_completo,
    COUNT(*) FILTER (
        WHERE c.status IN ('concluida', 'cancelada', 'falta')
    ) AS consultas_encerradas,
    COUNT(*) FILTER (WHERE c.status = 'falta') AS faltas,
    COUNT(*) FILTER (WHERE c.status = 'cancelada') AS cancelamentos,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE c.status = 'falta')
        / NULLIF(
            COUNT(*) FILTER (
                WHERE c.status IN ('concluida', 'cancelada', 'falta')
            ),
            0
        ),
        2
    ) AS percentual_faltas
FROM consulta AS c
JOIN profissional AS pr ON pr.profissional_id = c.profissional_id
GROUP BY pr.codigo, pr.nome_completo
ORDER BY percentual_faltas DESC NULLS LAST;

-- 7. Saldo de materiais e alerta de reposicao.
SELECT
    sku,
    nome,
    unidade,
    saldo_atual,
    estoque_minimo,
    saldo_atual <= estoque_minimo AS precisa_repor
FROM vw_saldo_estoque
ORDER BY precisa_repor DESC, nome;

-- 8. Compras por fornecedor e estado de recebimento.
SELECT
    oc.codigo,
    f.nome AS fornecedor,
    oc.solicitada_em,
    oc.prevista_para,
    oc.status,
    COUNT(i.item_ordem_compra_id) AS itens,
    SUM(i.quantidade * i.custo_unitario)::NUMERIC(12, 2) AS valor_pedido
FROM ordem_compra AS oc
JOIN fornecedor AS f ON f.fornecedor_id = oc.fornecedor_id
LEFT JOIN item_ordem_compra AS i ON i.ordem_compra_id = oc.ordem_compra_id
GROUP BY oc.ordem_compra_id, f.nome
ORDER BY oc.solicitada_em DESC;

-- 9. Consumo de materiais por mes.
SELECT
    DATE_TRUNC('month', me.ocorrida_em)::DATE AS mes,
    m.sku,
    m.nome,
    SUM(me.quantidade) AS quantidade_consumida
FROM movimentacao_estoque AS me
JOIN material AS m ON m.material_id = me.material_id
WHERE me.tipo = 'consumo'
GROUP BY DATE_TRUNC('month', me.ocorrida_em), m.sku, m.nome
ORDER BY mes, m.nome;

-- 10. Exemplo seguro de UPDATE: a transacao e revertida intencionalmente.
BEGIN;
UPDATE paciente
SET telefone = '+55 11 5550-0199'
WHERE codigo = 'PAC-001';
ROLLBACK;

-- 11. Exemplo seguro de DELETE: a transacao e revertida intencionalmente.
BEGIN;
DELETE FROM consulta
WHERE consulta_id = 1006;
ROLLBACK;
