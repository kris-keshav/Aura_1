import 'package:aura/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:aura/models/onboard.dart';
import 'package:aura/screens/home_screen.dart';
import 'package:aura/widgets/custom_btn.dart';
import 'package:aura/helper/global.dart';
import 'package:aura/helper/pref.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize mq size using MediaQuery.of(context).size
    mq = MediaQuery.of(context).size;

    final PageController pageController = PageController();

    final List<Onboard> onboardList = [
      Onboard(
        title: "Ask me Anything",
        subtitle: "I can be your Best Friend & You can ask me anything & I will help you",
        lottie: "ai_ask_me",
      ),
      Onboard(
        title: "Imagination to Reality",
        subtitle: "Just Imagine anything & let me know, I will create something wonderful for you",
        lottie: "ai_play",
      ),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        itemCount: onboardList.length,
        itemBuilder: (ctx, index) {
          final bool isLast = index == onboardList.length - 1;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/${onboardList[index].lottie}.json',
                height: mq.height * 0.6,
              ),
              Text(
                onboardList[index].title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: mq.height * 0.015),
              SizedBox(
                width: mq.width * 0.7,
                child: Text(
                  onboardList[index].subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    letterSpacing: 0.5,
                    color: Theme.of(context).lightTextColor,
                  ),
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 10,
                children: List.generate(
                  onboardList.length,
                      (i) => Container(
                    width: i == index ? 15 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == index ? Colors.blue : Colors.grey,
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              CustomBtn(
                onTap: () {
                  if (isLast) {
                    // Save the onboarding completion state
                    Pref.setOnboardingCompleted();
                    Get.off(() => const HomeScreen());
                  } else {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.ease,
                    );
                  }
                },
                text: isLast ? "Finish" : "Next",
              ),
              const Spacer(flex: 2),
            ],
          );
        },
      ),
    );
  }
}
