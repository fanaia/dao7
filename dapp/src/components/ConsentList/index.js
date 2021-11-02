import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import ConsentCard from "../ConsentCard";
import Loading from "../layout/loading";

function ConsentList() {
  const { contract } = useContext(ContractDAO7Context);
  const [viewLoading, setViewLoading] = useState(true);
  const [consents, setConsents] = useState([]);

  useEffect(() => {
    if (contract) {
      carregarVotacoes();
    }
  }, [contract]);

  async function carregarVotacoes() {
    const votacoes = await contract.methods.GetVotacoesAbertas().call();
    setConsents(votacoes);
    setViewLoading(false);
  }

  return (
    <div>
      {viewLoading && <Loading />}
      <ul>
        {consents.map((index) => (
          <li key={index}>
            <ConsentCard index={index} />
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ConsentList;
