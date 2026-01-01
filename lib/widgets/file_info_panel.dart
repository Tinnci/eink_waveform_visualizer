import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// File info panel showing details about the loaded waveform file
class FileInfoPanel extends StatelessWidget {
  const FileInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WaveformProvider>(
      builder: (context, provider, child) {
        if (!provider.hasFile) {
          return _buildEmptyState(context, provider);
        }

        final file = provider.currentFile!;
        final header = file.pviHeader;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Semantics(
                  label: 'Loaded file information',
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const ExcludeSemantics(
                          child: Icon(
                            Icons.description,
                            color: AppTheme.accentGreen,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MergeSemantics(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.fileName,
                                style: AppTypography.sectionTitle.copyWith(
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatBytes(file.fileSize),
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: provider.clearFile,
                        color: AppTheme.textMuted,
                        tooltip: 'Close file',
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Format info
                _buildInfoRow(
                  'Format',
                  file.format.name.toUpperCase(),
                  icon: Icons.format_list_bulleted,
                  valueColor: AppTheme.accentBlue,
                ),

                if (header != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Version',
                    header.versionString,
                    icon: Icons.info_outline,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Temp Segments',
                    header.tempSegmentCount.toString(),
                    icon: Icons.thermostat,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Table Offset',
                    '0x${header.tableOffset.toRadixString(16).toUpperCase()}',
                    icon: Icons.table_chart,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    'Checksum',
                    '0x${header.checksum.toRadixString(16).toUpperCase()}',
                    icon: Icons.verified_user,
                  ),
                ],

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Supported modes
                const Text('Supported Modes', style: AppTypography.dataLabel),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: file.supportedModes.map((mode) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.accentGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        mode.shortName,
                        style: AppTypography.caption.copyWith(
                          color: AppTheme.accentGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                if (file.loadedAt != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Loaded: ${_formatDateTime(file.loadedAt!)}',
                    style: AppTypography.caption.copyWith(fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WaveformProvider provider) {
    return Card(
      child: InkWell(
        onTap: provider.loadFile,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file,
                  color: AppTheme.accentBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Load Waveform File',
                style: AppTypography.sectionTitle,
              ),
              const SizedBox(height: 8),
              const Text(
                'Supports .bin, .wbf formats\n(PVI and RKF)',
                textAlign: TextAlign.center,
                style: AppTypography.caption,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: provider.loadFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Browse Files'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.accentBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            style: AppTypography.caption,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        const Text(':', style: AppTypography.caption),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: AppTypography.codeStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
