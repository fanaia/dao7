import { createContext, useEffect, useState } from "react";
import Web3 from "web3";
import contratoDAO7 from "../contracts/DAO7.json";

export const ContractDAO7Context = createContext({});

export const ContractDAO7Provider = (props) => {
  const [contract, setContract] = useState();

  useEffect(() => {
    loadBlockchainData();
  }, []);

  async function loadBlockchainData() {
    const web3 = new Web3(Web3.givenProvider);
    web3.eth.defaultChain = "80001"; // Mumbai
    // web3.eth.defaultChain = "1337"; //Ganache
    // web3.eth.defaultChain = "137"; //Polygon

    const contrato = await new web3.eth.Contract(
      contratoDAO7.abi,
      contratoDAO7.networks[web3.eth.defaultChain].address
    );

    setContract(contrato);
  }

  return <ContractDAO7Context.Provider value={{ contract }}>{props.children}</ContractDAO7Context.Provider>;
};
