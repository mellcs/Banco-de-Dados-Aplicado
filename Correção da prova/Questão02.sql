-- tabelas
CREATE TABLE alunos (
    matricula INT PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE cursos (
    codigo INT PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE matriculas (
    codigo_mat INT PRIMARY KEY,
    matricula INT,
    codigo INT,
    FOREIGN KEY (matricula) REFERENCES alunos (matricula),
    FOREIGN KEY (codigo) REFERENCES cursos (codigo)
);

-- inserts
INSERT INTO alunos (matricula, nome) VALUES 
(1, 'João Silva'),
(2, 'Maria Oliveira'),
(3, 'Carlos Souza'),
(4, 'Ana Costa');

INSERT INTO cursos (codigo, nome) VALUES 
(101, 'Engenharia de Software'),
(102, 'Ciência da Computação'),
(103, 'Matemática Aplicada');

INSERT INTO matriculas (codigo_mat, matricula, codigo) VALUES 
(1, 1, 101), 
(2, 2, 101), 
(3, 3, 102), 
(4, 4, 103); 

-- função
CREATE OR REPLACE FUNCTION quantidade_alunos_por_curso()
RETURNS TABLE(nome_curso TEXT, quantidade_alunos INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.nome::TEXT AS nome_curso,  
        COUNT(m.matricula)::INTEGER AS quantidade_alunos  
    FROM 
        cursos c
    JOIN 
        matriculas m ON c.codigo = m.codigo
    GROUP BY 
        c.nome;
END;
$$ LANGUAGE plpgsql;

-- teste
SELECT * FROM quantidade_alunos_por_curso();

