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

    event PropertySold(uint propertyId);

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
    }

    /**
     * @dev Buy a property listed for sale.
     * @param _id The identifier of the property to be bought.
     */
    function buyProperty(uint _id) public payable {
        Property storage property = properties[_id];

        require(property.forSale, "Property not for sale");
        require(property.price <= msg.value, "Insufficient funds");

        address previousOwner = property.owner;
        property.owner = msg.sender;
        property.forSale = false;

        payable(previousOwner).transfer(property.price);

        emit PropertySold(_id);
    }
}
