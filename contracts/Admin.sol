//SPDX-License-Identifier: MIT

//with property 24376;
//without erc721uristorage 24376;
//with property 51806;
//23802

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error Test__UserAlreadyExists();
// error Test__UserNotFound();
error Test__NotAuthorized();

contract Test is ERC721URIStorage {
    //type declarations

    //state variables

    address private immutable i_owner;

    mapping(address => uint256) private s_addressToEntryToken;

    uint256 private s_entryTokenCounter = 0;

    string private constant INITIAL_TOKEN_URI =
        "https://ipfs.io/ipfs/QmZ7qzYAQh342RfvX2FbU68HoxjSvUGtC3mw1ucM4FwY6P?filename=testEntryURI.json"; //reputation = 0 ; properties owned = 0 ; dealtokens = 0 ; warnings = 0;

    //events

    //modifiers
    modifier notRegistered() {
        _notRegistered();
        _;
    }

    //constructor

    constructor() ERC721("EntryToken", "ETN") {
        //access property, dealtoken status
        i_owner = msg.sender;
    }

    //external

    //public

    function registerUser() public notRegistered {
        s_entryTokenCounter += 1;
        s_addressToEntryToken[msg.sender] = s_entryTokenCounter;
        _safeMint(msg.sender, s_entryTokenCounter);
        _setTokenURI(s_entryTokenCounter, INITIAL_TOKEN_URI);
    }

    //onlyowner
    function updateTokenURI(
        string memory _newTokenURI,
        uint256 _entryTokenId
    ) public {
        if (msg.sender != i_owner) {
            revert Test__NotAuthorized();
        }
        _setTokenURI(_entryTokenId, _newTokenURI);
    }

    //internal

    //private

    function _notRegistered() private view {
        if (s_addressToEntryToken[msg.sender] != 0) {
            revert Test__UserAlreadyExists();
        }
    }

    //Getter functions

    function getTokenId(address _userAddress) public view returns (uint256) {
        return s_addressToEntryToken[_userAddress];
    }
}
