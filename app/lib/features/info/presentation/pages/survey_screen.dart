import 'package:flutter/material.dart';
import 'package:pillbin/features/info/data/repository/information_list.dart';
import 'package:pillbin/features/info/presentation/widgets/info_card.dart';
import 'package:pillbin/features/info/presentation/widgets/info_empty_state.dart';

class SurveysScreen extends StatelessWidget {
  final double sw;
  final double sh;
  final bool isTablet;

  const SurveysScreen({
    super.key,
    required this.sw,
    required this.sh,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    if (InformationList.survey_list.isEmpty) {
      return EmptyState(
        icon: Icons.poll_outlined,
        title: "No Surveys Available",
        message: "Surveys will appear here once they're available.",
        sw: sw,
        sh: sh,
        isTablet: isTablet,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: sh * 0.01,
        bottom: sh * 0.03,
      ),
      itemCount: InformationList.survey_list.length,
      itemBuilder: (context, index) {
        final survey = InformationList.survey_list[index];
        return InfoCard(
          title: survey.title,
          content: survey.description.isNotEmpty
              ? survey.description[0].children ?? []
              : [],
          image: survey.image,
          icon: Icons.poll_outlined,
          iconColor: const Color(0xFF9C27B0),
          sw: sw,
          sh: sh,
          isTablet: isTablet,
          isSurvey: true,
        );
      },
    );
  }
}
