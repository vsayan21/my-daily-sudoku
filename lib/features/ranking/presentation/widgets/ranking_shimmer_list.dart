import 'package:flutter/material.dart';

class RankingShimmerList extends StatelessWidget {
  const RankingShimmerList({super.key, this.itemCount = 9});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, index) => const _ShimmerRow(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: itemCount,
    );
  }
}

class _ShimmerRow extends StatelessWidget {
  const _ShimmerRow();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.colorScheme.surfaceContainerHighest;
    final highlight = theme.colorScheme.surface;

    return _Shimmer(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 16,
              color: highlight,
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: highlight,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: 120, color: highlight),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 160, color: highlight),
                ],
              ),
            ),
            Container(height: 16, width: 48, color: highlight),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({
    required this.child,
    required this.baseColor,
    required this.highlightColor,
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            final shift = _controller.value * 2 - 1;
            return LinearGradient(
              begin: Alignment(-1 - shift, 0),
              end: Alignment(1 - shift, 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.2, 0.5, 0.8],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
