import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function PayTokens(props) {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [loadContract, setLoadContract] = useState(false);
  const [viewLoadingLiquidar, setViewLoadingLiquidar] = useState(false);
  const [quantidadeToken, setQuantidadeToken] = useState(0);

  useEffect(() => {
    if (contract) {
      setLoadContract(true);
    }
  }, [contract]);

  async function loadToken() {
    // const token = await contract.methods.GetC(props.index).call();
    // const dataRegistro = new Date(socio.dataRegistro * 1000);
    // socio.dataRegistro = dataRegistro.toLocaleString();
    // setToken(socio);
    // const _tokens = await contract.methods.GetTokensPorSocio(socio.addressSocio).call();
    // setTokens(_tokens);
  }

  function handleChangeQuantidade(e) {
    setQuantidadeToken(e.target.value);
  }

  function liquidar(e) {
    e.preventDefault();

    console.log("liquidar", quantidadeToken);

    setViewLoadingLiquidar(true);
    contract.methods
      .LiquidarToken(quantidadeToken)
      .send({ from: account })
      .once("receipt", (receipt) => {
        // Informar quantidade liquidada
        console.log(receipt);
        setViewLoadingLiquidar(false);
      });
  }

  return (
    <form onSubmit={liquidar}>
      <div>
        <span>Quantidade</span>
        <input name="quantidade" type="text" onChange={handleChangeQuantidade} />
      </div>
      <button type="submit" disabled={!loadContract}>
        Liquidar
      </button>

      {viewLoadingLiquidar && <Loading />}
    </form>
  );
}

export default PayTokens;
