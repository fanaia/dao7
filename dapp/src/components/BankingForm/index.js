import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { useHistory } from "react-router";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";

function BankingForm() {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [loadContract, setLoadContract] = useState(false);
  const [banking, setBanking] = useState({});
  const history = useHistory();

  useEffect(() => {
    if (contract) {
      setLoadContract(true);
    }
  }, [contract]);

  function handleChange(e) {
    setBanking({ ...banking, [e.target.name]: e.target.value });
  }

  function AdicionarMovimentacaoFinanceira(e) {
    e.preventDefault();

    const intDataLiquidacao = new Date(banking.dataVencimento).getTime() / 1000;

    contract.methods
      .AddMovimentacaoFinanceira(
        banking.tipo,
        banking.titulo,
        banking.descricao,
        banking.valor,
        banking.conta,
        intDataLiquidacao
      )
      .send({ from: account })
      .once("receipt", (receipt) => {
        history.push("/movimentacoesFinanceiras", {});
      });
  }

  return (
    <form onSubmit={AdicionarMovimentacaoFinanceira}>
      <div>
        <span>tipo</span>
        <input name="tipo" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>titulo</span>
        <input name="titulo" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>descricao</span>
        <input name="descricao" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>valor</span>
        <input name="valor" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>conta</span>
        <input name="conta" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>dataVencimento</span>
        <input name="dataVencimento" type="datetime-local" onChange={handleChange} />
      </div>
      <button type="submit" disabled={!loadContract}>
        Adicionar
      </button>
    </form>
  );
}

export default BankingForm;
