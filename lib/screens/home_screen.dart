import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Main home screen of the waveform visualizer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaveformProvider>();

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(provider),
          Expanded(
            child: Row(
              children: [
                // Left sidebar - File info and controls
                SizedBox(
                  width: 280,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const FileInfoPanel(),
                        const SizedBox(height: 12),
                        const Expanded(child: ControlPanel()),
                      ],
                    ),
                  ),
                ),

                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                    child: Column(
                      children: [
                        // Tab bar
                        _buildTabBar(),
                        const SizedBox(height: 12),
                        // Content
                        Expanded(child: _buildTabContent(provider)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(WaveformProvider provider) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          // Logo and title
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentGreen.withOpacity(0.2),
                  AppTheme.accentBlue.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.waves,
              color: AppTheme.accentGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'E-Ink Waveform Visualizer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'PVI & RKF Format Parser',
                style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const Spacer(),

          // Status indicator
          if (provider.isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentGreen,
              ),
            ),

          // Error indicator
          if (provider.error != null)
            Tooltip(
              message: provider.error!,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accentRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      size: 16,
                      color: AppTheme.accentRed,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Warning',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentRed.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 16),

          // Export button
          _buildToolbarButton(
            icon: Icons.download,
            label: 'Export',
            onPressed: () => _exportWaveform(context, provider),
          ),
          const SizedBox(width: 8),

          // Open file button
          _buildToolbarButton(
            icon: Icons.folder_open,
            label: 'Open',
            onPressed: provider.loadFile,
          ),
          const SizedBox(width: 8),
          _buildToolbarButton(
            icon: Icons.help_outline,
            label: 'About',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _exportWaveform(
    BuildContext context,
    WaveformProvider provider,
  ) async {
    if (!provider.hasFile) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No waveform file loaded')));
      return;
    }

    final result = await provider.exportToCsv();
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Exported to: $result')));
    }
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.show_chart, 'Waveform'),
          _buildTab(1, Icons.code, 'Hex View'),
          _buildTab(2, Icons.table_chart, 'LUT Matrix'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentGreen.withOpacity(0.15) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(WaveformProvider provider) {
    switch (_selectedTab) {
      case 0:
        return const WaveformChart();
      case 1:
        return provider.hasFile
            ? HexViewer(
                data: provider.currentFile!.rawData,
                offset: provider.hexViewOffset,
                onOffsetChanged: (v) =>
                    context.read<SelectionProvider>().setHexViewOffset(v),
              )
            : _buildEmptyHexView();
      case 2:
        return _buildLutMatrix(provider);
      default:
        return const WaveformChart();
    }
  }

  Widget _buildEmptyHexView() {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: AppTheme.textMuted.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No file loaded',
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLutMatrix(WaveformProvider provider) {
    if (!provider.hasFile) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.table_chart,
                size: 64,
                color: AppTheme.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No file loaded',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Build a 16x16 LUT matrix visualization
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.table_chart,
                  color: AppTheme.accentPurple,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Gray Level Transition Matrix',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  'Mode: ${provider.selectedMode.shortName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMatrixGrid(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixGrid(WaveformProvider provider) {
    return Column(
      children: [
        // Header row (To Gray)
        Row(
          children: [
            const SizedBox(width: 40, height: 24),
            ...List.generate(
              16,
              (i) => Expanded(
                child: Center(
                  child: Text(
                    i.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Matrix rows
        Expanded(
          child: ListView.builder(
            itemCount: 16,
            itemBuilder: (context, fromGray) {
              return Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        fromGray.toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  ...List.generate(16, (toGray) {
                    final isSelected =
                        provider.selectedFromGray == fromGray &&
                        provider.selectedToGray == toGray;

                    // Calculate intensity based on transition
                    final diff = (toGray - fromGray).abs();
                    final color = Color.lerp(
                      AppTheme.surfaceDark,
                      AppTheme.accentGreen,
                      diff / 15,
                    )!;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          final selection = context.read<SelectionProvider>();
                          selection.setFromGray(fromGray);
                          selection.setToGray(toGray);
                          setState(() => _selectedTab = 0);
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          height: 30, // Give it a fixed height or min height
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(2),
                            border: isSelected
                                ? Border.all(
                                    color: AppTheme.accentGreen,
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'From Gray →',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
            const SizedBox(width: 16),
            Container(
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.surfaceDark, AppTheme.accentGreen],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '← To Gray',
              style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
            ),
          ],
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.borderDark),
        ),
        title: const Row(
          children: [
            Icon(Icons.waves, color: AppTheme.accentGreen),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'E-Ink Waveform Visualizer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About section
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A professional tool for parsing and visualizing E-Ink waveform files '
                  'used in electronic paper displays. Supports PVI (E-Ink Corp) and RKF (Rockchip) formats.',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Technical Info
                const Text(
                  'Technical Details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentBlue,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Header parsing: Version, checksum, temperature segments\n'
                  '• LUT decoding: 16x16 gray level transition lookup tables\n'
                  '• Voltage sequence: +15V, 0V, -15V patterns per frame\n'
                  '• Export support: CSV format for further analysis',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Open Source Credits
                const Text(
                  'Open Source Credits',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Waveform parsing logic is based on reverse engineering of:\n'
                  '• Rockchip EBC driver source code (kernel-rockchip)\n'
                  '• FriendlyARM kernel patches for EPD LUT handling\n'
                  '• pvi_waveform_v8.S assembly implementation',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // License & Repository
                const Text(
                  'License & Repository',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.accentPurple,
                  ),
                ),
                const SizedBox(height: 8),
                _buildLinkRow(
                  icon: Icons.description,
                  label: 'License',
                  value: 'MIT License',
                ),
                const SizedBox(height: 6),
                _buildLinkRow(
                  icon: Icons.code,
                  label: 'Repository',
                  value: 'github.com/Tinnci/eink_waveform_visualizer',
                ),
                const SizedBox(height: 6),
                _buildLinkRow(
                  icon: Icons.person,
                  label: 'Author',
                  value: 'shiso <shisoratsu@icloud.com>',
                ),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.textMuted,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This software is provided "as is" without warranty of any kind.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.accentCyan,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
