import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../providers/providers.dart';
import '../../../../theme/app_theme.dart';

/// Matrix view showing all possible gray level transitions for the current mode.
class LutMatrixView extends StatelessWidget {
  final WaveformProvider provider;
  final VoidCallback onTransitionSelected;

  const LutMatrixView({
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
          child: CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate((context, fromGray) {
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
                              final selection = context
                                  .read<SelectionProvider>();
                              selection.setFromGray(fromGray);
                              selection.setToGray(toGray);
                              onTransitionSelected();
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                final selection = context
                                    .read<SelectionProvider>();
                                selection.setFromGray(fromGray);
                                selection.setToGray(toGray);
                                onTransitionSelected();
                              },
                              child: Container(
                                margin: const EdgeInsets.all(1),
                                height: 48,
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
                }, childCount: 16),
              ),
            ],
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
