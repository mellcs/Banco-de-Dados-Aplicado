-- Tabelas de origem
CREATE TABLE Origem_Clientes (
    cliente_codigo SERIAL PRIMARY KEY,
    nome VARCHAR(40),
    endereco TEXT,
    cidade VARCHAR(60),
    estado VARCHAR(40)
);

CREATE TABLE Origem_Centros (
    centro_codigo SERIAL PRIMARY KEY,
    nome VARCHAR(50),
    endereco TEXT,
    cidade VARCHAR(60),
    estado VARCHAR(40)
);

CREATE TABLE Origem_Pedidos (
    pedido_codigo SERIAL PRIMARY KEY,
    data DATE,
    cliente_codigo INT,
    centro_saida_codigo INT,
    centro_destino_codigo INT,
    quantidade_produto INT,
    valor_total_pedido REAL,
    FOREIGN KEY (cliente_codigo) REFERENCES Origem_Clientes(cliente_codigo),
    FOREIGN KEY (centro_saida_codigo) REFERENCES Origem_Centros(centro_codigo),
    FOREIGN KEY (centro_destino_codigo) REFERENCES Origem_Centros(centro_codigo)
);

CREATE TABLE Origem_Entregas (
    entrega_codigo SERIAL PRIMARY KEY,
    pedido_codigo INT,
    data_saida DATE,
    data_chegada DATE,
    distancia_km REAL,
    FOREIGN KEY (pedido_codigo) REFERENCES Origem_Pedidos(pedido_codigo)
);

-- Inserts nas tabelas de origem
INSERT INTO Origem_Clientes (nome, endereco, cidade, estado)
VALUES ('Cliente A', 'Endereço 1', 'Cidade A', 'Estado A'),
       ('Cliente B', 'Endereço 2', 'Cidade B', 'Estado B');

INSERT INTO Origem_Centros (nome, endereco, cidade, estado)
VALUES ('Centro A', 'Endereço Centro 1', 'Cidade A', 'Estado A'),
       ('Centro B', 'Endereço Centro 2', 'Cidade B', 'Estado B');

INSERT INTO Origem_Pedidos (data, cliente_codigo, centro_saida_codigo, centro_destino_codigo, quantidade_produto, valor_total_pedido)
VALUES ('2024-01-01', 1, 1, 2, 100, 1500.0),
       ('2024-02-01', 2, 2, 1, 200, 3000.0);

INSERT INTO Origem_Entregas (pedido_codigo, data_saida, data_chegada, distancia_km)
VALUES (1, '2024-01-01', '2024-01-02', 500.0),
       (2, '2024-02-01', '2024-02-02', 1000.0);

-- Dimensões no Data Warehouse
CREATE TABLE DW_Clientes (
    cliente_sk SERIAL PRIMARY KEY,
    cliente_codigo INT,
    nome VARCHAR(40),
    endereco TEXT,
    cidade VARCHAR(60),
    estado VARCHAR(40),
    data_inicio_vigencia DATE,
    data_fim_vigencia DATE,
    ativo BOOLEAN,
    UNIQUE(cliente_codigo, data_inicio_vigencia)
);

CREATE TABLE DW_Centros (
    centro_sk SERIAL PRIMARY KEY,
    centro_codigo INT,
    nome VARCHAR(50),
    endereco TEXT,
    cidade VARCHAR(60),
    estado VARCHAR(40),
    data_inicio_vigencia DATE,
    data_fim_vigencia DATE,
    ativo BOOLEAN,
    UNIQUE(centro_codigo, data_inicio_vigencia)
);

CREATE TABLE DW_Tempo (
    tempo_sk SERIAL PRIMARY KEY,
    data DATE,
    ano INT,
    mes INT,
    dia INT
);

CREATE TABLE Fato_Entrega (
    entrega_sk INT PRIMARY KEY,
    cliente_sk INT,
    centro_saida_sk INT,
    centro_destino_sk INT,
    tempo_sk INT,
    quantidade INT,
    duracao_entrega_horas INT,
    distancia REAL,
    valor REAL,
    FOREIGN KEY (cliente_sk) REFERENCES DW_Clientes(cliente_sk),
    FOREIGN KEY (centro_saida_sk) REFERENCES DW_Centros(centro_sk),
    FOREIGN KEY (centro_destino_sk) REFERENCES DW_Centros(centro_sk),
    FOREIGN KEY (tempo_sk) REFERENCES DW_Tempo(tempo_sk)
);

-- Inserindo dados nas dimensões
INSERT INTO DW_Clientes (cliente_codigo, nome, endereco, cidade, estado, data_inicio_vigencia, ativo)
SELECT cliente_codigo, nome, endereco, cidade, estado, '2024-01-01', TRUE
FROM Origem_Clientes;

UPDATE DW_Clientes
SET data_fim_vigencia = '2024-06-01', ativo = FALSE
WHERE cliente_codigo = 1 AND ativo = TRUE;

INSERT INTO DW_Clientes (cliente_codigo, nome, endereco, cidade, estado, data_inicio_vigencia, ativo)
SELECT cliente_codigo, 'Novo Endereço', cidade, estado, '2024-06-01', TRUE
FROM Origem_Clientes
WHERE cliente_codigo = 1;

