import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import Loading from "../layout/loading";

function PartnerCard(props) {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoadingEfetivar, setViewLoadingEfetivar] = useState(false);
  const [partner, setPartner] = useState({});
  const [tokens, setTokens] = useState({});

  useEffect(() => {
    if (contract) {
      loadPartner();
    }
  }, [contract]);

  async function loadPartner() {
    const socio = await contract.methods.GetSocio(props.index).call();

    const dataRegistro = new Date(socio.dataRegistro * 1000);
    socio.dataRegistro = dataRegistro.toLocaleString();

    setPartner(socio);

    const _tokens = await contract.methods.GetTokensPorSocio(socio.addressSocio).call();
    setTokens(_tokens);
  }

  function efetivar() {
    setViewLoadingEfetivar(true);
    contract.methods
      .EfetivarVotacaoSocio(props.index)
      .send({ from: account })
      .once("receipt", (receipt) => {
        loadPartner();
        setViewLoadingEfetivar(false);
      });
  }

  return (
    <div>
      <hr />
      <div>indexSocioIndicacao: {partner.indexSocioIndicacao}</div>
      <div>addressSocio: {partner.addressSocio}</div>
      <div>nome: {partner.nome}</div>
      <div>email: {partner.email}</div>
      <div>conta: {partner.conta}</div>
      <div>dataRegistro: {partner.dataRegistro}</div>
      <div>status: {partner.status}</div>
      <hr />
      <div>total tokens: {tokens.total}</div>
      <div>tokens liberados: {tokens.liberados}</div>
      <hr />
      <button disabled={partner.status == 1 ? false : true} onClick={efetivar}>
        Efetivar
      </button>
      {viewLoadingEfetivar && <Loading />}
      <hr />
    </div>
  );
}

export default PartnerCard;
