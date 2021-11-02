import { useContext, useEffect, useState } from "react";
import { ContractDAO7Context } from "../../contexts/ContractDAO7";
import PartnerCard from "../PartnerCard";

function PartnerList() {
  const { contract } = useContext(ContractDAO7Context);
  const [partners, setPartners] = useState([]);

  useEffect(() => {
    if (contract) {
      loadPartners();
    }
  }, [contract]);

  async function loadPartners() {
    const socios = await contract.methods.GetSocios().call();
    setPartners(socios);
  }

  return (
    <ul>
      {partners.map((index) => (
        <li key={index}>
          <PartnerCard index={index} />
        </li>
      ))}
    </ul>
  );
}

export default PartnerList;
