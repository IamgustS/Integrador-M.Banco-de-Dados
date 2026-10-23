SET search_path TO sorriso_clinica, public;

-- Em cada consulta de anomalia abaixo, o resultado esperado e zero linhas.

-- 1. Codigo ou CRO duplicado (as restricoes UNIQUE tambem impedem insercoes novas).
SELECT codigo, COUNT(*)
FROM paciente
GROUP BY codigo
HAVING COUNT(*) > 1;

SELECT cro_exemplo, COUNT(*)
FROM profissional
GROUP BY cro_exemplo
HAVING COUNT(*) > 1;

-- 2. Consultas com relacoes obrigatorias ausentes (as FKs tambem impedem o caso).
SELECT c.consulta_id
FROM consulta AS c
LEFT JOIN paciente AS pa ON pa.paciente_id = c.paciente_id
LEFT JOIN profissional AS pr ON pr.profissional_id = c.profissional_id
LEFT JOIN sala AS sa ON sa.sala_id = c.sala_id
WHERE pa.paciente_id IS NULL OR pr.profissional_id IS NULL OR sa.sala_id IS NULL;

-- 3. Consulta faturada antes de ser concluida.
SELECT cb.cobranca_id, cb.consulta_id, c.status
FROM cobranca AS cb
JOIN consulta AS c ON c.consulta_id = cb.consulta_id
WHERE cb.status <> 'anulada'
  AND c.status <> 'concluida';

-- 4. Cobranca com valor pago acima do valor de procedimentos.
SELECT cobranca_id, total_cobrado, total_pago, saldo
FROM vw_saldo_cobranca
WHERE status <> 'anulada'
  AND total_pago > total_cobrado;

-- 5. Estado registrado da cobranca divergente do saldo derivado.
SELECT cobranca_id, status, total_cobrado, total_pago, saldo
FROM vw_saldo_cobranca
WHERE status <> 'anulada'
  AND (
      (status = 'paga' AND saldo <> 0)
      OR (status = 'parcial' AND (total_pago = 0 OR saldo <= 0))
      OR (status = 'aberta' AND total_pago <> 0)
  );

-- 6. Saldo negativo de estoque (o trigger tambem bloqueia insercoes que o gerem).
SELECT material_id, sku, nome, saldo_atual
FROM vw_saldo_estoque
WHERE saldo_atual < 0;

-- 7. Quantidade recebida acima da quantidade pedida.
SELECT
    i.item_ordem_compra_id,
    i.quantidade AS quantidade_pedida,
    COALESCE(SUM(me.quantidade), 0) AS quantidade_recebida
FROM item_ordem_compra AS i
LEFT JOIN movimentacao_estoque AS me
    ON me.item_ordem_compra_id = i.item_ordem_compra_id
   AND me.tipo = 'entrada_compra'
GROUP BY i.item_ordem_compra_id, i.quantidade
HAVING COALESCE(SUM(me.quantidade), 0) > i.quantidade;

-- 8. Compra marcada como recebida sem entrada de estoque para algum item.
SELECT oc.codigo, i.item_ordem_compra_id, m.nome
FROM ordem_compra AS oc
JOIN item_ordem_compra AS i ON i.ordem_compra_id = oc.ordem_compra_id
JOIN material AS m ON m.material_id = i.material_id
LEFT JOIN movimentacao_estoque AS me
    ON me.item_ordem_compra_id = i.item_ordem_compra_id
   AND me.tipo = 'entrada_compra'
WHERE oc.status = 'recebida'
GROUP BY oc.codigo, i.item_ordem_compra_id, m.nome
HAVING COALESCE(SUM(me.quantidade), 0) < i.quantidade;

-- 9. Consulta concluida sem procedimento registrado (alerta operacional, nao constraint).
SELECT c.consulta_id, c.inicio_em
FROM consulta AS c
LEFT JOIN procedimento_consulta AS pc ON pc.consulta_id = c.consulta_id
WHERE c.status = 'concluida'
GROUP BY c.consulta_id, c.inicio_em
HAVING COUNT(pc.procedimento_consulta_id) = 0;

