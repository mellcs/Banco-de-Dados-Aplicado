-- DROP TABLES
DROP TABLE IF EXISTS Fato_Aluguel;
DROP TABLE IF EXISTS Fato_Vendas;
DROP TABLE IF EXISTS Dim_Tempo;
DROP TABLE IF EXISTS Dim_Cliente;
DROP TABLE IF EXISTS Dim_Veiculo;
DROP TABLE IF EXISTS Dim_Loja;


-- TABELAS DE DIMENSÃO
CREATE TABLE Dim_Loja (
    ID_Loja INT PRIMARY KEY,
    CGCLoja CHAR(12),
    Nome_Loja CHAR(30),
    Endereco CHAR(100),
    Cidade CHAR(30),
    Estado CHAR(2),
    Pais CHAR(20)
);

CREATE TABLE Dim_Veiculo (
    ID_Veiculo INT PRIMARY KEY,
    NumeroChassi CHAR(30),
    Nome CHAR(30),
    Modelo CHAR(10),
    AnoFabricacao INT,
    CGCFabricante CHAR(12)
);

CREATE TABLE Dim_Cliente (
    ID_Cliente INT PRIMARY KEY,
    CPF CHAR(12),
    Nome CHAR(30),
    Endereco CHAR(100),
    Cidade CHAR(30),
    Bairro CHAR(10),
    Estado CHAR(2),
    Pais CHAR(20),
    Renda DECIMAL(15, 2)
);

CREATE TABLE Dim_Tempo (
    ID_Tempo INT PRIMARY KEY,
    Data DATE,
    Ano INT,
    Mes INT,
    Trimestre INT,
    Semana INT,
    Dia INT
);

-- TABELAS FATO
CREATE TABLE Fato_Vendas (
    ID_Venda INT PRIMARY KEY,
    ID_Loja INT,
    ID_Veiculo INT,
    ID_Cliente INT,
    ID_Tempo INT,
    Quantidade_Vendida INT,
    Valor_Venda DECIMAL(15, 2),
    Valor_Imposto DECIMAL(15, 2),
    Valor_ICMS DECIMAL(15, 2),
    FOREIGN KEY (ID_Loja) REFERENCES Dim_Loja(ID_Loja),
    FOREIGN KEY (ID_Veiculo) REFERENCES Dim_Veiculo(ID_Veiculo),
    FOREIGN KEY (ID_Cliente) REFERENCES Dim_Cliente(ID_Cliente),
    FOREIGN KEY (ID_Tempo) REFERENCES Dim_Tempo(ID_Tempo)
);

CREATE TABLE Fato_Aluguel (
    ID_Aluguel INT PRIMARY KEY,
    ID_Loja INT,
    ID_Veiculo INT,
    ID_Cliente INT,
    ID_Tempo INT,
    Quantidade_Alugada INT,
    Valor_Diaria DECIMAL(15, 2),
    Valor_Total_Aluguel DECIMAL(15, 2),
    FOREIGN KEY (ID_Loja) REFERENCES Dim_Loja(ID_Loja),
    FOREIGN KEY (ID_Veiculo) REFERENCES Dim_Veiculo(ID_Veiculo),
    FOREIGN KEY (ID_Cliente) REFERENCES Dim_Cliente(ID_Cliente),
    FOREIGN KEY (ID_Tempo) REFERENCES Dim_Tempo(ID_Tempo)
);

-- INSERTS
INSERT INTO Dim_Loja (ID_Loja, CGCLoja, Nome_Loja, Endereco, Cidade, Estado, Pais) VALUES
(1, '12345678000', 'Loja A', 'Rua das Flores, 123', 'São Paulo', 'SP', 'Brasil'),
(2, '12345678000', 'Loja B', 'Avenida Paulista, 456', 'São Paulo', 'SP', 'Brasil'),
(3, '12345678000', 'Loja C', 'Rua XV de Novembro, 789', 'Curitiba', 'PR', 'Brasil');

INSERT INTO Dim_Veiculo (ID_Veiculo, NumeroChassi, Nome, Modelo, AnoFabricacao, CGCFabricante) VALUES
(1, '9BWZZZ377VT004251', 'Volkswagen', 'Golf', 2020, '12345678000'),
(2, '1HGCM82633A123456', 'Honda', 'Civic', 2021, '98765432000'),
(3, '1FMCU0G77EUC45332', 'Ford', 'Ecosport', 2022, '23456789000');

INSERT INTO Dim_Cliente (ID_Cliente, CPF, Nome, Endereco, Cidade, Bairro, Estado, Pais, Renda) VALUES
(1, '12345678901', 'João Silva', 'Rua das Flores, 10', 'São Paulo', 'Centro', 'SP', 'Brasil', 120000.00),
(2, '98765432100', 'Maria Oliveira', 'Avenida Brasil, 20', 'São Paulo', 'Jardins', 'SP', 'Brasil', 80000.00),
(3, '11122233344', 'Carlos Pereira', 'Rua da Liberdade, 30', 'Curitiba', 'Centro', 'PR', 'Brasil', 95000.00);

