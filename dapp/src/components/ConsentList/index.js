import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import ConsentCard from "../ConsentCard";

function ConsentList() {
  const { contract } = useContext(ContractDAO7Context);
  const [consents, setConsents] = useState([]);

  useEffect(() => {
    if (contract) {
      loadPartners();
    }
  }, [contract]);

  async function loadPartners() {
    const votacoes = await contract.methods.GetVotacoesAbertas().call();
    setConsents(votacoes);
  }

  return (
    <ul>
      {consents.map((index) => (
        <li key={index}>
          <ConsentCard index={index} />
        </li>
      ))}
    </ul>
  );
}

export default ConsentList;
