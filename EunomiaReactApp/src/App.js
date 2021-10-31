import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import './App.css';
import eunomiaNFT from './utils/eunomiaNFT.json';

const App = () => {
  const [currentAccount, setCurrentAccount] = useState("");

  const contractAddress = "0x0969C4BF8290F0fBFF7942d0CF4d4A659e76613d";

  const checkIfWalletIsConnected = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        console.log("Make sure you have metamask!");
        return;
      } else {
        console.log("We have the ethereum object", ethereum);
        
      }

      const accounts = await ethereum.request({ method: 'eth_accounts' });

      if (accounts.length !== 0) {
        const account = accounts[0];
        console.log("Found an authorized account:", account);
        setCurrentAccount(account);

        setupEventListener()
        
      } else {
        console.log("No authorized account found")
      }
    } catch (error) {
      console.log(error);
    }
  }

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }

      const accounts = await ethereum.request({ method: "eth_requestAccounts" });

      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]); 

      setupEventListener()

    } catch (error) {
      console.log(error)
    }
  }

const setupEventListener = async () => {
    // Most of this looks the same as our function askContractToMintNft
    try {
      const { ethereum } = window;

      if (ethereum) {
        // Same stuff again
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const connectedContract = new ethers.Contract(contractAddress, eunomiaNFT.abi, signer);

        // THIS IS THE MAGIC SAUCE.
        // This will essentially "capture" our event when our contract throws it.
        // If you're familiar with webhooks, it's very similar to that!
        connectedContract.on("NFTMinted", (from, tokenId) => {
          console.log(from, tokenId.toNumber())
          alert(`Hey there! We've minted your NFT and sent it to your wallet. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: https://testnets.opensea.io/assets/${contractAddress}/${tokenId.toNumber()}`)
        });

        console.log("Setup event listener!")

      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error)
    }
  }  

  const dump = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const EunomiaContract = new ethers.Contract(contractAddress, eunomiaNFT.abi, signer);

        //let count = await EunomiaContract.get_dump();
        //console.log("Retrieved total dump count...", count.toNumber());

        const weight = document.getElementById("weight_input").value;
        const type = document.getElementById("type_input").value;

        const text_input = 'Type: ' + type.toString() + ' ; Weight: ' + weight.toString() + ' grams';

        const dumpTxn = await EunomiaContract.makeAnNFT(text_input, { gasLimit: 5000000 });
        console.log("Mining...", dumpTxn.hash);

        await dumpTxn.wait();

        console.log(`Mined, see transaction: https://ropsten.etherscan.io/tx/${dumpTxn.hash}`);

        //count = await EunomiaContract.get_dump();
        //console.log("Retrieved total dump count...", count.toNumber());

        const text = 'Your transaction has been mined -- ' + dumpTxn.hash.toString() + ' . Thank you for making the responsible choice.';
        alert(text)
      } else {
        console.log("Ethereum object doesn't exist!");
      }
    } catch (error) {
      console.log(error)
      alert('There has been an error. Your request was not processed.')
    }
  }


  useEffect(() => {
    checkIfWalletIsConnected();
  }, [])
  
  return (
    <div className="mainContainer">

      <div className="dataContainer">
        <div className="header">
        Welcome to Eunomia 
        </div>
        <p>This is a simulation of a terminal attached to the smart trash bin. There, the type will be predicted using computer vision and the weight will be computed <i>vice</i>.</p>

        <div className="bio">
        <h3>Types of trash:</h3>
        <ol type="1">
          <li>Low Density Polyeurethylene (including coated paper)</li>
          <li>Paper</li>
          <li>Bottles/Food containers/High Density Polyethylene</li>
          <li>Electronic Waste</li>
          <li>Metal Artefacts</li>
        </ol>
        </div>

        <label for="type_input">Enter the type of your trash - refer above: </label>
        <input type="number" id = "type_input" name = "type_input" min="1" max="5"/> 

        <label for="weight_input">Enter the weight of your trash in grams: </label>
        <input type="number" id = "weight_input" name = "weight_input" min = "1"/> 

        <button className="waveButton" onClick={dump}>
          Submit
        </button>

        
        {!currentAccount && (
          <button className="waveButton" onClick={connectWallet}>
            Connect Wallet
          </button>
        )}

      </div>
    </div>
  );
}

export default App