// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error Lottery__NotEnoughETHEntered();
error Lottery__TransferFailed();

contract Lottery is VRFConsumerBaseV2 {
    uint256 private immutable _entranceFee;
    address payable[] private _players;

    /**
     * Chainlink state variables
     */
    VRFCoordinatorV2Interface private immutable _vrfCoordinatorV2;
    bytes32 private immutable _gasLane; //  the maximum gas price you are willing to pay for a request in wei.
    uint64 private immutable _subscriptionId;
    uint32 private immutable _callbackGasLimit; // gas limit to use for the callback request to your contract's fullfillRandomWords()
    
    // Number of confirmations the chainlink nodes should wait before responding. 
    // The longest the node waits, the most secure the random value is.
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1; // number of random numbers we want to generate

    /**
     * Lottery variables    
     */
     address private _recentWinner;


    event LotteryEntered(address indexed player);
    event RequestedLotteryWinner(uint256 indexed requestId);
    event WinnerPicked(address indexed winner);

    constructor(
        address vrfCoordinatorV2,
        uint256 entranceFee,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinatorV2) {
        _entranceFee = entranceFee;
        _vrfCoordinatorV2 = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        _gasLane = gasLane;
        _subscriptionId = subscriptionId;
        _callbackGasLimit = callbackGasLimit;
    }

    function enterLottery() external payable {
        if (msg.value > _entranceFee) {
            revert Lottery__NotEnoughETHEntered();
        }
        _players.push(payable(msg.sender));

        emit LotteryEntered(msg.sender);
    }

    /**
    * Request the random number
    */
    function requestRandomWinner() external {
        uint256 requestId = _vrfCoordinatorV2.requestRandomWords(
            _gasLane,
            _subscriptionId,
            REQUEST_CONFIRMATIONS,
            _callbackGasLimit,
            NUM_WORDS
        );
        emit RequestedLotteryWinner(requestId);
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] memory randomWords
    ) internal override {
        uint256 indexOfWinner = randomWords[0] % _players.length;
        _recentWinner = _players[indexOfWinner];
        (bool success, ) = _recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Lottery__TransferFailed();
        }
        emit WinnerPicked(_recentWinner);
    }

    function getEntranceFee() external view returns (uint256) {
        return _entranceFee;
    }

    function getPlayer(uint256 index) external view returns (address) {
        return _players[index];
    }
}
