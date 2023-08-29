const { expect } = require('chai');
const { ethers } = require("hardhat");

describe('ModernSocialMedia', function () {
  let ModernSocialMedia;
  let modernSocialMedia;
  let owner;
  let user1;
  let user2;
  let user3;

  beforeEach(async function () {
    [owner, user1, user2, user3] = await ethers.getSigners();

    ModernSocialMedia = await ethers.getContractFactory('ModernSocialMedia');
    modernSocialMedia = await ModernSocialMedia.deploy();
    await modernSocialMedia.deployed();

    await modernSocialMedia.connect(user1).createUser('User1', 'Bio1', 'ProfilePic1');
    await modernSocialMedia.connect(user2).createUser('User2', 'Bio2', 'ProfilePic2');
    await modernSocialMedia.connect(user3).createUser('User3', 'Bio3', 'ProfilePic3');
  });

  it('should create a user profile', async function () {
    const user = await modernSocialMedia.users(user1.address);
    expect(user.name).to.equal('User1');
    expect(user.bio).to.equal('Bio1');
    expect(user.profilePicture).to.equal('ProfilePic1');
  });

  it('should create a post', async function () {
    await modernSocialMedia.connect(user1).createPost('Hello, world!');
    const post = await modernSocialMedia.users(user1.address).posts(0);
    expect(post.content).to.equal('Hello, world!');
  });

  it('should add a comment to a post', async function () {
    await modernSocialMedia.connect(user1).createPost('Post to comment on');
    await modernSocialMedia.connect(user2).addComment(0, 'Nice post!');
    const comment = await modernSocialMedia.users(user2.address).postComments(0, 0);
    expect(comment.content).to.equal('Nice post!');
  });

  it('should like a post', async function () {
    await modernSocialMedia.connect(user1).createPost('Awesome post!');
    await modernSocialMedia.connect(user2).likePost(user1.address, 0);
    const post = await modernSocialMedia.users(user1.address).posts(0);
    expect(post.likes).to.equal(1);
  });

  it('should follow and unfollow a user', async function () {
    await modernSocialMedia.connect(user1).followUser(user2.address);
    expect(await modernSocialMedia.users(user1.address).followers(user2.address)).to.be.true;

    await modernSocialMedia.connect(user1).unfollowUser(user2.address);
    expect(await modernSocialMedia.users(user1.address).followers(user2.address)).to.be.false;
  });

  it('should update user profile information', async function () {
    await modernSocialMedia.connect(user1).updateProfile('NewName', 'NewBio', 'NewProfilePic');
    const user = await modernSocialMedia.users(user1.address);
    expect(user.name).to.equal('NewName');
    expect(user.bio).to.equal('NewBio');
    expect(user.profilePicture).to.equal('NewProfilePic');
  });

  it('should send a private message', async function () {
    await modernSocialMedia.connect(user1).sendMessage(user2.address, 'Hello, user2!');
    const message = await modernSocialMedia.users(user1.address).messages(0);
    expect(message.content).to.equal('Hello, user2!');
  });

});
