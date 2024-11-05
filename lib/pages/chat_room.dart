// chat_room.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatRoom extends StatefulWidget {
  final String chatRoomId; // Unique ID for each chat room
  final bool isGroupChat; // True if it's a group chat, false for single chat

  const ChatRoom({required this.chatRoomId, this.isGroupChat = false, super.key});

  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search input
  final ScrollController _scrollController = ScrollController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  // Get current user
  User? get _currentUser => _auth.currentUser;
  final List<Map<String, dynamic>> _messages = []; // All messages
  List<Map<String, dynamic>> _filteredMessages = [];
  bool _isSearching = false; 

  @override
  void initState() {
    super.initState();
    _updateUserPresence(true); 
    // Listen to changes in the search input
    _searchController.addListener(() {
      _searchMessages(_searchController.text);
    });
  }

  @override
  void dispose() {
    _updateUserPresence(false); // Mark user as offline
    _messageController.dispose();
    _scrollController.dispose();
    _searchController.dispose(); // Dispose of search controller
    super.dispose();
  }

  void _updateUserPresence(bool isOnline) {
    if (_currentUser != null) {
      _dbRef
          .child('users/${_currentUser!.uid}/presence')
          .set(isOnline ? 'online' : 'offline');
    }
  }

  // Define a method to upload the image to Firebase Storage
  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      // Create a unique file name based on the current timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Reference to the Firebase Storage
      Reference reference =
          FirebaseStorage.instance.ref().child('chat_images/$fileName');

      // Upload the file
      UploadTask uploadTask = reference.putFile(imageFile);

      // Get the download URL after the upload is complete
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl; // Return the download URL
    } catch (e) {
      print("Error uploading image: $e");
      return null; // Return null in case of error
    }
  }

  void _sendMessage({String? text, File? imageFile}) async {
    if (_currentUser == null) return;

    final message = {
      'senderId': _currentUser!.uid,
      'text': text ?? '',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'imageUrl': '',
    };

    if (imageFile != null) {
      // Upload image to Firebase Storage and get the download URL
      String? imageUrl = await _uploadImageToFirebase(imageFile);
      if (imageUrl != null) {
        message['imageUrl'] = imageUrl; // Set the image URL in the message
      }
    }

    // Save message to the database
    _dbRef.child('chatRooms/${widget.chatRoomId}/messages').push().set(message);
    _messageController.clear();

    // Scroll to the bottom of the chat after sending a message
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _sendMessage(imageFile: _imageFile);
    }
  }

  // Function to search messages
  void _searchMessages(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMessages = []; // Clear filtered messages if query is empty
      });
      return;
    }

    // Assuming messages is our original list of messages fetched from Firebase
    final allMessages = _messages; // This should be our original message list
    final results = allMessages.where((message) {
      // Check if the message text contains the query (case insensitive)
      return message['text'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredMessages = results; // Update the filtered messages
    });
  }

  Widget _buildMessageItem(Map<dynamic, dynamic> message) {
    final bool isMe = message['senderId'] == _currentUser?.uid;

    return Container(
      margin: EdgeInsets.only(
        top: 8.0,
        bottom: 8.0,
        left: isMe ? 50.0 : 10.0, 
        right: isMe ? 10.0 : 50.0, 
      ),
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft, // Align messages
      child: Row(
        mainAxisSize: MainAxisSize.min, // Minimum size of the row
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile icon for the other user (receiver)
          if (!isMe)
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person), 
            ),
          const SizedBox(width: 8), 
          Expanded(
            // Use Expanded to allow the message bubble to take up available space
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.blueAccent
                        : Colors.grey[300], // Set background color
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    message['text'] ?? '',
                    style: TextStyle(
                      color:
                          isMe ? Colors.white : Colors.black, // Set text color
                    ),
                  ),
                ),
                if (message['imageUrl'] != null && message['imageUrl'] != '')
                  Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Image.network(
                      message['imageUrl'],
                      width: 200, // Set image width
                      height: 200, // Set image height
                      fit: BoxFit.cover, // Set image fit
                    ),
                  ),
              ],
            ),
          ),
          // Profile icon for the current user (sender)
          if (isMe)
            const Padding(
              padding: EdgeInsets.only(
                  left: 8.0), // Add space between the message and icon
              child: CircleAvatar(
                radius: 16,
                child: Icon(Icons.person), 
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isGroupChat ? 'Group Chat' : 'Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching; // Toggle search field visibility
                if (!_isSearching) {
                  _searchController
                      .clear(); // Clear the search field when closing
                  _filteredMessages = []; // Reset filtered messages
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search TextField displayed conditionally
          if (_isSearching) // Show search field only when searching
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: _dbRef
                  .child('chatRooms/${widget.chatRoomId}/messages')
                  .onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(child: Text('No messages yet.'));
                }

                final data =
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final messages = data.values.toList();
                messages
                    .sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

                // Using filtered messages if search is active
                final displayedMessages = _searchController.text.isEmpty
                    ? messages
                    : _filteredMessages;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: displayedMessages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageItem(displayedMessages[index]),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_messageController.text.trim().isNotEmpty) {
                _sendMessage(text: _messageController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}
