//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Project.sol";

contract DAO7 is Project {
    constructor() {}

    function Votar(uint256 index, bool voto) public {
        require(
            Partner.SocioAtivo(msg.sender) == true,
            "Apenas socios ativos podem votar!"
        );

        (, , , , , uint256 dataVotacao) = Consent.GetPropostaVotacao(index);
        uint256 totalTokens = Token.GetTotalTokensPorData(dataVotacao);
        uint256 tokensSocio = Token.GetTokensPorSocioPorData(
            msg.sender,
            dataVotacao
        );
        uint256 peso = ((10000 * tokensSocio) / totalTokens);

        Consent.Votar(index, peso, voto);
    }
}
