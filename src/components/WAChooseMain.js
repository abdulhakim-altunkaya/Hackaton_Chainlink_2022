import React from 'react';
import { ethers } from "ethers";
import { ABI } from "./ContractABI";
import { CONTRACT_ADDRESS } from "./ContractAddress";
 
function WAChooseMain() {

    let contract;
    let signer;
    const CONTRACT_ABI = ABI;
    const ADDRESS = CONTRACT_ADDRESS;

    const connectContract = async () => {
        const ABI = CONTRACT_ABI;
        const Address = ADDRESS;
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        contract = new ethers.Contract(Address, ABI, signer);
    }

    const chooseMain = async () => {
        await connectContract();
        let txArray = await contract.getAllPro();
        let randomN1 = await contract.randomNumber();
        let randomN2 = await randomN1.toString();
        let randomN3 = parseInt(randomN2, 10);
        if(randomN3 >= txArray.length ) {
            alert( `Random Number is out of range. Create another random Number again`);
        }  else {
            await contract.chooseMainProposal();
            alert("Success, main proposal choosen. You can now see it by clicking on See Main Proposal Button")
        }
    }
    return (
        <div>
            <button className='button-56' style={{backgroundColor: "#dc143c"}} onClick={chooseMain}>Choose Proposal (Only Owner)</button>
        </div>
    )
}

export default WAChooseMain