import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:arrow_flow/core/constants/app_dimensions.dart';
import 'package:arrow_flow/features/game/game_provider.dart';
import 'package:arrow_flow/features/game/widgets/arrow_cell.dart';
import 'package:arrow_flow/game/models/arrow.dart';
import 'package:arrow_flow/game/models/game_state.dart';

/// Renders the N×N sliding-arrow grid.
///
/// - Computes which arrows can slide this turn and dims blocked ones.
/// - Shows a blue path-preview for the hovered arrow.
/// - Triggers [GameNotifier.tapArrow] on valid tap.
/// - Triggers [GameNotifier.startHover] / [GameNotifier.endHover] on touch.
class GameGrid extends ConsumerWidget {
  const GameGrid({super.key, required this.playing});

  final GamePlaying playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final gridSize = playing.grid.length;

    // ── Pre-compute which arrows can slide ──────────────────────────────────
    final canSlideSet = <int>{
      for (final a in playing.arrows)
        if (!a.isSliding && GameNotifier.canSlide(a, playing.grid)) a.id,
    };

    // ── Pre-compute path-preview cells for the hovered arrow ────────────────
    Set<(int, int)> previewCells = {};
    if (playing.hoveredArrowId != null) {
      Arrow? hovered;
      for (final a in playing.arrows) {
        if (a.id == playing.hoveredArrowId) {
          hovered = a;
          break;
        }
      }
      if (hovered != null && canSlideSet.contains(hovered.id)) {
        previewCells = GameNotifier.pathCells(hovered, playing.grid).toSet();
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = math.min(
          constraints.maxWidth - AppDimensions.spaceLG * 2,
          constraints.maxHeight - AppDimensions.spaceMD * 2,
        );
        final gap = (available / gridSize * 0.06).clamp(2.0, 6.0);
        final cellSize = available / gridSize - gap;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceMD),
            // overflow: visible so sliding arrows paint past the grid bounds.
            child: OverflowBox(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(gridSize, (row) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: row < gridSize - 1 ? gap : 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(gridSize, (col) {
                        final arrow = playing.grid[row][col];

                        // Also check the arrows list for a sliding arrow
                        // that has already vacated this cell.
                        Arrow? slidingHere;
                        for (final a in playing.arrows) {
                          if (a.isSliding &&
                              a.row == row &&
                              a.col == col) {
                            slidingHere = a;
                            break;
                          }
                        }
                        final displayArrow = arrow ?? slidingHere;

                        final isError = displayArrow != null &&
                            displayArrow.id == playing.errorArrow?.id;
                        final isHinted = displayArrow != null &&
                            displayArrow.id == playing.hintArrowId;
                        final isPreview = previewCells.contains((row, col));
                        final canSlide = displayArrow != null &&
                            canSlideSet.contains(displayArrow.id);

                        return Padding(
                          padding: EdgeInsets.only(
                              right: col < gridSize - 1 ? gap : 0),
                          child: ArrowCell(
                            arrow: displayArrow,
                            isError: isError,
                            isHinted: isHinted,
                            isPathPreview: isPreview,
                            canSlide: canSlide,
                            cellSize: cellSize,
                            onTap: displayArrow != null
                                ? () => notifier.tapArrow(displayArrow.id)
                                : null,
                            onTapDown: displayArrow != null
                                ? (_) =>
                                    notifier.startHover(displayArrow.id)
                                : null,
                            onTapUp: displayArrow != null
                                ? (_) => notifier.endHover()
                                : null,
                            onTapCancel: displayArrow != null
                                ? () => notifier.endHover()
                                : null,
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}


/// Renders the N×N grid of [ArrowCell] tiles for the current [GamePlaying]
/// state. Sizes itself to the available space via [LayoutBuilder].
