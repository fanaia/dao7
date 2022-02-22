//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./Projeto.sol";

contract DAO7 is Projeto {
    constructor() {}

    function Votar(uint256 index, bool voto) public {
        require(
            Sociedade.SocioAtivo(msg.sender) == true,
            "Apenas socios ativos podem votar!"
        );

        (, , , , , uint256 dataVotacao) = Consenso.GetPropostaVotacao(index);
        uint256 totalTokens = Token.GetTotalTokensPorData(dataVotacao);
        uint256 tokensSocio = Token.GetTokensPorSocioPorData(
            msg.sender,
            dataVotacao
        );
        uint256 peso = ((10000 * tokensSocio) / totalTokens);

        Consenso.Votar(index, peso, voto);
    }
}
