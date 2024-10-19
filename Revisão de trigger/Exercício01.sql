-- tabelas
CREATE TABLE ItemEstoque (
    cod_item INT PRIMARY KEY,
    descricao VARCHAR(100),
    qtd_disponivel INT
);

CREATE TABLE ItensVenda (
    cod_venda INT,
    id_item INT,
    qtd_vendida INT,
    FOREIGN KEY (id_item) REFERENCES ItemEstoque(cod_item)
);

-- insert
INSERT INTO ItemEstoque (cod_item, descricao, qtd_disponivel) VALUES 
(1, 'Notebook', 50),
(2, 'Smartphone', 120),
(3, 'Tablet', 70),
(4, 'Monitor', 80);

-- function
CREATE OR REPLACE FUNCTION atualizar_estoque()
RETURNS TRIGGER AS $$
BEGIN
 
    UPDATE ItemEstoque
    SET qtd_disponivel = qtd_disponivel - NEW.qtd_vendida
    WHERE cod_item = NEW.id_item;

    IF (SELECT qtd_disponivel FROM ItemEstoque WHERE cod_item = NEW.id_item) < 0 THEN
        RAISE EXCEPTION 'Estoque insuficiente para o item %', NEW.id_item;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- trigger
CREATE TRIGGER trg_atualizar_estoque
AFTER INSERT ON ItensVenda
FOR EACH ROW
EXECUTE FUNCTION atualizar_estoque();

-- testes
INSERT INTO ItensVenda (cod_venda, id_item, qtd_vendida) VALUES (1, 1, 5);

SELECT * FROM ItemEstoque WHERE cod_item = 1;

-- ver se o aviso de erro funciona
INSERT INTO ItensVenda (cod_venda, id_item, qtd_vendida) VALUES (2, 1, 60);
