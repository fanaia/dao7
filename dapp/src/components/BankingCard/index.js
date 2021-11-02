import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function BankingCard(props) {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoadingEfetivar, setViewLoadingEfetivar] = useState(false);
  const [banking, setBanking] = useState({});

  useEffect(() => {
    if (contract) {
      loadBanking();
    }
  }, [contract]);

  async function loadBanking() {
    const movimentacaoFinanceira = await contract.methods.GetMovimentacaoFinanceira(props.index).call();

    const dataVencimento = new Date(movimentacaoFinanceira.dataVencimento * 1000);
    movimentacaoFinanceira.dataVencimento = dataVencimento.toLocaleDateString();

    const dataEfetivacao = new Date(movimentacaoFinanceira.dataEfetivacao * 1000);
    movimentacaoFinanceira.dataEfetivacao = dataEfetivacao.toLocaleDateString();

    const dataRegistro = new Date(movimentacaoFinanceira.dataRegistro * 1000);
    movimentacaoFinanceira.dataRegistro = dataRegistro.toLocaleDateString();

    setBanking(movimentacaoFinanceira);
  }

  function efetivar() {
    setViewLoadingEfetivar(true);
    contract.methods
      .EfetivarLancamento(props.index)
      .send({ from: account })
      .once("receipt", (receipt) => {
        loadBanking();
        setViewLoadingEfetivar(false);
      });
  }

  return (
    <div>
      <hr />

      <div>status: {banking.status}</div>
      <div>tipo: {banking.tipo}</div>
      <div>indexSocioInclusao: {banking.indexSocioInclusao}</div>
      <div> indexSocioEfetivacao: {banking.indexSocioEfetivacao}</div>
      <div> titulo: {banking.titulo}</div>
      <div> descricao: {banking.descricao}</div>
      <div> valor: {banking.valor}</div>
      <div> conta: {banking.conta}</div>
      <div> dataVencimento: {banking.dataVencimento}</div>
      <div> dataEfetivacao: {banking.dataEfetivacao}</div>
      <div> dataRegistro: {banking.dataRegistro}</div>
      <hr />
      <button disabled={banking.status == 1 ? false : true} onClick={efetivar}>
        Efetivar
      </button>
      {viewLoadingEfetivar && <Loading />}
      <hr />
    </div>
  );
}

export default BankingCard;
