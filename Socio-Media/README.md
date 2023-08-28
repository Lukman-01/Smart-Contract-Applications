 # Modern Social Media Contract

The **Modern Social Media Contract** is a Solidity smart contract that implements a simplified social media platform on the Ethereum blockchain. It allows users to create posts, add comments, like posts, follow/unfollow users, update their profiles, and send private messages to other users.
## Introduction

The Modern Social Media Contract provides a foundation for building a decentralized social media platform where users can interact with each other and share content. The contract is designed to be easy to understand and extendable, allowing developers to customize and enhance its features.

## Getting Started

To use the Modern Social Media Contract, follow these steps:

1. Deploy the contract to the Ethereum blockchain using a development environment such as Remix or Truffle.
2. Interact with the contract using an Ethereum wallet or a DApp (Decentralized Application).

## Contract Overview

The contract consists of several key components:

- **User Struct**: Represents a user on the platform. It includes fields for the user's name, biography, profile picture, friends, posts, messages, followers, and post comments.

- **Post Struct**: Represents a post created by a user. It includes the author's address, content, timestamp, and the number of likes.

- **Comment Struct**: Represents a comment on a post. It includes the author's address, content, and timestamp.

- **Message Struct**: Represents a private message between users. It includes the sender's address, recipient's address, content, and timestamp.

- **Modifiers**: The contract includes modifiers to ensure that only existing users can perform certain actions and that provided post IDs are valid.

- **Events**: The contract emits events for various actions such as post creation, comment addition, user following, post liking, profile updates, and message sending.

- **Functions**: The contract provides functions for creating users, posts, comments, liking posts, following users, unfollowing users, updating profiles, and sending messages.

## Usage

To use the Modern Social Media Contract, deploy the contract to an Ethereum network and interact with it using an Ethereum wallet or a DApp. Here are some example interactions:

1. **Create a User Profile**: Call the `createUser` function to create a new user profile with a name, biography, and profile picture.

2. **Create a Post**: Call the `createPost` function to create a new post with content on the platform.

3. **Add a Comment**: Call the `addComment` function to add a comment to an existing post.

4. **Like a Post**: Call the `likePost` function to like a post created by another user.

5. **Follow/Unfollow Users**: Call the `followUser` function to follow another user or the `unfollowUser` function to unfollow a user.

6. **Update Profile**: Call the `updateProfile` function to update your profile information, including name, biography, and profile picture.

7. **Send a Message**: Call the `sendMessage` function to send a private message to another user.

