import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function SaldoFundo() {
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoading, setViewLoading] = useState(true);
  const [saldo, setSaldo] = useState({});

  useEffect(() => {
    if (contract) {
      loadSaldo();
    }
  }, [contract]);

  async function loadSaldo() {
    const saldoFundo = await contract.methods.GetSaldoFundoTokens().call();
    setSaldo(saldoFundo);
    setViewLoading(false);
  }

  return (
    <div>
      <hr />
      <h2>Saldo bancário</h2>
      {viewLoading && <Loading />}
      R$ {saldo / 100}
      <hr />
    </div>
  );
}

export default SaldoFundo;
