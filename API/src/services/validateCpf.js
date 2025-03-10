const connect = require("../db/connect")

module.exports = async function validateCpf(cpf, userId){
    const query = "SELECT id_usuario FROM usuario WHERE cpf=?";
    const values =[cpf];

    await connect.query(query,values,(err, results)=>{
        if(err){
            //Fazer algo
        }
        else if (results.length > 0){
            const idDocpfCadastrado = results[0].id_usuario;
            
            if(userId && idDocpfCadastrado !== userId){
                return{error:"Cpf ja cadastrado para outro usuario"}
            }else if(!userId){
                return{error:"Cpf ja cadastrado"}

            }
        }
        else{
            return null;
        }
    })
}