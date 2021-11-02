//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Partner.sol";

contract Banking is Partner {
    enum statusMovimentacaoFinanceira {
        pendenteVotacao,
        pendenteEfetivacao,
        ativo,
        recusado
    }

    enum tipoMovimentacaoFinanceira {
        pagar,
        receber
    }

    struct MovimentacaoFinanceira {
        statusMovimentacaoFinanceira status;
        tipoMovimentacaoFinanceira tipo;
        uint256 indexSocioInclusao;
        uint256 indexSocioEfetivacao;
        string titulo;
        string descricao;
        uint256 valor;
        string conta;
        uint256 dataVencimento;
        uint256 dataEfetivacao;
        uint256 dataRegistro;
    }

    MovimentacaoFinanceira[] movimentacoesFinanceiras;
    mapping(uint256 => uint256) votacoesMovimentacoesFinanceiras; // index movimentacoesFinanceiras[] => index votacoes[]
    uint256 saldoFinanceiro;

    uint256 private prazoVotacao;

    constructor() {
        prazoVotacao = 3 days;
    }

    function GetEnumTipoMovimentacaoFinanceira(uint256 index)
        public
        pure
        returns (string memory)
    {
        string[2] memory stringToEnum = ["pagar", "receber"];
        return stringToEnum[index];
    }

    function GetEnumStatusMovimentacaoFinanceira(uint256 index)
        public
        pure
        returns (string memory)
    {
        string[4] memory stringToEnum = [
            "pendenteVotacao",
            "pendenteEfetivacao",
            "ativo",
            "recusado"
        ];
        return stringToEnum[index];
    }

    function GetSaldoFundoTokens() public view returns (uint256 valor) {
        // Considera o balanço financeiro dos últimos 30 dias
        return saldoFinanceiro;
    }

    function AddMovimentacaoFinanceira(
        tipoMovimentacaoFinanceira tipo,
        string memory titulo,
        string memory descricao,
        uint256 valor,
        string memory conta,
        uint256 dataVencimento
    ) public returns (uint256 index) {
        (, uint256 indexSocioInclusao) = GetIndexSocioByAddress(msg.sender);

        MovimentacaoFinanceira memory mv = MovimentacaoFinanceira({
            status: statusMovimentacaoFinanceira.pendenteVotacao,
            tipo: tipo,
            indexSocioInclusao: indexSocioInclusao,
            indexSocioEfetivacao: 0,
            titulo: titulo,
            descricao: descricao,
            valor: valor,
            conta: conta,
            dataVencimento: dataVencimento,
            dataEfetivacao: 0,
            dataRegistro: block.timestamp
        });
        movimentacoesFinanceiras.push(mv);
        index = movimentacoesFinanceiras.length - 1;

        AddPropostaVotacaoMovimentacaoFinanceira(index);
    }

    function AddPropostaVotacaoMovimentacaoFinanceira(uint256 index) private {
        MovimentacaoFinanceira memory mv = movimentacoesFinanceiras[index];

        string memory titulo = string(
            abi.encodePacked("Movimentacao financeira: ", mv.titulo)
        );
        string memory descricao = string(
            abi.encodePacked("Descricao: ", mv.descricao)
        );
        string[] memory tags = new string[](2);
        tags[0] = "banking";
        tags[1] = "movimentacaoFinanceira";
        // tags[2] = string(abi.encodePacked("index:", index));
        // tags[3] = GetEnumTipoMovimentacaoFinanceira(uint256(mv.tipo));

        uint256 dataTermino = mv.dataRegistro + prazoVotacao;
        uint256 indexVotacao = AddPropostaVotacao(
            titulo,
            descricao,
            tags,
            dataTermino
        );
        votacoesMovimentacoesFinanceiras[index] = indexVotacao;
    }

    function GetMovimentacaoFinanceira(uint256 index)
        public
        view
        returns (
            statusMovimentacaoFinanceira status,
            tipoMovimentacaoFinanceira tipo,
            uint256 indexSocioInclusao,
            uint256 indexSocioEfetivacao,
            string memory titulo,
            string memory descricao,
            uint256 valor,
            string memory conta,
            uint256 dataVencimento,
            uint256 dataEfetivacao,
            uint256 dataRegistro
        )
    {
        MovimentacaoFinanceira memory mv = movimentacoesFinanceiras[index];
        uint256 indexVotacao = votacoesMovimentacoesFinanceiras[index];

        if (mv.status == statusMovimentacaoFinanceira.pendenteVotacao) {
            (bool finalizada, , , ) = Consent.GetResultadoVotacao(indexVotacao);

            if (finalizada == true) {
                mv.status = statusMovimentacaoFinanceira.pendenteEfetivacao;
            }
        }

        return (
            mv.status,
            mv.tipo,
            mv.indexSocioInclusao,
            mv.indexSocioEfetivacao,
            mv.titulo,
            mv.descricao,
            mv.valor,
            mv.conta,
            mv.dataVencimento,
            mv.dataEfetivacao,
            mv.dataRegistro
        );
    }

    function GetMovimentacoesFinanceira()
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory arrayIndex = new uint256[](
            movimentacoesFinanceiras.length
        );

        for (uint256 i; i < movimentacoesFinanceiras.length; i++) {
            arrayIndex[i] = i;
        }

        return arrayIndex;
    }

    function GetMovimentacoesFinanceirasPendentesEfetivacao()
        public
        view
        returns (uint256[] memory)
    {
        uint256 index = 0;
        uint256 tamanhoArray = 0;
        uint256[] memory arrayTemp;

        for (uint256 i; i < movimentacoesFinanceiras.length; i++) {
            if (
                movimentacoesFinanceiras[i].status ==
                statusMovimentacaoFinanceira.pendenteVotacao
            ) {
                (bool finalizada, , , ) = GetResultadoVotacao(
                    votacoesMovimentacoesFinanceiras[i]
                );

                if (finalizada == true) {
                    tamanhoArray++;
                }
            }
        }

        arrayTemp = new uint256[](tamanhoArray);

        for (uint256 i; i < movimentacoesFinanceiras.length; i++) {
            if (
                movimentacoesFinanceiras[i].status ==
                statusMovimentacaoFinanceira.pendenteVotacao
            ) {
                (bool finalizada, , , ) = GetResultadoVotacao(
                    votacoesMovimentacoesFinanceiras[i]
                );

                if (finalizada == true) {
                    arrayTemp[index] = i;
                    index++;
                }
            }
        }

        return arrayTemp;
    }

    function EfetivarLancamento(uint256 index) public returns (bool) {
        (bool finalizada, bool resultado, , ) = GetResultadoVotacao(
            votacoesMovimentacoesFinanceiras[index]
        );

        if (
            movimentacoesFinanceiras[index].status ==
            statusMovimentacaoFinanceira.pendenteVotacao &&
            finalizada == true
        ) {
            if (resultado == true) {
                movimentacoesFinanceiras[index]
                    .status = statusMovimentacaoFinanceira.ativo;
            } else {
                movimentacoesFinanceiras[index]
                    .status = statusMovimentacaoFinanceira.recusado;
            }

            (, uint256 indexSocioEfetivacao) = GetIndexSocioByAddress(
                msg.sender
            );
            movimentacoesFinanceiras[index]
                .indexSocioEfetivacao = indexSocioEfetivacao;
            movimentacoesFinanceiras[index].dataEfetivacao = block.timestamp;

            if (
                movimentacoesFinanceiras[index].tipo ==
                tipoMovimentacaoFinanceira.pagar
            ) {
                saldoFinanceiro =
                    saldoFinanceiro -
                    movimentacoesFinanceiras[index].valor;
            } else {
                saldoFinanceiro =
                    saldoFinanceiro +
                    movimentacoesFinanceiras[index].valor;
            }

            return true;
        }

        return false;
    }
}
