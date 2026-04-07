import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/providers/backup_providers.dart';
import 'package:memox/features/settings/presentation/widgets/settings_action_row.dart';
import 'package:memox/features/settings/presentation/widgets/settings_backup_actions.dart';
import 'package:memox/features/settings/presentation/widgets/settings_group_card.dart';
import 'package:memox/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:memox/shared/widgets/cards/app_card.dart';
import 'package:memox/shared/widgets/feedback/app_async_builder.dart';
import 'package:memox/shared/widgets/layout/spacing.dart';

class SettingsBackupSection extends ConsumerWidget {
  const SettingsBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentGoogleUserProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsSectionHeader(label: context.l10n.settingsBackupSection),
        const Gap.lg(),
        AppAsyncBuilder<GoogleSignInAccount?>(
          value: userAsync,
          onData: (user) {
            if (user == null) {
              return _SignedOutView(onSignIn: () => _signIn(ref));
            }
            return _SignedInView(user: user);
          },
          onLoading: () => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Future<void> _signIn(WidgetRef ref) async {
    await ref.read(googleSignInServiceProvider).signIn();
    ref.invalidate(currentGoogleUserProvider);
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView({required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) => SettingsGroupCard(
    children: [
      SettingsActionRow(
        title: context.l10n.settingsSignInAction,
        icon: Icons.login_outlined,
        onTap: onSignIn,
      ),
    ],
  );
}

class _SignedInView extends ConsumerWidget {
  const _SignedInView({required this.user});

  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    children: [
      _BackupAccountCard(user: user),
      const Gap.md(),
      SettingsGroupCard(
        children: [
          SettingsActionRow(
            title: context.l10n.settingsBackupNowAction,
            icon: Icons.cloud_upload_outlined,
            onTap: () => handleBackupToDrive(context, ref),
          ),
          SettingsActionRow(
            title: context.l10n.settingsRestoreAction,
            icon: Icons.cloud_download_outlined,
            onTap: () => handleShowBackupList(context, ref),
          ),
        ],
      ),
      const Gap.md(),
      SettingsGroupCard(
        children: [
          SettingsActionRow(
            title: context.l10n.settingsSignOutAction,
            icon: Icons.logout_outlined,
            onTap: () => _signOut(ref),
          ),
        ],
      ),
    ],
  );

  Future<void> _signOut(WidgetRef ref) async {
    await ref.read(googleSignInServiceProvider).signOut();
    ref.invalidate(currentGoogleUserProvider);
  }
}

class _BackupAccountCard extends StatelessWidget {
  const _BackupAccountCard({required this.user});

  final GoogleSignInAccount user;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Icon(Icons.cloud_done_outlined, color: context.colors.primary),
        const Gap.md(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? user.email,
                style: context.textTheme.titleMedium,
              ),
              if (user.displayName != null) ...[
                const Gap.xs(),
                Text(
                  user.email,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}
