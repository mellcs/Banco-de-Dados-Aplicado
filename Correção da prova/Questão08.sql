-- tabela
CREATE TABLE produtos_estoque (
    p_cod_produto INT PRIMARY KEY,
    p_nome_produto VARCHAR(100),
    p_descricao TEXT,
    p_preco NUMERIC(10, 2),
    p_qtde_estoque INT
);

-- insert
INSERT INTO produtos_estoque (p_cod_produto, p_nome_produto, p_descricao, p_preco, p_qtde_estoque) VALUES 
(1, 'Notebook', 'Notebook de alta performance', 3500.00, 50),
(2, 'Smartphone', 'Smartphone com tela de 6.5 polegadas', 1500.00, 120),
(3, 'Tablet', 'Tablet com caneta inclusa', 1200.00, 70),
(4, 'Monitor', 'Monitor LED 24 polegadas', 800.00, 80);

-- procedure
CREATE OR REPLACE PROCEDURE atualizar_preco_produto(
    IN codigo_produto INT,
    IN novo_preco NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF novo_preco < 0 THEN
        RAISE EXCEPTION 'O preço não pode ser negativo.';
    END IF;

    UPDATE produtos_estoque
    SET p_preco = novo_preco
    WHERE p_cod_produto = codigo_produto;

    IF NOT FOUND THEN
        RAISE NOTICE 'Nenhum produto com o código % encontrado.', codigo_produto;
    ELSE
        RAISE NOTICE 'O preço do produto com o código % foi atualizado para %.', codigo_produto, novo_preco;
    END IF;
END;
$$;

-- teste
CALL atualizar_preco_produto(1, 3600.00);

SELECT * FROM produtos_estoque WHERE p_cod_produto = 1;

