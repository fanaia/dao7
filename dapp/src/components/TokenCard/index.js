import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";

function TokenCard(props) {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [token, setToken] = useState({});

  useEffect(() => {
    if (contract) {
      loadToken();
    }
  }, [contract]);

  async function loadToken() {
    const contratoToken = await contract.methods.GetContratoToken(props.index).call();

    const dataLiquidacao = new Date(contratoToken.dataLiquidacao * 1000);
    contratoToken.dataLiquidacao = dataLiquidacao.toLocaleString();

    const dataRegistro = new Date(contratoToken.dataRegistro * 1000);
    contratoToken.dataRegistro = dataRegistro.toLocaleString();

    setToken(contratoToken);
  }

  function efetivar() {
    contract.methods
      .EfetivarVotacaoToken(props.index)
      .send({ from: account })
      .once("receipt", (receipt) => {
        console.log(receipt);
        loadToken();
      });
  }

  return (
    <div>
      <hr />
      <div>indexSocio: {token.indexSocio}</div>
      <div>quantidadeTokens: {token.quantidadeTokens}</div>
      <div>quantidadeTokensRestante: {token.quantidadeTokensRestante}</div>
      <div>dataLiquidacao: {token.dataLiquidacao}</div>
      <div>dataRegistro: {token.dataRegistro}</div>
      <div>status: {token.status}</div>
      <hr />
      <button disabled={token.status == 1 ? false : true} onClick={efetivar}>
        Efetivar
      </button>
      <hr />
    </div>
  );
}

export default TokenCard;
