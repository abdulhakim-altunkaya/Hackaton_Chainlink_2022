// Sources flattened with hardhat v2.12.2 https://hardhat.org

// File @chainlink/contracts/src/v0.8/interfaces/OwnableInterface.sol@v0.5.1

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface OwnableInterface {
  function owner() external returns (address);

  function transferOwnership(address recipient) external;

  function acceptOwnership() external;
}


// File @chainlink/contracts/src/v0.8/ConfirmedOwnerWithProposal.sol@v0.5.1


pragma solidity ^0.8.0;

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwnerWithProposal is OwnableInterface {
  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  /**
   * @notice Allows an owner to begin transferring ownership to a new address,
   * pending.
   */
  function transferOwnership(address to) public override onlyOwner {
    _transferOwnership(to);
  }

  /**
   * @notice Allows an ownership transfer to be completed by the recipient.
   */
  function acceptOwnership() external override {
    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  /**
   * @notice Get the current owner
   */
  function owner() public view override returns (address) {
    return s_owner;
  }

  /**
   * @notice validate, transfer ownership, and emit relevant events
   */
  function _transferOwnership(address to) private {
    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  /**
   * @notice validate access
   */
  function _validateOwnership() internal view {
    require(msg.sender == s_owner, "Only callable by owner");
  }

  /**
   * @notice Reverts if called by anyone other than the contract owner.
   */
  modifier onlyOwner() {
    _validateOwnership();
    _;
  }
}


// File @chainlink/contracts/src/v0.8/ConfirmedOwner.sol@v0.5.1


pragma solidity ^0.8.0;

/**
 * @title The ConfirmedOwner contract
 * @notice A contract with helpers for basic contract ownership.
 */
contract ConfirmedOwner is ConfirmedOwnerWithProposal {
  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}


// File @chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol@v0.5.1


pragma solidity ^0.8.4;

/** ****************************************************************************
 * @notice Interface for contracts using VRF randomness
 * *****************************************************************************
 * @dev PURPOSE
 *
 * @dev Reggie the Random Oracle (not his real job) wants to provide randomness
 * @dev to Vera the verifier in such a way that Vera can be sure he's not
 * @dev making his output up to suit himself. Reggie provides Vera a public key
 * @dev to which he knows the secret key. Each time Vera provides a seed to
 * @dev Reggie, he gives back a value which is computed completely
 * @dev deterministically from the seed and the secret key.
 *
 * @dev Reggie provides a proof by which Vera can verify that the output was
 * @dev correctly computed once Reggie tells it to her, but without that proof,
 * @dev the output is indistinguishable to her from a uniform random sample
 * @dev from the output space.
 *
 * @dev The purpose of this contract is to make it easy for unrelated contracts
 * @dev to talk to Vera the verifier about the work Reggie is doing, to provide
 * @dev simple access to a verifiable source of randomness. It ensures 2 things:
 * @dev 1. The fulfillment came from the VRFCoordinator
 * @dev 2. The consumer contract implements fulfillRandomWords.
 * *****************************************************************************
 * @dev USAGE
 *
 * @dev Calling contracts must inherit from VRFConsumerBase, and can
 * @dev initialize VRFConsumerBase's attributes in their constructor as
 * @dev shown:
 *
 * @dev   contract VRFConsumer {
 * @dev     constructor(<other arguments>, address _vrfCoordinator, address _link)
 * @dev       VRFConsumerBase(_vrfCoordinator) public {
 * @dev         <initialization with other arguments goes here>
 * @dev       }
 * @dev   }
 *
 * @dev The oracle will have given you an ID for the VRF keypair they have
 * @dev committed to (let's call it keyHash). Create subscription, fund it
 * @dev and your consumer contract as a consumer of it (see VRFCoordinatorInterface
 * @dev subscription management functions).
 * @dev Call requestRandomWords(keyHash, subId, minimumRequestConfirmations,
 * @dev callbackGasLimit, numWords),
 * @dev see (VRFCoordinatorInterface for a description of the arguments).
 *
 * @dev Once the VRFCoordinator has received and validated the oracle's response
 * @dev to your request, it will call your contract's fulfillRandomWords method.
 *
 * @dev The randomness argument to fulfillRandomWords is a set of random words
 * @dev generated from your requestId and the blockHash of the request.
 *
 * @dev If your contract could have concurrent requests open, you can use the
 * @dev requestId returned from requestRandomWords to track which response is associated
 * @dev with which randomness request.
 * @dev See "SECURITY CONSIDERATIONS" for principles to keep in mind,
 * @dev if your contract could have multiple requests in flight simultaneously.
 *
 * @dev Colliding `requestId`s are cryptographically impossible as long as seeds
 * @dev differ.
 *
 * *****************************************************************************
 * @dev SECURITY CONSIDERATIONS
 *
 * @dev A method with the ability to call your fulfillRandomness method directly
 * @dev could spoof a VRF response with any random value, so it's critical that
 * @dev it cannot be directly called by anything other than this base contract
 * @dev (specifically, by the VRFConsumerBase.rawFulfillRandomness method).
 *
 * @dev For your users to trust that your contract's random behavior is free
 * @dev from malicious interference, it's best if you can write it so that all
 * @dev behaviors implied by a VRF response are executed *during* your
 * @dev fulfillRandomness method. If your contract must store the response (or
 * @dev anything derived from it) and use it later, you must ensure that any
 * @dev user-significant behavior which depends on that stored value cannot be
 * @dev manipulated by a subsequent VRF request.
 *
 * @dev Similarly, both miners and the VRF oracle itself have some influence
 * @dev over the order in which VRF responses appear on the blockchain, so if
 * @dev your contract could have multiple VRF requests in flight simultaneously,
 * @dev you must ensure that the order in which the VRF responses arrive cannot
 * @dev be used to manipulate your contract's user-significant behavior.
 *
 * @dev Since the block hash of the block which contains the requestRandomness
 * @dev call is mixed into the input to the VRF *last*, a sufficiently powerful
 * @dev miner could, in principle, fork the blockchain to evict the block
 * @dev containing the request, forcing the request to be included in a
 * @dev different block with a different hash, and therefore a different input
 * @dev to the VRF. However, such an attack would incur a substantial economic
 * @dev cost. This cost scales with the number of blocks the VRF oracle waits
 * @dev until it calls responds to a request. It is for this reason that
 * @dev that you can signal to an oracle you'd like them to wait longer before
 * @dev responding to the request (however this is not enforced in the contract
 * @dev and so remains effective only in the case of unmodified oracle software).
 */
abstract contract VRFConsumerBaseV2 {
  error OnlyCoordinatorCanFulfill(address have, address want);
  address private immutable vrfCoordinator;

  /**
   * @param _vrfCoordinator address of VRFCoordinator contract
   */
  constructor(address _vrfCoordinator) {
    vrfCoordinator = _vrfCoordinator;
  }

  /**
   * @notice fulfillRandomness handles the VRF response. Your contract must
   * @notice implement it. See "SECURITY CONSIDERATIONS" above for important
   * @notice principles to keep in mind when implementing your fulfillRandomness
   * @notice method.
   *
   * @dev VRFConsumerBaseV2 expects its subcontracts to have a method with this
   * @dev signature, and will call it once it has verified the proof
   * @dev associated with the randomness. (It is triggered via a call to
   * @dev rawFulfillRandomness, below.)
   *
   * @param requestId The Id initially returned by requestRandomness
   * @param randomWords the VRF output expanded to the requested number of words
   */
  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal virtual;

  // rawFulfillRandomness is called by VRFCoordinator when it receives a valid VRF
  // proof. rawFulfillRandomness then calls fulfillRandomness, after validating
  // the origin of the call
  function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external {
    if (msg.sender != vrfCoordinator) {
      revert OnlyCoordinatorCanFulfill(msg.sender, vrfCoordinator);
    }
    fulfillRandomWords(requestId, randomWords);
  }
}


// File @chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol@v0.5.1


pragma solidity ^0.8.0;

interface VRFCoordinatorV2Interface {
  /**
   * @notice Get configuration relevant for making requests
   * @return minimumRequestConfirmations global min for request confirmations
   * @return maxGasLimit global max for request gas limit
   * @return s_provingKeyHashes list of registered key hashes
   */
  function getRequestConfig()
    external
    view
    returns (
      uint16,
      uint32,
      bytes32[] memory
    );

  /**
   * @notice Request a set of random words.
   * @param keyHash - Corresponds to a particular oracle job which uses
   * that key for generating the VRF proof. Different keyHash's have different gas price
   * ceilings, so you can select a specific one to bound your maximum per request cost.
   * @param subId  - The ID of the VRF subscription. Must be funded
   * with the minimum subscription balance required for the selected keyHash.
   * @param minimumRequestConfirmations - How many blocks you'd like the
   * oracle to wait before responding to the request. See SECURITY CONSIDERATIONS
   * for why you may want to request more. The acceptable range is
   * [minimumRequestBlockConfirmations, 200].
   * @param callbackGasLimit - How much gas you'd like to receive in your
   * fulfillRandomWords callback. Note that gasleft() inside fulfillRandomWords
   * may be slightly less than this amount because of gas used calling the function
   * (argument decoding etc.), so you may need to request slightly more than you expect
   * to have inside fulfillRandomWords. The acceptable range is
   * [0, maxGasLimit]
   * @param numWords - The number of uint256 random values you'd like to receive
   * in your fulfillRandomWords callback. Note these numbers are expanded in a
   * secure way by the VRFCoordinator from a single random value supplied by the oracle.
   * @return requestId - A unique identifier of the request. Can be used to match
   * a request to a response in fulfillRandomWords.
   */
  function requestRandomWords(
    bytes32 keyHash,
    uint64 subId,
    uint16 minimumRequestConfirmations,
    uint32 callbackGasLimit,
    uint32 numWords
  ) external returns (uint256 requestId);

  /**
   * @notice Create a VRF subscription.
   * @return subId - A unique subscription id.
   * @dev You can manage the consumer set dynamically with addConsumer/removeConsumer.
   * @dev Note to fund the subscription, use transferAndCall. For example
   * @dev  LINKTOKEN.transferAndCall(
   * @dev    address(COORDINATOR),
   * @dev    amount,
   * @dev    abi.encode(subId));
   */
  function createSubscription() external returns (uint64 subId);

  /**
   * @notice Get a VRF subscription.
   * @param subId - ID of the subscription
   * @return balance - LINK balance of the subscription in juels.
   * @return reqCount - number of requests for this subscription, determines fee tier.
   * @return owner - owner of the subscription.
   * @return consumers - list of consumer address which are able to use this subscription.
   */
  function getSubscription(uint64 subId)
    external
    view
    returns (
      uint96 balance,
      uint64 reqCount,
      address owner,
      address[] memory consumers
    );

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @param newOwner - proposed new owner of the subscription
   */
  function requestSubscriptionOwnerTransfer(uint64 subId, address newOwner) external;

  /**
   * @notice Request subscription owner transfer.
   * @param subId - ID of the subscription
   * @dev will revert if original owner of subId has
   * not requested that msg.sender become the new owner.
   */
  function acceptSubscriptionOwnerTransfer(uint64 subId) external;

  /**
   * @notice Add a consumer to a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - New consumer which can use the subscription
   */
  function addConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Remove a consumer from a VRF subscription.
   * @param subId - ID of the subscription
   * @param consumer - Consumer to remove from the subscription
   */
  function removeConsumer(uint64 subId, address consumer) external;

  /**
   * @notice Cancel a subscription
   * @param subId - ID of the subscription
   * @param to - Where to send the remaining LINK to
   */
  function cancelSubscription(uint64 subId, address to) external;

  /*
   * @notice Check to see if there exists a request commitment consumers
   * for all consumers and keyhashes for a given sub.
   * @param subId - ID of the subscription
   * @return true if there exists at least one unfulfilled request for the subscription, false
   * otherwise.
   */
  function pendingRequestExists(uint64 subId) external view returns (bool);
}


// File contracts/VRFv2Consumer.sol



pragma solidity >= 0.8.4;
//CONTRACT FOR RANDOMNESS 
//CONTRACT PROVIDED BY CHAINLINK
//ADAPTED FOR FANTOM_TESTNET

contract VRFv2Consumer is VRFConsumerBaseV2, ConfirmedOwner {
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; 
        bool exists; 
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; 
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;

    uint256[] public requestIds;
    uint256 public lastRequestId;
    //keyhash for fantom_testnet hardcoded
    bytes32 keyHash = 0x121a143066e0f2f08b620784af77cccb35c6242460b4a8ee251b4b416abaebd4;
    uint32 callbackGasLimit = 100000;

    uint16 requestConfirmations = 3;

    uint32 numWords = 2;

    /*
    HARDCODED FOR FANTOM_TESTNET
    COORDINATOR: 0xbd13f08b8352A3635218ab9418E340c60d6Eb418
    */
    constructor(uint64 subscriptionId)
        VRFConsumerBaseV2(0xbd13f08b8352A3635218ab9418E340c60d6Eb418)
        ConfirmedOwner(msg.sender)
    {
        COORDINATOR = VRFCoordinatorV2Interface(0xbd13f08b8352A3635218ab9418E340c60d6Eb418);
        s_subscriptionId = subscriptionId;
    }


    function requestRandomWords() external /*onlyOwner*/ returns (uint256 requestId) {

        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false});
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }
}


// File contracts/Voting.sol



pragma solidity >= 0.8.4;
contract Voting {
    
    mapping(address => bool) public membershipStatus;
    address[] public activeMembers;

    string public mainProposal;
    string[] internal proposalList;
    string[] internal proposalPassed;
    string[] internal proposalRejected;

    //Creating an owner for the Contract
    address internal owner;
    constructor() {
        owner = msg.sender;
    }
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
    function setContract(address _addressA) external /*onlyOwner*/ { 
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
