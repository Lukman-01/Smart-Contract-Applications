// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

/**
 * @title ModernSocialMedia
 * @notice This contract implements a simplified social media platform on the Ethereum blockchain.
 * Users can create posts, add comments, like posts, follow/unfollow users, update their profiles,
 * and send messages to other users.
 */
contract ModernSocialMedia {
    struct User {
        string name;
        string bio;
        string profilePicture;
        address[] friends;
        mapping(address => bool) isFriend;
        Post[] posts;
        Message[] messages;
        mapping(address => bool) followers;
        mapping(uint256 => Comment[]) postComments;
    }

    struct Post {
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }

    struct Comment {
        address author;
        string content;
        uint256 timestamp;
    }

    struct Message {
        address sender;
        address recipient;
        string content;
        uint256 timestamp;
    }

    mapping(address => User) public users;

    event PostCreated(address indexed author, uint256 indexed postId);
    event CommentAdded(address indexed author, uint256 indexed postId, uint256 commentId);
    event UserFollowed(address indexed follower, address indexed following);
    event PostLiked(address indexed liker, address indexed author, uint256 indexed postId);
    event ProfileUpdated(address indexed user, string newName, string newBio, string newProfilePicture);
    event MessageSent(address indexed sender, address indexed recipient, string content);

    /**
     * @dev Modifier to restrict access to only existing users.
     * It checks if the sender's name is not an empty string.
     */
    modifier onlyExistingUser() {
        require(bytes(users[msg.sender].name).length > 0, "User does not exist");
        _;
    }

    /**
     * @dev Modifier to check the validity of a post ID.
     * @param _postId The ID of the post to be checked.
     */
    modifier validPost(uint256 _postId) {
        require(_postId < users[msg.sender].posts.length, "Invalid post ID");
        _;
    }

    /**
     * @notice Creates a new user profile on the platform.
     * @param _name The name of the user.
     * @param _bio The user's biography or description.
     * @param _profilePicture The IPFS hash or URL of the user's profile picture.
     */
    function createUser(string memory _name, string memory _bio, string memory _profilePicture) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        users[msg.sender] = User(_name, _bio, _profilePicture, new address[](0), new Post[](0), new Message[](0));
    }

    /**
     * @notice Creates a new post on the platform.
     * @param _content The content of the post.
     */
    function createPost(string memory _content) public onlyExistingUser {
        Post memory newPost = Post(msg.sender, _content, block.timestamp, 0);
        users[msg.sender].posts.push(newPost);
        emit PostCreated(msg.sender, users[msg.sender].posts.length - 1);
    }

    /**
     * @notice Adds a comment to a post.
     * @param _postId The ID of the post to which the comment is added.
     * @param _content The content of the comment.
     */
    function addComment(uint256 _postId, string memory _content) public onlyExistingUser validPost(_postId) {
        Comment memory newComment = Comment(msg.sender, _content, block.timestamp);
        users[msg.sender].postComments[_postId].push(newComment);
        emit CommentAdded(msg.sender, _postId, users[msg.sender].postComments[_postId].length - 1);
    }

    /**
     * @notice Likes a post.
     * @param _author The author of the post.
     * @param _postId The ID of the post to be liked.
     */
    function likePost(address _author, uint256 _postId) public onlyExistingUser validPost(_postId) {
        users[_author].posts[_postId].likes++;
        emit PostLiked(msg.sender, _author, _postId);
    }

    /**
     * @notice Follows a user.
     * @param _userToFollow The address of the user to follow.
     */
    function followUser(address _userToFollow) public onlyExistingUser {
        require(_userToFollow != msg.sender && bytes(users[_userToFollow].name).length > 0, "Invalid user");
        users[msg.sender].followers[_userToFollow] = true;
        users[_userToFollow].followers[msg.sender] = true;
        emit UserFollowed(msg.sender, _userToFollow);
    }

    /**
     * @notice Unfollows a user.
     * @param _userToUnfollow The address of the user to unfollow.
     */
    function unfollowUser(address _userToUnfollow) public onlyExistingUser {
        require(users[_userToUnfollow].followers[msg.sender], "You are not following this user");
        users[msg.sender].followers[_userToUnfollow] = false;
        users[_userToUnfollow].followers[msg.sender] = false;
    }

    /**
     * @notice Updates user profile information.
     * @param _newName The new name of the user.
     * @param _newBio The new biography of the user.
     * @param _newProfilePicture The new IPFS hash or URL of the user's profile picture.
     */
    function updateProfile(string memory _newName, string memory _newBio, string memory _newProfilePicture) public onlyExistingUser {
        users[msg.sender].name = _newName;
        users[msg.sender].bio = _newBio;
        users[msg.sender].profilePicture = _newProfilePicture;
        emit ProfileUpdated(msg.sender, _newName, _newBio, _newProfilePicture);
    }

    /**
     * @notice Sends a private message to another user.
     * @param _recipient The recipient of the message.
     * @param _content The content of the message.
     */
    function sendMessage(address _recipient, string memory _content) public onlyExistingUser {
        require(bytes(users[_recipient].name).length > 0, "Recipient does not exist");

        Message memory newMessage = Message(msg.sender, _recipient, _content, block.timestamp);
        users[msg.sender].messages.push(newMessage);
        users[_recipient].messages.push(newMessage);
        emit MessageSent(msg.sender, _recipient, _content);
    }
}
