-- tabelas base
create table cliente(
	id_cliente int primary key,
	nome_cliente char(40),
	data_nascimento date,
	endereco text,
	categoria_fidelidade char(20),
	data_ultima_alteracao date
);

create table hotel(
	id_hotel int primary key,
	nome_hotel char(40),
	cidade char(30),
	pais char(30),
	data_inauguracao date
);

create table quarto(
	id_quarto int primary key,
	id_hotel int,
	tipo_quarto char(30),
	status_manutencao char (30),
	data_ultima_reforma date,
	foreign key (id_hotel) REFERENCES hotel(id_hotel)
);

create table reserva(
	id_reserva int primary key,
	id_cliente int,
	id_hotel int,
	id_quarto int,
	check_in_data date,
	check_out_data date,
	valor_reserva real,
	foreign key (id_cliente) REFERENCES cliente(id_cliente),
	foreign key (id_quarto) REFERENCES quarto(id_quarto),
	foreign key (id_hotel) REFERENCES hotel(id_hotel)
);

create table receitas(
	id_hotel int,
	data_receita date,
	receita_total_diaria real,
	despesas_operacionais_diarias real,
	foreign key (id_hotel) REFERENCES hotel(id_hotel)
);

-- tabelas de dimensão
CREATE TABLE dim_clientes (
    id_cliente_sk INT PRIMARY KEY,           
    id_cliente_natural INT,                  
    nome_cliente CHAR(40),
    data_nascimento DATE,
    endereco TEXT,
    categoria_fidelidade CHAR(20),
    data_inicio DATE,                      
    data_fim DATE,                           
    ativo BOOLEAN                            
);

CREATE TABLE dim_hotel (
    id_hotel_sk INT PRIMARY KEY,            
    id_hotel_natural INT,                   
    nome_hotel CHAR(40),
    cidade CHAR(30),
    pais CHAR(30),
    data_inauguracao DATE
);

CREATE TABLE dim_quarto (
    id_quarto_sk INT PRIMARY KEY,            
    id_quarto_natural INT,                   
    id_hotel_sk INT,                        
    tipo_quarto CHAR(30),
    status_manutencao CHAR(30),
    data_inicio DATE,                        
    data_fim DATE,                          
    ativo BOOLEAN,                           
    FOREIGN KEY (id_hotel_sk) REFERENCES dim_hotel(id_hotel_sk)
);

CREATE TABLE dim_tempo2 (
    id_tempo INT PRIMARY KEY,              
    data DATE UNIQUE,
    ano INT,
    mes INT,
    trimestre INT,
    dia INT
);

-- tabela fato
CREATE TABLE fato_reserva (
    id_fato INT PRIMARY KEY,
    id_cliente_sk INT,                          
    id_quarto_sk INT,                           
    id_hotel_sk INT,                            
    id_tempo INT,                               
    valor_reserva REAL,
    receita_total_diaria REAL,
    despesas_operacionais_diarias REAL,
    taxa_ocupacao FLOAT,
    FOREIGN KEY (id_cliente_sk) REFERENCES dim_clientes(id_cliente_sk),
    FOREIGN KEY (id_quarto_sk) REFERENCES dim_quarto(id_quarto_sk),
    FOREIGN KEY (id_hotel_sk) REFERENCES dim_hotel(id_hotel_sk),
    FOREIGN KEY (id_tempo) REFERENCES dim_tempo2(id_tempo)
);

-- inserts
INSERT INTO dim_clientes (id_cliente_sk, id_cliente_natural, nome_cliente, data_nascimento, endereco, categoria_fidelidade, data_inicio, data_fim, ativo)
VALUES 
    (1, 101, 'Ana Silva', '1985-04-15', 'Av. Central, 123', 'Ouro', '2024-01-01', NULL, TRUE),
    (2, 102, 'Carlos Santos', '1990-08-23', 'Rua Flores, 456', 'Prata', '2024-01-01', '2024-06-30', FALSE),
    (3, 102, 'Carlos Santos', '1990-08-23', 'Rua Flores, 456', 'Ouro', '2024-07-01', NULL, TRUE),
    (4, 103, 'Bruna Costa', '1988-03-11', 'Av. Brasil, 789', 'Bronze', '2024-01-01', NULL, TRUE);

INSERT INTO dim_hotel (id_hotel_sk, id_hotel_natural, nome_hotel, cidade, pais, data_inauguracao)
VALUES 
    (1, 201, 'Hotel Plus SP', 'São Paulo', 'Brasil', '2005-09-12'),
    (2, 202, 'Hotel Plus NY', 'Nova York', 'EUA', '2010-05-23'),
    (3, 203, 'Hotel Plus Tóquio', 'Tóquio', 'Japão', '2015-11-15');

