-- Criação de function
delimiter $$
create function calcula_idade(datanascimento date)
returns int 
deterministic
contains sql
begin
    declare idade int;
    set idade = timestampdiff(year, datanascimento, curdate());
    return idade ;
end; $$
delimiter ;

-- Verifica s e a função especificada foi criada

SHOW CREATE FUNCTION calcula_idade;

SELECT  name, calcula_idade(data_nascimento) AS idade FROM usuario;


delimiter $$
create function status_sistema()
returns varchar(50)
no sql
begin
    return "Sistema operando normalmente";
end; $$
delimiter ;

select status_sistema();

delimiter $$
create function total_compras_usuario(id_usuario int)
returns int
reads sql data
begin
    declare total int;

    select count(*) into total
    from compra
    where id_usuario = compra.fk_id_usuario;

    return total;

end; $$
delimiter ;

select total_compras_usuario(3)  as "total de compras";

-- Tabela para testar a clausula modifies sql data

create table log_evento (
    id_log int auto_increment primary key,
    mensagem varchar(255),
    data_log datetime default current_timestamp
);

delimiter $$
create function registrar_log_evento(texto varchar(255))
returns varchar(50)
 not deterministic
modifies sql data
begin
    insert into log_evento(mensagem)
    values (texto);

    return 'Log inserido com sucesso';

end; $$
delimiter ;

SHOW CREATE FUNCTION registrar_log_evento;

-- Vizualiza o estado da variavel de controle para permissoes de criação de funções

show variables like 'log_bin_trust_function_creators' ;

-- Alterar a variavel global do MYSQL 
-- precisa ter permissao de adiministrador do banco
set global log_bin_trust_function_creators = 1 ;

select registrar_log_evento('teste') ;

delimiter $$
create function mensagem_boas_vindas(nome_usuario varchar(100))
returns varchar(255)
deterministic
contains sql 
begin
    declare msg varchar(255);
    set msg = concat('Ola, ',nome_usuario, '! Seja bem-vindo(a) ao sistema VIO.');
    return msg;
end; $$
delimiter ;

select mensagem_boas_vindas("Marcos");

-- ================================================
-- 14/04

-- FEITO PRA VER AS FUNCTIONS NO BCD
select routine_name from 
information_schema.routines 
    where routine_type = 'FUNCTION' 
        and routine_schema ='vio_pedro';


-- maior idade
-- Criar uma function que verifica se o usuario e maior de idade
delimiter $$ 

create function is_maior_idade(data_nascimento date)
returns boolean
not deterministic
contains sql
begin
    declare idade int;
    
    -- utilizando a função ja criada
    set idade = calcula_idade(data_nascimento);
    return idade >= 18;
end; $$

delimiter ;

-- categorizar usuarios por faixa etaria

delimiter $$
create function faixa_etaria(data_nascimento date)
returns varchar(20)
not deterministic
contains sql
begin 
    declare idade int;

    -- calculo da idade com a function ja criada
    set idade = calcula_idade(data_nascimento);
    if idade < 18 then
        return 'Menor de idade';
    
    elseif idade < 60 then
        return 'Adulto';
    
    else 
        return 'Idoso';
    end if;
end; $$ 
delimiter ;

-- agrupar usuarios por faixa etaria
select faixa_etaria(data_nascimento) as faixa_etaria, count(*) as quantidade from usuario
group by faixa_etaria(data_nascimento);


select faixa_etaria(data_nascimento) as faixa, count(*) as quantidade from usuario
group by faixa(data_nascimento);

-- identificar uma faixa etaria especifica
select name  from usuario
where faixa_etaria(data_nascimento) = 'Adulto';

-- calcular a media de idade de usuarios cadastrados
delimiter $$
create function media_idade()
returns decimal(5,2)
not deterministic
reads sql data
begin
    declare media decimal(5,2);

    -- calculo da media de idades

    -- avg calucula a media de idades
    select avg(timestampdiff(year, data_nascimento, curdate())) into media from usuario;

    return ifnull(media, 0);

END; $$
delimiter ;

-- selecionar idade especifica
select "A media de idade dos clientes é maior que 30" as resultado where media_idade() > 30;



-- exercicio direcionado
-- calculo do total gasto por um usuario
delimiter $$
create function calcula_total_gasto(pid_usuario int)
returns decimal(10,2)
not deterministic       
reads sql data  
begin
    declare total decimal(10,2);

    -- soma o valor gasto por um usuario
    select sum(i.preco * ic.quantidade) into total
    from compra c
    join ingresso_compra ic on c.id_compra = ic.fk_id_compra
    join ingresso i on i.id_ingresso = ic.id_ingresso
    where c.fk_id_usuario = p_id_usuario;
    return ifnull (total, 0);
end; $$
delimiter ;


-- busca a faixa etaria de um usuario
delimiter $$
create function buscar_faixa_etaria(pid int)
returns varchar(20)
not deterministic
reads sql data 
begin 
    declare nascimento date;
    declare faixa varchar(20);

    select data_nascimento into nascimento
    from usuario
    where id_usuario = pid;

    set faixa = faixa_etaria(nascimento);

    return faixa;
end; $$
delimiter ; 
   

   

