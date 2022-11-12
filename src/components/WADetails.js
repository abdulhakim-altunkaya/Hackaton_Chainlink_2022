import React from 'react';
import WAMainProposal from './WAMainProposal';
import WALeaveMembership from './WALeaveMembership';
import { useNavigate } from 'react-router-dom';
import WAWithdrawBalance from './WAWithdrawBalance';
import WARandom1 from './WARandom1';
import WARandom2 from './WARandom2';
import WARandom3 from './WARandom3';
import WARandom4 from './WARandom4';
import WAChooseMain from "./WAChooseMain";

 
function WADetails() {
    const navigate = useNavigate();
    

    return (
        <div>
            <WAMainProposal />
            <button className='button-56' onClick={ () => navigate("/vote") }>Vote for Proposal</button>
            <br />
            <button className='button-56' onClick={ () => navigate("/member") }>Become Member</button>
            <br />
            <button className='button-56' onClick={ () => navigate("/submit") }>Submit Proposal</button>
            <br />
            <WAChooseMain />
            <br />
            <button className='button-56 redButton' onClick={ () => navigate("/close") }>Close Voting (Only Owner)</button>
            <br />
            <button className='button-56 redButton' onClick={ () => navigate("/remove") }>Remove Person (Only Owner)</button>
            <br />
            <WAWithdrawBalance />
            <br />
            <WALeaveMembership />
            <br />
            <WARandom1 />
            <br />
            <WARandom2 />
            <br />
            <WARandom3 />
            <br />
            <WARandom4 />
        </div>
    )
}

export default WADetails