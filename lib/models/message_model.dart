import 'package:flutter/material.dart';

class Message {
  final String senderName;
  final String lastMessage;
  final String time;
  final IconData avatarIcon;
  final bool isRead;

  Message({
    required this.senderName,
    required this.lastMessage,
    required this.time,
    required this.avatarIcon,
    this.isRead = false,
  });
}
