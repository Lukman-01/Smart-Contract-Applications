// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract RealEstate {
    using SafeMath for uint256;

    struct Property{
        uint price;
        address owner;
        bool forSale;
        string name;
        string description;
        string location;
    }

    
}
