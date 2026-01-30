import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiLayer extends StatelessWidget {
  const ConfettiLayer({
    super.key,
    required this.controller,
  });

  final ConfettiController controller;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.05,
        numberOfParticles: 30,
        gravity: 0.2,
      ),
    );
  }
}
