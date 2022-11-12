import React, { useState } from 'react';
import { ABI } from './ContractABI';
import { CONTRACT_ADDRESS} from "./ContractAddress";
import { ethers } from "ethers";

function WARandom4() {
    let[randomNum, setRandomNum] = useState("");
    //connect to contract block
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
    const getNum = async () => {
        await connectContract();
        let num = await contract.randomNumber();
        setRandomNum(`Random Number is: ${num}` );
    }

    return (
        <div>
            <button className='button-56' style={{backgroundColor: "lightGreen"}}
            onClick={getNum}>4- See Random Number</button>
            <p>{randomNum}</p>
        </div>
    )
}

export default WARandom4;