import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../theme/app_theme.dart';
import 'waveform_painter.dart';

/// Main waveform visualization widget
class WaveformChart extends StatefulWidget {
  const WaveformChart({super.key});

  @override
  State<WaveformChart> createState() => _WaveformChartState();
}

class _WaveformChartState extends State<WaveformChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _showGrid = true;
  bool _showLabels = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateWaveform() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WaveformProvider>(
      builder: (context, provider, child) {
        // Animate when sequence changes
        if (provider.currentSequence.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_animationController.isAnimating &&
                _animationController.value == 0) {
              _animateWaveform();
            }
          });
        }

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with controls
              _buildHeader(provider),
              const Divider(height: 1),
              // Chart area
              Expanded(child: _buildChartArea(provider)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(WaveformProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Title
          const Icon(Icons.show_chart, color: AppTheme.accentGreen, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Voltage Waveform',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Toggle buttons
          _buildToggleButton(
            icon: Icons.grid_4x4,
            label: 'Grid',
            isActive: _showGrid,
            onPressed: () => setState(() => _showGrid = !_showGrid),
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            icon: Icons.label_outline,
            label: 'Labels',
            isActive: _showLabels,
            onPressed: () => setState(() => _showLabels = !_showLabels),
          ),
          const SizedBox(width: 8),
          _buildToggleButton(
            icon: Icons.replay,
            label: 'Replay',
            isActive: false,
            onPressed: _animateWaveform,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.accentGreen.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppTheme.accentGreen : AppTheme.borderDark,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppTheme.accentGreen : AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? AppTheme.accentGreen : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartArea(WaveformProvider provider) {
    if (!provider.hasFile) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 200,
              minWidth: double.infinity,
            ),
            child: CustomPaint(
              painter: WaveformPainter(
                voltages: provider.currentSequence,
                animationProgress: _animation.value,
                showGrid: _showGrid,
                showLabels: _showLabels,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.waves,
            size: 64,
            color: AppTheme.textMuted.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No waveform loaded',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Load a waveform file to visualize voltage patterns',
            style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