INSERT INTO DW_Centros (centro_codigo, nome, endereco, cidade, estado, data_inicio_vigencia, ativo)
SELECT centro_codigo, nome, endereco, cidade, estado, '2024-01-01', TRUE
FROM Origem_Centros
ON CONFLICT (centro_codigo, data_inicio_vigencia) 
DO UPDATE SET ativo = EXCLUDED.ativo;

UPDATE DW_Centros
SET data_fim_vigencia = '2024-07-01', ativo = FALSE
WHERE centro_codigo = 1 AND ativo = TRUE;

INSERT INTO DW_Centros (centro_codigo, nome, endereco, cidade, estado, data_inicio_vigencia, ativo)
SELECT centro_codigo, 'Novo Endereço Centro', endereco, cidade, estado, '2024-07-01', TRUE
FROM Origem_Centros
WHERE centro_codigo = 1;

INSERT INTO DW_Tempo (data, ano, mes, dia)
SELECT DISTINCT data, EXTRACT(YEAR FROM data), EXTRACT(MONTH FROM data), EXTRACT(DAY FROM data)
FROM Origem_Pedidos;

-- Inserindo dados na tabela Fato_Entrega com duração calculada em horas usando AGE
INSERT INTO Fato_Entrega (entrega_sk, cliente_sk, centro_saida_sk, centro_destino_sk, tempo_sk, quantidade, duracao_entrega_horas, distancia, valor)
SELECT e.entrega_codigo, 
       dc.cliente_sk, 
       dcs.centro_sk, 
       dcd.centro_sk, 
       dt.tempo_sk, 
       p.quantidade_produto, 
       (EXTRACT(EPOCH FROM AGE(e.data_chegada, e.data_saida)) / 3600)::INT AS duracao_entrega_horas,
       e.distancia_km, 
       p.valor_total_pedido
FROM Origem_Entregas e
JOIN Origem_Pedidos p ON e.pedido_codigo = p.pedido_codigo
JOIN DW_Clientes dc ON p.cliente_codigo = dc.cliente_codigo
JOIN DW_Centros dcs ON p.centro_saida_codigo = dcs.centro_codigo
JOIN DW_Centros dcd ON p.centro_destino_codigo = dcd.centro_codigo
JOIN DW_Tempo dt ON p.data = dt.data
ON CONFLICT (entrega_sk) DO NOTHING;

-- consultas
SELECT 
    fe.entrega_id,
    dc.nome_cliente AS nome_cliente,
    dcs.nome_centro AS centro_saida,
    dcd.nome_centro AS centro_destino,
    dt.data AS data_pedido,
    fe.quantidade,
    fe.tempo_total_entrega,
    fe.quilometragem,
    fe.valor_total
FROM 
    Fato_Entregas fe
JOIN 
    Dim_Cliente dc ON fe.cliente_surrogate_key = dc.cliente_surrogate_key
JOIN 
    Dim_Centro dcs ON fe.centro_saida_surrogate_key = dcs.centro_surrogate_key
JOIN 
    Dim_Centro dcd ON fe.centro_destino_surrogate_key = dcd.centro_surrogate_key
JOIN 
    Dim_Tempo dt ON fe.tempo_id = dt.tempo_id;

--   
SELECT 
    cliente_surrogate_key,
    cliente_id,
    nome_cliente,
    endereco_cliente,
    cidade_cliente,
    estado_cliente,
    data_inicio,
    data_fim,
    ativo
FROM 
    Dim_Cliente
ORDER BY 
    cliente_id, data_inicio;

--
SELECT 
    centro_surrogate_key,
    centro_id,
    nome_centro,
    endereco_centro,
    cidade_centro,
    estado_centro,
    data_inicio,
    data_fim,
    ativo
FROM 
    Dim_Centro
ORDER BY 
    centro_id, data_inicio;

--
SELECT 
    tempo_id,
    data,
    ano,
    mes,
    dia
FROM 
    Dim_Tempo
ORDER BY 
    data;

--
SELECT 
    dc.nome_cliente AS nome_cliente,
    AVG(fe.quilometragem) AS distancia_media,
    AVG(fe.tempo_total_entrega) AS tempo_medio_entrega
FROM 
    Fato_Entregas fe
JOIN 
    Dim_Cliente dc ON fe.cliente_surrogate_key = dc.cliente_surrogate_key
GROUP BY 
    dc.nome_cliente;

--
SELECT 
    dcs.nome_centro AS centro_saida,
    SUM(fe.valor_total) AS receita_total
FROM 
    Fato_Entregas fe
JOIN 
    Dim_Centro dcs ON fe.centro_saida_surrogate_key = dcs.centro_surrogate_key
GROUP BY 
    dcs.nome_centro;

--
SELECT 
    dt.ano,
    dt.mes,
    COUNT(fe.entrega_id) AS total_entregas
FROM 
    Fato_Entregas fe
JOIN 
    Dim_Tempo dt ON fe.tempo_id = dt.tempo_id
GROUP BY 
    dt.ano, dt.mes
ORDER BY 
    dt.ano, dt.mes;
