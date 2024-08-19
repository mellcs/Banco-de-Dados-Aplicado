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
