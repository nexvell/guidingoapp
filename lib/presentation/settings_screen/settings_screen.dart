import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_bottom_bar.dart';

/// Settings Screen - Simple placeholder for app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Impostazioni',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(4.w),
          children: [
            _buildSettingsSection(theme, 'Notifiche', [
              _buildSettingsTile(
                theme,
                Icons.notifications_outlined,
                'Notifiche push',
                'Ricevi promemoria per studiare',
                onTap: () {},
              ),
              _buildSettingsTile(
                theme,
                Icons.alarm_outlined,
                'Promemoria giornaliero',
                'Imposta orario di studio',
                onTap: () {},
              ),
            ]),
            SizedBox(height: 2.h),
            _buildSettingsSection(theme, 'Account', [
              _buildSettingsTile(
                theme,
                Icons.person_outline,
                'Profilo',
                'Modifica informazioni account',
                onTap: () {},
              ),
              _buildSettingsTile(
                theme,
                Icons.language_outlined,
                'Lingua',
                'Italiano',
                onTap: () {},
              ),
            ]),
            SizedBox(height: 2.h),
            _buildSettingsSection(theme, 'Supporto', [
              _buildSettingsTile(
                theme,
                Icons.help_outline,
                'Centro assistenza',
                'FAQ e guide',
                onTap: () {},
              ),
              _buildSettingsTile(
                theme,
                Icons.feedback_outlined,
                'Invia feedback',
                'Aiutaci a migliorare',
                onTap: () {},
              ),
            ]),
            SizedBox(height: 2.h),
            _buildSettingsSection(theme, 'Altro', [
              _buildSettingsTile(
                theme,
                Icons.workspace_premium_outlined,
                'Passa a Premium',
                'Vite illimitate e contenuti esclusivi',
                onTap: () {
                  Navigator.pushNamed(context, '/premium-placeholder-screen');
                },
                trailing: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF39C12), Color(0xFFE74C3C)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              _buildSettingsTile(
                theme,
                Icons.info_outline,
                'Informazioni',
                'Versione 1.0.0',
                onTap: () {},
              ),
            ]),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/settings-screen',
        onNavigate: (route) {
          if (route != '/settings-screen') {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    ThemeData theme,
    String title,
    List<Widget> tiles,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle, {
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 24),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
