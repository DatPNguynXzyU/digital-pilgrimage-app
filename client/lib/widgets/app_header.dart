import 'package:flutter/material.dart';

import '../config/app_theme.dart';

/// Shared app bar for screens that need a title and optional screen actions.
/// Branded headers, such as the home page, can retain their custom layout.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = AppTheme.background,
    this.foregroundColor = AppTheme.text,
    this.centerTitle = false,
    this.automaticallyImplyLeading = true,
    this.showBackButton,
    this.onBack,
    this.showDivider = true,
    this.bottom,
    this.toolbarHeight = 64,
    this.elevation = 0,
    this.surfaceTintColor = Colors.transparent,
    this.titleSpacing = 16,
  });

  final Widget title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final bool showDivider;
  final PreferredSizeWidget? bottom;
  final double toolbarHeight;
  final double elevation;
  final Color surfaceTintColor;
  final double titleSpacing;

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final shouldImplyLeading = showBackButton ?? automaticallyImplyLeading;
    return AppBar(
      title: DefaultTextStyle.merge(
        style: AppTheme.headerTitleStyle.copyWith(color: foregroundColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: title,
      ),
      leading:
          leading ??
          (onBack == null
              ? null
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: onBack,
                  icon: const BackButtonIcon(),
                )),
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: centerTitle,
      automaticallyImplyLeading: shouldImplyLeading,
      elevation: elevation,
      scrolledUnderElevation: 0,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: toolbarHeight,
      titleSpacing: titleSpacing,
      bottom: bottom,
      shape: showDivider
          ? const Border(bottom: BorderSide(color: AppTheme.border, width: 0.7))
          : const Border(),
    );
  }
}
