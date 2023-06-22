//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error Property__OnlyLandlordAllowed();
error Property__OnlyCurrentTenantAllowed();
error Property__NotVerifiedByLandlord();
error Property__NotEnoughSecurityPaid();
error Property__NotEnoughRentPaid();
error Property__NoRentAvailableToWithdraw();
error Property__TransactionFailed();
error Property__NotAuthorized();
error Property__OnRent();
error Property__TransferNotAllowed();
error Property__OwnerCannotAddReview();
error Property__AgreementNotEnded();
error Property__RentALreadyPaid();
error Property__NotEnoughTimeToGiveWarning();
error Property__RentLeftToBePaid();

contract Property is ERC721URIStorage {
    //type declarations

    //state variables

    uint256 private s_propertyRent;
    uint256 private s_propertySecurity;
    address private immutable i_owner;

    string private s_propertyData;
    address private s_verifiedByLandlord;

    uint256 private s_dealTokenCounter = 0;
    uint256 private s_dueDate;
    uint256 private s_endDate;
    uint256 private s_totalRentToBePaid;

    mapping(address => uint256) private s_addressToDealToken;
    address private s_currentTenant;
    string[] private s_reviews;
    // address[] private s_interestedTenants;

    uint256 private constant ONE_MONTH_THIRTY_DAYS = 2592000;

    //events

    event TenantAdded(
        address indexed _tenantAddress,
        uint256 indexed _dealTokenId
    );
    event RentPaid(uint256 indexed _rentToBePaid, uint256 indexed _dueDate);
    event TenureEnded(
        address indexed _lastTenant,
        uint256 indexed _lastDealToken
    );
    event AppliedInterested(address indexed _interestedTenantAddress);
    event ReviewAdded(address indexed _tenantAddress, string indexed _review);

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
        s_propertyRent = _propertyRent * 1e18;
        s_propertySecurity = _propertySecurity * 1e18;
        i_owner = _owner;
        s_currentTenant = _owner;
        s_verifiedByLandlord = _owner;
    }

    //external

    //public

    //no check for people with only entry token to work
    //make all transfers and approves null
    // retrieve and fallback

    // should contain amount paid by dates with status
    //is verified by owner correct

    //dealtoken has a reputation, that can be affected if rent is not paid on time //////////////

    //start date and end date in dealtoken
    //due date, duration and end date in contract
    //use propertyfactory money to update dealtoken
    // add available or not available status in property contract

    function addTenant(
        string calldata _newTokenURI,
        uint256 _dueDate,
        uint256 _endDate,
        uint256 _duration
    ) public payable notOnRent {
        if (s_verifiedByLandlord != msg.sender) {
            revert Property__NotVerifiedByLandlord();
        }
        if (msg.value < s_propertySecurity) {
            revert Property__NotEnoughSecurityPaid();
        }
        s_verifiedByLandlord = i_owner;
        s_dealTokenCounter += 1;

        s_addressToDealToken[msg.sender] = s_dealTokenCounter;
        s_currentTenant = msg.sender;

        s_dueDate = _dueDate;
        s_endDate = _endDate;
        s_totalRentToBePaid = s_propertyRent * _duration;

        _safeMint(msg.sender, s_dealTokenCounter);
        _setTokenURI(s_dealTokenCounter, _newTokenURI);
        emit TenantAdded(msg.sender, s_dealTokenCounter);
    }

    function payRent() public payable onlyCurrentTenant {
        //absolute value of rent
        if (msg.value != s_propertyRent) {
            revert Property__NotEnoughRentPaid();
        }
        if (s_totalRentToBePaid == 0) {
            revert Property__RentALreadyPaid();
        }
        s_totalRentToBePaid -= s_propertyRent;
        s_dueDate += ONE_MONTH_THIRTY_DAYS;

        emit RentPaid(s_totalRentToBePaid, s_dueDate);
    }

    function withdrawMonthRent() public onlyLandlord {
        if (address(this).balance < s_propertyRent + s_propertySecurity) {
            revert Property__NoRentAvailableToWithdraw();
        }
        (bool success, ) = payable(msg.sender).call{value: s_propertyRent}("");
        if (!success) {
            revert Property__TransactionFailed();
        }
    }

    function endTenantTime() public {
        // can be closed anytime by current tenant
        if (msg.sender != s_currentTenant || msg.sender != i_owner) {
            //check better way
            revert Property__NotAuthorized();
        }
        if (block.timestamp <= s_endDate) {
            revert Property__AgreementNotEnded();
        }
        if (s_totalRentToBePaid > 0) {
            revert Property__RentLeftToBePaid();
        }
        address temp_currentTenant = s_currentTenant;
        s_currentTenant = i_owner;
        (bool success, ) = payable(temp_currentTenant).call{
            value: s_propertySecurity
        }("");
        if (!success) {
            revert Property__TransactionFailed();
        }
        emit TenureEnded(temp_currentTenant, s_dealTokenCounter);
    }

    function giveWarning(string calldata _newDealTokenURI) public onlyLandlord {
        // if (block.timestamp < s_dueDate) {
        //     revert Property__NotEnoughTimeToGiveWarning();
        // }
        _setTokenURI(s_dealTokenCounter, _newDealTokenURI);
    }

    function giveReviewToProperty(
        string calldata _newReview
    ) public onlyCurrentTenant {
        if (msg.sender == i_owner) {
            revert Property__OwnerCannotAddReview();
        }
        s_reviews.push(_newReview);
        emit ReviewAdded(msg.sender, _newReview);
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

    //this will use tenant's money to apply interested, which is not good ux
    function applyInterested() public notOnRent {
        // s_interestedTenants.push(msg.sender);
        emit AppliedInterested(msg.sender);
    }

    function verifiedByLandlord(
        address _proposedTenantAddress
    ) public onlyLandlord {
        s_verifiedByLandlord = _proposedTenantAddress;
        // s_interestedTenants = new address[](0);
    }

    function updateRent(uint256 _newRent) public onlyLandlord {
        s_propertyRent = _newRent;
    }

    function updateSecurity(uint256 _newSecurity) public onlyLandlord {
        s_propertySecurity = _newSecurity;
    }

    function updatePropertyData(string calldata _newURI) public onlyLandlord {
        s_propertyData = _newURI;
    }

    function updateTokenURI(
        string calldata _newTokenURI,
        uint256 _dealTokenId
    ) public {
        if (msg.sender != i_owner) {
            revert Property__NotAuthorized();
        }
        _setTokenURI(_dealTokenId, _newTokenURI);
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
        return s_propertyRent;
    }

    function getSecurity() public view returns (uint256) {
        return s_propertySecurity;
    }

    function getLandlord() public view returns (address) {
        return i_owner;
    }

    function getPropertyData() public view returns (string memory) {
        return s_propertyData;
    }

    function getAddressVerifiedByOwner() public view returns (address) {
        return s_verifiedByLandlord;
    }

    function getDueDate() public view returns (uint256) {
        return s_dueDate;
    }

    function getEndDate() public view returns (uint256) {
        return s_endDate;
    }

    function getTotalRentLeftToBePaid() public view returns (uint256) {
        return s_totalRentToBePaid;
    }

    function getDealToken(address _address) public view returns (uint256) {
        return s_addressToDealToken[_address];
    }

    function getCurrentTenant() public view returns (address) {
        return s_currentTenant;
    }

    function getNoOfReviews() public view returns (uint256) {
        return s_reviews.length;
    }

    function getReview(uint256 _index) public view returns (string memory) {
        return s_reviews[_index];
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // function getNoOfInterestedTenants() public view returns (uint256){
    //     return s_interestedTenants.length;
    // }

    // function getInterestedTenant(uint256 _index) public view returns(address){
    //     return s_interestedTenants[_index];
    // }
}

contract PropertyFactory {
    // address[] private s_totalProperties;
    // mapping(address => address[]) public s_ownerToProperties;

    event PropertyListed(
        address indexed _ownerAddress,
        Property indexed _propertyAddress,
        string indexed _propertyData
    );

    function listProperty(
        string calldata _propertyData,
        uint256 _propertyRent,
        uint256 _propertySecurity
    ) public {
        Property _newPropertyAddress = new Property(
            _propertyData,
            _propertyRent,
            _propertySecurity,
            msg.sender
        );
        emit PropertyListed(msg.sender, _newPropertyAddress, _propertyData);
    }

    //Getter Functions

    // function getPropertyAddress(uint256 _index) public view returns (Property) {
    //     return (s_totalProperties[_index]);
    // }

    // // function getOwnedProperties (address _address, uint256 _index) public view returns(Property){
    // //     return s_ownerToProperties[_address][_index];
    // // }

    // function getNoOfProperties() public view returns (uint256) {
    //     return s_totalProperties.length;
    // }

    // function getNoOfPropertiesOwned(address _address) public view returns(uint256){
    //     return (s_ownerToProperties[_address]).length;
    // }
}

//with new modifiers : 25552
//with give warning  : 29212

//Deployer - 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
//Landlord - 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Tenant - 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
//Not Authorized - 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
