//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Sociedade.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Dedicacao is Sociedade {

    enum statusTempoDedicado {
        pendenteVotacao,
        pendenteEfetivacao,
        aceito,
        recusado
    }
    
    enum grauConhecimento {
        aprendiz,
        iniciante,
        experiente,
        especialista,
        lider
    }

    struct TempoDedicado {
        statusTempoDedicado status;
        uint256 indexSocio;
        uint256 indexSocioInclusao;
        uint256 indexSocioEfetivacao;
        string descricao;        
        grauConhecimento conhecimento;
        uint256 tempo;
        uint256 dataEfetivacao;
        uint256 dataRegistro;
    }

    TempoDedicado[] private tempoDedicados;
    mapping(uint256 => uint256) votacoesTempoDedicado; //index Socio / index Votacao

    constructor() {
    }

    function AddTempoDedicado(
        address addressSocio, 
        string memory descricao,
        grauConhecimento conhecimento,
        uint256 tempo
    ) public 
    {
        require(
            SocioAtivo(msg.sender) == true,
            "Apenas socios ativos podem adicionar Tempo Dedicado!"
        );

        (, uint256 indexSocio) = GetIndexSocioByAddress(addressSocio);
        (, uint256 indexSocioInclusao) = GetIndexSocioByAddress(msg.sender);

        TempoDedicado memory tempoDedicado = TempoDedicado({
            status: statusTempoDedicado.pendenteVotacao,
            indexSocio: indexSocio,
            indexSocioInclusao: indexSocioInclusao,
            descricao: descricao,   
            conhecimento: conhecimento,
            tempo: tempo,
            dataRegistro: block.timestamp
        });
        tempoDedicados.push(tempoDedicado);
        uint256 index = tempoDedicados.length - 1;

        AddPropostaVotacaoTempoDedicado(index);
    } 

    function AddPropostaVotacaoTempoDedicado(uint256 index) private {
        TempoDedicado memory tempoDedicado = tempoDedicados[index];
        (, , string memory nomeSocio, , , , ) = Sociedade.GetSocio(tempoDedicado.indexSocio);
        (, uint256 indexSocioInclusao) = Sociedade.GetIndexSocioByAddress(msg.sender);
        (, , string memory nomeSocioInclusao, , , , ) = Sociedade.GetSocio(indexSocioInclusao);

        string memory titulo = string(
            abi.encodePacked(
                "Registro de Tempo Dedicado: ",
                Strings.toString(tempoDedicado.tempo),
                " hora(s) de ",
                grauConhecimento,
                " para ",
                nomeSocio
            )
        );
        string memory detalhe;
        string[] memory tags = new string[](2);
        tags[0] = "tempoDedicado";
        tags[1] = "novo";

        uint256 dataTermino = contrato.dataRegistro + prazoVotacao;

        uint256 _indexVotacao = AddPropostaVotacao(
            titulo,
            detalhe,
            tags,
            dataTermino
        );
        votacoesTempoDedicado[index] = _indexVotacao;
    }

    function EfetivarVotacaoTempoDedicado(uint256 index) public {
        //se tiver aguardando aprovacao e a votacao estiver encerrada, altera o status conforme o resultado;

        (bool finalizada, bool resultado, , ) = GetResultadoVotacao(
            votacoesTempoDedicado[index]
        );

        if (
            tempoDedicados[index].status == statusTempoDedicado.pendenteVotacao &&
            finalizada == true
        ) {
            if (resultado == true) {
                tempoDedicados[index].status = statusTempoDedicado.aceito;
                //Transferir Tokens
            } else {
                tempoDedicados[index].status = statusTempoDedicado.recusado;
            }
        }
    }

    function GetEnumGrauConhecimento(uint256 index)
        public
        pure
        returns (string memory)
    {
        string[5] memory stringToEnum = [
            "aprendiz",
            "iniciante",
            "experiente",
            "especialista",
            "lider"
        ];
        return stringToEnum[index];
    }

    function GetEnumStatusTempoDedicado(uint256 index)
        public
        pure
        returns (string memory)
    {
        string[4] memory stringToEnum = [
            "pendenteVotacao",
            "pendenteEfetivacao",
            "aceito",
            "recusado"
        ];
        return stringToEnum[index];
    }

    function GetTempoDedicado(uint256 index)
        public
        view
        returns (
            statusTempoDedicado status,
            uint256 indexSocio,
            uint256 indexSocioInclusao,
            uint256 indexSocioEfetivacao,
            string descricao,        
            grauConhecimento conhecimento,
            uint256 tempo,
            uint256 dataEfetivacao,
            uint256 dataRegistro
        )
    {
        TempoDedicado memory td = tempoDedicados[index];
        uint256 indexVotacao = votacoesTempoDedicado[index];

        if (td.status == statusTempoDedicado.pendenteVotacao) {
            (bool finalizada, , , ) = Consenso.GetResultadoVotacao(indexVotacao);

            if (finalizada == true) {
                td.status = statusTempoDedicado.pendenteEfetivacao;
            }
        }

        return (
            td.status,
            td.indexSocio,
            td.indexSocioInclusao,
            td.indexSocioEfetivacao,
            td.descricao,        
            td.conhecimento,
            td.tempo,
            td.dataEfetivacao,
            td.dataRegistro
        );
    }

    function GetTempoDedicados()
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory arrayIndex = new uint256[](tempoDedicados.length);

        for (uint256 i; i < tempoDedicados.length; i++) {
            arrayIndex[i] = i;
        }

        return arrayIndex;
    }
}