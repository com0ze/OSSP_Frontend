import 'package:flutter/material.dart';
import '../models/user.dart';
import 'show_widget.dart';

class ShowUser extends ShowWidget {
  final User user;
  final VoidCallback? onTap;

  ShowUser({
    required this.user,
    this.onTap,
  });

  @override
  Widget makeWidget() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? Text(user.name[0].toUpperCase())
              : null,
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${user.score}점'),
                const SizedBox(width: 16),
                Text('거래 ${user.dealHistory.length}건'),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
