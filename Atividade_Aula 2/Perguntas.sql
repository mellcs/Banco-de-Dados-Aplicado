-- 04) Criação de tabelas.

create table usuario (
	id serial,
	nome varchar(40) unique,
	primary key(id)
);

create table livro (
	id_book serial,
	titulo varchar(100) unique,
	autor varchar(40),
	paginas int,
	primary key(id_book)
);

create table registros (
	id_reg serial,
	data date,
	status varchar(40),
	avaliacao int,
	nome varchar(40),
	titulo varchar(100),
	primary key(id_reg),
	foreign key (nome) references usuario(nome),
	foreign key (titulo) references livro(titulo)
);

-- 05)

insert into usuario (id, nome) values (1, 'Sena');
insert into usuario (id, nome) values (2, 'Eve');
insert into usuario (id, nome) values (3, 'Michelle');
insert into usuario (id, nome) values (4, 'Ludacris');
insert into usuario (id, nome) values (5, 'Camila');

insert into livro (id_book, titulo, autor, paginas) values (1, 'A Bússola de Ouro', 'Philip Pullman', 344);
insert into livro (id_book, titulo, autor, paginas) values (2, 'Duna', 'Frank Herbert', 843);
insert into livro (id_book, titulo, autor, paginas) values (3, 'Lolita', 'Vladimir Nabokov', 293);
insert into livro (id_book, titulo, autor, paginas) values (4, 'Objetos Cortantes', 'Gillian Flynn', 256);
insert into livro (id_book, titulo, autor, paginas) values (5, 'Sundial', 'Catriona Ward', 304);

insert into registros (id_reg, data, status, avaliacao, nome, titulo) values (1, '2024-01-11', 'Terminado', 5, 'Eve', 'A Bússola de Ouro');
insert into registros (id_reg, data, status, avaliacao, nome, titulo) values (2, '2024-07-03', 'Lendo', 3, 'Ludacris', 'Lolita');
insert into registros (id_reg, data, status, avaliacao, nome, titulo) values (3, '2024-07-05', 'Lendo', null, 'Sena', 'Duna');
insert into registros (id_reg, data, status, avaliacao, nome, titulo) values (4, '2024-08-23', 'Terminado', 4, 'Sena', 'Duna');
insert into registros (id_reg, data, status, avaliacao, nome, titulo) values (5, '2024-12-17', 'Quero Ler', null, 'Camila', 'Objetos Cortantes');

-- 06)

select * from usuario;
select * from livro;
select * from registros;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, usuario.nome from registros
inner join usuario on registros.nome = usuario.nome;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, usuario.nome from registros
left join usuario on registros.nome = usuario.nome;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, usuario.nome, livro.titulo, livro.autor from registros
left join usuario on registros.nome = usuario.nome left join livro on registros.titulo = livro.titulo;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, livro.titulo, livro.autor from registros
right join livro on registros.titulo = livro.titulo;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, usuario.nome from registros
full outer join usuario on registros.nome = usuario.nome;

select registros.id_reg, registros.data, registros.status, registros.avaliacao, usuario.nome, livro.titulo, livro.autor 
from registros full outer join usuario on registros.nome = usuario.nome full outer join livro on registros.titulo = livro.titulo;

-- 07)

select * from usuario as u, livro as l, registros as r where u.nome = r.nome and l.titulo = r.titulo;

-- 08)

select max(avaliacao) as max_avaliacao from registros;

select min(avaliacao) as min_avaliacao from registros;

select avg(paginas) as avg_paginas from livro;

select sum(paginas) as sum_paginas from livro;

select count(avaliacao) as count_avaliacao from registros;

-- 09)

select status, avg(avaliacao) as media_avaliacao from registros group by status;

-- 10)

select status, avg(avaliacao) as media_avaliacao from registros group by status having avg(avaliacao) > 3;
