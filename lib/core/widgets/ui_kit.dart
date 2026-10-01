import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.onTap,
    this.radius = AppRadii.lg,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ApcColors.card,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: softShadow(),
        border: Border.all(color: ApcColors.border.withValues(alpha: 0.6)),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: card,
      ),
    );
  }
}

class ConnectionStatusChip extends StatelessWidget {
  const ConnectionStatusChip({
    super.key,
    required this.connected,
    required this.label,
    this.lightOnDark = false,
  });

  final bool connected;
  final String label;
  final bool lightOnDark;

  @override
  Widget build(BuildContext context) {
    final color = connected ? ApcColors.green : ApcColors.brown;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: lightOnDark
            ? Colors.white.withValues(alpha: 0.18)
            : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: lightOnDark ? Colors.white54 : color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
            size: 16,
            color: lightOnDark ? ApcColors.white : color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: lightOnDark ? ApcColors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientCtaButton extends StatelessWidget {
  const GradientCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
    this.busy = false,
    this.colors = const [ApcColors.green, ApcColors.greenDark],
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;
  final bool busy;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(AppRadii.pill),
              boxShadow: softShadow(blur: 22, y: 10, opacity: 0.18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ApcColors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: busy
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(icon, color: ApcColors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PillSearchField extends StatelessWidget {
  const PillSearchField({
    super.key,
    this.hint = 'Search…',
    this.controller,
    this.onChanged,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ApcColors.white,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        boxShadow: softShadow(blur: 14, y: 4, opacity: 0.05),
        border: Border.all(color: ApcColors.border),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: ApcColors.muted),
          suffixIcon: const Icon(Icons.tune_rounded, color: ApcColors.muted),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        ),
      ),
    );
  }
}

class ActionGridTile extends StatelessWidget {
  const ActionGridTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              height: 1.2,
              color: ApcColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingPillNav extends StatelessWidget {
  const FloatingPillNav({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<({IconData icon, String label})> items;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: ApcColors.white,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          boxShadow: softShadow(blur: 24, y: 10, opacity: 0.12),
          border: Border.all(color: ApcColors.border.withValues(alpha: 0.8)),
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: i == index ? ApcColors.greenSoft : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          items[i].icon,
                          size: 22,
                          color: i == index ? ApcColors.green : ApcColors.muted,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: i == index ? ApcColors.green : ApcColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ApprovalTimeline extends StatelessWidget {
  const ApprovalTimeline({
    super.key,
    required this.currentStatus,
    this.compact = false,
  });

  final String currentStatus;
  final bool compact;

  static const steps = [
    ('Agent', 'Submitted by field agent', Icons.person_pin_circle_outlined),
    ('Ward', 'Ward supervisor review', Icons.account_tree_outlined),
    ('LGA', 'LGA supervisor review', Icons.location_city_outlined),
    ('State', 'State supervisor review', Icons.flag_outlined),
    ('Situation Room', 'State verified · read-only', Icons.monitor_heart_outlined),
  ];

  int get _activeIndex {
    switch (currentStatus) {
      case 'draft':
        return 0;
      case 'pending_ward':
        return 1;
      case 'pending_lga':
        return 2;
      case 'pending_state':
        return 3;
      case 'state_verified':
        return 4;
      case 'rejected':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex;
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: active < 0
                          ? ApcColors.redSoft
                          : i < active
                              ? ApcColors.green
                              : i == active
                                  ? ApcColors.blue
                                  : ApcColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: active < 0
                            ? ApcColors.red
                            : i <= active
                                ? Colors.transparent
                                : ApcColors.border,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      active < 0 && i == 0
                          ? Icons.close
                          : i < active
                              ? Icons.check_rounded
                              : steps[i].$3,
                      size: 14,
                      color: i <= active && active >= 0 ? ApcColors.white : ApcColors.muted,
                    ),
                  ),
                  if (i < steps.length - 1)
                    Container(
                      width: 2,
                      height: compact ? 28 : 36,
                      color: i < active ? ApcColors.green : ApcColors.border,
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: i < steps.length - 1 ? (compact ? 8 : 14) : 0, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: i <= active && active >= 0 ? ApcColors.ink : ApcColors.muted,
                        ),
                      ),
                      if (!compact)
                        Text(
                          steps[i].$2,
                          style: const TextStyle(fontSize: 12, color: ApcColors.muted),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class FormSectionCard extends StatelessWidget {
  const FormSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.accent,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final c = accent ?? ApcColors.green;
    return SoftCard(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: c),
                ),
                const SizedBox(width: 10),
              ],
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class StatusTrustRow extends StatelessWidget {
  const StatusTrustRow({super.key, this.syncPending = 0});

  final int syncPending;

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.cloud_sync_rounded, syncPending > 0 ? 'Sync ($syncPending)' : 'Offline sync', ApcColors.blue),
      (Icons.gps_fixed_rounded, 'GPS ready', ApcColors.green),
      (Icons.lock_rounded, 'Encrypted', ApcColors.brown),
    ];
    return Row(
      children: [
        for (final item in items)
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.$3.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.$1, color: item.$3, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  item.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ApcColors.muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
