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
    const chainID = "80001";
    // const chainID = "1337";

    const web3 = new Web3(Web3.givenProvider);
    const contrato = await new web3.eth.Contract(contratoDAO7.abi, contratoDAO7.networks[chainID].address);

    setContract(contrato);
  }

  return <ContractDAO7Context.Provider value={{ contract }}>{props.children}</ContractDAO7Context.Provider>;
};
