
-- total_ingressos_vendidos
delimiter $$

create function total_ingressos_vendidos(id_evento int)
returns int
not deterministic
begin
    declare total int;

    -- Soma a quantidade de ingressos vendidos para um evento específico
    select ifnull(sum(ic.quantidade), 0)
     into total
    from ingresso_compra ic
    join ingresso i on ic.fk_id_ingresso = i.id_ingresso
    where i.fk_id_evento = id_evento;

    return total;    
end; $$

delimiter ;



-- renda_total_evento
delimiter $$
    create function renda_total_evento(id_evento int)
    returns decimal(10,2)
    not deterministic
    begin
        declare total decimal(10,2);

        -- Calcula a renda total de um evento específico
        select ifnull(sum(i.preco * ic.quantidade), 0)
        into total
        from ingresso_compra ic
        join ingresso i on ic.fk_id_ingresso = i.id_ingresso
        where i.fk_id_evento = id_evento;

        return total;
    end; $$
delimiter ;


-- Procedure


delimiter $$

create procedure resumo_evento( IN pid_evento int)
begin
    select 
    e.nome as nome_evento,
    e.data_hora as data,
    total_ingressos_vendidos(pid_evento) as total_vendidos,
    renda_total_evento (pid_evento) renda_total 
    from 
    evento e
    where e.id_evento = pid_evento;
end; $$

delimiter ;