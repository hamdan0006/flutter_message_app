import 'package:flutter/material.dart';

final List<Map<String, dynamic>> menuItems = [
  {'icon': Icons.message, 'text': 'Messages', 'check': true},
  {'icon': Icons.report, 'text': 'Spam'},
  {'icon': Icons.delete_outline, 'text': 'Recently Deleted'},
  {'divider': true},
  {'header': 'Filter by'},
  {'icon': Icons.inbox, 'text': 'Unread'},
  {'divider': true},
  {'icon': Icons.settings, 'text': 'Manage Filtering'},
];
