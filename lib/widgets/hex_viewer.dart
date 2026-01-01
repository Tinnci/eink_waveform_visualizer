import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_theme.dart';

/// Hex viewer widget for displaying raw binary data
class HexViewer extends StatefulWidget {
  final Uint8List data;
  final int bytesPerRow;
  final int offset;
  final void Function(int)? onOffsetChanged;
  final Set<int>? highlightedBytes;

  const HexViewer({
    super.key,
    required this.data,
    this.bytesPerRow = 16,
    this.offset = 0,
    this.onOffsetChanged,
    this.highlightedBytes,
  });

  @override
  State<HexViewer> createState() => _HexViewerState();
}

class _HexViewerState extends State<HexViewer> {
  late ScrollController _scrollController;
  final TextEditingController _offsetController = TextEditingController();
  int _hoveredByte = -1;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _offsetController.text =
        '0x${widget.offset.toRadixString(16).toUpperCase()}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  static const double _rowHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(child: _buildHexContent()),
          const Divider(height: 1),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.code, color: AppTheme.accentBlue, size: 18),
          const SizedBox(width: 8),
          const Text(
            'Hex Viewer',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          // Offset input
          const Text(
            'Offset: ',
            style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
          SizedBox(
            width: 90,
            height: 24,
            child: TextField(
              controller: _offsetController,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: AppTheme.textPrimary,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.borderDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppTheme.accentBlue),
                ),
                filled: true,
                fillColor: AppTheme.surfaceDark,
              ),
              onSubmitted: _goToOffset,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_upward, size: 16),
            tooltip: 'Go to start',
            onPressed: () => _goToOffset('0'),
            color: AppTheme.textSecondary,
            iconSize: 16,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildHexContent() {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      );
    }

    final rowCount = (widget.data.length / widget.bytesPerRow).ceil();

    final textScaler = MediaQuery.textScalerOf(context);
    final dynamicRowHeight = textScaler.scale(_rowHeight);

    return Semantics(
      label:
          'Binary data viewer showing hex offsets, bytes, and ASCII representation.',
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          height: 1.4,
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: rowCount,
            itemExtent: dynamicRowHeight,
            itemBuilder: (context, index) {
              return RepaintBoundary(child: _buildHexRow(index));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHexRow(int rowIndex) {
    final startOffset = rowIndex * widget.bytesPerRow;
    final endOffset = (startOffset + widget.bytesPerRow).clamp(
      0,
      widget.data.length,
    );
    final rowBytes = widget.data.sublist(startOffset, endOffset);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Offset column
          SizedBox(
            width: 60,
            child: Text(
              startOffset.toRadixString(16).padLeft(8, '0').toUpperCase(),
              style: const TextStyle(color: AppTheme.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          // Hex bytes
          Expanded(flex: 3, child: _buildHexBytes(rowBytes, startOffset)),
          const SizedBox(width: 12),
          // ASCII representation
          Expanded(
            flex: 1,
            child: Text(
              _bytesToAscii(rowBytes),
              style: const TextStyle(color: AppTheme.accentPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexBytes(Uint8List bytes, int startOffset) {
    final widgets = <Widget>[];

    for (var i = 0; i < bytes.length; i++) {
      final byteOffset = startOffset + i;
      final isHighlighted =
          widget.highlightedBytes?.contains(byteOffset) ?? false;
      final isHovered = _hoveredByte == byteOffset;

      widgets.add(
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredByte = byteOffset),
          onExit: (_) => setState(() => _hoveredByte = -1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppTheme.accentBlue.withValues(alpha: 0.2)
                  : isHighlighted
                  ? AppTheme.accentOrange.withValues(alpha: 0.2)
                  : null,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase(),
              style: TextStyle(
                color: isHighlighted
                    ? AppTheme.accentOrange
                    : _getByteColor(bytes[i]),
              ),
            ),
          ),
        ),
      );

      // Add separator every 8 bytes
      if ((i + 1) % 8 == 0 && i < bytes.length - 1) {
        widgets.add(const SizedBox(width: 6));
      } else if (i < bytes.length - 1) {
        widgets.add(const SizedBox(width: 3));
      }
    }

    // Pad with empty spaces if row is incomplete
    for (var i = bytes.length; i < widget.bytesPerRow; i++) {
      widgets.add(const SizedBox(width: 20, child: Text('  ')));
      if ((i + 1) % 8 == 0 && i < widget.bytesPerRow - 1) {
        widgets.add(const SizedBox(width: 6));
      } else if (i < widget.bytesPerRow - 1) {
        widgets.add(const SizedBox(width: 3));
      }
    }

    return Row(children: widgets);
  }

  Color _getByteColor(int byte) {
    if (byte == 0x00) {
      return AppTheme.textMuted;
    }
    if (byte == 0xFF) {
      return AppTheme.accentRed;
    }
    if (byte == 0xFC) {
      return AppTheme.accentOrange;
    }
    if (byte >= 0x20 && byte <= 0x7E) {
      return AppTheme.accentGreen;
    } // Printable ASCII
    return AppTheme.textSecondary;
  }

  String _bytesToAscii(Uint8List bytes) {
    return bytes.map((b) {
      if (b >= 0x20 && b <= 0x7E) {
        return String.fromCharCode(b);
      }
      return '.';
    }).join();
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _buildLegendItem(AppTheme.textMuted, 'Null (0x00)'),
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.accentRed, 'End (0xFF)'),
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.accentOrange, 'Special (0xFC)'),
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.accentGreen, 'Printable'),
          const Spacer(),
          Text(
            'Size: ${_formatSize(widget.data.length)}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _goToOffset(String value) {
    try {
      int offset;
      if (value.startsWith('0x') || value.startsWith('0X')) {
        offset = int.parse(value.substring(2), radix: 16);
      } else {
        offset = int.parse(value);
      }
      offset = offset.clamp(0, widget.data.length);
      widget.onOffsetChanged?.call(offset);

      // Scroll to the offset
      final rowIndex = offset ~/ widget.bytesPerRow;
      _scrollController.animateTo(
        rowIndex * _rowHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      // Invalid input, ignore
    }
  }
}
