import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A selectable option card used in onboarding and settings.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? AppColors.gold : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: kSerif,
                          color: AppColors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                            color: AppColors.inkMuted,
                            fontSize: 13,
                            height: 1.35),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? AppColors.gold : AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
