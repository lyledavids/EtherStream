// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenStream {
    address payable public owner;

    event StreamCreated(address indexed sender, address streamContract);

    struct Stream {
        uint256 startTime;
        uint256 amount;
        uint256 duration;
    }

    mapping(address => Stream) public streams;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    constructor() {
        owner = payable(msg.sender);
    }

    function createStream(address payable _recipient, uint256 _duration) external payable {
        require(msg.value > 0, "Amount must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        streams[msg.sender] = Stream({
            startTime: block.timestamp,
            amount: msg.value,
            duration: _duration
        });

        _recipient.transfer(msg.value);

        emit StreamCreated(msg.sender, address(this));
    }

    function claim() external {
        Stream storage stream = streams[msg.sender];
        
        require(stream.startTime > 0, "No active stream found");
        require(block.timestamp >= stream.startTime, "Stream has not started yet");
        require(block.timestamp < stream.startTime + stream.duration, "Stream has ended");
        
        uint256 elapsedTime = block.timestamp - stream.startTime;
        uint256 tokensToTransfer = (elapsedTime * stream.amount) / stream.duration;
        
        require(address(this).balance >= tokensToTransfer, "Insufficient balance");

        payable(msg.sender).transfer(tokensToTransfer);
    }
}
