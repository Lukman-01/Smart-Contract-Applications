// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

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
