import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:arrow_flow/core/constants/app_strings.dart';
import 'package:arrow_flow/core/widgets/gradient_scaffold.dart';

/// Leaderboard screen displaying global and friends rankings.
class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const List<_LeaderboardEntry> _mockEntries = [
    _LeaderboardEntry(rank: 1, name: 'ArrowMaster', score: 98500),
    _LeaderboardEntry(rank: 2, name: 'PuzzlePro', score: 87200),
    _LeaderboardEntry(rank: 3, name: 'GridGuru', score: 76400),
    _LeaderboardEntry(rank: 4, name: 'FlowKing', score: 65100),
    _LeaderboardEntry(rank: 5, name: 'TapWizard', score: 54300),
    _LeaderboardEntry(rank: 6, name: 'You', score: 42000),
  ];

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.leaderboardTitle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Chip(label: const Text(AppStrings.leaderboardGlobal)),
                  const SizedBox(width: 8),
                  const Chip(label: Text(AppStrings.leaderboardFriends)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _mockEntries.length,
                itemBuilder: (_, i) {
                  final entry = _mockEntries[i];
                  final isUser = entry.name == 'You';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(200)
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withAlpha(150),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Text(
                        _rankEmoji(entry.rank),
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        entry.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isUser
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                      ),
                      trailing: Text(
                        '${entry.score}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _rankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}

class _LeaderboardEntry {
  const _LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
  });

  final int rank;
  final String name;
  final int score;
}
