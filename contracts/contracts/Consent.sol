//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

contract Consent {
    address owner;

    struct PropostaVotacao {
        address owner;
        string titulo;
        string descricao;
        string[] tags;
        uint256 dataTermino;
        uint256 dataRegistro;
    }

    struct Voto {
        address owner;
        bool voto;
        uint256 peso;
        uint256 dataRegistro;
    }

    PropostaVotacao[] private votacoes;
    Voto[] private votos;

    mapping(uint256 => uint256[]) votacao; //index votacao / array votos

    constructor() {}

    function AddPropostaVotacao(
        string memory titulo,
        string memory descricao,
        string[] memory tags,
        uint256 dataTermino
    ) internal returns (uint256 index) {
        //Transformar o método em privado pois só poderá ser acessado
        //pelos Contratos filhos devido a necessidade de reconhecer a
        //lista de sócios e o peso de cada voto

        votacoes.push(
            PropostaVotacao({
                owner: msg.sender,
                titulo: titulo,
                descricao: descricao,
                tags: tags,
                dataTermino: dataTermino,
                dataRegistro: block.timestamp
            })
        );
        index = votacoes.length - 1;
        return index;
    }

    function JaVotou(uint256 index, address addressSocio)
        public
        view
        returns (bool votado)
    {
        votado = false;
        uint256[] memory indexVoto = votacao[index];

        for (uint256 i = 0; i < indexVoto.length; i++) {
            if (votos[indexVoto[i]].owner == addressSocio) {
                votado = true;
            }
        }

        return votado;
    }

    function Votar(
        uint256 index,
        uint256 peso,
        bool voto
    ) internal {
        require(JaVotou(index, msg.sender) == false, "Ja votou!");

        votos.push(
            Voto({
                owner: msg.sender,
                voto: voto,
                peso: peso,
                dataRegistro: block.timestamp
            })
        );
        uint256 indexVoto = votos.length - 1;
        votacao[index].push(indexVoto);
    }

    function GetPropostaVotacao(uint256 index)
        public
        view
        returns (
            address ownerVotacao,
            string memory titulo,
            string memory descricao,
            string[] memory tags,
            uint256 dataTermino,
            uint256 dataRegistro
        )
    {
        PropostaVotacao memory propostaVotacao = votacoes[index];

        return (
            propostaVotacao.owner,
            propostaVotacao.titulo,
            propostaVotacao.descricao,
            propostaVotacao.tags,
            propostaVotacao.dataTermino,
            propostaVotacao.dataRegistro
        );
    }

    function GetResultadoVotacao(uint256 index)
        public
        view
        returns (
            bool finalizada,
            bool resultado,
            uint256 votosAprovacao,
            uint256 votosReprovacao
        )
    {
        //se nao tiver resultado, verificar no array votacoes se já encerrou o prazo e carregar o resultado no mapping

        finalizada = false;
        resultado = false;
        votosAprovacao = 0;
        votosReprovacao = 0;

        uint256[] memory _votos = votacao[index];

        for (uint256 i; i < _votos.length; i++) {
            if (votos[_votos[i]].voto == true) {
                votosAprovacao += votos[_votos[i]].peso;
            } else {
                votosReprovacao += votos[_votos[i]].peso;
            }
        }

        if (
            votacoes[index].dataTermino < block.timestamp ||
            votosAprovacao > 5000 ||
            votosReprovacao > 5000
        ) {
            finalizada = true;
        }

        if (votosAprovacao > votosReprovacao) {
            resultado = true;
        } else {
            resultado = false;
        }

        return (finalizada, resultado, votosAprovacao, votosReprovacao);
    }

    function GetVotacoesAbertas()
        public
        view
        returns (uint256[] memory _votacoes)
    {
        uint256 _index = 0;
        uint256 _qtdVotacoes = 0;
        uint256[] memory _arrayTemp;
        uint256 _agora = block.timestamp;

        for (uint256 i; i < votacoes.length; i++) {
            if (votacoes[i].dataTermino >= _agora) {
                _qtdVotacoes++;
            }
        }

        _arrayTemp = new uint256[](_qtdVotacoes);
        for (uint256 i; i < votacoes.length; i++) {
            if (votacoes[i].dataTermino >= _agora) {
                _arrayTemp[_index] = i;
                _index++;
            }
        }

        _votacoes = _arrayTemp;

        return _votacoes;
    }
}
