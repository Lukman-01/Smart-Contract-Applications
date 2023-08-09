import { ethers } from 'hardhat';
import { expect } from 'chai';

describe('RealEstate', function () {
  let realEstate;
  let owner;
  let buyer;

  before(async function () {
    [owner, buyer] = await ethers.getSigners();

    const RealEstate = await ethers.getContractFactory('RealEstate');
    realEstate = await RealEstate.deploy();
    await realEstate.deployed();
  });

  it('should list a property for sale', async function () {
    const propertyId = 1;
    const price = ethers.utils.parseEther('1');
    const name = 'Property 1';
    const description = 'A nice property';
    const location = 'Somewhere';

    await realEstate.listPropertyForSale(propertyId, price, name, description, location);

    const property = await realEstate.properties(propertyId);
    expect(property.price).to.equal(price);
    expect(property.owner).to.equal(owner.address);
    expect(property.forSale).to.equal(true);
    expect(property.name).to.equal(name);
    expect(property.description).to.equal(description);
    expect(property.location).to.equal(location);
  });

  it('should allow buying a property', async function () {
    const propertyId = 1;
    const property = await realEstate.properties(propertyId);
    const initialOwnerBalance = await owner.getBalance();
    const initialBuyerBalance = await buyer.getBalance();

    await expect(() => buyer.sendTransaction({ to: realEstate.address, value: property.price }))
      .to.changeEtherBalances([owner, buyer], [property.price, -property.price]);

    const newProperty = await realEstate.properties(propertyId);
    expect(newProperty.owner).to.equal(buyer.address);
    expect(newProperty.forSale).to.equal(false);

    expect(await owner.getBalance()).to.equal(initialOwnerBalance.add(property.price));
    expect(await buyer.getBalance()).to.be.at.most(initialBuyerBalance.sub(property.price));
  });

  it('should withdraw a property from sale', async function () {
    const propertyId = 1;
    await expect(realEstate.withdrawProperty(propertyId))
      .to.emit(realEstate, 'PropertyWithdrawn')
      .withArgs(propertyId, owner.address);

    const property = await realEstate.properties(propertyId);
    expect(property.owner).to.equal(ethers.constants.AddressZero);
    expect(property.forSale).to.equal(false);
  });
});
