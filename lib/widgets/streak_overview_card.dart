import 'package:flutter/material.dart';

class StreakOverviewCard extends StatelessWidget {
  const StreakOverviewCard({
    super.key,
    required this.streakCount,
    required this.hasCompletedToday,
    required this.days,
  });

  final int streakCount;
  final bool hasCompletedToday;
  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.2),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department_outlined,
                  color: colorScheme.onPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$streakCount Tage Streak',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasCompletedToday ? 'Heute erledigt' : 'Heute noch offen',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: hasCompletedToday
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasCompletedToday
                      ? colorScheme.primary
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  hasCompletedToday ? 'Streak gesichert' : 'Heute lösen',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: hasCompletedToday
                            ? colorScheme.onPrimary
                            : colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.map((day) {
              final isToday = _isSameDay(day, today);
              final isDone = day.isBefore(startOfToday);
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isDone ? colorScheme.primary : colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: isToday ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.day.toString(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isDone
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight:
                                  isToday ? FontWeight.w700 : FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isToday ? 'Heute' : 'Tag',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isToday
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            hasCompletedToday
                ? 'Du hältst deine Serie am Leben – weiter so!'
                : 'Löse heute ein Sudoku, um deine Serie zu halten.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
