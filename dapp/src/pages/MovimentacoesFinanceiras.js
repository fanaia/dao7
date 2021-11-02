import { Link } from "react-router-dom";
import BankingList from "../components/BankingList";

function MovimentacoesFinanceiras() {
  return (
    <div>
      <h1>Movimentação financeira</h1>
      <Link to="/adicionarMovimentacaoFinanceira">Adicionar</Link>
      <BankingList />
    </div>
  );
}

export default MovimentacoesFinanceiras;
