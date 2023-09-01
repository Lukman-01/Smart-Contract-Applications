const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Voting Contract', function () {
  let Voting;
  let voting;
  let owner;
  let candidateAddress;
  let voterAddress;

  beforeEach(async function () {
    [owner] = await ethers.getSigners();
    Voting = await ethers.getContractFactory('Voting');
    voting = await Voting.deploy();
    await voting.deployed();
    candidateAddress = 'YOUR_CANDIDATE_ETHEREUM_ADDRESS';
    voterAddress = 'YOUR_VOTER_ETHEREUM_ADDRESS';
  });

  it('Should allow the owner to register a candidate', async function () {
    await voting.connect(owner).setCandidate(
      candidateAddress,
      'John Doe',
      '35',
      'https://image-url.com/johndoe.jpg',
      'Qm...'
    );
    const candidate = await voting.candidates(candidateAddress);
    expect(candidate.name).to.equal('John Doe');
  });

  it('Should allow the owner to register a voter', async function () {
    await voting.connect(owner).voterRight(
      voterAddress,
      'Alice Smith',
      'https://image-url.com/alicesmith.jpg',
      'Qm...'
    );
    const voter = await voting.voters(voterAddress);
    expect(voter.name).to.equal('Alice Smith');
  });

  it('Should allow a registered voter to cast a vote', async function () {
    await voting.connect(owner).setCandidate(
      candidateAddress,
      'John Doe',
      '35',
      'https://image-url.com/johndoe.jpg',
      'Qm...'
    );
    await voting.connect(owner).voterRight(
      voterAddress,
      'Alice Smith',
      'https://image-url.com/alicesmith.jpg',
      'Qm...'
    );

    await voting.vote(candidateAddress, 1);

    const candidate = await voting.candidates(candidateAddress);
    const voter = await voting.voters(voterAddress);

    expect(candidate.voteCount).to.equal(1);
    expect(voter.voted).to.equal(true);
  });

  it('Should prevent non-owner from registering a candidate', async function () {
    const [nonOwner] = await ethers.getSigners();

    await expect(
      voting.connect(nonOwner).setCandidate(
        candidateAddress,
        'John Doe',
        '35',
        'https://image-url.com/johndoe.jpg',
        'Qm...'
      )
    ).to.be.revertedWith('Ownable: caller is not the owner');
  });

  it('Should prevent non-owner from registering a voter', async function () {
    const [nonOwner] = await ethers.getSigners();

    await expect(
      voting.connect(nonOwner).voterRight(
        voterAddress,
        'Alice Smith',
        'https://image-url.com/alicesmith.jpg',
        'Qm...'
      )
    ).to.be.revertedWith('Ownable: caller is not the owner');
  });

  it('Should prevent a voter from voting twice', async function () {
    await voting.connect(owner).setCandidate(
      candidateAddress,
      'John Doe',
      '35',
      'https://image-url.com/johndoe.jpg',
      'Qm...'
    );
    await voting.connect(owner).voterRight(
      voterAddress,
      'Alice Smith',
      'https://image-url.com/alicesmith.jpg',
      'Qm...'
    );

    await voting.vote(candidateAddress, 1);

    await expect(
      voting.connect(owner).vote(candidateAddress, 1)
    ).to.be.revertedWith('You have already voted');
  });

  it('Should prevent a voter from voting for a non-existent candidate', async function () {
    await voting.connect(owner).voterRight(
      voterAddress,
      'Alice Smith',
      'https://image-url.com/alicesmith.jpg',
      'Qm...'
    );

    await expect(
      voting.connect(owner).vote(candidateAddress, 1)
    ).to.be.revertedWith('Candidate not found');
  });

  it('Should prevent a voter from voting for an invalid candidate ID', async function () {
    await voting.connect(owner).setCandidate(
      candidateAddress,
      'John Doe',
      '35',
      'https://image-url.com/johndoe.jpg',
      'Qm...'
    );
    await voting.connect(owner).voterRight(
      voterAddress,
      'Alice Smith',
      'https://image-url.com/alicesmith.jpg',
      'Qm...'
    );

    await expect(
      voting.connect(owner).vote(candidateAddress, 2)
    ).to.be.revertedWith('Invalid candidate ID');
  });

});
