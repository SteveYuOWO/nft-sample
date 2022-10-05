import { BigNumber, ethers } from "ethers";
import React, { useState } from "react";
import roboPunksNFT from "./RoboPunksNFT.json";
const roboPunksNFTAddress = "0xb40c270c3712D01e3cABf73fBCdbce5E5E01d921";
function MainMint({
  accounts,
  setAccounts,
}: {
  accounts: string[];
  setAccounts: React.Dispatch<React.SetStateAction<string[]>>;
}) {
  const [mintAmount, setMintAmount] = useState(1);
  const isConnected = accounts && Boolean(accounts[0]);

  async function handleMint() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        roboPunksNFTAddress,
        roboPunksNFT.abi,
        signer
      );
      try {
        console.log(contract);
        const res = await contract.mint(BigNumber.from(mintAmount), {
          value: ethers.utils.parseEther((0.02 * mintAmount).toString()),
        });
        console.log("response", res);
      } catch (e) {
        throw e;
      }
    }
  }

  const handleDecr = () => {
    if (mintAmount <= 1) return;
    setMintAmount(mintAmount - 1);
  };
  const handleIncr = () => {
    if (mintAmount >= 3) return;
    setMintAmount(mintAmount + 1);
  };
  return (
    <div style={{ display: "flex", alignItems: "center" }}>
      <button onClick={handleIncr}>Incr</button>
      <div style={{ padding: "20px" }}>{mintAmount}</div>
      <button onClick={handleDecr}>decr</button>
      <button onClick={handleMint}>Mint</button>
    </div>
  );
}

export default MainMint;
