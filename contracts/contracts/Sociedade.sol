//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Consenso.sol";

contract Sociedade is Consenso {
    enum statusSocio {
        pendenteVotacao,
        pendenteEfetivacao,
        ativo,
        recusado,
        bloqueado
    }

    struct Socio {
        uint256 indexSocioIndicacao;
        address addressSocio;
        string nome;
        string email;
        string telefone;
        uint256 dataRegistro;
        statusSocio status;
    }

    struct LogStatus {
        statusSocio status;
        uint256 dataRegistro;
    }

    Socio[] socios;
    mapping(uint256 => LogStatus[]) logStatus; //index Socio / array Status
    mapping(uint256 => uint256) votacoesSocios; //index Socio / index Votacao
    // uint256 quantidadeVotacoesPendentes;

    uint256 private prazoVotacao;

    constructor() {
        // quantidadeVotacoesPendentes = 0;
        prazoVotacao = 3 days;

        Socio memory socio = Socio({
            indexSocioIndicacao: 0,
            addressSocio: msg.sender,
            nome: "owner",
            email: "",
            telefone: "",
            dataRegistro: block.timestamp,
            status: statusSocio.ativo
        });
        socios.push(socio);
    }

    function AddSocio(
        address addressSocio,
        string memory nome,
        string memory email,
        string memory telefone
    ) public {
        require(
            SocioAtivo(msg.sender) == true,
            "Apenas socios ativos podem adicionar novos socios!"
        );

        (, uint256 indexSocioIndicacao) = GetIndexSocioByAddress(msg.sender);

        Socio memory socio = Socio({
            indexSocioIndicacao: indexSocioIndicacao,
            addressSocio: addressSocio,
            nome: nome,
            email: email,
            telefone: telefone,
            dataRegistro: block.timestamp,
            status: statusSocio.pendenteVotacao
        });
        socios.push(socio);
        uint256 index = socios.length - 1;

        logStatus[index].push(
            LogStatus({status: socio.status, dataRegistro: socio.dataRegistro})
        );

        AddPropostaVotacaoSocio(index);
    }

    function SocioAtivo(address addressSocio)
        public
        view
        returns (bool socioAtivo)
    {
        socioAtivo = false;

        (bool socioEncontrado, uint256 index) = GetIndexSocioByAddress(
            addressSocio
        );

        if (socioEncontrado == true) {
            if (socios[index].status == statusSocio.ativo) {
                socioAtivo = true;
            }
        }

        return socioAtivo;
    }

    function AddPropostaVotacaoSocio(uint256 index) private {
        Socio memory socio = socios[index];

        string memory titulo = string(
            abi.encodePacked(
                "Inclusao do ",
                socio.nome,
                " feita por ",
                socios[socio.indexSocioIndicacao].nome
            )
        );
        string memory detalhe;
        string[] memory tags = new string[](2);
        tags[0] = "sociedade";
        tags[1] = "novo";

        uint256 dataTermino = socios[index].dataRegistro + prazoVotacao;

        uint256 _indexVotacao = AddPropostaVotacao(
            titulo,
            detalhe,
            tags,
            dataTermino
        );
        votacoesSocios[index] = _indexVotacao;
    }

    function GetSocios() public view returns (uint256[] memory) {
        uint256[] memory sociosIndex = new uint256[](socios.length);

        for (uint256 i; i < socios.length; i++) {
            sociosIndex[i] = i;
        }

        return sociosIndex;
    }

    function SociosPendentes() public view returns (uint256[] memory) {
        uint256 indexSocio = 0;
        uint256 quantidadeSocios = 0;
        uint256[] memory sociosTemp;
        for (uint256 i; i < socios.length; i++) {
            if (socios[i].status == statusSocio.pendenteVotacao) {
                (bool finalizada, , , ) = GetResultadoVotacao(
                    votacoesSocios[i]
                );
                if (finalizada == true) {
                    quantidadeSocios++;
                }
            }
        }
        sociosTemp = new uint256[](quantidadeSocios);
        for (uint256 i; i < socios.length; i++) {
            if (socios[i].status == statusSocio.pendenteVotacao) {
                (bool finalizada, , , ) = GetResultadoVotacao(
                    votacoesSocios[i]
                );
                if (finalizada == true) {
                    sociosTemp[indexSocio] = i;
                    indexSocio++;
                }
            }
        }
        return sociosTemp;
    }

    function EfetivarVotacaoSocio(uint256 index) public {
        //se tiver aguardando aprovacao e a votacao estiver encerrada, altera o status conforme o resultado;

        (bool finalizada, bool resultado, , ) = GetResultadoVotacao(
            votacoesSocios[index]
        );

        if (
            socios[index].status == statusSocio.pendenteVotacao &&
            finalizada == true
        ) {
            if (resultado == true) {
                AlterarStatus(index, statusSocio.ativo);
            } else {
                AlterarStatus(index, statusSocio.recusado);
            }
        }
    }

    function AlterarStatus(uint256 index, statusSocio status) private {
        socios[index].status = status;

        logStatus[index].push(
            LogStatus({status: status, dataRegistro: block.timestamp})
        );
    }

    function GetSocio(uint256 index)
        public
        view
        returns (
            uint256 indexSocioIndicacao,
            address addressSocio,
            string memory nome,
            string memory email,
            string memory conta,
            uint256 dataRegistro,
            statusSocio status
        )
    {
        Socio memory socio = socios[index];

        if (socio.status == statusSocio.pendenteVotacao) {
            (bool finalizada, , , ) = GetResultadoVotacao(
                votacoesSocios[index]
            );

            if (finalizada == true) {
                socio.status = statusSocio.pendenteEfetivacao;
            }
        }

        return (
            socio.indexSocioIndicacao,
            socio.addressSocio,
            socio.nome,
            socio.email,
            socio.telefone,
            socio.dataRegistro,
            socio.status
        );
    }

    function GetIndexSocioByAddress(address _addressSocio)
        internal
        view
        returns (bool socioEncontrado, uint256 index)
    {
        socioEncontrado = false;

        for (uint256 i; i < socios.length; i++) {
            if (socios[i].addressSocio == _addressSocio) {
                socioEncontrado = true;
                index = i;

                return (socioEncontrado, index);
            }
        }

        return (socioEncontrado, index);
    }
}