INSERT INTO Dim_Tempo (ID_Tempo, Data, Ano, Mes, Trimestre, Semana, Dia) VALUES
(1, '2023-01-01', 2023, 1, 1, 1, 1),
(2, '2023-02-01', 2023, 2, 1, 5, 1),
(3, '2023-03-01', 2023, 3, 1, 9, 1),
(4, '2023-04-01', 2023, 4, 2, 14, 1),
(5, '2023-05-01', 2023, 5, 2, 18, 1),
(6, '2023-06-01', 2023, 6, 2, 23, 1),
(7, '2023-07-01', 2023, 7, 3, 27, 1),
(8, '2023-08-01', 2023, 8, 3, 31, 1),
(9, '2023-09-01', 2023, 9, 3, 36, 1),
(10, '2023-10-01', 2023, 10, 4, 40, 1),
(11, '2023-11-01', 2023, 11, 4, 44, 1),
(12, '2023-12-01', 2023, 12, 4, 48, 1);

INSERT INTO Fato_Vendas (ID_Venda, ID_Loja, ID_Veiculo, ID_Cliente, ID_Tempo, Quantidade_Vendida, Valor_Venda, Valor_Imposto, Valor_ICMS) VALUES
(1, 1, 1, 1, 1, 1, 90000.00, 9000.00, 8100.00),
(2, 2, 2, 2, 2, 2, 120000.00, 12000.00, 10800.00),
(3, 3, 3, 3, 3, 1, 70000.00, 7000.00, 6300.00);

INSERT INTO Fato_Aluguel (ID_Aluguel, ID_Loja, ID_Veiculo, ID_Cliente, ID_Tempo, Quantidade_Alugada, Valor_Diaria, Valor_Total_Aluguel) VALUES
(1, 1, 1, 1, 4, 5, 150.00, 750.00),
(2, 2, 2, 2, 5, 3, 200.00, 600.00),
(3, 3, 3, 3, 6, 2, 180.00, 360.00);

-- TOTAL DE VENDAS DE X LOJA EM X PERÍODO
SELECT 
    d.Nome_Loja,
    SUM(f.Valor_Venda) AS Total_Vendas
FROM 
    Fato_Vendas f
JOIN 
    Dim_Loja d ON f.ID_Loja = d.ID_Loja
JOIN 
    Dim_Tempo t ON f.ID_Tempo = t.ID_Tempo
WHERE 
    d.Nome_Loja = 'Loja A' AND  -- Nome da loja que realmente existe
    t.Data BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    d.Nome_Loja;

-- LOJAS QUE VENDERAM MAIS EM X PERÍODO
SELECT 
    d.Nome_Loja,
    SUM(f.Valor_Venda) AS Total_Vendas
FROM 
    Fato_Vendas f
JOIN 
    Dim_Loja d ON f.ID_Loja = d.ID_Loja
JOIN 
    Dim_Tempo t ON f.ID_Tempo = t.ID_Tempo
WHERE 
    t.Data BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    d.Nome_Loja
ORDER BY 
    Total_Vendas DESC
LIMIT 10;

-- LOJAS QUE VENDERAM MENOS EM X PERÍODO
SELECT 
    d.Nome_Loja,
    SUM(f.Valor_Venda) AS Total_Vendas
FROM 
    Fato_Vendas f
JOIN 
    Dim_Loja d ON f.ID_Loja = d.ID_Loja
JOIN 
    Dim_Tempo t ON f.ID_Tempo = t.ID_Tempo
WHERE 
    t.Data BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY 
    d.Nome_Loja
ORDER BY 
    Total_Vendas ASC
LIMIT 10;

-- CLIENTES NOS QUAIS SE DEVE INVESTIR 
SELECT 
    c.CPF,
    c.Nome,
    c.Renda
FROM 
    Dim_Cliente c
WHERE 
    c.Renda > 100000; 

-- VEÍCULOS DE MAIOR ACEITAÇÃO EM X REGIÃO   
SELECT 
    v.Nome,
    v.Modelo,
    l.Cidade,
    COUNT(f.ID_Veiculo) AS Total_Alugados
FROM 
    Fato_Aluguel f
JOIN 
    Dim_Veiculo v ON f.ID_Veiculo = v.ID_Veiculo
JOIN 
    Dim_Loja l ON f.ID_Loja = l.ID_Loja
WHERE 
    l.Cidade = 'São Paulo'  -- Nome da cidade que realmente existe
GROUP BY 
    v.Nome, v.Modelo, l.Cidade
ORDER BY 
    Total_Alugados DESC
LIMIT 10;
