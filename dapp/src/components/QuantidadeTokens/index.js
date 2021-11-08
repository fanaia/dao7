import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function QuantidadeTokens() {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoading, setViewLoading] = useState(true);
  const [qtdTokens, setQtdTokens] = useState({});
  const [qtdMeusTokens, setQtdMeusTokens] = useState({});

  useEffect(() => {
    if (contract && account) {
      loadSaldo();
    }
  }, [contract, account]);

  async function loadSaldo() {
    const qtd = await contract.methods.GetTotalTokens().call();
    setQtdTokens(qtd);

    const qtdMeus = await contract.methods.GetTokensPorSocio(account).call();
    setQtdMeusTokens(qtdMeus);

    setViewLoading(false);
  }

  return (
    <div>
      <hr />
      <h2>Tokens</h2>
      {viewLoading && <Loading />}
      <div>Liberados: {qtdTokens.liberados}</div>
      <div>Total: {qtdTokens.total}</div>
      <hr />
      <h2>Meus Tokens</h2>
      {viewLoading && <Loading />}
      <div>Liberados: {qtdMeusTokens.liberados}</div>
      <div>Total: {qtdMeusTokens.total}</div>
      <hr />
    </div>
  );
}

export default QuantidadeTokens;
