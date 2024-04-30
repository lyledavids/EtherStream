// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Combined contract for creating and managing token streams
contract TokenStream {
    address payable public owner;

    event StreamCreated(address indexed sender, address streamContract);

    // Mapping to track active streaming contracts
    mapping(address => bool) public isStreamContract;

    // Modifier to restrict access to owner-only functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    // Struct to store stream details
    struct Stream {
        uint256 startTime;
        uint256 amount;
        uint256 duration;
    }

    // Mapping to store stream details by contract address
    mapping(address => Stream) public streams;

    // Function to create a new streaming contract
    function createStream(address payable _recipient, uint256 _duration) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        // Set stream parameters
        streams[msg.sender] = Stream({
            startTime: block.timestamp,
            amount: msg.value,
            duration: _duration
        });

        // Transfer initial Ether to the recipient
        _recipient.transfer(msg.value);

        emit StreamCreated(msg.sender, address(this));
    }

    // Function to claim tokens from the stream
    function claim() external {
        Stream storage stream = streams[msg.sender];
        
        require(stream.startTime > 0, "No active stream found");
        require(block.timestamp >= stream.startTime, "Stream has not started yet");
        require(block.timestamp < stream.startTime + stream.duration, "Stream has ended");
        
        // Calculate the amount of Ether to transfer based on time elapsed
        uint256 elapsedTime = block.timestamp - stream.startTime;
        uint256 tokensToTransfer = (elapsedTime * stream.amount) / stream.duration;
        
        // Ensure the contract has sufficient balance
        require(address(this).balance >= tokensToTransfer, "Insufficient balance");

        // Transfer Ether to the caller
        payable(msg.sender).transfer(tokensToTransfer);
    }
}
