import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/medicines/data/repository/family_member_provider.dart';
import 'package:pillbin/network/models/family_member_model.dart';
import 'package:provider/provider.dart';

class ManageFamilyScreen extends StatefulWidget {
  const ManageFamilyScreen({Key? key}) : super(key: key);

  @override
  State<ManageFamilyScreen> createState() => _ManageFamilyScreenState();
}

class _ManageFamilyScreenState extends State<ManageFamilyScreen> {
  bool _isAdding = false;

  InputDecoration _fieldDecoration(double sw, String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle:
          PillBinRegular.style(fontSize: sw * 0.034, color: PillBinColors.textSecondary),
      hintStyle:
          PillBinRegular.style(fontSize: sw * 0.034, color: PillBinColors.textLight),
      contentPadding:
          EdgeInsets.symmetric(horizontal: sw * 0.04, vertical: sw * 0.035),
      filled: true,
      fillColor: PillBinColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: PillBinColors.greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: PillBinColors.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: PillBinColors.primary, width: 2),
      ),
    );
  }

  Future<void> _openAddSheet() async {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(sw * 0.05, sh * 0.025, sw * 0.05,
              sh * 0.03),
          decoration: BoxDecoration(
            color: PillBinColors.background,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add family member',
                  style: PillBinBold.style(
                      fontSize: sw * 0.045,
                      color: PillBinColors.textPrimary)),
              SizedBox(height: sh * 0.02),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: PillBinRegular.style(
                    fontSize: sw * 0.038, color: PillBinColors.textPrimary),
                decoration: _fieldDecoration(sw, 'Name', 'e.g., Mom'),
              ),
              SizedBox(height: sh * 0.015),
              TextField(
                controller: relationCtrl,
                style: PillBinRegular.style(
                    fontSize: sw * 0.038, color: PillBinColors.textPrimary),
                decoration:
                    _fieldDecoration(sw, 'Relation (optional)', 'e.g., Mother'),
              ),
              SizedBox(height: sh * 0.025),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PillBinColors.primary,
                    padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('Add',
                      style: PillBinMedium.style(
                          fontSize: sw * 0.038, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      final name = nameCtrl.text.trim();
      if (name.isEmpty) return;

      setState(() => _isAdding = true);
      final ok = await context.read<FamilyMemberProvider>().add(
            name: name,
            relation: relationCtrl.text.trim().isEmpty
                ? null
                : relationCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() => _isAdding = false);

      if (!ok) {
        CustomSnackBar.show(
          context: context,
          icon: Icons.error_outline,
          title:
              context.read<FamilyMemberProvider>().lastError ?? 'Could not add',
        );
      }
    });
  }

  Future<void> _confirmRemove(FamilyMember member) async {
    final sw = MediaQuery.of(context).size.width;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove ${member.name}?',
            style: PillBinBold.style(
                fontSize: sw * 0.042, color: PillBinColors.textPrimary)),
        content: Text(
          'Medicines already tagged to ${member.name} will move back to you.',
          style: PillBinRegular.style(
              fontSize: sw * 0.034, color: PillBinColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel',
                style: PillBinMedium.style(
                    fontSize: sw * 0.036, color: PillBinColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Remove',
                style: PillBinMedium.style(
                    fontSize: sw * 0.036, color: PillBinColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context.read<FamilyMemberProvider>().remove(member.id);
    if (!mounted) return;
    if (!ok) {
      CustomSnackBar.show(
        context: context,
        icon: Icons.error_outline,
        title: context.read<FamilyMemberProvider>().lastError ??
            'Could not remove',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: PillBinColors.background,
      appBar: AppBar(
        backgroundColor: PillBinColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: sw * 0.05, color: PillBinColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Manage Family',
            style: PillBinBold.style(
                fontSize: sw * 0.046, color: PillBinColors.textPrimary)),
      ),
      body: SafeArea(
        child: Consumer<FamilyMemberProvider>(
          builder: (context, familyProvider, _) {
            final members = familyProvider.members;

            return Column(
              children: [
                Expanded(
                  child: familyProvider.isLoading && members.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : members.isEmpty
                          ? _emptyState(sw, sh)
                          : ListView.separated(
                              padding: EdgeInsets.all(sw * 0.05),
                              itemCount: members.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: sh * 0.012),
                              itemBuilder: (context, index) {
                                final member = members[index];
                                return _memberTile(sw, sh, member);
                              },
                            ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      sw * 0.05, 0, sw * 0.05, sh * 0.02),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isAdding ? null : _openAddSheet,
                      icon: Icon(Icons.add, size: sw * 0.045),
                      label: Text('Add family member',
                          style: PillBinMedium.style(
                              fontSize: sw * 0.038,
                              color: PillBinColors.primary)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: PillBinColors.primary),
                        padding: EdgeInsets.symmetric(vertical: sh * 0.016),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState(double sw, double sh) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sw * 0.1),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.family_restroom_rounded,
                size: sw * 0.16, color: PillBinColors.textLight),
            SizedBox(height: sh * 0.02),
            Text('No family members yet',
                style: PillBinMedium.style(
                    fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.008),
            Text(
              'Add someone to track their medicines separately from yours.',
              textAlign: TextAlign.center,
              style: PillBinRegular.style(
                  fontSize: sw * 0.034, color: PillBinColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile(double sw, double sh, FamilyMember member) {
    return Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: PillBinColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PillBinColors.greyLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: sw * 0.05,
            backgroundColor: PillBinColors.primary.withValues(alpha: 0.1),
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: PillBinBold.style(
                  fontSize: sw * 0.04, color: PillBinColors.primary),
            ),
          ),
          SizedBox(width: sw * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: PillBinMedium.style(
                        fontSize: sw * 0.04,
                        color: PillBinColors.textPrimary)),
                if (member.relation != null && member.relation!.isNotEmpty)
                  Text(member.relation!,
                      style: PillBinRegular.style(
                          fontSize: sw * 0.032,
                          color: PillBinColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline_rounded,
                size: sw * 0.05, color: PillBinColors.error),
            onPressed: () => _confirmRemove(member),
          ),
        ],
      ),
    );
  }
}
