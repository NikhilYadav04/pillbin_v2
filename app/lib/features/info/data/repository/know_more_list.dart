import 'package:pillbin/features/info/data/model/know_more_model.dart';

class KnowMoreList {
  static List<KnowMoreModel> know_more_list = [
    //* Index 0: "For more information" links
    KnowMoreModel(
      links: [
        {
          'text': 'How to Safely Dispose of unused or Expired medicine',
          'url': "https://www.youtube.com/watch?v=2kAklblMi24"
        },
        {
          'text': 'Disposal of Expired Medicines by NTEP',
          'url': "https://ntep.in/node/2439/CP-disposal-expired-supplies"
        },
        {
          'text': 'Guidelines for safe disposal of expired medicines',
          'url':
              "https://www.pib.gov.in/newsite/PrintRelease.aspx?relid=178039#:~:text=All%20bio%2Dmedical%20waste%20shall,for%20all%20disposal%20of%20waste"
        },
      ],
    ),

    //* Index 1: "NGOs which collect unused medicines" links
    KnowMoreModel(
      links: [
        {'text': 'Kerala PROUD', 'url': "https://tinyurl.com/4z6zad33"},
        {'text': 'ShareMeds', 'url': "https://www.instagram.com/sharemeds/"},
        {
          'text': 'Medicine Baba',
          'url': "https://www.medicinebaba.in/index.php"
        },
        {'text': 'Uday Foundation', 'url': "https://www.udayfoundation.org/"},
      ],
    ),

    //* Index 2: "Companies which do Bio-waste management" links
    KnowMoreModel(
      links: [
        {
          'text': 'Environmental Synergies in Development (Ensyde)',
          'url':
              "https://bangaloreinternationalcentre.org/bcause/nonprofits/environmental-synergies-in-development/"
        },
        {
          'text': 'Safe Water Network',
          'url': "https://safewaternetwork.org/our-work/india/"
        },
        {'text': 'Ramky Enviro Engineers Ltd', 'url': "https://ramky.com/"},
        {
          'text': 'Synergy Waste Management',
          'url': "https://www.synergywastemgmt.com/"
        },
      ],
    ),
  ];
}
