import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function ContacaoToken() {
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoading, setViewLoading] = useState(true);
  const [cotacaoToken, setCotacaoToken] = useState({});

  useEffect(() => {
    if (contract) {
      loadCotacaoToken();
    }
  }, [contract]);

  async function loadCotacaoToken() {
    const cotacao = await contract.methods.GetCotacaoToken().call();
    setCotacaoToken(cotacao);
    setViewLoading(false);
  }

  return (
    <div>
      <hr />
      <h2>Cotação Token</h2>
      {viewLoading && <Loading />}
      R$ {cotacaoToken / 100}
      <hr />
    </div>
  );
}

export default ContacaoToken;
