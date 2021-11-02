import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function QuantidadeTokens() {
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoading, setViewLoading] = useState(true);
  const [qtdTokens, setQtdTokens] = useState({});

  useEffect(() => {
    if (contract) {
      loadSaldo();
    }
  }, [contract]);

  async function loadSaldo() {
    const qtd = await contract.methods.GetTotalTokens().call();
    setQtdTokens(qtd);
    setViewLoading(false);
  }

  return (
    <div>
      <hr />
      <h2>Qtd tokens</h2>
      {viewLoading && <Loading />}
      <div>Liberados: {qtdTokens.liberados}</div>
      <div>Total: {qtdTokens.total}</div>
      <hr />
    </div>
  );
}

export default QuantidadeTokens;
