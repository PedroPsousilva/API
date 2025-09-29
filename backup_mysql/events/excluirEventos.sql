create event if not exists excluir_eventos_antigo
    on schedule every 1 week
    starts current_timestamp + interval 5 minute
    on completion preserve
    enable
do
    delete from evento
    where data_compra < now() - interval 1 year;