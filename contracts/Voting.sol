//SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8.4;

import "./VRFv2Consumer.sol";

contract Voting {
    
    mapping(address => bool) public membershipStatus;
    address[] public activeMembers;

    string public mainProposal;
    string[] internal proposalList;
    string[] internal proposalPassed;
    string[] internal proposalRejected;

    //Creating an owner for the Contract
    address internal owner;

    modifier onlyOwner(){
        require(msg.sender == owner, "you are not owner");
        _;
    }
    function renounceOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    modifier onlyMember(){
        bool status;
        for(uint i=0; i <activeMembers.length; i++) {
            if(activeMembers[i] == msg.sender) {
                status = true;
            }
        }
        require(status == true, "you are not a member");
        _;
    }


    //Membership Function
    function becomeMember() external payable {
        bool status = false;
        for(uint i=0; i<activeMembers.length; i++) {
            if(activeMembers[i] == msg.sender) {
                status = true;
            }
        }
        require(status == false, "you are already a member");
        require(msg.value >= 1 ether, "pay the membership fee of 1 FTM");
        activeMembers.push(msg.sender);
        membershipStatus[msg.sender] = true;
    }

    //Members can make proposals
    function makeProposal(string memory _proposal) external onlyMember {
        proposalList.push(_proposal);
    }

    /* CHAINLINK PART
    The purpose of this decentralized voting system is to make sure the transparency and efficiency
    of the voting process. All proposals submitted by members should have equal weight to become 
    main proposal. 

    Main proposal decision process will be managed by the Owner. And Owner should not
    choose proposal according to his/her pleasure. Instead randomness will be used here
    to determine which proposal will become main proposal.

    Random Number obtained from CHAINLINK will be used to determine the main proposal.

    We will use a simple Math Division operation to convert random number into a number between 0-99.
    Then the proposal matching this number will become the main proposal. 

    And there is no reason to keep main proposal inside the proposal list.
    Because it will later go inside passed or rejected list. 

    Thats why we are using for loop in orderly way to remove the main proposal
    from proposal pool. We are starting for loop from main proposal index.

    To create a random number first click on "createRandomValues" 
    Then click on "createRandomNumber"
    */
    VRFv2Consumer public chainlinkContract;
    uint public randomNumber;
    uint public requestId;
    /* //THIS FUNCTION WILL BE REPLACED WITH CONSTRUCTOR TO MAKE PROJECT MORE CONCISE
    function setContract(address _addressA) external onlyOwner { 
        chainlinkContract = VRFv2Consumer(_addressA);
    }
    */
    constructor(address _addressA) {
        owner = msg.sender;
        chainlinkContract = VRFv2Consumer(_addressA);
    }
    function createRandomValues() external {
        chainlinkContract.requestRandomWords();
    }
    function getRequestId() external {
        requestId = chainlinkContract.lastRequestId();
    }
    function createRandomNumber() external returns(uint) {
        (, uint[] memory randomWords) = chainlinkContract.getRequestStatus(requestId);
        randomNumber = randomWords[0] % 10; //Assumption is proposalList array will be smaller than 10
        return randomNumber;
    }

    //VOTING INITIATION CONTRACT
    //Random Number provided by ChainLink will become the index number of target proposal in 
    //proposals array.
    uint public votingStartTime;
    function chooseMainProposal() external /*onlyOwner*/ {
        require(randomNumber < proposalList.length, "proposal with this index (random number) does not exist. Recreate a random number again");
        mainProposal = proposalList[randomNumber];
        for(uint i = randomNumber; i < proposalList.length-1; i++) {
            proposalList[i] = proposalList[i+1];
        }
        proposalList.pop();
        votingStartTime = block.timestamp;
    }


    //VIEW FUNCTIONS: WAITING PROPOSAL POOL, REJECTED OR PASSED ONES
    function getAllPro() external view returns(string[] memory) {
        return proposalList;
    }
    function getAllProPassed() external view returns(string[] memory) {
        return proposalPassed;
    }
    function getAllProRejected() external view returns(string[] memory) {
        return proposalRejected;
    }

    //VIEW FUNCTION: BALANCE OF THE CONTRACT
    function getBalance() external view returns(uint) {
        return (address(this).balance);
    }

    //VIEW FUNCTION: OWNER AND CONTRACT ADDRESS
    function getDetails() external view returns(address, address) {
        return(owner, address(this));
    }


    //this struct is to save voting results in resultsMapping after closing the voting.
    // And getRecordStruct function is used to details of a voting session.
    struct ResultStruct {
        string proposalName;
        uint yesV;
        uint noV;
        uint totalV;
    }
    ResultStruct record;
    mapping(uint => ResultStruct) internal resultsMapping;

    function getRecordStruct(uint id) external view returns(ResultStruct memory) {
        return resultsMapping[id];
    }

    //VOTING PROCESS ON THE MAIN PROPOSAL
    //y: yes votes, n: no votes
    uint internal y;
    uint internal n;
    mapping(address => bool) public votingStatus;
    address[] internal voters;
    function voteYes() external onlyMember {
        require(votingStatus[msg.sender] == false, "you have already voted");
        require(block.timestamp < votingStartTime + 20 minutes, "voting period has ended");
        votingStatus[msg.sender] = true;
        voters.push(msg.sender);
        y++;
    }
    function voteNo() external onlyMember {
        require(votingStatus[msg.sender] == false, "you have already voted");
        require(block.timestamp < votingStartTime + 20 minutes, "voting period has ended");
        votingStatus[msg.sender] = true;
        voters.push(msg.sender);
        n++;
    }
    function getVotingStatus() external view returns(bool) {
        return votingStatus[msg.sender];
    }

    //no need to reset votingStartTime here. 
    function closeVoting(uint indexMapping) external /*onlyOwner*/ {
        uint totalVotes = y + n;
        uint percentage1 = y*100;
        uint percentage2 = percentage1/totalVotes;
        if(percentage2 >= 60) {
            proposalPassed.push(mainProposal);
        } else {
            proposalRejected.push(mainProposal);
        }
        record = ResultStruct(mainProposal, y, n, totalVotes);
        resultsMapping[indexMapping] = record;
    }
    //reset the table for next voting
    function resetTable() external /*onlyOwner*/ {
        n=0;
        y=0;
        mainProposal = "";
        for(uint i=0; i <voters.length; i++) {
            votingStatus[voters[i]] = false;
        }
        delete voters;
    }

    //leaving membership. First we are searching for member index in activeMembers array.
    //Then we are removing the msg.sender in an orderly way.
    function leaveMembership() external onlyMember {
        uint memberIndex;
        for(uint i=0; i<activeMembers.length; i++) {
            if(activeMembers[i] == msg.sender) {
                memberIndex = i;
                break;
            }
        }
        for(uint i = memberIndex; i < activeMembers.length -1; i++) {
            activeMembers[i] = activeMembers[i+1];
        }
        activeMembers.pop();
        membershipStatus[msg.sender] = false;
    }

    //owner can withdraw all the ether inside the contract
    function withdraw() external onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "you are not owner");
    }

    //owner can remove a member to prevent exploitation
    function removeMember(address _member) external onlyOwner {
        uint memberIndex;
        for(uint i=0; i<activeMembers.length; i++) {
            if(activeMembers[i] == _member) {
                memberIndex = i;
                break;
            }
        }
        for(uint i = memberIndex; i < activeMembers.length -1; i++) {
            activeMembers[i] = activeMembers[i+1];
        }
        activeMembers.pop();
        membershipStatus[_member] = false;
    }

    fallback() external payable {}
    receive() external payable {}
}