import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memox/core/backup/backup_data.dart';
import 'package:memox/core/extensions/context_extensions.dart';
import 'package:memox/core/theme/tokens/radius_tokens.dart';
import 'package:memox/core/theme/tokens/size_tokens.dart';
import 'package:memox/core/theme/tokens/spacing_tokens.dart';
import 'package:memox/shared/widgets/lists/app_list_tile.dart';

Future<String?> showBackupListSheet(
  BuildContext context, {
  required List<BackupInfo> backups,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _BackupListSheet(backups: backups),
);

class _BackupListSheet extends StatelessWidget {
  const _BackupListSheet({required this.backups});

  final List<BackupInfo> backups;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: SizeTokens.bottomSheetHandleWidth,
            height: SizeTokens.bottomSheetHandle,
            decoration: BoxDecoration(
              color: context.colors.outline,
              borderRadius: BorderRadius.circular(RadiusTokens.full),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            context.l10n.settingsRestoreAction,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.lg),
          ...backups.map(
            (backup) => AppListTile(
              title: _formatDate(backup.modifiedTime),
              subtitle: _formatSize(backup.sizeBytes),
              leading: Icon(
                Icons.cloud_done_outlined,
                color: context.colors.onSurfaceVariant,
              ),
              onTap: () => Navigator.of(context).pop(backup.fileId),
            ),
          ),
        ],
      ),
    ),
  );

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }
    return DateFormat.yMMMd().add_Hm().format(date.toLocal());
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
}
