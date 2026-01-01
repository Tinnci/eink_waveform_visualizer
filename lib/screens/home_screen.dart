import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

/// Main home screen of the waveform visualizer
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static void showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const _AboutDialog(),
    );
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  bool _isSidebarVisible = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WaveformProvider>();
    final width = MediaQuery.sizeOf(context).width;

    // 2026 Adaptive Breakpoints
    final isPhone = width < 600;
    final isTablet = width >= 600 && width < 1200;

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: _HomeAppBar(currentFile: provider.currentFile),
      // Mobile bottom bar (2026 Standard)
      bottomNavigationBar: isPhone
          ? NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: (index) =>
                  setState(() => _selectedTab = index),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: 'Waveform',
                ),
                NavigationDestination(
                  icon: Icon(Icons.data_object_outlined),
                  selectedIcon: Icon(Icons.data_object),
                  label: 'Hex',
                ),
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view),
                  label: 'Matrix',
                ),
              ],
            )
          : null,
      drawer: isPhone || isTablet
          ? const Drawer(
              width: 300,
              backgroundColor: AppTheme.primaryDark,
              child: SafeArea(child: _HomeSidebar()),
            )
          : null,
      body: Row(
        children: [
          // Navigation Rail only for Tablet/Desktop
          if (!isPhone)
            Builder(
              builder: (context) => _HomeNavigationRail(
                selectedIndex: _selectedTab,
                isSidebarVisible: !isTablet && _isSidebarVisible,
                onTabSelected: (index) => setState(() => _selectedTab = index),
                onToggleSidebar: () {
                  if (isTablet) {
                    Scaffold.of(context).openDrawer();
                  } else {
                    setState(() => _isSidebarVisible = !_isSidebarVisible);
                  }
                },
              ),
            ),
          if (!isPhone) const VerticalDivider(width: 1),
          // Permanent Sidebar only for Desktop
          if (!isPhone && !isTablet && _isSidebarVisible)
            const SizedBox(width: 280, child: _HomeSidebar()),
          if (!isPhone && !isTablet && _isSidebarVisible)
            const VerticalDivider(width: 1),
          Expanded(
            child: _HomeMainContent(
              selectedTab: _selectedTab,
              provider: provider,
              onTabChanged: (index) => setState(() => _selectedTab = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final WaveformFile? currentFile;

  const _HomeAppBar({this.currentFile});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      title: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.waves, color: AppTheme.accentGreen, size: 20),
          ),
          const SizedBox(width: 8),
          const Text(
            'E-Ink Waveform Visualizer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (currentFile != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                currentFile!.fileName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: ExcludeSemantics(
          child: Container(color: AppTheme.borderDark, height: 1),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);
}

class _HomeNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final bool isSidebarVisible;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onToggleSidebar;

  const _HomeNavigationRail({
    required this.selectedIndex,
    required this.isSidebarVisible,
    required this.onTabSelected,
    required this.onToggleSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTabSelected,
      backgroundColor: AppTheme.surfaceDark,
      labelType:
          NavigationRailLabelType.all, // 2026 Standard: Avoid guessing icons
      minWidth: 72, // Modern spacing
      useIndicator: true, // Show the M3 "Pill" indicator
      leading: Column(
        children: [
          const SizedBox(height: 8),
          IconButton(
            icon: Icon(
              isSidebarVisible ? Icons.menu_open : Icons.menu,
              color: AppTheme.textPrimary,
            ),
            onPressed: onToggleSidebar,
            tooltip: 'Toggle Sidebar',
          ),
          const SizedBox(height: 16),
        ],
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: Text('Waveform'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.data_object_outlined),
          selectedIcon: Icon(Icons.data_object),
          label: Text('Hex'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view),
          label: Text('Matrix'),
        ),
      ],
    );
  }
}

class _HomeSidebar extends StatelessWidget {
  const _HomeSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.primaryDark,
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            FileInfoPanel(),
            SizedBox(height: 12),
            Expanded(child: ControlPanel()),
          ],
        ),
      ),
    );
  }
}

class _HomeMainContent extends StatelessWidget {
  final int selectedTab;
  final WaveformProvider provider;
  final ValueChanged<int> onTabChanged;