INSERT INTO dim_quarto (id_quarto_sk, id_quarto_natural, id_hotel_sk, tipo_quarto, status_manutencao, data_inicio, data_fim, ativo)
VALUES 
    (1, 301, 1, 'Standard', 'Disponível', '2024-01-01', '2024-04-30', FALSE),
    (2, 301, 1, 'Luxo', 'Disponível', '2024-05-01', NULL, TRUE),
    (3, 302, 2, 'Suíte', 'Em manutenção', '2024-01-01', NULL, TRUE),
    (4, 303, 3, 'Standard', 'Disponível', '2024-01-01', NULL, TRUE);

INSERT INTO dim_tempo2 (id_tempo, data, ano, mes, trimestre, dia)
VALUES 
    (1, '2024-06-01', 2024, 6, 2, 1),
    (2, '2024-06-15', 2024, 6, 2, 15),
    (3, '2024-07-01', 2024, 7, 3, 1),
    (4, '2024-08-01', 2024, 8, 3, 1);

INSERT INTO fato_reserva (id_fato, id_cliente_sk, id_quarto_sk, id_hotel_sk, id_tempo, valor_reserva, receita_total_diaria, despesas_operacionais_diarias, taxa_ocupacao)
VALUES 
    (1, 1, 1, 1, 1, 500.00, 10000.00, 2000.00, 0.85),
    (2, 2, 2, 2, 2, 750.00, 15000.00, 2500.00, 0.92),
    (3, 3, 3, 3, 3, 300.00, 8000.00, 1800.00, 0.75),
    (4, 4, 4, 1, 4, 400.00, 12000.00, 2100.00, 0.80);

-- consultas

-- 1: Qual é a receita média por cliente em cada categoria de fidelidade?
SELECT 
    c.categoria_fidelidade, 
    AVG(f.valor_reserva) AS receita_media_por_cliente
FROM 
    fato_reserva f
JOIN 
    dim_clientes c ON f.id_cliente_sk = c.id_cliente_sk
GROUP BY 
    c.categoria_fidelidade;

-- 2: Quais hotéis possuem as taxas de ocupação mais altas em um período específico?
SELECT 
    h.nome_hotel, 
    AVG(f.taxa_ocupacao) AS taxa_ocupacao_media
FROM 
    fato_reserva f
JOIN 
    dim_hotel h ON f.id_hotel_sk = h.id_hotel_sk
JOIN 
    dim_tempo2 t ON f.id_tempo = t.id_tempo
WHERE 
    t.data BETWEEN '2024-06-01' AND '2024-08-01' 
GROUP BY 
    h.nome_hotel
ORDER BY 
    taxa_ocupacao_media DESC
LIMIT 5; 

-- 3: Qual a média de tempo que os clientes de uma determinada categoria de fidelidade permanecem nos hotéis?
SELECT 
    c.categoria_fidelidade, 
    AVG(r.check_out_data - r.check_in_data) AS media_tempo_permanencia_dias
FROM 
    reserva r
JOIN 
    cliente c ON r.id_cliente = c.id_cliente
WHERE 
    r.check_in_data IS NOT NULL 
    AND r.check_out_data IS NOT NULL
GROUP BY 
    c.categoria_fidelidade;

-- 4: Quais quartos são mais frequentemente reformados, e com que frequência?
SELECT 
    q.id_quarto_natural,
    q.tipo_quarto,
    COUNT(*) AS frequencia_reformas
FROM 
    dim_quarto q
WHERE 
    q.data_fim IS NOT NULL
GROUP BY 
    q.id_quarto_natural, q.tipo_quarto
ORDER BY 
    frequencia_reformas DESC;

-- 5: Qual o perfil dos clientes com maior gasto em reservas por país e categoria de fidelidade?
SELECT 
    c.nome_cliente, 
    c.categoria_fidelidade,
    h.pais, 
    SUM(f.valor_reserva) AS gasto_total
FROM 
    fato_reserva f
JOIN 
    dim_clientes c ON f.id_cliente_sk = c.id_cliente_sk
JOIN 
    dim_hotel h ON f.id_hotel_sk = h.id_hotel_sk
GROUP BY 
    c.nome_cliente, c.categoria_fidelidade, h.pais
ORDER BY 
    gasto_total DESC
LIMIT 10;  

