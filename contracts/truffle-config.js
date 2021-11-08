require("dotenv/config");
const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic = process.env.MNEMONIC;
const rpcUrlPolygonMainnet = process.env.RPC_URL_POLYGON_MAINNET;
const rpcUrlPolygonMumbai = process.env.RPC_URL_POLYGON_MUMBAI;

module.exports = {
  contracts_build_directory: "../dapp/src/contracts",
  networks: {
    ganache: {
      host: "localhost",
      port: 7545,
      network_id: "1337",
    },
    polygon: {
      provider: function () {
        return new HDWalletProvider(mnemonic, rpcUrlPolygonMainnet);
      },
      network_id: "137",
    },
    mumbai: {
      provider: function () {
        return new HDWalletProvider(mnemonic, rpcUrlPolygonMumbai);
      },
      network_id: "80001",
    },
  },
  compilers: {
    solc: {
      version: "0.8.7",
    },
  },
};
