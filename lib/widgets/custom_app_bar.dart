import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App bar style variants
enum CustomAppBarStyle {
  /// Standard app bar with title and actions
  standard,

  /// App bar with centered title
  centered,

  /// App bar with large title (iOS style)
  large,

  /// Transparent app bar for overlays
  transparent,

  /// App bar with search functionality
  search,
}

/// Custom app bar optimized for mobile learning interface
/// Maintains clean visual hierarchy while providing essential navigation controls
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text to display
  final String? title;

  /// Optional subtitle text
  final String? subtitle;

  /// Leading widget (typically back button or menu)
  final Widget? leading;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// App bar style variant
  final CustomAppBarStyle style;

  /// Whether to show back button automatically
  final bool automaticallyImplyLeading;

  /// Custom background color (overrides theme)
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// Whether to show bottom border
  final bool showBottomBorder;

  /// Custom bottom widget (e.g., progress indicator)
  final PreferredSizeWidget? bottom;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.style = CustomAppBarStyle.standard,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showBottomBorder = false,
    this.bottom,
    this.onBackPressed,
  });

  @override
  Size get preferredSize {
    final double height = style == CustomAppBarStyle.large ? 96.0 : 56.0;
    final double bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(height + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBackgroundColor =
        backgroundColor ??
        (style == CustomAppBarStyle.transparent
            ? Colors.transparent
            : colorScheme.surface);

    final effectiveForegroundColor = foregroundColor ?? colorScheme.onSurface;

    return AppBar(
      title: _buildTitle(context, effectiveForegroundColor),
      leading: _buildLeading(context, effectiveForegroundColor),
      actions: _buildActions(context, effectiveForegroundColor),
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      centerTitle:
          style == CustomAppBarStyle.centered ||
          style == CustomAppBarStyle.large,
      automaticallyImplyLeading: automaticallyImplyLeading,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      toolbarHeight: style == CustomAppBarStyle.large ? 96.0 : 56.0,
      bottom: _buildBottom(context, colorScheme),
    );
  }

  Widget? _buildTitle(BuildContext context, Color foregroundColor) {
    if (title == null && subtitle == null) return null;

    if (style == CustomAppBarStyle.search) {
      return _buildSearchField(context);
    }

    if (subtitle != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: style == CustomAppBarStyle.centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Text(
            title ?? '',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: foregroundColor.withValues(alpha: 0.7),
              letterSpacing: 0.4,
            ),
          ),
        ],
      );
    }

    return Text(
      title!,
      style: GoogleFonts.inter(
        fontSize: style == CustomAppBarStyle.large ? 28 : 18,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
        letterSpacing: style == CustomAppBarStyle.large ? 0 : 0.15,
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Cerca...',
          hintStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, Color foregroundColor) {
    if (leading != null) return leading;

    if (automaticallyImplyLeading && Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: foregroundColor,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Indietro',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context, Color foregroundColor) {
    if (actions == null || actions!.isEmpty) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return IconButton(
          icon: action.icon,
          onPressed: () {
            HapticFeedback.selectionClick();
            action.onPressed?.call();
          },
          tooltip: action.tooltip,
          color: foregroundColor,
        );
      }
      return action;
    }).toList();
  }

  PreferredSizeWidget? _buildBottom(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    if (bottom != null) return bottom;

    if (showBottomBorder) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      );
    }

    return null;
  }
}

/// App bar with lives counter for learning sessions
class CustomAppBarWithLives extends StatelessWidget
    implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// Number of lives remaining
  final int lives;

  /// Maximum number of lives
  final int maxLives;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomAppBarWithLives({
    super.key,
    required this.title,
    required this.lives,
    this.maxLives = 5,
    this.actions,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.15,
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Indietro',
      ),
      actions: [
        // Lives counter
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: lives <= 2
                ? const Color(0xFFE74C3C).withValues(alpha: 0.12)
                : const Color(0xFFF39C12).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: lives <= 2
                    ? const Color(0xFFE74C3C)
                    : const Color(0xFFF39C12),
              ),
              const SizedBox(width: 4),
              Text(
                '$lives',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: lives <= 2
                      ? const Color(0xFFE74C3C)
                      : const Color(0xFFF39C12),
                ),
              ),
            ],
          ),
        ),
        if (actions != null) ...actions!,
      ],
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
    );
  }
}

/// App bar with progress indicator for lessons
class CustomAppBarWithProgress extends StatelessWidget
    implements PreferredSizeWidget {
  /// Title text to display
  final String title;

  /// Progress value (0.0 to 1.0)
  final double progress;

  /// Optional subtitle showing progress text
  final String? progressText;

  /// Action widgets displayed on the right
  final List<Widget>? actions;

  /// Callback when back button is pressed
  final VoidCallback? onBackPressed;

  const CustomAppBarWithProgress({
    super.key,
    required this.title,
    required this.progress,
    this.progressText,
    this.actions,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
          ),
          if (progressText != null) ...[
            const SizedBox(height: 2),
            Text(
              progressText!,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ],
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        tooltip: 'Indietro',
      ),
      actions: actions,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          minHeight: 4,
        ),
      ),
    );
  }
}