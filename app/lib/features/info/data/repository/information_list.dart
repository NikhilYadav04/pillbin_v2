import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appImages.dart';
import 'package:pillbin/features/info/data/model/info_model.dart';
import 'package:url_launcher/url_launcher.dart';

class InformationList {
  //* List of all information
  static List<InfoModel> information_list = [
    //* About Us
    InfoModel(
        title: "About us",
        description: [
          TextSpan(children: [
            TextSpan(
                text:
                    """I am an undergraduate Pharmacy student who is passionate about
environmental issues. When I learned about environmental hazards from
expired and/or unused medicines, I decided to investigate this issue. Hence,
a survey was conducted to evaluate the community's knowledge with
respect to drug disposal awareness. The survey showed that the majority of
people have many unused or expired medicines at household level, and
they are unaware of drug disposal methods as well as environmental
hazards associated with them.

 The goal of this website is to educate the public on safe disposal practices,
raise awareness about the environmental impact of improper drug disposal,
and provide resources to prevent pharmaceutical pollution. By sharing
knowledge and promoting responsible actions, we should aim to protect our
environment and ensure a healthier future.""")
          ])
        ],
        image: ""),

    //* DRUG DISPOSAL
    InfoModel(
        title: "DRUG DISPOSAL",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "• Drug disposal refers to the process of safely discarding unused, expired, or unwanted pharmaceutical products to prevent harm to the environment, humans, and animals.\n\n",
              ),
              TextSpan(
                text:
                    "• Proper drug disposal ensures that pharmaceuticals are not misused, abused, or introduced into ecosystems through improper channels like flushing down drains or throwing in regular trash.\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Daily Use of Medicines:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Contain active pharmaceutical ingredients that can harm the environment.\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Leakage Points:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Manufacturing, distribution, use, and improper disposal. In Asian and African it is found that the most common method of disposing of unused medication was throwing in the garbage, which ended up in landfills.\n\n",
              ),
              TextSpan(
                text:
                    "• In Maine, US state the pain reliever acetaminophen, for example, was present in samples from one landfill at concentrations of ",
              ),
              TextSpan(
                text: "117,000 ng/L",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ", the highest level of any drug measured in the study. ",
              ),
              TextSpan(
                text: "Know More",
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(
                      'https://tinyurl.com/99dd7wcn',
                    );

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "\n\n"),
              TextSpan(text: "• "),
              TextSpan(
                text: "Sewage Treatment Limitations:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Conventional methods target general properties and can't fully remove pharmaceutical compounds.",
              ),
            ],
          ),
        ],
        image: AppImages.drug_disposal),

    //* Risks associated with Drug Disposal
    InfoModel(
        title: "Risks associated with Drug Disposal: Antibiotic Resistance",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "• The release of antibiotics into the environment, mainly through wastewater and improper disposal, drives the emergence of antimicrobial resistance.\n\n",
              ),
              TextSpan(
                text:
                    "• Unused and expired antibiotics are often discarded in garbage, landfills, or sewers due to the cost of proper disposal. A recent study found that ",
              ),
              TextSpan(
                text: "more than a quarter of some 258 rivers",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " around the world were polluted with drugs to a toxic degree. The highest concentrations of active pharmaceutical ingredients were found in Sub-Saharan Africa, South Asia, and South America. ",
              ),
              TextSpan(
                  text: "Know more",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse(
                        'https://www.pnas.org/doi/10.1073/pnas.2113947119',
                      );

                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
              TextSpan(text: "\n\n"),
              TextSpan(
                text:
                    "• Even in small concentrations, these antibiotics promote resistance through horizontal gene transfer or genetic modification. This indiscriminate release transforms harmless microbes into resistant pathogens, compromising antibiotic effectiveness. Third-generation cephalosporin-resistant E. coli, methicillin-resistant Staphylococcus aureus, multi drug resistant Candida auris, Klebsiella pneumoniae are the examples of antibiotic resistant organisms. ",
              ),
              TextSpan(
                  text: "Know more",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse(
                        'https://www.who.int/news-room/fact-sheets/detail/antimicrobial-resistance',
                      );

                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
              TextSpan(text: "\n\n"),
              TextSpan(
                text:
                    "• When transmitted to humans, resistant bacteria lead to higher morbidity, mortality, and economic strain on healthcare systems. It was associated with an estimated ",
              ),
              TextSpan(
                text: "five million deaths in 2019",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ". "),
              TextSpan(
                  text: "Know more",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse(
                        'https://tinyurl.com/3txrkd6h',
                      );

                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
            ],
          ),
        ],
        image: AppImages.risk_drug_disposal),

    //* Impact of Pharmaceutical Contaminants
    InfoModel(
        title:
            "Impact of Pharmaceutical Contaminants on Biodiversity and Ecosystems",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "• The rising presence of antibiotics for human and veterinary use in the environment and food chain has been linked to the obesity epidemic. The veterinary use of diclofenac, an NSAID, has critically endangered three Asian vulture species in the Indian subcontinent.\n\n",
              ),
              TextSpan(
                text:
                    "• Vultures feeding on livestock treated with diclofenac suffer organ failure (visceral gout) and die, disrupting ecosystems. Pharmaceutical contaminants also impact terrestrial and aquatic species, with psychiatric drugs like benzodiazepines causing behavioral changes in fish and their prey. ",
              ),
              TextSpan(
                text: "Know more",
                style: TextStyle(fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(
                      'https://www.researchgate.net/publication/228008880_Diclofenac_Poisoning_as_a_Cause_of_Vulture_Population_Declines_across_the_Indian_Subcontinent',
                    );

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
              ),
              TextSpan(text: "\n\n"),
              TextSpan(
                text:
                    "• The population of the White-rumped vulture Gyps bengalensis fell ",
              ),
              TextSpan(
                text: "96% between 1993 and 2002",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: ".\n\n",
              ),
              TextSpan(
                text:
                    "• The populations of the Indian vulture Gyps indicus and the slender-billed vulture Gyps tenuirostris fell ",
              ),
              TextSpan(
                text: "97%",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ". "),
              TextSpan(
                text: "Know more",
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(
                      'https://www.sciencehistory.org/stories/magazine/poison-pill-the-mysterious-die-off-of-indias-vultures/',
                    );

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: "\n\n"),
              TextSpan(
                text:
                    "• These effects highlight the urgent need to regulate veterinary pharmaceuticals to protect biodiversity and prevent ecological harm.",
              ),
            ],
          ),
        ],
        image: AppImages.impact_pharma),

    //* Effect on Marine Life
    InfoModel(
        title: "Effect on Marine Life",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "• Elevated levels of estrogenic steroids, such as natural estradiol and synthetic ethinyl estradiol, introduced into aquatic environments through sources like wastewater effluents, can disrupt the endocrine systems of fish.\n\n",
              ),
              TextSpan(
                text:
                    "• This disruption often leads to the feminization of male fish, characterized by the production of vitellogenin a protein typically synthesized only in females for egg yolk development and the development of intersex conditions, where individuals exhibit both male and female reproductive tissues.\n\n",
              ),
              TextSpan(
                text:
                    "• Such hormonal imbalances can impair reproductive behaviors and reduce fertility, potentially resulting in population declines and broader ecological consequences.\n\n",
              ),
              TextSpan(
                text:
                    "• To mitigate these effects, it is essential to enhance wastewater treatment processes to effectively remove estrogenic compounds, promote proper disposal of pharmaceuticals to prevent environmental contamination, and develop eco-friendly alternatives to current estrogenic substances.\n\n",
              ),
              TextSpan(
                text:
                    "• The presence of ethinylestradiol in the living environment of Hydra vulgaris, Gammarus pulex, Chironarus riparius, Hyalella Azteca, and Lymnaea stagnalis may adversely affect the hatchability rate, body size, molt passing ability, reproductive behavior, and the number of eggs laid. ",
              ),
              TextSpan(
                  text: "Know more",
                  style: TextStyle(fontWeight: FontWeight.bold),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri url = Uri.parse(
                        'https://pubmed.ncbi.nlm.nih.gov/12651186/',
                      );

                      if (!await launchUrl(url,
                          mode: LaunchMode.externalApplication)) {
                        throw Exception('Could not launch $url');
                      }
                    }),
            ],
          ),
        ],
        image: AppImages.marine_life),

    //* Survey on Drug Disposal Awareness
    InfoModel(
        title: "Survey on Drug Disposal: Methodology and Findings",
        description: [
          TextSpan(
            children: [
              TextSpan(text: "• "),
              TextSpan(
                text: "Survey Design:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Questionnaire-based, mixed-method study targeting individuals of all genders aged 18 and above.\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Structure:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Part 1: Collected personal details of participants. Part 2: Focused on practices and perceptions regarding unused medication disposal.\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Questionnaire Development:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Framed in English, adapted from published literature, and validated by subject experts. Pilot-tested with 15 respondents to refine the questions (pilot responses excluded from final analysis).\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Content:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    " Five sections covering demographics, knowledge, current practices, awareness, accessibility of disposal methods, and suggestions.\n\n",
              ),
              TextSpan(text: "• "),
              TextSpan(
                text: "Participation:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: " Voluntary, with informed consent obtained.\n\n",
              ),
              TextSpan(
                text:
                    "From the survey conducted on 382 participants, it was found that 66.1% participants were unaware of the proper drug disposal methods and guidelines.",
              ),
            ],
          ),
        ],
        image: AppImages.survey_drug_disposal),

    //* Reasons for Policy
    InfoModel(
        title:
            "Reasons for policy and there implementation for proper Medicine Disposal",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text: "1. Over-purchasing and Early Discontinuation\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Many Indians buy excess medicines or stop treatment prematurely, leading to surplus medicines that increase misuse and health risks. Strict rules can promote responsible use and adherence to the prescriptions.\n\n",
              ),
              TextSpan(
                text: "2. Improper Disposal Practices\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Flushing unused medicines without any knowledge of their proprties is common, causing environmental harm. Clear guidelines are needed to regulate which medicines can be flushed and encourage eco-friendly disposal methods for others.\n\n",
              ),
              TextSpan(
                text: "3. Community Drug Donation\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Establishing systems for collecting and redistributing unused medicines can reduce waste and provide essential medications to those in need.\n\n",
              ),
              TextSpan(
                text: "4. Eco-friendly Disposal Awareness\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Public education on safe disposal methods and accessible return systems can prevent environmental damage and encourage responsible handling of pharmaceutical waste.",
              ),
            ],
          ),
        ],
        image: ""),

    //* Drug Take-Back Programs
    InfoModel(
        title: "What we need : Drug Take-Back Programs",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text: "1. Periodic Drug Take-Back Events\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "There should be temporary setting up of collection sites for safe disposal of medications. Local law enforcement and waste management authorities should organize similar events.\n\n",
              ),
              TextSpan(
                text: "2. Drug Take-Back Locations\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Authorized facilities, such as pharmacies, clinics, and law enforcement agencies, should provide year-round disposal options, including kiosks, drop-off boxes, and mail-back programs. To locate a nearby facility, use Google Maps (\"drug disposal near me\").\n\n",
              ),
              TextSpan(
                text: "3. Prepaid Drug Mail-Back Envelopes\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "They should be available for purchase at pharmacies or online, these envelopes provide a convenient way to dispose of medications.",
              ),
            ],
          ),
        ],
        image: ""),

    //* Drug Disposal Methods
    InfoModel(
        title: "Drug Disposal Methods",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text: "Flush Drugs as per US FDA\n\n",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0), // Assuming subtitle style
              ),
              TextSpan(
                text: "Medicine Disposal Guidelines\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "1.",
              ),
              TextSpan(
                text: "Follow Healthcare Provider Instructions\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Dispose of unused or expired medicines as directed by your doctor or pharmacist.\n\n",
              ),
              TextSpan(
                text: "2.",
              ),
              TextSpan(
                text:
                    "Preferred Disposal Method\nUse a drug take-back option\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "  ○ Drop off medicines at an authorized take-back location.\n",
              ),
              TextSpan(
                text:
                    "  ○ Mail them using a pre-paid drug mail-back envelope.\n\n",
              ),
              TextSpan(
                text: "3.",
              ),
              TextSpan(
                text: "Check the FDA's Flush List\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "If take-back options are unavailable, verify if the medicine is on the FDA's Flush List. Only flush medicines that:\n",
              ),
              TextSpan(
                text: "  ○ Have high misuse or abuse potential.\n",
              ),
              TextSpan(
                text:
                    "  ○ Can cause death from a single dose if improperly used.\n\n",
              ),
              TextSpan(
                text: "Important Reminder\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text:
                    "Do not flush medicines unless they are explicitly listed on the FDA's Flush List. ",
              ),
              TextSpan(
                text: "Know more",
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(
                      'https://www.fda.gov/drugs/disposal-unused-medicines-what-you-should-know/drug-disposal-fdas-flush-list-certain-medicines',
                    );

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        image: AppImages.flush_drugs),

    //* Non-Flush Drugs as per US FDA
    InfoModel(
        title: "Non Flush Drugs as per US FDA",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "If drug take-back options are unavailable, dispose of most medicines at home by:\n\n",
              ),
              TextSpan(
                text: "1. Removing them from their original containers.\n\n",
              ),
              TextSpan(
                text:
                    "2. Mixing them with an unappealing substance like dirt, cat litter, or coffee grounds (without crushing tablets/capsules).\n\n",
              ),
              TextSpan(
                text: "3. Placing the mixture in a sealed plastic bag.\n\n",
              ),
              TextSpan(
                text: "4. Throwing the sealed bag in your household trash.\n\n",
              ),
              TextSpan(
                text:
                    "5. Scratching out personal information on prescription labels before throwing the empty containers. ",
              ),
              TextSpan(
                text: "Know more",
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri url = Uri.parse(
                      'https://www.fda.gov/drugs/safe-disposal-medicines/disposal-unused-medicines-what-you-should-know',
                    );

                    if (!await launchUrl(url,
                        mode: LaunchMode.externalApplication)) {
                      throw Exception('Could not launch $url');
                    }
                  },
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
        image: AppImages.non_flush_drugs),
  ];

  //* List of Surveys
  static List<InfoModel> survey_list = [
    //* View of Pharmacy College Students during survey
    InfoModel(
        title:
            "Views of Pharmacy Students collected during survey on Drug Disposal Awareness",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "“I believe if we initially give only the required/needed amount of medicines instead of extras the wastage of meds can be reduced. Also about the drug disposal i believe there should be a community set up at every city level to collect the old expired meds from every house this way the disposal will be carried out in correct way rather than the non medico people who do not have correct info of how to dispose meds.”\n\n",
              ),
              TextSpan(
                text:
                    "“To improve drug disposal practices, local communities can establish more accessible drop-off points at pharmacies, healthcare facilities, and police stations, ensuring safe disposal methods. Public education campaigns can raise awareness about the dangers of improper disposal and promote the use of mail-back programs and take-back events. Additionally, increasing collaboration with waste management services to ensure secure incineration or recycling can reduce environmental impact.”\n\n",
              ),
              TextSpan(
                text:
                    "“The Best way as per me is to guide the pharmacist and tell them to make general public aware of any such schemes or guidelines of the Government for disposing the medicines, of there will be some incentives while returning the same to them the General public will be surely following. Government if possible can run ads on TV or Social Media or BEST buses and Local train so that it can it can come to their notice. Medicine Disposer Box a special dustbin near Pharmacies where people if it's locality can dispose their Leftover or Unused medications.”",
              ),
            ],
          ),
        ],
        image: ""),

    //* View of Doctors collected during survey
    InfoModel(
        title:
            "Views of Doctors collected during survey on Drug Disposal Awareness",
        description: [
          TextSpan(
            children: [
              TextSpan(
                text:
                    "“Pharmacist should collect even expired medicine and from them disposal system should function.”\n\n",
              ),
              TextSpan(
                text:
                    "“1. Check medicine cabinet and gather all expired unused medications.\n2. Take them to a nearby pharmacy for safe disposal.”\n\n",
              ),
              TextSpan(
                text:
                    "“Every society should have separate drug collection bin like dust bin.”",
              ),
            ],
          ),
        ],
        image: "")
  ];
}
