import { Link } from "react-router-dom";
import TokenList from "../components/TokenList";

function Tokens() {
  return (
    <div>
      <h1>Tokens</h1>
      <Link to="/adicionarTokens">Adicionar</Link> | <Link to="/liquidarTokens">Liquidar</Link> |{" "}
      <Link to="/">Investir</Link>
      <TokenList />
    </div>
  );
}

export default Tokens;
