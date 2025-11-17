import 'package:chat_app/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.text,
    this.subtitle,
    this.time,
    this.trailing,
    this.unreadCount = 0,
    this.onTap,
  });

  final String text;
  final String? subtitle;
  final String? time; 
  final Widget? trailing;
  final int unreadCount;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.mainGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.blackColor.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.whiteColor.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: AppColors.whiteColor, size: 22),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null || time != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (subtitle != null)
                          Expanded(
                            child: Text(
                              subtitle!,
                              style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (time != null)
                          Text(
                            time!,
                            style: TextStyle(
                              color: AppColors.whiteColor.withValues(alpha: 0.7),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(color: AppColors.whiteColor, fontSize: 12),
                ),
              ),
            if (trailing != null) ...[const Gap(6), trailing!],
          ],
        ),
      ),
    );
  }
}
