import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App";
import "./index.css";

declare global {
  interface Window {
    ethereum?: import("ethers").providers.ExternalProvider;
  }
}
ReactDOM.createRoot(document.getElementById("root") as HTMLElement).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);
