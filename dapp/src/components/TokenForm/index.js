import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { useHistory } from "react-router";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";

function TokenForm() {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [loadContract, setLoadContract] = useState(false);
  const [token, setToken] = useState({});
  const history = useHistory();

  useEffect(() => {
    if (account) {
      setToken({ ...token, ["addressSocio"]: account });
    }
  }, [account]);

  useEffect(() => {
    console.log(contract);
    if (contract) {
      setLoadContract(true);
    }
  }, [contract]);

  function handleChange(e) {
    setToken({ ...token, [e.target.name]: e.target.value });
  }

  function AdicionarSocio(e) {
    e.preventDefault();

    const intDataLiquidacao = new Date(token.dataLiquidacao).getTime() / 1000;

    contract.methods
      .AddContratoToken(token.addressSocio, token.quantidadeTokens, intDataLiquidacao)
      .send({ from: account })
      .once("receipt", (receipt) => {
        history.push("/tokens", {});
      });
  }

  return (
    <form onSubmit={AdicionarSocio}>
      <div>
        <span>Address</span>
        <input name="addressSocio" value={token.addressSocio} type="text" onChange={handleChange} />
      </div>
      <div>
        <span>Quantidade</span>
        <input name="quantidadeTokens" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>Data liquidação</span>
        <input name="dataLiquidacao" type="datetime-local" onChange={handleChange} />
      </div>
      <button type="submit" disabled={!loadContract}>
        Adicionar
      </button>
    </form>
  );
}

export default TokenForm;
