import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ThankYouMessageWidget extends StatelessWidget {
  const ThankYouMessageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            color: Colors.red,
            size: 18,
          ),
          SizedBox(width: 8),
          Text(
            '感謝您使用 GOAA 分帳神器',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 
