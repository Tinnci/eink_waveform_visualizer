import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/providers.dart';
import '../../models/models.dart';
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
        if (provider.currentSequence != null &&
            provider.currentSequence!.data.isNotEmpty) {
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
          const Flexible(
            child: Text(
              'Voltage Waveform',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
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
              ? AppTheme.accentGreen.withValues(alpha: 0.15)
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 200,
                  minWidth: double.infinity,
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTapUp: (details) => _handleChartTap(
                        details,
                        provider,
                        constraints.maxWidth,
                        constraints.maxHeight < 200
                            ? 200
                            : constraints.maxHeight,
                      ),
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: WaveformPainter(
                          voltages: provider.currentSequence?.data ?? [],
                          animationProgress: _animation.value,
                          showGrid: _showGrid,
                          showLabels: _showLabels,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildVirtualPixelPreview(provider),
                    ),
                  ],
                ),
              );
            },
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
            color: AppTheme.textMuted.withValues(alpha: 0.5),
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

  Widget _buildVirtualPixelPreview(WaveformProvider provider) {
    if (provider.simulationResult.isEmpty) return const SizedBox.shrink();

    final totalFrames = provider.simulationResult.length;
    final currentIndex = (_animation.value * (totalFrames - 1)).floor();
    final clampedIndex = currentIndex.clamp(0, totalFrames - 1);

    final reflectance = provider.simulationResult[clampedIndex];
    // Map 0.0 (Black) -> 1.0 (White) to Color
    // Note: E-Ink usually uses 0x00 for Black, 0xFF for White.
    // OpticalSimulator returns 0.0-1.0.
    final grayValue = (reflectance * 255).round().clamp(0, 255);
    final color = Color.fromARGB(255, grayValue, grayValue, grayValue);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.borderDark.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Optical Simulation',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'L*: ${(reflectance * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Frame: ${clampedIndex + 1}/$totalFrames',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleChartTap(
    TapUpDetails details,
    WaveformProvider provider,
    double width,
    double height,
  ) {
    if (provider.currentSequence == null ||
        provider.currentSequence!.data.isEmpty) {
      return;
    }

    final sequence = provider.currentSequence!.data;

    // Layout logic must match WaveformPainter to be accurate
    const paddingLeft = 60.0;
    const paddingRight = 30.0;

    final plotWidth = width - paddingLeft - paddingRight;
    if (plotWidth <= 0) return;

    final dx = details.localPosition.dx;

    // Check if click is within the horizontal plot area
    if (dx < paddingLeft || dx > width - paddingRight) return;

    // Calculate frame index
    // relativeX represents 0.0 to 1.0 within the plot area
    final relativeX = (dx - paddingLeft) / plotWidth;
    final index = (relativeX * sequence.length).floor();

    if (index >= 0 && index < sequence.length) {
      final currentVoltage = sequence[index];
      VoltageLevel nextVoltage;

      // Toggle cycle: 0V -> +15V -> -15V -> 0V
      switch (currentVoltage) {
        case VoltageLevel.zero:
        case VoltageLevel.hold:
          nextVoltage = VoltageLevel.positive;
          break;
        case VoltageLevel.positive:
          nextVoltage = VoltageLevel.negative;
          break;
        case VoltageLevel.negative:
          nextVoltage = VoltageLevel.zero;
          break;
      }

      // Update via provider
      provider.updateVoltageAt(index, nextVoltage);
    }
  }
}
