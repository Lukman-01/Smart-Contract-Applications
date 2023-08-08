// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

/**
 * @title RealEstate
 * @dev A smart contract for managing real estate properties on the Ethereum blockchain.
 */
contract RealEstate {
    using SafeMath for uint256;

    struct Property {
        uint price;
        address owner;
        bool forSale;
        string name;
        string description;
        string location;
    }

    mapping(uint => Property) public properties;
    uint[] public propertyIds;

    event PropertyListed(uint256 propertyId, address owner);
    event PropertySold(uint256 propertyId, address oldOwner, address newOwner);

    modifier onlyOwner(uint256 _id) {
        require(properties[_id].owner == msg.sender, "You are not the owner");
        _;
    }

    modifier propertyExists(uint256 _id) {
        require(properties[_id].owner != address(0), "Property does not exist");
        _;
    }

    modifier propertyForSale(uint256 _id) {
        require(properties[_id].forSale, "Property is not for sale");
        _;
    }

    /**
     * @dev List a new property for sale.
     * @param _id The unique identifier of the property.
     * @param _price The price of the property in Wei (smallest unit of Ether).
     * @param _name The name of the property.
     * @param _description The description of the property.
     * @param _location The location of the property.
     */
    function listPropertyForSale(
        uint _id,
        uint _price,
        string memory _name,
        string memory _description,
        string memory _location
    ) public {

        require(properties[_id].owner == address(0), "Property already exists");

        Property memory newProperty = Property({
            price: _price,
            owner: msg.sender,
            forSale: true,
            name: _name,
            description: _description,
            location: _location
        });

        properties[_id] = newProperty;
        propertyIds.push(_id);

        emit PropertyListed(_id, msg.sender);
    }

    /**
     * @dev Buy a property listed for sale.
     * @param _id The identifier of the property to be bought.
     */
    function buyProperty(uint _id) public payable propertyExists(_id) propertyForSale(_id){
        Property storage property = properties[_id];

        require(property.forSale, "Property not for sale");
        require(property.price <= msg.value, "Insufficient funds");

        address previousOwner = property.owner;
        property.owner = msg.sender;
        property.forSale = false;

        payable(previousOwner).transfer(property.price);

        emit PropertySold(_id);
    }

    function withdrawProperty(uint256 _id) public onlyOwner(_id) propertyExists(_id) {
        Property storage property = properties[_id];

        require(!property.forSale, "Cannot withdraw while property is for sale");

        property.owner = address(0);
        property.forSale = false;

        emit PropertySold(_id, property.owner, address(0));

    }
}
