import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

// ── Glassy Container ─────────────────────────────────────────
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.borderColor,
    this.backgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppColors.border,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// ── System Label ──────────────────────────────────────────────
class SystemLabel extends StatelessWidget {
  final String text;
  final Color? color;

  const SystemLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.systemLabel.copyWith(color: color),
    );
  }
}

// ── XP Bar ────────────────────────────────────────────────────
class XpProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final int currentXp;
  final int maxXp;
  final Color? color;

  const XpProgressBar({
    super.key,
    required this.progress,
    required this.currentXp,
    required this.maxXp,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = color ?? AppColors.systemBlue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('EXP', style: AppTextStyles.caption.copyWith(color: barColor)),
            Text(
              '${_formatNumber(currentXp)} / ${_formatNumber(maxXp)}',
              style: AppTextStyles.caption.copyWith(color: barColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: AppColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [barColor.withAlpha(180), barColor],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ── Rank Badge ────────────────────────────────────────────────
class RankBadge extends StatelessWidget {
  final String rank;
  final Color color;
  final double fontSize;

  const RankBadge({
    super.key,
    required this.rank,
    required this.color,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        '◆ $rank-RANK',
        style: AppTextStyles.rankBadge.copyWith(
          color: color,
          fontSize: fontSize,
        ),
      ),
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final IconData? icon;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 100,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
          ],
          SizedBox(
            width: 90,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
          ),
          Expanded(
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(2.5),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              value.toString(),
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Glowing Button ────────────────────────────────────────────
class SystemButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isOutlined;
  final double? width;
  final IconData? icon;

  const SystemButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.isOutlined = false,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.systemBlue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : c.withAlpha(40),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withAlpha(150), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: c, size: 16),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.xpLabel.copyWith(color: c, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag Chip ──────────────────────────────────────────────────
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback? onRemove;

  const TagChip({super.key, required this.label, this.color, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.systemBlue;
    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: onRemove != null ? 4 : 8,
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        color: c.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: c.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: c,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 12, color: c),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SystemLabel('[ $title ]'),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(subtitle!, style: AppTextStyles.caption),
                ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ── Separator ─────────────────────────────────────────────────
class SystemDivider extends StatelessWidget {
  const SystemDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.border,
            AppColors.border,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}
