import 'package:chat_app/core/utils/app_colors.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final VoidCallback onTap;

  const UserListItem({
    super.key,
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: isSelected ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.blackColor.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isSelected ? Colors.white : const Color(0xFF06B6D4),
          child: Text(
            user.username[0].toUpperCase(),
            style: TextStyle(
              color: isSelected ? const Color(0xFF06B6D4) : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.username,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          user.email,
          style: TextStyle(
            color: isSelected ? Colors.white70 : Colors.grey[600],
          ),
        ),
        trailing: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isSelected
              ? const Icon(Icons.check, size: 16, color: Color(0xFF06B6D4))
              : null,
        ),
        onTap: onTap,
      ),
    );
  }
}
