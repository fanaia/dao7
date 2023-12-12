//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Financeiro.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Token is Financeiro {
    // Os tokens sao sempre vinculados com contratos e esses com data de liquidacao;
    // Os tokens tem um valor mínimo;
    // Caso não tenha saldo suficiente para liquidar todos os contratos já liberados, segue a "fila" conforme a data de liquidação
    // A participacao dos sócios é dinamica, considerando a quantidade total de tokens pela quantidade de tokens ue o socio tem
    // Para as votações, não serão considerados os tokens recebidos nos últimos 30 dias
    // Todos os valores financeiros nos contratos são armazenados sem virgula, ou seja, o valor * 100.

    enum statusContratoToken {
        pendenteVotacao,
        pendenteEfetivacao,
        ativo,
        recusado
    }

    struct ContratoToken {
        uint256 indexSocio;
        uint256 quantidadeTokens;
        uint256 dataRegistro;
        statusContratoToken status;
    }

    uint256 cotacaoMinima;

    ContratoToken[] private contratosToken;
    mapping(uint256 => uint256) votacoesContratos; //index Socio / index Votacao

    uint256 private prazoVotacao;

    constructor() {
        cotacaoMinima = 2000;
        prazoVotacao = 3 days;

        uint256 data = block.timestamp;
        contratosToken.push(
            ContratoToken({
                indexSocio: 0,
                quantidadeTokens: 1,
                dataRegistro: data,
                status: statusContratoToken.ativo
            })
        );
        proximoContrato[0] = 0;
    }

    function AddPropostaVotacaoToken(uint256 index) private {
        ContratoToken memory contrato = contratosToken[index];
        (, , string memory nomeSocio, , , , ) = Sociedade.GetSocio(
            contrato.indexSocio
        );
        (, uint256 indexSocioInclusao) = Sociedade.GetIndexSocioByAddress(
            msg.sender
        );
        (, , string memory nomeSocioInclusao, , , , ) = Sociedade.GetSocio(
            indexSocioInclusao
        );

        string memory titulo = string(
            abi.encodePacked(
                "Inclusao de contrato de Token de ",
                Strings.toString(contrato.quantidadeTokens),
                "??? para ",
                nomeSocio,
                " feita por ",
                nomeSocioInclusao
            )
        );
        string memory detalhe;
        string[] memory tags = new string[](2);
        tags[0] = "token";
        tags[1] = "novo";

        uint256 dataTermino = contrato.dataRegistro + prazoVotacao;

        uint256 _indexVotacao = AddPropostaVotacao(
            titulo,
            detalhe,
            tags,
            dataTermino
        );
        votacoesContratos[index] = _indexVotacao;
    }

    function GetContratosToken() public view returns (uint256[] memory) {
        uint256[] memory arrayIndex = new uint256[](contratosToken.length);
        uint256 index = 0;

        for (uint256 i; i < contratosToken.length; i++) {
            arrayIndex[index] = i;
            index = proximoContrato[index];
        }

        return arrayIndex;
    }

    function GetContratoToken(uint256 index)
        public
        view
        returns (
            uint256 indexSocio,
            uint256 quantidadeTokens,
            uint256 dataRegistro,
            statusContratoToken status
        )
    {
        ContratoToken memory contratoToken = contratosToken[index];

        if (contratoToken.status == statusContratoToken.pendenteVotacao) {
            (bool finalizada, , , ) = GetResultadoVotacao(
                votacoesContratos[index]
            );

            if (finalizada == true) {
                contratoToken.status = statusContratoToken.pendenteEfetivacao;
            }
        }

        return (
            indexSocio = contratoToken.indexSocio,
            quantidadeTokens = contratoToken.quantidadeTokens,
            dataRegistro = contratoToken.dataRegistro,
            status = contratoToken.status
        );
    }

    function GetCotacaoToken() public view returns (uint256 cotacao) {
        (, uint256 liberados) = GetTotalTokens();
        uint256 saldo = GetSaldoFundoTokens();

        cotacao = saldo / liberados;
        if (cotacao < cotacaoMinima) {
            return cotacaoMinima;
        }

        return cotacao;
    }

    function AddContratoToken(
        address addressSocio,
        uint256 quantidadeTokens
    ) private returns (uint256 index) {
        require(
            Sociedade.SocioAtivo(addressSocio) == true,
            "Apenas socios podem receber tokens!"
        );

        (, uint256 indexSocio) = GetIndexSocioByAddress(addressSocio);

        contratosToken.push(
            ContratoToken({
                indexSocio: indexSocio,
                quantidadeTokens: quantidadeTokens,
                dataRegistro: block.timestamp,
                status: statusContratoToken.pendenteVotacao
            })
        );

        index = contratosToken.length - 1;
        AddPropostaVotacaoToken(index);
    }

    function EfetivarVotacaoToken(uint256 index) public {
        //se tiver aguardando aprovacao e a votacao estiver encerrada, altera o status conforme o resultado;

        (bool finalizada, bool resultado, , ) = GetResultadoVotacao(
            votacoesContratos[index]
        );

        if (
            contratosToken[index].status ==
            statusContratoToken.pendenteVotacao &&
            finalizada == true
        ) {
            if (resultado == true) {
                contratosToken[index].status = statusContratoToken.ativo;
                
                //Transfere os Tokens ERC20 para o Sócio
            } else {
                contratosToken[index].status = statusContratoToken.recusado;
            }
        }
    }

    // function GetTokensPorSocio(address addressSocio)
    //     public
    //     view
    //     returns (uint256 total, uint256 liberados)
    // {
    //     (, uint256 indexSocio) = GetIndexSocioByAddress(addressSocio);
    //     total = 0;
    //     liberados = 0;

    //     for (uint256 i = 0; i < contratosToken.length; i++) {
    //         if (
    //             contratosToken[i].indexSocio == indexSocio &&
    //             contratosToken[i].status == statusContratoToken.ativo
    //         ) {
    //             total = total + contratosToken[i].quantidadeTokensRestante;
    //             if (contratosToken[i].dataLiquidacao < block.timestamp) {
    //                 liberados =
    //                     liberados +
    //                     contratosToken[i].quantidadeTokensRestante;
    //             }
    //         }
    //     }

    //     return (total, liberados);
    // }

    // function GetTokensPorSocioPorData(address addressSocio, uint256 data)
    //     public
    //     view
    //     returns (uint256 total)
    // {
    //     (, uint256 indexSocio) = GetIndexSocioByAddress(addressSocio);
    //     total = 0;

    //     for (uint256 i = 0; i < contratosToken.length; i++) {
    //         if (
    //             contratosToken[i].indexSocio == indexSocio &&
    //             contratosToken[i].status == statusContratoToken.ativo &&
    //             contratosToken[i].dataRegistro < data
    //         ) {
    //             total = total + contratosToken[i].quantidadeTokensRestante;
    //         }
    //     }

    //     return (total);
    // }

    // function GetTotalTokens()
    //     public
    //     view
    //     returns (uint256 total, uint256 liberados)
    // {
    //     total = 0;
    //     liberados = 0;

    //     for (uint256 i = 0; i < contratosToken.length; i++) {
    //         if (contratosToken[i].status == statusContratoToken.ativo) {
    //             total = total + contratosToken[i].quantidadeTokensRestante;
    //             if (contratosToken[i].dataLiquidacao < block.timestamp) {
    //                 liberados =
    //                     liberados +
    //                     contratosToken[i].quantidadeTokensRestante;
    //             }
    //         }
    //     }

    //     return (total, liberados);
    // }

    // function GetTotalTokensPorData(uint256 data)
    //     public
    //     view
    //     returns (uint256 total)
    // {
    //     total = 0;

    //     for (uint256 i = 0; i < contratosToken.length; i++) {
    //         if (
    //             contratosToken[i].status == statusContratoToken.ativo &&
    //             contratosToken[i].dataRegistro < data
    //         ) {
    //             total = total + contratosToken[i].quantidadeTokensRestante;
    //         }
    //     }

    //     return (total);
    // }
}
