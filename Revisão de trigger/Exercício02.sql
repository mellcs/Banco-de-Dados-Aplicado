-- tabelas
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100),
    senha VARCHAR(100)
);

CREATE TABLE tb_bkp_usuarios (
    id INT,
    nome VARCHAR(100),
    senha VARCHAR(100)
);

-- insert
INSERT INTO usuarios (nome, senha) VALUES 
('João da Silva', 'senha123'),
('Maria Oliveira', 'senha456'),
('Pedro Santos', 'senha789');

-- function
CREATE OR REPLACE FUNCTION backup_usuario()
RETURNS TRIGGER AS $$
BEGIN

    INSERT INTO tb_bkp_usuarios (id, nome, senha)
    VALUES (OLD.id, OLD.nome, OLD.senha);

    RETURN OLD;  
END;
$$ LANGUAGE plpgsql;

-- trigger
CREATE TRIGGER trg_backup_usuario
BEFORE DELETE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION backup_usuario();

-- testes
DELETE FROM usuarios WHERE id = 1;

SELECT * FROM tb_bkp_usuarios;

SELECT * FROM usuarios;
