import React from 'react'
import { ABI } from './ContractABI';
import { CONTRACT_ADDRESS} from "./ContractAddress";
import { ethers } from "ethers";

function WARandom2() {
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
    const createRequestID = async () => {
        await connectContract();
        await contract.getRequestId();
    }

    return (
        <div>
            <button className='button-56' style={{backgroundColor: "lightGreen"}}
            onClick={createRequestID}>2- Create Request ID</button>
        </div>
    )
}

export default WARandom2