import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/features/campaign/presentation/widgets/campaign_card.dart';

class CampaignDetailsModal extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailsModal({Key? key, required this.campaign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sw = MediaQuery.of(context).size.width;
    final double sh = MediaQuery.of(context).size.height;
    final bool isTablet = sw > 600;

    return Container(
      height: sh * 0.8,
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 32 : 24),
          topRight: Radius.circular(isTablet ? 32 : 24),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: sw * 0.12,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: sh * 0.015),
            decoration: BoxDecoration(
              color: PillBinColors.greyLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isTablet ? sw * 0.04 : sw * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          campaign.title,
                          style: PillBinBold.style(
                            fontSize: isTablet ? sw * 0.035 : sw * 0.06,
                            color: PillBinColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? sw * 0.02 : sw * 0.03,
                          vertical: isTablet ? sh * 0.005 : sh * 0.008,
                        ),
                        decoration: BoxDecoration(
                          color: campaign.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          campaign.status,
                          style: PillBinMedium.style(
                            fontSize: isTablet ? sw * 0.02 : sw * 0.03,
                            color: campaign.statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sh * 0.02),
                  Text(
                    campaign.description,
                    style: PillBinRegular.style(
                      fontSize: isTablet ? sw * 0.025 : sw * 0.04,
                      color: PillBinColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: sh * 0.03),
                  _buildDetailRow(
                      'Date', campaign.formattedDate, sw, sh, isTablet),
                  _buildDetailRow(
                      'Location', campaign.location, sw, sh, isTablet),
                  _buildDetailRow(
                      'Status', campaign.timeStatus, sw, sh, isTablet),
                  _buildDetailRow(
                      'Joined Date',
                      '${campaign.joinedDate.day}/${campaign.joinedDate.month}/${campaign.joinedDate.year}',
                      sw,
                      sh,
                      isTablet),
                  _buildDetailRow('Medicines Collected',
                      '${campaign.medicinesCollected} items', sw, sh, isTablet),
                  _buildDetailRow('Participants',
                      '${campaign.participantsCount} people', sw, sh, isTablet),
                  const Spacer(),
                  if (campaign.status == 'Ongoing' ||
                      campaign.status == 'Upcoming')
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.all(isTablet ? sw * 0.025 : sw * 0.04),
                      decoration: BoxDecoration(
                        color: campaign.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: campaign.statusColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        campaign.status == 'Ongoing'
                            ? 'This campaign is currently active. You can participate by bringing your expired medicines to the collection point.'
                            : 'This campaign is scheduled to start soon. Mark your calendar and prepare your expired medicines for safe disposal.',
                        style: PillBinRegular.style(
                          fontSize: isTablet ? sw * 0.02 : sw * 0.035,
                          color: campaign.statusColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, double sw, double sh, bool isTablet) {
    return Padding(
      padding: EdgeInsets.only(bottom: sh * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: PillBinMedium.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                color: PillBinColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: PillBinRegular.style(
                fontSize: isTablet ? sw * 0.022 : sw * 0.038,
                color: PillBinColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
