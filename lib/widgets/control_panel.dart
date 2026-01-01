import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../theme/app_theme.dart';

/// Control panel for adjusting waveform visualization parameters
class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WaveformProvider, SelectionProvider>(
      builder: (context, provider, selection, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader(
                    icon: Icons.tune,
                    title: 'Controls',
                    color: AppTheme.accentPurple,
                  ),
                  const SizedBox(height: 16),

                  // Gray Level Controls
                  _buildGrayLevelControl(
                    label: 'From Gray Level',
                    value: provider.selectedFromGray,
                    onChanged: provider.hasFile
                        ? (v) => selection.setFromGray(v)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildGrayLevelControl(
                    label: 'To Gray Level',
                    value: provider.selectedToGray,
                    onChanged: provider.hasFile
                        ? (v) => selection.setToGray(v)
                        : null,
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Mode Selection
                  _buildSectionHeader(
                    icon: Icons.layers,
                    title: 'Refresh Mode',
                    color: AppTheme.accentOrange,
                  ),
                  const SizedBox(height: 12),
                  _buildModeSelector(context, provider, selection),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // Temperature Control
                  _buildSectionHeader(
                    icon: Icons.thermostat,
                    title: 'Temperature',
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(height: 12),
                  _buildTemperatureControl(provider, selection),

                  const SizedBox(height: 20),

                  // Transition Info
                  if (provider.hasFile) _buildTransitionInfo(provider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGrayLevelControl({
    required String label,
    required int value,
    required Function(int)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Gray level preview box
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Color.lerp(Colors.white, Colors.black, value / 15)!,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppTheme.borderDark),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 16,
                  ),
                  activeTrackColor: AppTheme.accentGreen,
                  inactiveTrackColor: AppTheme.borderDark,
                  thumbColor: AppTheme.accentGreen,
                  overlayColor: AppTheme.accentGreen.withOpacity(0.2),
                ),
                child: Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 15,
                  divisions: 15,
                  onChanged: onChanged != null
                      ? (v) => onChanged(v.round())
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    WaveformProvider provider,
    SelectionProvider selection,
  ) {
    final modes = [
      WaveformMode.gc16,
      WaveformMode.gl16,
      WaveformMode.a2,
      WaveformMode.gray2,
      WaveformMode.glr16,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: modes.map((mode) {
        final isSelected = provider.selectedMode == mode;
        final isSupported =
            provider.currentFile?.supportedModes.contains(mode) ?? true;

        return Tooltip(
          message: mode.description,
          child: ChoiceChip(
            label: Text(mode.shortName),
            selected: isSelected,
            onSelected: provider.hasFile && isSupported
                ? (_) => selection.setMode(mode)
                : null,
            selectedColor: AppTheme.accentGreen.withOpacity(0.2),
            backgroundColor: AppTheme.surfaceDark,
            labelStyle: TextStyle(
              color: isSelected
                  ? AppTheme.accentGreen
                  : isSupported
                  ? AppTheme.textSecondary
                  : AppTheme.textMuted,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? AppTheme.accentGreen : AppTheme.borderDark,
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTemperatureControl(
    WaveformProvider provider,
    SelectionProvider selection,
  ) {
    final tempRange = provider.currentFile?.temperatureRange;
    final minTemp = tempRange?.$1 ?? 0;
    final maxTemp = tempRange?.$2 ?? 50;
    final maxIndex = provider.currentFile?.pviHeader?.tempSegmentCount ?? 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '${minTemp + (provider.selectedTemperature * (maxTemp - minTemp) / maxIndex).round()}°C',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentCyan,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Idx: ${provider.selectedTemperature}',
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppTheme.accentCyan,
            inactiveTrackColor: AppTheme.borderDark,
            thumbColor: AppTheme.accentCyan,
            overlayColor: AppTheme.accentCyan.withOpacity(0.2),
          ),
          child: Slider(
            value: provider.selectedTemperature.toDouble(),
            min: 0,
            max: (maxIndex - 1).clamp(1, 20).toDouble(),
            divisions: (maxIndex - 1).clamp(1, 20),
            onChanged: provider.hasFile
                ? (v) => selection.setTemperature(v.round())
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTransitionInfo(WaveformProvider provider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transition Info',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                'Frames',
                (provider.currentSequence?.length ?? 0).toString(),
                AppTheme.accentGreen,
              ),
              _buildInfoChip(
                'Direction',
                provider.selectedFromGray < provider.selectedToGray
                    ? '→ Darker'
                    : provider.selectedFromGray > provider.selectedToGray
                    ? '← Lighter'
                    : 'No change',
                AppTheme.accentBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 11, color: color.withOpacity(0.8)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
