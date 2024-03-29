select * from aluno
select * from professor
select * from turma_has_aluno
select * from horario
select * from disciplina
select * from turma


select distinct t.idTurma, d.nome as disciplina ,t.local_aula as local ,h.horario as horario ,p.nome as professor
from  turma as t, disciplina as d,horario as h,professor as p, aluno as a 
where t.professor_matriculaprofessor = p.matricula and 
t.disciplina_idDisciplina = d.idDisciplina and t.status = 'A' and a.matricula not in (1)

select distinct  t.idTurma, d.nome as disciplina ,t.local_aula as local ,h.horario as horario ,p.nome as professor
from  turma as t, disciplina as d,horario as h,professor as p, aluno as a 
where t.professor_matriculaprofessor = p.matricula and 
t.disciplina_idDisciplina = d.idDisciplina and t.status = 'A'

-- Seleciona as turmas que o aluno logado ainda nao se cadastrou
select distinct turma.idturma, disc.nome as disciplina, turma.local_aula as local, horario.horario, prof.nome as professor from aluno, turma
inner join professor as prof
on turma.professor_matriculaprofessor = prof.matricula
inner join disciplina as disc
on turma.disciplina_iddisciplina = disc.iddisciplina
inner join horario
on  horario.turma_idturma = turma.idturma
where turma.status = 'A' and idturma not in (select distinct turma.idturma from aluno
inner join turma_has_aluno as tha
on aluno.matricula = tha.aluno_matriculaaluno
inner join turma 
on tha.turma_idturma = turma.idturma
where aluno.matricula = ?) ;--incognita e o id do aluno logado

--creates
create table aluno(
	matricula bigserial primary key,
	nome varchar(150) not null unique,
	rg varchar(15) not null,
	senha varchar(64) not null,
	rua varchar(100),
	numero smallint,
	bairro varchar(40)
);

create table professor(
	matricula bigserial primary key,
	nome varchar(150) not null unique,
	rua varchar(100),
	numero smallint,
	bairro varchar(40),
	senha varchar(64) not null
);

create table disciplina(
	idDisciplina bigserial primary key,
	nome varchar(50) not null unique,
	carga_horaria smallint not null default 60,--60h
	hora_aula float not null default 1,--1h a dura��o da aula
	check (carga_horaria > 0 and hora_aula > 0 and carga_horaria >= hora_aula)
);

create type statusTurma as enum ('A','F');--aberta e fechada

create table turma(
	idTurma bigserial primary key,
	local_aula varchar(50) not null,
	status statusTurma not null default 'A',
	professor_matriculaProfessor bigserial references professor(matricula) on delete set null on update cascade,
	disciplina_idDisciplina bigserial references disciplina(idDisciplina) on delete restrict on update cascade
);

create table horario(
	idHorario bigserial primary key,
	horario varchar(6) not null,
	turma_idTurma bigserial references turma(idTurma) on delete cascade on update cascade
);

create table turma_has_aluno(
	turma_idTurma bigserial references turma(idTurma) on delete restrict on update cascade,
	aluno_matriculaAluno bigserial references aluno(matricula) on delete cascade on update cascade,
	p1 double precision not null default 0,
	p2 double precision not null default 0,
	p3 double precision not null default 0,
	p4 double precision default 0,
	faltas smallint not null default 0,
	aprovado boolean default false,
	media_final double precision not null default 0,
	primary key(turma_idTurma, aluno_matriculaAluno)
);

create table ex_aluno(
	matricula bigserial primary key,
	nome varchar(150) not null unique,
	rg varchar(15) not null,
	senha varchar(64) not null,
	rua varchar(100),
	numero smallint,
	bairro varchar(40),
	data_exclusao date
);

create or replace rule adiciona_ex_aluno as
on delete to aluno do insert into ex_aluno 
values (old.matricula,old.nome,old.rg,old.senha,old.rua,old.numero,old.bairro,now());

-- inserts

insert into aluno values(default,'J','70495748623','20141084010110','Zema123');
insert into aluno values (default,'Bor�','70495748623','20151084010110','Boro123');

insert into professor values(default,'Silvio','JACINTO P',42,'LAgoa Seca','Silvio123');
insert into professor values(default,'PC','Augusta',69,'Centro','PC123');

insert into disciplina values(default,'Arquitetura',60,1);
insert into disciplina values(default,'Discreta',60,1);
insert into disciplina values (default, 'POO', 60, 60);

insert into turma values(default,'LAB 4','A',1,1),
				 (default,'Central de aulas 5 sala 3','A',2,2);
insert into turma values (default, 'LCC', 'A', 1, 1);

insert into horario values(default,'35M34',1),
						  (default,'35M12',2);

						  
insert into turma_has_aluno values(1,1,75,80,60,default,12,default,default);
insert into turma_has_aluno values(2,2,70,70,50,default,4,default,default);






-- fim dos inserts


-- vis�es

create view visao_alunos as (select d.idDisciplina as C�digo,a.nome as Nome,d.nome as Disciplina,
							 tha.p1 as Unidade1,tha.p2 as Unidade2,tha.p3 as Unidade3,tha.p4 as Recuperac�o
							 ,tha.media_final as resultado,tha.faltas as faltas
							 from aluno as a,disciplina as d, turma_has_aluno as tha, turma as t 
							 where a.idaluno = tha.aluno_idAluno and tha.turma_idturma = t.idturma
							 and t.disciplina_idDisciplina = d.idDisciplina);

create view home_aluno as (select d.nome as disciplina_nome ,t.local_aula as local_aula ,h.horario as horario ,p.nome as professor_nome from 
						  turma as t, disciplina as d,horario as h,professor as p, turma_has_aluno as tha, aluno as a where
						  ((t.professor_matriculaprofessor = p.matricula and t.disciplina_idDisciplina = d.idDisciplina and h.turma_idTurma = t.idTurma 
						  and t.idTurma = tha.turma_idTurma and tha.aluno_matriculaaluno = a.matricula) 
						  and a.matricula = x)
						  );
							 
select * from home_aluno;

--	fim das vis�es	

/* fun��es


create function calcula_media_final(float,float,float,float)

-- p1,p2,p3,p4
returns float
as 
'SELECT CASE
	
	WHEN $4 <= 0 THEN CAST(CAST((($1 + $2 + $3)/3) as numeric(3,1)) as float)
	
WHEN $4 > 0 THEN CAST(CAST(((($1 + $2 + $3)/3*6 + ($4)*4)/10) as numeric(3,1)) as float)

END '

language 'sql';



create function pega_qtd_maxima_falta(bigint)
-- id da turma
returns float
as 'select (0.25 * (d.carga_horaria /d.hora_aula)) from turma_has_aluno as tha,turma as t, disciplina as d 
where tha.turma_idTurma = t.idturma and t.disciplina_idDisciplina = d.idDisciplina and tha.turma_idTurma = $1;'
language 'sql';



create function teste_aprovado(float,float,float,float)
--(media_final,p4,faltas_obtidas,faltas_maximas)
returns boolean
as 'SELECT CASE 
		WHEN ($3 > $4) THEN false
		WHEN (($2 > 0) and  ($1 < 5)) THEN false
		WHEN (($2 <= 0) and ($1 < 7)) THEN false
		ELSE true
	END;	
	'
language 'sql';	




