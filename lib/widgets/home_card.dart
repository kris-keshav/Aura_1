import 'package:aura/helper/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:aura/models/home_type.dart';

class HomeCard extends StatelessWidget {
  final HomeType homeType;

  const HomeCard({super.key, required this.homeType});

  @override
  Widget build(BuildContext context) {
    Animate.restartOnHotReload = true;

    return Card(
      color: Colors.blue.withOpacity(0.2),
      elevation: 0,
      margin: EdgeInsets.only(bottom: mq.height * 0.02),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: homeType.onTap,
        child: Row(
          children: [
            if (homeType.leftAlign) ...[
              _buildLottie(),
              const Spacer(),
              _buildTitle(),
              const Spacer(flex: 2),
            ] else ...[
              const Spacer(flex: 2),
              _buildTitle(),
              const Spacer(),
              _buildLottie(),
            ],
          ],
        ),
      ),
    ).animate().fade(duration: 1.seconds, curve: Curves.easeIn);
  }

  Widget _buildLottie() {
    return Container(
      width: mq.width * 0.35,
      padding: homeType.padding,
      child: Lottie.asset('assets/lottie/${homeType.lottie}'),
    );
  }

  Widget _buildTitle() {
    return Text(
      homeType.title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
      ),
    );
  }
}
