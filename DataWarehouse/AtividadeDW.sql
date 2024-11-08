-- Tabelas base
CREATE TABLE Clientes (
    cliente_id SERIAL PRIMARY KEY,
    nome_cliente VARCHAR(40),
    endereco_cliente TEXT,
    cidade_cliente VARCHAR(60),
    estado_cliente VARCHAR(40)
);

CREATE TABLE Centros_Distribuicao (
    centro_id SERIAL PRIMARY KEY,
    nome_centro VARCHAR(50),
    endereco_centro TEXT,
    cidade_centro VARCHAR(60),
    estado_centro VARCHAR(40)
);

CREATE TABLE Pedidos (
    pedido_id SERIAL PRIMARY KEY,
    data_pedido DATE,
    cliente_id INT,
    centro_saida_id INT,
    centro_destino_id INT,
    quantidade INT,
    valor_total REAL,
    FOREIGN KEY (cliente_id) REFERENCES Clientes(cliente_id),
    FOREIGN KEY (centro_saida_id) REFERENCES Centros_Distribuicao(centro_id),
    FOREIGN KEY (centro_destino_id) REFERENCES Centros_Distribuicao(centro_id)
);

CREATE TABLE Entregas (
    entrega_id SERIAL PRIMARY KEY,
    pedido_id INT,
    data_saida DATE,
    data_chegada DATE,
    quilometragem REAL,
    FOREIGN KEY (pedido_id) REFERENCES Pedidos(pedido_id)
);

-- Dimensões com SCD tipo 2

CREATE TABLE Dim_Cliente (
    cliente_surrowgate_key SERIAL PRIMARY KEY,
    cliente_id INT,
    nome_cliente VARCHAR(40),
    endereco_cliente TEXT,
    cidade_cliente VARCHAR(60),
    estado_cliente VARCHAR(40),
    data_inicio DATE,
    data_fim DATE,
    ativo BOOLEAN,
    UNIQUE(cliente_id, data_inicio)
);

CREATE TABLE Dim_Centro (
    centro_surrogate_key SERIAL PRIMARY KEY,
    centro_id INT,
    nome_centro VARCHAR(50),
    endereco_centro TEXT,
    cidade_centro VARCHAR(60),
    estado_centro VARCHAR(40),
    data_inicio DATE,
    data_fim DATE,
    ativo BOOLEAN,
    UNIQUE(centro_id, data_inicio)
);

-- Dimensão tempo

CREATE TABLE Dim_Tempo (
    tempo_id SERIAL PRIMARY KEY,
    data DATE,
    ano INT,
    mes INT,
    dia INT
);

-- Tabela de fatos

CREATE TABLE Fato_Entregas (
    entrega_id INT PRIMARY KEY,
    cliente_surrogate_key INT,
    centro_saida_surrogate_key INT,
    centro_destino_surrogate_key INT,
    tempo_id INT,
    quantidade INT,
    tempo_total_entrega INT,
    quilometragem FLOAT,
    valor_total FLOAT,
    FOREIGN KEY (cliente_surrogate_key) REFERENCES Dim_Cliente(cliente_surrogate_key),
    FOREIGN KEY (centro_saida_surrogate_key) REFERENCES Dim_Centro(centro_surrogate_key),
    FOREIGN KEY (centro_destino_surrogate_key) REFERENCES Dim_Centro(centro_surrogate_key),
    FOREIGN KEY (tempo_id) REFERENCES Dim_Tempo(tempo_id)
);

-- Inserts para as dimensões e fatos

INSERT INTO Dim_Cliente (cliente_id, nome_cliente, endereco_cliente, cidade_cliente, estado_cliente, data_inicio, data_fim, ativo)
VALUES (1, 'Cliente A', 'Endereço 1', 'Cidade A', 'Estado A', '2024-01-01', NULL, TRUE);

UPDATE Dim_Cliente
SET data_fim = '2024-06-01', ativo = FALSE
WHERE cliente_id = 1 AND ativo = TRUE;

INSERT INTO Dim_Cliente (cliente_id, nome_cliente, endereco_cliente, cidade_cliente, estado_cliente, data_inicio, data_fim, ativo)
VALUES (1, 'Cliente A', 'Novo Endereço', 'Cidade A', 'Estado A', '2024-06-01', NULL, TRUE);

INSERT INTO Dim_Centro (centro_id, nome_centro, endereco_centro, cidade_centro, estado_centro, data_inicio, data_fim, ativo)
VALUES (1, 'Centro A', 'Endereço Centro 1', 'Cidade B', 'Estado B', '2024-01-01', NULL, TRUE);

UPDATE Dim_Centro
SET data_fim = '2024-07-01', ativo = FALSE
WHERE centro_id = 1 AND ativo = TRUE;

INSERT INTO Dim_Centro (centro_id, nome_centro, endereco_centro, cidade_centro, estado_centro, data_inicio, data_fim, ativo)
VALUES (1, 'Centro A', 'Novo Endereço Centro', 'Cidade B', 'Estado B', '2024-07-01', NULL, TRUE);
INSERT INTO Dim_Centro (centro_id, nome_centro, endereco_centro, cidade_centro, estado_centro, data_inicio, data_fim, ativo)
VALUES (3, 'Centro C', 'Endereço Centro C', 'Cidade C', 'Estado C', '2024-01-01', NULL, TRUE);

INSERT INTO Dim_Tempo (data, ano, mes, dia)
VALUES ('2024-01-01', 2024, 1, 1),
       ('2024-01-02', 2024, 1, 2),
       ('2024-01-03', 2024, 1, 3);

INSERT INTO Fato_Entregas (entrega_id, cliente_surrogate_key, centro_saida_surrogate_key, centro_destino_surrogate_key, tempo_id, quantidade, tempo_total_entrega, quilometragem, valor_total)
VALUES (1, 1, 1, 2, 1, 100, 5, 500.0, 1200.0),
       (2, 1, 2, 3, 2, 200, 8, 1000.0, 2200.0);

-- métrica aditiva (total de produtos transportados)
SELECT 
    SUM(quantidade) AS total_produtos_transportados,
    SUM(tempo_total_entrega) AS tempo_total_entrega
FROM 
    Fato_Entregas;

-- métrica não aditiva (tempo de entrega por pedido)
SELECT 
    AVG(tempo_total_entrega) AS tempo_medio_entrega_por_pedido
FROM 
    Fato_Entregas;

-- métrica não aditiva (custo médio por quilômetro)
SELECT 
    AVG(valor_total / quilometragem) AS custo_medio_por_km
FROM 
    Fato_Entregas;

