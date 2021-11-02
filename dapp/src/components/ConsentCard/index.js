import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";

function ConsentCard(props) {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [consent, setConsent] = useState({});
  const [result, setResult] = useState({});
  const [votado, setVotado] = useState(true);
  const [tokensTotal, setTokensTotal] = useState(0);
  const [tokensSocio, setTokensSocio] = useState(0);

  useEffect(() => {
    if (contract) {
      loadConsent();
      loadResult();
    }
  }, [contract]);

  async function loadConsent() {
    const votacao = await contract.methods.GetPropostaVotacao(props.index).call();

    const _tokensTotal = await contract.methods.GetTotalTokensPorData(votacao.dataRegistro).call();
    setTokensTotal(_tokensTotal);

    const _tokensSocio = await contract.methods.GetTokensPorSocioPorData(account, votacao.dataRegistro).call();
    setTokensSocio(_tokensSocio);

    const dataTermino = new Date(votacao.dataTermino * 1000);
    votacao.dataTermino = dataTermino.toLocaleDateString();

    const dataRegistro = new Date(votacao.dataRegistro * 1000);
    votacao.dataRegistro = dataRegistro.toLocaleDateString();

    setConsent(votacao);
  }

  async function loadResult() {
    const resultado = await contract.methods.GetResultadoVotacao(props.index).call();
    setResult(resultado);

    const votado = await contract.methods.JaVotou(props.index, account).call();
    setVotado(votado);
  }

  function votar(aceitar) {
    contract.methods
      .Votar(props.index, aceitar)
      .send({ from: account })
      .once("receipt", (receipt) => {
        loadResult();
      });
  }

  return (
    <div>
      <hr />
      <div>ownerVotacao: {consent.ownerVotacao}</div>
      <div>titulo: {consent.titulo}</div>
      <div>descricao: {consent.descricao}</div>
      <div>tags: {consent.tags}</div>
      <div>dataTermino: {consent.dataTermino}</div>
      <div>dataRegistro: {consent.dataRegistro}</div>
      <hr />
      <div>
        peso: {tokensSocio}/{tokensTotal} ({(100 * tokensSocio) / tokensTotal}%)
      </div>
      <hr />
      <div>finalizada: {result.finalizada && result.finalizada.toString()}</div>
      <div>resultado: {result.resultado && result.resultado.toString()}</div>
      <div>votosAprovacao: {result.votosAprovacao / 100}%</div>
      <div>votosReprovacao: {result.votosReprovacao / 100}%</div>
      <hr />
      <button disabled={result.finalizada || votado} onClick={() => votar(false)}>
        Recusar
      </button>
      <button disabled={result.finalizada || votado} onClick={() => votar(true)}>
        Aceitar
      </button>
      {votado && "Votado!"}
      <hr />
    </div>
  );
}

export default ConsentCard;
