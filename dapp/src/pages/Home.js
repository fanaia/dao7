import ContacaoToken from "../components/CotacaoToken";
import QuantidadeTokens from "../components/QuantidadeTokens";
import SaldoFundo from "../components/SaldoFundo";

function Home() {
  return (
    <div>
      <h1>DAO7</h1>
      <SaldoFundo />
      <ContacaoToken />
      <QuantidadeTokens />
    </div>
  );
}

export default Home;
