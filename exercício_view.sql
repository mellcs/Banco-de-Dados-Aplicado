-- View para determinar o número de alunos matriculados em cada disciplina
CREATE VIEW vw_numero_alunos_por_disciplina AS
SELECT d.nome AS nome_disciplina, 
       d.codigo AS codigo_disciplina,
       COUNT(c.matricula) AS total_alunos
FROM Disciplina d
JOIN Cursa c ON d.codigo = c.codigo_disciplina
GROUP BY d.nome, d.codigo;

-- View para calcular a média das notas dos alunos em cada disciplina
CREATE VIEW vw_media_notas_por_disciplina AS
SELECT d.nome AS nome_disciplina,
       d.codigo AS codigo_disciplina,
       AVG(c.nota) AS media_notas
FROM Disciplina d
JOIN Cursa c ON d.codigo = c.codigo_disciplina
GROUP BY d.nome, d.codigo;

-- View para calcular a média de faltas dos alunos em cada disciplina
CREATE VIEW vw_media_faltas_por_disciplina AS
SELECT d.nome AS nome_disciplina,
       d.codigo AS codigo_disciplina,
       AVG(c.falta) AS media_faltas
FROM Disciplina d
JOIN Cursa c ON d.codigo = c.codigo_disciplina
GROUP BY d.nome, d.codigo;

-- Function para retornar um relatório completo com número de alunos, média de notas e média de faltas
CREATE FUNCTION fn_relatorio_alunos_por_disciplina()
RETURNS TABLE (
    nome_disciplina VARCHAR(255),
    codigo_disciplina VARCHAR(10),
    total_alunos INT,
    media_notas DECIMAL(5, 2),
    media_faltas DECIMAL(5, 2)
) 
AS $$
BEGIN
    RETURN QUERY
    SELECT d.nome AS nome_disciplina,
           d.codigo AS codigo_disciplina,
           COUNT(c.matricula) AS total_alunos,
           AVG(c.nota) AS media_notas,
           AVG(c.falta) AS media_faltas
    FROM Disciplina d
    JOIN Cursa c ON d.codigo = c.codigo_disciplina
    GROUP BY d.nome, d.codigo;
END;
$$ LANGUAGE plpgsql;

-- Procedure para gerar o relatório chamando a function
CREATE PROCEDURE sp_gerar_relatorio_disciplina()
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT * FROM fn_relatorio_alunos_por_disciplina();
END;
$$;

-- Execução da procedure para gerar o relatório completo
CALL sp_gerar_relatorio_disciplina();
