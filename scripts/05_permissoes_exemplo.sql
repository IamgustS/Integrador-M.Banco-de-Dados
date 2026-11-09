-- Opcional. Execute com usuario administrador depois de criar o esquema.
-- Este papel nao tem senha nem LOGIN; nao conceda credenciais de producao aqui.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'clinica_leitura') THEN
        EXECUTE 'CREATE ROLE clinica_leitura';
    END IF;
END;
$$;
GRANT USAGE ON SCHEMA sorriso_clinica TO clinica_leitura;
GRANT SELECT ON ALL TABLES IN SCHEMA sorriso_clinica TO clinica_leitura;
ALTER DEFAULT PRIVILEGES IN SCHEMA sorriso_clinica
    GRANT SELECT ON TABLES TO clinica_leitura;
