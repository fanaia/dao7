import { useMetaMask } from "metamask-react";
import { useContext, useEffect, useState } from "react";
import { useHistory } from "react-router";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";

function PartnerForm() {
  const { account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);
  const [loadContract, setLoadContract] = useState(false);
  const [partner, setPartner] = useState({});
  const history = useHistory();

  useEffect(() => {
    if (contract) {
      setLoadContract(true);
    }
  }, [contract]);

  function handleChange(e) {
    setPartner({ ...partner, [e.target.name]: e.target.value });
  }

  function AdicionarSocio(e) {
    e.preventDefault();

    contract.methods
      .AddSocio(partner.addressSocio, partner.nome, partner.email, partner.conta)
      .send({ from: account })
      .once("receipt", (receipt) => {
        history.push("/socios", {});
      });
  }

  return (
    <form onSubmit={AdicionarSocio}>
      <div>
        <span>Address</span>
        <input name="addressSocio" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>Nome</span>
        <input name="nome" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>E-mail</span>
        <input name="email" type="text" onChange={handleChange} />
      </div>
      <div>
        <span>Conta (PIX)</span>
        <input name="conta" type="text" onChange={handleChange} />
      </div>
      <button type="submit" disabled={!loadContract}>
        Adicionar
      </button>
    </form>
  );
}

export default PartnerForm;
