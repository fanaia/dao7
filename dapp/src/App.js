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
import MovimentacaoFinanceira from "./pages/MovimentacaoFinanceira";
import { useMetaMask } from "metamask-react";

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
      <div>{{ status } === "notConnected" ? <button onClick={connect}>Conectar</button> : `Status: ${status}`}</div>
      <div>Account: {account}</div>
      <div>Contract: {contract && contract._address}</div>
      <Navbar />
      <Switch>
        <Route path="/" exact component={Home} />
        <Route path="/votacoesPendentes" component={VotacoesPendentes} />
        <Route path="/socios" component={Socios} />
        <Route path="/adicionarSocio" component={AdicionarSocio} />
        <Route path="/tokens" component={Tokens} />
        <Route path="/adicionarTokens" component={AdicionarTokens} />
        <Route path="/movimentacaoFinanceira" component={MovimentacaoFinanceira} />
      </Switch>
      <Footer />
    </BrowserRouter>
  );
}

export default App;
