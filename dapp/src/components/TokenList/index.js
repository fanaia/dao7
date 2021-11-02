import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import TokenCard from "../TokenCard";

function TokenList() {
  const { contract } = useContext(ContractDAO7Context);
  const [tokens, setTokens] = useState([]);

  useEffect(() => {
    if (contract) {
      loadTokens();
    }
  }, [contract]);

  async function loadTokens() {
    const contratosTokens = await contract.methods.GetContratosToken().call();
    setTokens(contratosTokens);
  }

  return (
    <ul>
      {tokens.map((index) => (
        <li key={index}>
          <TokenCard index={index} />
        </li>
      ))}
    </ul>
  );
}

export default TokenList;
