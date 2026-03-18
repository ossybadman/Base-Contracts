// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MessageStorage {
    struct Message {
        address author;
        string text;
        uint256 timestamp;
    }

    Message[] public messages;
    Message public latestMessage;

    event MessageStored(address indexed author, string text, uint256 timestamp);

    // Anyone can store a message
    function setMessage(string memory _text) public {
        require(bytes(_text).length > 0, "Message cannot be empty");
        require(bytes(_text).length <= 280, "Message too long");
        
        Message memory newMsg = Message({
            author: msg.sender,
            text: _text,
            timestamp: block.timestamp
        });

        messages.push(newMsg);
        latestMessage = newMsg;

        emit MessageStored(msg.sender, _text, block.timestamp);
    }

    // Get the latest message
    function getLatestMessage() public view returns (
        address author,
        string memory text,
        uint256 timestamp
    ) {
        require(messages.length > 0, "No messages yet");
        return (latestMessage.author, latestMessage.text, latestMessage.timestamp);
    }

    // Get total message count
    function getMessageCount() public view returns (uint256) {
        return messages.length;
    }

    // Get message by index
    function getMessage(uint256 index) public view returns (
        address author,
        string memory text,
        uint256 timestamp
    ) {
        require(index < messages.length, "Index out of range");
        Message memory m = messages[index];
        return (m.author, m.text, m.timestamp);
    }
}
