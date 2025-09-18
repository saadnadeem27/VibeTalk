import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flash_chat/app/models/chat_model.dart';
import 'package:flash_chat/app/models/message_model.dart';
import 'package:flash_chat/app/models/user_model.dart';

class ChatService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all chats for current user
  Stream<List<ChatModel>> getUserChats() {
    if (_auth.currentUser == null) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _auth.currentUser!.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  // Get messages for a specific chat
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  // Send a text message
  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? replyToMessageId,
  }) async {
    if (_auth.currentUser == null) return;

    final user = _auth.currentUser!;

    // Get user data
    final userDoc = await _firestore.collection('users').doc(user.uid).get();

    final userData = UserModel.fromFirestore(userDoc);

    final message = MessageModel(
      id: '',
      chatId: chatId,
      senderId: user.uid,
      senderName: userData.displayName,
      senderPhotoURL: userData.photoURL,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      mediaUrl: mediaUrl,
      replyToMessageId: replyToMessageId,
      status: MessageStatus.sent,
    );

    // Add message to chat
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());

    // Update chat's last message
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'lastMessageSenderId': user.uid,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    // Update unread count for other participants
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final chat = ChatModel.fromFirestore(chatDoc);

    Map<String, int> unreadCount = Map.from(chat.unreadCount);
    for (String participantId in chat.participants) {
      if (participantId != user.uid) {
        unreadCount[participantId] = (unreadCount[participantId] ?? 0) + 1;
      }
    }

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount': unreadCount,
    });
  }

  // Create or get individual chat
  Future<String> createOrGetIndividualChat(String otherUserId) async {
    if (_auth.currentUser == null) return '';

    final currentUserId = _auth.currentUser!.uid;

    // Check if chat already exists
    final existingChats = await _firestore
        .collection('chats')
        .where('type', isEqualTo: 'individual')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (final doc in existingChats.docs) {
      final chat = ChatModel.fromFirestore(doc);
      if (chat.participants.contains(otherUserId)) {
        return doc.id;
      }
    }

    // Create new chat
    final otherUserDoc =
        await _firestore.collection('users').doc(otherUserId).get();

    final otherUser = UserModel.fromFirestore(otherUserDoc);

    final chat = ChatModel(
      id: '',
      name: otherUser.displayName,
      type: ChatType.individual,
      participants: [currentUserId, otherUserId],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: currentUserId,
    );

    final chatRef =
        await _firestore.collection('chats').add(chat.toFirestore());

    return chatRef.id;
  }

  // Create group chat
  Future<String> createGroupChat({
    required String name,
    required List<String> participantIds,
    String? description,
    String? photoURL,
  }) async {
    if (_auth.currentUser == null) return '';

    final currentUserId = _auth.currentUser!.uid;

    final chat = ChatModel(
      id: '',
      name: name,
      description: description,
      photoURL: photoURL,
      type: ChatType.group,
      participants: [currentUserId, ...participantIds],
      admins: [currentUserId],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: currentUserId,
    );

    final chatRef =
        await _firestore.collection('chats').add(chat.toFirestore());

    return chatRef.id;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    if (_auth.currentUser == null) return;

    final currentUserId = _auth.currentUser!.uid;

    // Reset unread count for current user
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$currentUserId': 0,
    });

    // Mark messages as read
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('readBy', whereNotIn: [currentUserId]).get();

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      final message = MessageModel.fromFirestore(doc);
      final updatedReadBy = [...message.readBy, currentUserId];

      batch.update(doc.reference, {
        'readBy': updatedReadBy,
        'status': updatedReadBy.length > 1 ? 'read' : 'delivered',
      });
    }

    await batch.commit();
  }

  // Update typing status
  Future<void> updateTypingStatus(String chatId, bool isTyping) async {
    if (_auth.currentUser == null) return;

    final currentUserId = _auth.currentUser!.uid;

    await _firestore.collection('chats').doc(chatId).update({
      'typingStatus.$currentUserId': isTyping,
    });

    // Remove typing status after 3 seconds if still typing
    if (isTyping) {
      Future.delayed(const Duration(seconds: 3), () async {
        await _firestore.collection('chats').doc(chatId).update({
          'typingStatus.$currentUserId': false,
        });
      });
    }
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final results = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return results.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .where((user) => user.id != _auth.currentUser?.uid)
        .toList();
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}
