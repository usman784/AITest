import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/features/game/game_provider.dart';
import 'package:arrow_flow/features/game/widgets/arrow_cell.dart';
import 'package:arrow_flow/game/models/game_state.dart';

/// Renders the N×N grid of [ArrowCell] tiles for the current [GamePlaying]
/// state. Sizes itself to the available space via [LayoutBuilder].
class GameGrid extends ConsumerWidget {
  const GameGrid({super.key, required this.playing});

  final GamePlaying playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final gridSize = playing.grid.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserve padding on both axes.
        final available = math.min(
          constraints.maxWidth - AppDimensions.spaceLG * 2,
          constraints.maxHeight - AppDimensions.spaceMD * 2,
        );
        final rawCell = available / gridSize;
        final gap = (rawCell * 0.06).clamp(2.0, 6.0);
        final cellSize = rawCell - gap;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(gridSize, (row) {
                return Padding(
                  padding: EdgeInsets.only(bottom: row < gridSize - 1 ? gap : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(gridSize, (col) {
                      final arrow = playing.grid[row][col];
                      final isError =
                          arrow != null && arrow.id == playing.errorArrow?.id;
                      final isHinted =
                          arrow != null && arrow.id == playing.hintArrowId;

                      return Padding(
                        padding: EdgeInsets.only(
                            right: col < gridSize - 1 ? gap : 0),
                        child: ArrowCell(
                          arrow: arrow,
                          isError: isError,
                          isHinted: isHinted,
                          cellSize: cellSize,
                          onTap: arrow != null
                              ? () => notifier.tapArrow(arrow.id)
                              : null,
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
