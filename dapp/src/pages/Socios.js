import { Link } from "react-router-dom";
import PartnerList from "../components/PartnerList";

function Socios() {
  return (
    <div>
      <h1>Sócios</h1>
      <Link to="/adicionarSocio">Adicionar</Link>
      <PartnerList />
    </div>
  );
}

export default Socios;
