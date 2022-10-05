import { ethers } from "ethers";
import React from "react";

function NavBar({
  accounts,
  setAccounts,
}: {
  accounts: string[];
  setAccounts: React.Dispatch<React.SetStateAction<string[]>>;
}) {
  const isConnected = accounts.length > 0 && Boolean(accounts[0]);

  async function connectAccount() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = provider.getSigner();
      setAccounts([await signer.getAddress()]);
    }
  }
  return (
    <div>
      {isConnected ? (
        <div>{accounts[0]}</div>
      ) : (
        <button onClick={connectAccount}>Connect</button>
      )}
    </div>
  );
}

export default NavBar;
