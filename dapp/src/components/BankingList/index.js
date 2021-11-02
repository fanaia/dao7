import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import BankingCard from "../BankingCard";

function BankingList() {
  const { contract } = useContext(ContractDAO7Context);
  const [bankings, setBankings] = useState([]);

  useEffect(() => {
    if (contract) {
      loadBankings();
    }
  }, [contract]);

  async function loadBankings() {
    const movimentacoes = await contract.methods.GetMovimentacoesFinanceira().call();
    setBankings(movimentacoes);
  }

  return (
    <ul>
      {bankings.map((index) => (
        <li key={index}>
          <BankingCard index={index} />
        </li>
      ))}
    </ul>
  );
}

export default BankingList;