  const _HomeMainContent({
    required this.selectedTab,
    required this.provider,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HomeToolbar(title: _getTabTitle(selectedTab), provider: provider),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation, secondaryAnimation) {
                return FadeThroughTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  child: child,
                );
              },
              child: _buildTabContent(context),
            ),
          ),
        ),
      ],
    );
  }

  String _getTabTitle(int index) {
    switch (index) {
      case 0:
        return 'Waveform Analysis';
      case 1:
        return 'Binary Data Explorer';
      case 2:
        return 'Transition Matrix';
      default:
        return '';
    }
  }

  Widget _buildTabContent(BuildContext context) {
    switch (selectedTab) {
      case 0:
        return const WaveformChart(key: ValueKey('waveform'));
      case 1:
        return provider.hasFile
            ? HexViewer(
                key: const ValueKey('hex'),
                data: provider.currentFile!.rawData,
                offset: provider.hexViewOffset,
                onOffsetChanged: (v) =>
                    context.read<SelectionProvider>().setHexViewOffset(v),
              )
            : const _EmptyStatePlaceholder(
                key: ValueKey('empty_hex'),
                icon: Icons.code,
                message: 'No file loaded',
              );
      case 2:
        return provider.hasFile
            ? _LutMatrixView(
                key: const ValueKey('matrix'),
                provider: provider,
                onTransitionSelected: () => onTabChanged(0),
              )
            : const _EmptyStatePlaceholder(
                key: ValueKey('empty_matrix'),
                icon: Icons.table_chart,
                message: 'No file loaded',
              );
      default:
        return const WaveformChart(key: ValueKey('waveform_default'));
    }
  }
}

class _EmptyStatePlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyStatePlaceholder({
    super.key,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeToolbar extends StatelessWidget {
  final String title;
  final WaveformProvider provider;

  const _HomeToolbar({required this.title, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (provider.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          const SizedBox(width: 16),
          _ToolbarButton(
            icon: Icons.folder_open,
            label: 'Open',
            onPressed: provider.loadFile,
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
            icon: Icons.download,
            label: 'Export',
            onPressed: () => _exportWaveform(context, provider),
          ),
          const SizedBox(width: 8),
          _ToolbarButton(
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

  void _showAboutDialog(BuildContext context) {
    // Note: Reusing the existing _showAboutDialog logic but potentially moving it later
    // For now, I'll keep the static reference or move the logic here.
    // I will call a static method or keep it in the main class for brevity in this step.
    HomeScreen.showAbout(context);
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onPressed,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 80),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppTheme.borderDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LutMatrixView extends StatelessWidget {
  final WaveformProvider provider;
  final VoidCallback onTransitionSelected;

  const _LutMatrixView({
    super.key,
    required this.provider,
    required this.onTransitionSelected,
  });

  @override
  Widget build(BuildContext context) {
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
              child: _MatrixGrid(
                provider: provider,
                onTransitionSelected: onTransitionSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatrixGrid extends StatelessWidget {
  final WaveformProvider provider;
  final VoidCallback onTransitionSelected;

  const _MatrixGrid({
    required this.provider,
    required this.onTransitionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
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

                    final diff = (toGray - fromGray).abs();
                    final color = Color.lerp(
                      AppTheme.surfaceDark,
                      AppTheme.accentGreen,
                      diff / 15,
                    )!;

                    return Expanded(
                      child: Semantics(
                        label: 'Transition from Gray $fromGray to $toGray',
                        selected: isSelected,
                        button: true,
                        onTap: () {
                          final selection = context.read<SelectionProvider>();
                          selection.setFromGray(fromGray);
                          selection.setToGray(toGray);
                          onTransitionSelected();
                        },
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            final selection = context.read<SelectionProvider>();
                            selection.setFromGray(fromGray);
                            selection.setToGray(toGray);
                            onTransitionSelected();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(1),
                            height:
                                48, // 2026 Compliance: 48px minimum touch target
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.accentGreen,
                                      width: 2,
                                    )
                                  : null,
                            ),
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
        // Legend
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
                gradient: const LinearGradient(
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
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              _buildLinkRow(Icons.description, 'License', 'MIT License'),
              const SizedBox(height: 6),
              _buildLinkRow(
                Icons.code,
                'Repository',
                'github.com/Tinnci/eink_waveform_visualizer',
              ),
              const SizedBox(height: 6),
              _buildLinkRow(
                Icons.person,
                'Author',
                'shiso <shisoratsu@icloud.com>',
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
    );
  }

  Widget _buildLinkRow(IconData icon, String label, String value) {
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
