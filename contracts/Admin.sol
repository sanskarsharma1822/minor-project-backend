//SPDX-License-Identifier: MIT

//with property 24376;
//without erc721uristorage 24376;
//with property 51806;
//23802

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error Admin__UserAlreadyExists();
error Admin__NotAuthorized();

contract Admin is ERC721URIStorage {
    //type declarations

    //state variables

    mapping(address => uint256) private s_addressToEntryToken;
    address private immutable i_owner;
    uint256 private s_entryTokenCounter = 0;
    string private i_initialTokenURI;

    //events

    //modifiers
    modifier notRegistered() {
        _notRegistered();
        _;
    }

    //constructor

    constructor(string memory _initialTokenURI) ERC721("EntryToken", "ETN") {
        //access property, dealtoken status
        i_owner = msg.sender;
        i_initialTokenURI = _initialTokenURI;
    }

    //external

    //public

    function registerUser() public notRegistered {
        s_entryTokenCounter += 1;
        s_addressToEntryToken[msg.sender] = s_entryTokenCounter;
        _safeMint(msg.sender, s_entryTokenCounter);
        _setTokenURI(s_entryTokenCounter, i_initialTokenURI);
    }

    function updateTokenURI(
        string memory _newTokenURI,
        uint256 _entryTokenId
    ) public {
        if (msg.sender != i_owner) {
            revert Admin__NotAuthorized();
        }
        _setTokenURI(_entryTokenId, _newTokenURI);
    }

    //internal

    //private

    function _notRegistered() private view {
        if (s_addressToEntryToken[msg.sender] != 0) {
            revert Admin__UserAlreadyExists();
        }
    }

    //Getter functions

    function getTokenId(address _userAddress) public view returns (uint256) {
        return s_addressToEntryToken[_userAddress];
    }
}
