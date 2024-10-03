const { expect } = require("chai");

describe("ModernSocialMedia", function () {
  let ModernSocialMedia;
  let modernSocialMedia;
  let owner; // The account that deploys the contract
  let user1;
  let user2;

  beforeEach(async function () {
    ModernSocialMedia = await ethers.getContractFactory("ModernSocialMedia");
    [owner, user1, user2] = await ethers.getSigners();
    modernSocialMedia = await ModernSocialMedia.deploy();
    await modernSocialMedia.deployed();
  });

  it("Should create a user profile", async function () {
    const name = "Alice";
    const bio = "Hello, I'm Alice!";
    const profilePicture = "ipfs_hash_or_url";

    await modernSocialMedia.connect(user1).createUser(name, bio, profilePicture);

    const user = await modernSocialMedia.users(user1.address);

    expect(user.name).to.equal(name);
    expect(user.bio).to.equal(bio);
    expect(user.profilePicture).to.equal(profilePicture);
  });

  it("Should create a post", async function () {
    const content = "My first post!";

    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");
    await modernSocialMedia.connect(user1).createPost(content);

    const user = await modernSocialMedia.users(user1.address);
    const post = user.posts[0];

    expect(post.content).to.equal(content);
    expect(post.likes).to.equal(0);
  });

  it("Should add a comment to a post", async function () {
    const postContent = "My post";
    const commentContent = "Nice post!";

    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");
    await modernSocialMedia.connect(user1).createPost(postContent);
    await modernSocialMedia.connect(user2).addComment(0, commentContent);

    const user = await modernSocialMedia.users(user2.address);
    const comment = user.postComments[0][0];

    expect(comment.content).to.equal(commentContent);
  });

  it("Should like a post", async function () {
    const postContent = "My post";

    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");
    await modernSocialMedia.connect(user1).createPost(postContent);
    await modernSocialMedia.connect(user2).likePost(user1.address, 0);

    const user = await modernSocialMedia.users(user1.address);
    const post = user.posts[0];

    expect(post.likes).to.equal(1);
  });

  it("Should follow and unfollow a user", async function () {
    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");
    await modernSocialMedia.connect(user2).createUser("Bob", "Hello, I'm Bob!", "ipfs_hash_or_url");

    await modernSocialMedia.connect(user1).followUser(user2.address);

    let alice = await modernSocialMedia.users(user1.address);
    let bob = await modernSocialMedia.users(user2.address);

    expect(alice.followers[user2.address]).to.equal(true);
    expect(bob.followers[user1.address]).to.equal(true);

    await modernSocialMedia.connect(user1).unfollowUser(user2.address);

    alice = await modernSocialMedia.users(user1.address);
    bob = await modernSocialMedia.users(user2.address);

    expect(alice.followers[user2.address]).to.equal(false);
    expect(bob.followers[user1.address]).to.equal(false);
  });

  it("Should update user profile", async function () {
    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");

    const newName = "Alicia";
    const newBio = "Updated bio";
    const newProfilePicture = "new_ipfs_hash_or_url";

    await modernSocialMedia.connect(user1).updateProfile(newName, newBio, newProfilePicture);

    const user = await modernSocialMedia.users(user1.address);

    expect(user.name).to.equal(newName);
    expect(user.bio).to.equal(newBio);
    expect(user.profilePicture).to.equal(newProfilePicture);
  });

  it("Should send a private message", async function () {
    await modernSocialMedia.connect(user1).createUser("Alice", "Hello, I'm Alice!", "ipfs_hash_or_url");
    await modernSocialMedia.connect(user2).createUser("Bob", "Hello, I'm Bob!", "ipfs_hash_or_url");

    const messageContent = "Hello, Bob!";

    await modernSocialMedia.connect(user1).sendMessage(user2.address, messageContent);

    const aliceMessages = await modernSocialMedia.users(user1.address).messages;
    const bobMessages = await modernSocialMedia.users(user2.address).messages;

    expect(aliceMessages[0].content).to.equal(messageContent);
    expect(bobMessages[0].content).to.equal(messageContent);
  });
});
