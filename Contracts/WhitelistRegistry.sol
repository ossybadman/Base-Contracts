// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract WhitelistRegistry {
    struct Whitelist {
        address creator;
        string name;
        string description;
        uint256 maxSpots;
        uint256 spotsUsed;
        bool isOpen;
        uint256 createdAt;
    }

    uint256 public whitelistCount;
    mapping(uint256 => Whitelist) public whitelists;
    mapping(uint256 => mapping(address => bool)) public isWhitelisted;
    mapping(uint256 => address[]) private members;
    mapping(address => uint256[]) public creatorWhitelists;
    mapping(address => uint256[]) public registrantWhitelists;

    event WhitelistCreated(uint256 indexed id, address indexed creator, string name, uint256 maxSpots);
    event Registered(uint256 indexed id, address indexed registrant, uint256 spotsRemaining);
    event WhitelistClosed(uint256 indexed id);
    event WhitelistOpened(uint256 indexed id);
    event MemberRemoved(uint256 indexed id, address indexed member);

    function createWhitelist(
        string calldata name,
        string calldata description,
        uint256 maxSpots
    ) external returns (uint256) {
        require(bytes(name).length > 0, "Name required");
        require(bytes(name).length <= 100, "Name too long");
        require(maxSpots > 0 && maxSpots <= 10000, "Max spots must be 1-10000");

        whitelistCount++;
        whitelists[whitelistCount] = Whitelist({
            creator: msg.sender,
            name: name,
            description: description,
            maxSpots: maxSpots,
            spotsUsed: 0,
            isOpen: true,
            createdAt: block.timestamp
        });

        creatorWhitelists[msg.sender].push(whitelistCount);
        emit WhitelistCreated(whitelistCount, msg.sender, name, maxSpots);
        return whitelistCount;
    }

    function register(uint256 whitelistId) external {
        Whitelist storage w = whitelists[whitelistId];
        require(w.creator != address(0), "Whitelist does not exist");
        require(w.isOpen, "Whitelist is closed");
        require(w.spotsUsed < w.maxSpots, "Whitelist is full");
        require(!isWhitelisted[whitelistId][msg.sender], "Already registered");

        isWhitelisted[whitelistId][msg.sender] = true;
        members[whitelistId].push(msg.sender);
        w.spotsUsed++;
        registrantWhitelists[msg.sender].push(whitelistId);

        emit Registered(whitelistId, msg.sender, w.maxSpots - w.spotsUsed);
    }

    function setOpen(uint256 whitelistId, bool open) external {
        require(whitelists[whitelistId].creator == msg.sender, "Not creator");
        whitelists[whitelistId].isOpen = open;
        if (open) emit WhitelistOpened(whitelistId);
        else emit WhitelistClosed(whitelistId);
    }

    function removeMember(uint256 whitelistId, address member) external {
        require(whitelists[whitelistId].creator == msg.sender, "Not creator");
        require(isWhitelisted[whitelistId][member], "Not a member");
        isWhitelisted[whitelistId][member] = false;
        whitelists[whitelistId].spotsUsed--;
        emit MemberRemoved(whitelistId, member);
    }

    function getMembers(uint256 whitelistId) external view returns (address[] memory) {
        return members[whitelistId];
    }

    function spotsRemaining(uint256 whitelistId) external view returns (uint256) {
        Whitelist memory w = whitelists[whitelistId];
        return w.maxSpots - w.spotsUsed;
    }

    function checkWhitelisted(uint256 whitelistId, address addr) external view returns (bool) {
        return isWhitelisted[whitelistId][addr];
    }

    function getCreatorWhitelists(address creator) external view returns (uint256[] memory) {
        return creatorWhitelists[creator];
    }

    function getRegistrantWhitelists(address registrant) external view returns (uint256[] memory) {
        return registrantWhitelists[registrant];
    }

    function getWhitelist(uint256 whitelistId) external view returns (
        address creator,
        string memory name,
        string memory description,
        uint256 maxSpots,
        uint256 spotsUsed,
        bool isOpen,
        uint256 createdAt
    ) {
        Whitelist memory w = whitelists[whitelistId];
        return (w.creator, w.name, w.description, w.maxSpots, w.spotsUsed, w.isOpen, w.createdAt);
    }
}
