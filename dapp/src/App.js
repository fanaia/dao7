import { useContext, useEffect, useState } from "react";
import { BrowserRouter, Switch, Route } from "react-router-dom";
import { ContractDAO7Context } from "./contexts/ContractDAO7";

import Navbar from "./components/layout/Navbar";
import Footer from "./components/layout/Footer";

import Home from "./pages/Home";
import VotacoesPendentes from "./pages/VotacoesPendentes";
import Socios from "./pages/Socios";
import AdicionarSocio from "./pages/AdicionarSocio";
import Tokens from "./pages/Tokens";
import AdicionarTokens from "./pages/AdicionarTokens";
import MovimentacoesFinanceiras from "./pages/MovimentacoesFinanceiras";
import AdicionarMovimentacaoFinanceira from "./pages/AdicionarMovimentacaoFinanceira";
import { useMetaMask } from "metamask-react";
import LiquidarTokens from "./pages/LiquidarTokens";

function App() {
  const { status, connect, account } = useMetaMask();
  const { contract } = useContext(ContractDAO7Context);

  useEffect(() => {
    if (contract) {
      carregar();
    }
  }, [contract]);

  async function carregar() {
    // const ret = await contract.methods.retornaSender().call();
    // console.log(ret);
  }

  return (
    <BrowserRouter>
      <div>
        Status: {status} {status === "notConnected" && <button onClick={connect}>Conectar</button>}
      </div>
      <div>Account: {account}</div>
      <div>ChainID: {contract && contract.defaultChain} </div>
      <div>Contract: {contract && contract._address} </div>
      <Navbar />
      <Switch>
        <Route path="/" exact component={Home} />
        <Route path="/votacoesPendentes" component={VotacoesPendentes} />
        <Route path="/socios" component={Socios} />
        <Route path="/adicionarSocio" component={AdicionarSocio} />
        <Route path="/tokens" component={Tokens} />
        <Route path="/adicionarTokens" component={AdicionarTokens} />
        <Route path="/liquidarTokens" component={LiquidarTokens} />
        <Route path="/movimentacoesFinanceiras" component={MovimentacoesFinanceiras} />
        <Route path="/adicionarMovimentacaoFinanceira" component={AdicionarMovimentacaoFinanceira} />
      </Switch>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
