import 'package:bett_box/common/common.dart';
import 'package:bett_box/models/models.dart';
import 'package:flutter/material.dart';

class SubscriptionInfoView extends StatelessWidget {
  final SubscriptionInfo? subscriptionInfo;

  const SubscriptionInfoView({super.key, this.subscriptionInfo});

  @override
  Widget build(BuildContext context) {
    if (subscriptionInfo == null) {
      return const SizedBox.shrink();
    }

    final use = subscriptionInfo!.upload + subscriptionInfo!.download;
    final total = subscriptionInfo!.total;

    // No traffic info
    if (use == 0 && total == 0) {
      return const SizedBox.shrink();
    }

    // Show progress bar
    final progress = total > 0 ? use / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            width: double.infinity,
            color: context.colorScheme.primary.opacity15,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(color: context.colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
