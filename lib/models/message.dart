import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId, senderEmail, recieverId, message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.recieverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderId,
      'senderEmail': senderEmail,
      'recieverID': recieverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