-- 10. Saldos e itens abaixo do estoque minimo: resultados informativos, nao anomalias.
SELECT sku, nome, saldo_atual, estoque_minimo
FROM vw_saldo_estoque
WHERE saldo_atual <= estoque_minimo
ORDER BY nome;

-- 11. Testes automatizados das restricoes. Cada caso espera uma violacao especifica;
-- se a operacao invalida for aceita ou falhar por outro motivo, o bloco falha.
DO $$
BEGIN
    BEGIN
        INSERT INTO consulta
            (consulta_id, paciente_id, profissional_id, sala_id, inicio_em, fim_em, status)
        VALUES
            (9901, 1, 1, 1, '2026-12-01 10:00:00-03', '2026-12-01 09:00:00-03', 'agendada');
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: intervalo invertido bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: intervalo invertido foi aceito.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO consulta
            (consulta_id, paciente_id, profissional_id, sala_id, inicio_em, fim_em, status)
        VALUES
            (9902, 1, 3, 1, '2026-11-05 09:15:00-03', '2026-11-05 09:45:00-03', 'agendada');
    EXCEPTION WHEN exclusion_violation THEN
        RAISE NOTICE 'PASS: conflito de profissional bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: conflito de profissional foi aceito.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO consulta
            (consulta_id, paciente_id, profissional_id, sala_id, inicio_em, fim_em, status)
        VALUES
            (9903, 1, 2, 3, '2026-11-05 09:30:00-03', '2026-11-05 10:00:00-03', 'agendada');
    EXCEPTION WHEN exclusion_violation THEN
        RAISE NOTICE 'PASS: conflito de sala bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: conflito de sala foi aceito.';
END;
$$;

DO $$
BEGIN
    INSERT INTO consulta
        (consulta_id, paciente_id, profissional_id, sala_id, inicio_em, fim_em, status)
    VALUES
        (9904, 1, 4, 4, '2026-10-05 09:00:00-03', '2026-10-05 09:30:00-03', 'agendada'),
        (9905, 1, 1, 1, '2026-10-06 09:00:00-03', '2026-10-06 10:00:00-03', 'agendada');
    DELETE FROM consulta WHERE consulta_id IN (9904, 9905);
    RAISE NOTICE 'PASS: cancelamento e falta nao bloqueiam novos agendamentos.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO pagamento (cobranca_id, pago_em, valor, meio)
        VALUES (5001, CURRENT_TIMESTAMP, 0, 'pix');
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: pagamento com valor zero bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: pagamento com valor zero foi aceito.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO movimentacao_estoque
            (material_id, consulta_id, tipo, quantidade, custo_unitario)
        VALUES
            (5, 1001, 'consumo', 1, 19.00);
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'PASS: consumo sem saldo bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: consumo sem saldo foi aceito.';
END;
$$;

DO $$
BEGIN
    BEGIN
        UPDATE movimentacao_estoque
        SET quantidade = quantidade + 1
        WHERE movimentacao_estoque_id = 9001;
    EXCEPTION WHEN object_not_in_prerequisite_state THEN
        RAISE NOTICE 'PASS: alteracao de movimento bloqueada.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: alteracao de movimento foi aceita.';
END;
$$;

DO $$
BEGIN
    BEGIN
        DELETE FROM movimentacao_estoque
        WHERE movimentacao_estoque_id = 9001;
    EXCEPTION WHEN object_not_in_prerequisite_state THEN
        RAISE NOTICE 'PASS: exclusao de movimento bloqueada.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: exclusao de movimento foi aceita.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO cobranca (consulta_id, emitida_em, status)
        VALUES (1001, CURRENT_DATE, 'aberta');
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'PASS: segunda cobranca da consulta bloqueada.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: segunda cobranca da consulta foi aceita.';
END;
$$;

DO $$
BEGIN
    BEGIN
        INSERT INTO pagamento (cobranca_id, pago_em, valor, meio)
        VALUES (999999, CURRENT_TIMESTAMP, 1, 'pix');
    EXCEPTION WHEN foreign_key_violation THEN
        RAISE NOTICE 'PASS: pagamento sem cobranca bloqueado.';
        RETURN;
    END;
    RAISE EXCEPTION 'FAIL: pagamento sem cobranca foi aceito.';
END;
$$;
