import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../models/models.dart';
import '../../../../theme/app_theme.dart';

/// Custom painter for rendering the voltage waveform
class WaveformPainter extends CustomPainter {
  final List<VoltageLevel> voltages;
  final double animationProgress;
  final bool showGrid;
  final bool showLabels;

  WaveformPainter({
    required this.voltages,
    this.animationProgress = 1.0,
    this.showGrid = true,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (voltages.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    const padding = EdgeInsets.fromLTRB(60, 30, 30, 40);
    final chartRect = Rect.fromLTWH(
      padding.left,
      padding.top,
      size.width - padding.horizontal,
      size.height - padding.vertical,
    );

    // Draw components
    _drawGrid(canvas, chartRect);
    _drawAxisLabels(canvas, chartRect, size);
    _drawWaveform(canvas, chartRect);
    _drawLegend(canvas, size);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No waveform data',
        style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawGrid(Canvas canvas, Rect rect) {
    if (!showGrid) return;

    final gridPaint = Paint()
      ..color = AppTheme.gridLine
      ..strokeWidth = 1;

    final majorGridPaint = Paint()
      ..color = AppTheme.gridLineMajor
      ..strokeWidth = 1;

    // Horizontal grid lines (voltage levels)
    const yDivisions = 4; // +15V, +7.5V, 0V, -7.5V, -15V
    for (var i = 0; i <= yDivisions; i++) {
      final y = rect.top + (rect.height / yDivisions) * i;
      final paint = i == 2 ? majorGridPaint : gridPaint; // Center line is major
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }

    // Vertical grid lines (time divisions)
    final xDivisions = math.min(voltages.length, 20);
    for (var i = 0; i <= xDivisions; i++) {
      final x = rect.left + (rect.width / xDivisions) * i;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Rect rect, Size size) {
    if (!showLabels) return;

    // Y-axis labels (voltage)
    const voltageLabels = ['+15V', '+7.5V', '0V', '-7.5V', '-15V'];
    for (var i = 0; i < voltageLabels.length; i++) {
      final y = rect.top + (rect.height / 4) * i;
      final textPainter = TextPainter(
        text: TextSpan(
          text: voltageLabels[i],
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left - textPainter.width - 8, y - textPainter.height / 2),
      );
    }

    // X-axis label (Frame)
    final xLabelPainter = TextPainter(
      text: TextSpan(
        text: 'Frame (${voltages.length} total)',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    xLabelPainter.layout();
    xLabelPainter.paint(
      canvas,
      Offset(
        rect.left + (rect.width - xLabelPainter.width) / 2,
        size.height - 20,
      ),
    );

    // Y-axis title
    canvas.save();
    canvas.translate(15, rect.top + rect.height / 2);
    canvas.rotate(-math.pi / 2);
    final yTitlePainter = TextPainter(
      text: const TextSpan(
        text: 'Voltage',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    yTitlePainter.layout();
    yTitlePainter.paint(canvas, Offset(-yTitlePainter.width / 2, 0));
    canvas.restore();
  }

  void _drawWaveform(Canvas canvas, Rect rect) {
    if (voltages.isEmpty) return;

    final visibleCount = (voltages.length * animationProgress).ceil();
    if (visibleCount == 0) return;

    final stepWidth = rect.width / voltages.length;
    final centerY = rect.top + rect.height / 2;
    final maxAmplitude = rect.height / 2 - 10;

    // Draw the waveform as a step function
    final path = Path();
    var prevY = centerY;

    for (var i = 0; i < visibleCount; i++) {
      final voltage = voltages[i];
      final x = rect.left + i * stepWidth;
      final y = _getYForVoltage(voltage, centerY, maxAmplitude);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        // Step function: horizontal then vertical
        path.lineTo(x, prevY);
        path.lineTo(x, y);
      }
      prevY = y;
    }

    // Extend to the end of the last step
    if (visibleCount > 0) {
      path.lineTo(rect.left + visibleCount * stepWidth, prevY);
    }

    // Draw glow effect
    final glowPaint = Paint()
      ..color = _getColorForVoltage(voltages.first).withValues(alpha: 0.3)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // Draw main line with gradient
    final linePaint = Paint()
      ..color = AppTheme.accentGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Draw voltage level indicators (dots at each step)
    for (var i = 0; i < visibleCount; i++) {
      final voltage = voltages[i];
      final x = rect.left + i * stepWidth + stepWidth / 2;
      final y = _getYForVoltage(voltage, centerY, maxAmplitude);
      final color = _getColorForVoltage(voltage);

      // Draw dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // Draw outer ring
      final ringPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(x, y), 6, ringPaint);
    }
  }

  double _getYForVoltage(
    VoltageLevel voltage,
    double centerY,
    double amplitude,
  ) {
    switch (voltage) {
      case VoltageLevel.positive:
        return centerY - amplitude;
      case VoltageLevel.negative:
        return centerY + amplitude;
      case VoltageLevel.zero:
      case VoltageLevel.hold:
        return centerY;
    }
  }

  Color _getColorForVoltage(VoltageLevel voltage) {
    switch (voltage) {
      case VoltageLevel.positive:
        return AppTheme.voltagePositive;
      case VoltageLevel.negative:
        return AppTheme.voltageNegative;
      case VoltageLevel.zero:
        return AppTheme.voltageZero;
      case VoltageLevel.hold:
        return AppTheme.voltageHold;
    }
  }

  void _drawLegend(Canvas canvas, Size size) {
    const legendItems = [
      (VoltageLevel.positive, '+15V'),
      (VoltageLevel.zero, '0V'),
      (VoltageLevel.negative, '-15V'),
      (VoltageLevel.hold, 'HOLD'),
    ];

    const itemWidth = 70.0;
    final startX = size.width - (legendItems.length * itemWidth) - 10;

    for (var i = 0; i < legendItems.length; i++) {
      final (voltage, label) = legendItems[i];
      final x = startX + i * itemWidth;
      const y = 10.0;

      // Draw color dot
      canvas.drawCircle(
        Offset(x, y + 6),
        5,
        Paint()..color = _getColorForVoltage(voltage),
      );

      // Draw label
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + 10, y));
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return voltages != oldDelegate.voltages ||
        animationProgress != oldDelegate.animationProgress ||
        showGrid != oldDelegate.showGrid ||
        showLabels != oldDelegate.showLabels;
  }
}
