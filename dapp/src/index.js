import React from "react";
import ReactDOM from "react-dom";
import App from "./App";
import { MetaMaskProvider } from "metamask-react";
import { ContractDAO7Provider } from "./contexts/ContractDAO7";

ReactDOM.render(
  <React.StrictMode>
    <MetaMaskProvider>
      <ContractDAO7Provider>
        <App />
      </ContractDAO7Provider>
    </MetaMaskProvider>
  </React.StrictMode>,
  document.getElementById("root")
);
