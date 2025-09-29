const connect = require("../db/connect");

module.exports = class compraController {
  static async registrarCompraSimples(req, res) {
    const { id_usuario, id_ingresso, quantidade } = req.body;

    console.log("Body: ", id_usuario, id_ingresso, quantidade);

    if (!id_usuario || !id_ingresso || !quantidade) {
      return res
        .status(400)
        .json({ error: "Dados Obrigatórios não enviados!" });
    }

    // Chamada da Procedure diretamente com os parametros
    connect.query(
      "call registrar_compra(?,?,?);",
      [id_usuario, id_ingresso, quantidade],
      (err, results) => {
        if (err) {
          console.log("Erro ao registra compra: ", err.message);
          return res.status(500).json({ error: err.message });
        } // fim err

        return res.status(201).json({
          message: "Compra registrada com sucesso via procedure!",
          dados: {
            id_usuario,
            id_ingresso,
            quantidade,
          },
        });
      }
    ); // fim da query
  } //fim registrarCompraSimples

  static async registrarCompra(req, res) {
    const { id_usuario, ingressos } = req.body;

    console.log("Body: ", id_usuario, ingressos);

    connect.query(
      "insert into compra (data_compra, fk_id_usuario) values (now(), ?)",
      [id_usuario],
      (err, result) => {
        if (err) {
          //Em caso de erro na inserção da compra, retorna 500
          console.log("Erro ao inserir compra: ", err);
          return res
            .status(500)
            .json({ error: "Erro ao criar a compra no sistema" });
        }

        // Recupera o id da compra recem criada
        const id_compra = result.insertId;
        console.log("Compra criada com o ID:", id_compra);

        //Inicializa o indice dos ingressos a serem processados
        let index = 0;

        //Função recursiva para processar cada ingresso sequencialmente
        function processarIngressos() {
          //Condição: todos os ingressos foram processados?
          if (index >= ingressos.length) {
            return res.status(201).json({
              message: "Compra realizada com Sucesso",
              id_compra,
              ingressos,
            }); // fim do return
          } // fim do if

          //obter o ingresso atual com base no indice
          const ingresso = ingressos[index];

          // chamada da proceudre para registrar as compras
          connect.query(
            "call registrar_compra2 (?,?,?);",
            [ingresso.id_ingresso, id_compra, ingresso.quantidade],
            (err) => {
              if (err) {
                return res.status(500).json({
                  error: `Erro ao registrar ingresso ${index + 1}`,
                  detalhes: err.message,
                });
              }
              index++
              processarIngressos();
            } // fim err
          ); // fim da querry
        } // fim da function

        processarIngressos();
      } // fim da respostas
    ); // fim da query
  } // fim registrarCompra
}; // fim compraController