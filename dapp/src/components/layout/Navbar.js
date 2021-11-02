import { Link } from "react-router-dom";

function Navbar() {
  return (
    <div>
      <ul>
        <li>
          <Link to="/">DAO7 - Home</Link>
        </li>
        <li>
          <Link to="/votacoesPendentes">Votações</Link>
        </li>
        <li>
          <Link to="/socios">Sócios</Link>
        </li>
        <li>
          <Link to="/tokens">Tokens</Link>
        </li>
        <li>
          <Link to="/movimentacoesFinanceiras">Movimentações Financeiras</Link>
        </li>
      </ul>
      <hr />
    </div>
  );
}

export default Navbar;
