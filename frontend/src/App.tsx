import { useState } from "react";
import MainMint from "./MainMint";
import NavBar from "./NavBar";

function App() {
  const [accounts, setAccounts] = useState<string[]>([]);

  return (
    <div className="App">
      <NavBar {...{ accounts, setAccounts }} />
      <MainMint {...{ accounts, setAccounts }} />
    </div>
  );
}

export default App;
