//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error Property__OnlyLandlordAllowed();
error Property__OnlyCurrentTenantAllowed();
error Property__NotVerifiedByLandlord();
error Property__TenantAlreadyOccupied();
error Property__NotEnoughSecurityPaid();
error Property__NotEnoughRentPaid();
error Property__NoRentAvailableToWithdraw();
error Property__TransactionFailed();
error Property__NotAuthorized();
error Property__OnRent();
error Property__TransferNotAllowed();

contract Property is ERC721URIStorage {
    //type declarations

    //state variables

    uint256 private immutable i_propertyRent;
    uint256 private immutable i_propertySecurity;
    address private immutable i_owner;

    string private s_propertyData;
    bool private s_verifiedByLandlord = false;
    bool private s_verifiedByTenant = false;

    uint256 private s_dealTokenCounter = 0;

    mapping(address => uint256) private s_addressToDealToken;
    address[] private s_listOfTenants;
    address private s_currentTenant;

    //events

    //modifiers

    modifier onlyLandlord() {
        _onlyLandlord();
        _;
    }

    modifier notOnRent() {
        _onRent();
        _;
    }

    modifier onlyCurrentTenant() {
        _onlyCurrentTenant();
        _;
    }

    //constructor

    constructor(
        string memory _propertyData,
        uint256 _propertyRent,
        uint256 _propertySecurity,
        address _owner
    ) ERC721("DealToken", "DTN") {
        s_propertyData = _propertyData;
        i_propertyRent = _propertyRent * 1e18;
        i_propertySecurity = _propertySecurity * 1e18;
        i_owner = _owner;
        s_currentTenant = _owner;
    }

    //external

    //public

    //no check for people with only entry token to work
    //make all transfers and approves null
    // retrieve and fallback

    // should contain amount paid by dates with status
    //is verified by owner correct

    function addTenant(
        string memory _newTokenURI
    ) public payable notOnRent returns (bool) {
        if (!s_verifiedByLandlord) {
            revert Property__NotVerifiedByLandlord();
        }
        if (msg.value < i_propertySecurity) {
            revert Property__NotEnoughSecurityPaid();
        }
        s_verifiedByLandlord = false;
        s_dealTokenCounter += 1;
        s_addressToDealToken[msg.sender] = s_dealTokenCounter;
        s_listOfTenants.push(msg.sender);
        s_currentTenant = msg.sender;
        _safeMint(msg.sender, s_dealTokenCounter);
        _setTokenURI(s_dealTokenCounter, _newTokenURI);
        return true;
    }

    function payRent() public payable onlyCurrentTenant {
        //absolute value of rent
        if (msg.value < i_propertyRent) {
            revert Property__NotEnoughRentPaid();
        }
    }

    function withdrawMonthRent() public onlyLandlord {
        if (address(this).balance < i_propertyRent + i_propertySecurity) {
            revert Property__NoRentAvailableToWithdraw();
        }
        (bool success, ) = payable(msg.sender).call{value: i_propertyRent}("");
        if (!success) {
            revert Property__TransactionFailed();
        }
    }

    function endTenantTime() public returns (bool) {
        // can be closed anytime by current tenant
        if (msg.sender != s_currentTenant && msg.sender != i_owner) {
            //check better way
            revert Property__NotAuthorized();
        }
        address temp_currentTenant = s_currentTenant;
        s_currentTenant = i_owner;
        (bool success, ) = payable(temp_currentTenant).call{
            value: i_propertySecurity
        }("");
        if (!success) {
            revert Property__TransactionFailed();
        }
        return true; // change user entryToken
    }

    function giveWarning(string memory _newDealTokenURI) public onlyLandlord {
        _setTokenURI(s_dealTokenCounter, _newDealTokenURI);
    }

    function giveReviewToProperty(
        string memory _newPropertyData
    ) public onlyCurrentTenant {
        s_propertyData = _newPropertyData;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override {
        revert Property__TransferNotAllowed();
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override {
        revert Property__TransferNotAllowed();
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) public pure override {
        revert Property__TransferNotAllowed();
    }

    function verifiedByLandlord() public onlyLandlord {
        s_verifiedByLandlord = true;
    }

    //internal

    //private
    function _onlyLandlord() private view {
        if (msg.sender != i_owner) {
            revert Property__OnlyLandlordAllowed();
        }
    }

    function _onlyCurrentTenant() private view {
        if (msg.sender != s_currentTenant) {
            revert Property__OnlyCurrentTenantAllowed();
        }
    }

    function _onRent() private view {
        if (s_currentTenant != i_owner) {
            revert Property__OnRent();
        }
    }

    // function verifiedByTenant() private{
    //     s_verifiedByTenant = true;
    // }

    //Getter functions

    function getRent() public view returns (uint256) {
        return i_propertyRent;
    }

    function getSecurity() public view returns (uint256) {
        return i_propertySecurity;
    }

    function getLandlord() public view returns (address) {
        return i_owner;
    }

    function getPropertyData() public view returns (string memory) {
        return s_propertyData;
    }

    function getCurrentTenant() public view returns (address) {
        return s_currentTenant;
    }

    function getTenant(uint256 _index) public view returns (address) {
        return s_listOfTenants[_index];
    }
}

contract PropertyFactory {
    Property[] private s_totalProperties;

    function listProperty(
        string memory _propertyData,
        uint256 _propertyRent,
        uint256 _propertySecurity
    ) public {
        Property _newPropertyAddress = new Property(
            _propertyData,
            _propertyRent,
            _propertySecurity,
            msg.sender
        );
        s_totalProperties.push(_newPropertyAddress);
    }

    //Getter Functions

    function getPropertyAddress(uint256 _index) public view returns (Property) {
        return (s_totalProperties[_index]);
    }

    function getNoOfProperties() public view returns (uint256) {
        return s_totalProperties.length;
    }
}

//with new modifiers : 25552
//with give warning  : 29212

//Deployer - 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Landlord - 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Tenant - 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
//Not Authorized - 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
