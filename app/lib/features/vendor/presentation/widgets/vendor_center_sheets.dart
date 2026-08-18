import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pillbin/config/theme/appColors.dart';
import 'package:pillbin/config/theme/appTextStyles.dart';
import 'package:pillbin/core/utils/snackBar.dart';
import 'package:pillbin/features/vendor/data/models/vendor_models.dart';
import 'package:pillbin/features/vendor/data/repository/vendor_provider.dart';
import 'package:provider/provider.dart';

void showVendorCenterDetailsSheet(BuildContext context, VendorCenter? center) {
  if (center == null) return;
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: PillBinColors.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(sw * 0.06, sh * 0.025, sw * 0.06, sh * 0.035),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: sw * 0.1,
                height: 4,
                decoration: BoxDecoration(
                  color: PillBinColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: sh * 0.02),
            Text('Center Details',
                style: PillBinBold.style(fontSize: sw * 0.05, color: PillBinColors.textPrimary)),
            SizedBox(height: sh * 0.02),
            _detailRow(context, sw, sh, Icons.business_outlined, 'Name', center.name),
            _detailRow(context, sw, sh, Icons.local_hospital_outlined, 'Type', center.facilityType),
            _detailRow(context, sw, sh, Icons.location_on_outlined, 'Address', center.address),
            _detailRow(context, sw, sh, Icons.phone_outlined, 'Phone', center.phoneNumber),
            if (center.email != null && center.email!.isNotEmpty)
              _detailRow(context, sw, sh, Icons.email_outlined, 'Email', center.email),
            if (center.website != null && center.website!.isNotEmpty)
              _detailRow(context, sw, sh, Icons.language_outlined, 'Website', center.website),
            if (center.images.isNotEmpty) ...[
              SizedBox(height: sh * 0.014),
              Text('Photos',
                  style: PillBinRegular.style(
                      fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
              SizedBox(height: sh * 0.008),
              SizedBox(
                height: sw * 0.25,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: center.images.length,
                  separatorBuilder: (_, __) => SizedBox(width: sw * 0.025),
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: center.images[i].url,
                      width: sw * 0.25,
                      height: sw * 0.25,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: sw * 0.25,
                        height: sw * 0.25,
                        color: PillBinColors.greyLight,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: sw * 0.25,
                        height: sw * 0.25,
                        color: PillBinColors.greyLight,
                        child: Icon(Icons.broken_image_outlined,
                            color: PillBinColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            SizedBox(height: sh * 0.025),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PillBinColors.primary, PillBinColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PillBinColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(ctx);
                    showVendorEditCenterSheet(context, center);
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: sh * 0.018),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit_outlined,
                            color: Colors.white, size: 20),
                        SizedBox(width: sw * 0.02),
                        Text('Edit Details',
                            style: PillBinMedium.style(
                                fontSize: sw * 0.042, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _detailRow(BuildContext context, double sw, double sh, IconData icon, String label, dynamic value) {
  if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: EdgeInsets.only(bottom: sh * 0.014),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: sw * 0.045, color: PillBinColors.primary),
        SizedBox(width: sw * 0.03),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: PillBinRegular.style(
                      fontSize: sw * 0.028, color: PillBinColors.textSecondary)),
              Text(value.toString(),
                  style: PillBinMedium.style(
                      fontSize: sw * 0.036, color: PillBinColors.textPrimary)),
            ],
          ),
        ),
      ],
    ),
  );
}

Future<void> _pickCenterImage(BuildContext context, 
    List<File> images, void Function(void Function()) setSheetState) async {
  final picker = ImagePicker();
  final xfile =
      await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (xfile == null) return;
  final cropped = await ImageCropper().cropImage(
    sourcePath: xfile.path,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: PillBinColors.primary,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      ),
      IOSUiSettings(title: 'Crop Image'),
    ],
  );
  if (cropped != null) {
    setSheetState(() => images.add(File(cropped.path)));
  }
}

void showVendorEditCenterSheet(BuildContext context, VendorCenter center) {
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;

  final nameCtrl = TextEditingController(text: center.name);
  final addressCtrl = TextEditingController(text: center.address);
  final phoneCtrl = TextEditingController(text: center.phoneNumber);
  final emailCtrl = TextEditingController(text: center.email ?? '');
  final websiteCtrl = TextEditingController(text: center.website ?? '');
  String facilityType =
      center.facilityType.isNotEmpty ? center.facilityType : 'pharmacy';
  final formKey = GlobalKey<FormState>();
  final List<File> newImages = [];
  // Keep full objects so we can pass publicIds to the backend on save
  final List<Map<String, String>> existingImages = center.images
      .map((img) => {'url': img.url, 'publicId': img.publicId})
      .toList();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: sh * 0.9),
            decoration: const BoxDecoration(
              color: PillBinColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: sh * 0.014),
                Container(
                  width: sw * 0.11,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PillBinColors.greyLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      sw * 0.06, sh * 0.022, sw * 0.04, sh * 0.018),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Edit Center Details',
                                style: PillBinBold.style(
                                    fontSize: sw * 0.05,
                                    color: PillBinColors.textDark)),
                            SizedBox(height: sh * 0.004),
                            Text('Donors see this information',
                                style: PillBinRegular.style(
                                    fontSize: sw * 0.032,
                                    color: PillBinColors.textSecondary)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: EdgeInsets.all(sw * 0.022),
                          decoration: BoxDecoration(
                            color: PillBinColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close_rounded,
                              size: sw * 0.045,
                              color: PillBinColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: PillBinColors.greyLight),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        sw * 0.06, sh * 0.022, sw * 0.06, sh * 0.03),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editSectionLabel('Basic details', sw, sh),
                          _editField(context, nameCtrl, 'Center Name',
                              Icons.business_outlined,
                              hint: 'e.g. Sunrise Medical Center',
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null),
                          SizedBox(height: sh * 0.02),
                          _editField(context, addressCtrl, 'Address',
                              Icons.location_on_outlined,
                              hint: 'Shop no, street, area, city',
                              isRequired: true,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Required'
                                  : null),
                          SizedBox(height: sh * 0.02),
                          _editField(context, phoneCtrl, 'Phone Number',
                              Icons.phone_outlined,
                              hint: '10-digit mobile number',
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Required';
                                if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                  return 'Enter a valid 10-digit number';
                                }
                                return null;
                              }),
                          SizedBox(height: sh * 0.03),
                          _editSectionLabel('Contact (optional)', sw, sh),
                          _editField(context, emailCtrl, 'Email',
                              Icons.email_outlined,
                              hint: 'contact@yourcenter.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return null;
                                return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                        .hasMatch(value)
                                    ? null
                                    : 'Enter a valid email';
                              }),
                          SizedBox(height: sh * 0.02),
                          _editField(context, websiteCtrl, 'Website',
                              Icons.language_outlined,
                              hint: 'https://yourcenter.com',
                              keyboardType: TextInputType.url,
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return null;
                                return value.contains('.') &&
                                        !value.contains(' ')
                                    ? null
                                    : 'Enter a valid website';
                              }),
                          SizedBox(height: sh * 0.03),
                          _editSectionLabel('Facility & photos', sw, sh),
                          Text('Facility Type',
                              style: PillBinMedium.style(
                                  fontSize: sw * 0.04,
                                  color: PillBinColors.textPrimary)),
                          SizedBox(height: sh * 0.008),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: sw * 0.04),
                            decoration: BoxDecoration(
                              color: PillBinColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: PillBinColors.greyLight),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: facilityType,
                                isExpanded: true,
                                icon: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: PillBinColors.textSecondary),
                                items: [
                                  'pharmacy',
                                  'hospital',
                                  'clinic',
                                  'health_center'
                                ]
                                    .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(
                                              t[0].toUpperCase() +
                                                  t
                                                      .substring(1)
                                                      .replaceAll('_', ' '),
                                              style: PillBinRegular.style(
                                                  fontSize: sw * 0.036,
                                                  color: PillBinColors
                                                      .textDark)),
                                        ))
                                    .toList(),
                                onChanged: (v) =>
                                    setSheetState(() => facilityType = v!),
                              ),
                            ),
                          ),
                          SizedBox(height: sh * 0.022),
                          Row(
                            children: [
                              Text('Center Photos',
                                  style: PillBinMedium.style(
                                      fontSize: sw * 0.04,
                                      color: PillBinColors.textPrimary)),
                              SizedBox(width: sw * 0.015),
                              Text(
                                  '${existingImages.length + newImages.length} of 3',
                                  style: PillBinRegular.style(
                                      fontSize: sw * 0.03,
                                      color: PillBinColors.textLight)),
                            ],
                          ),
                          SizedBox(height: sh * 0.012),
                          _editPhotoSlots(context, sw, sh, existingImages, newImages,
                              setSheetState),
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                    height: 1,
                    thickness: 1,
                    color: PillBinColors.greyLight),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      sw * 0.06, sh * 0.016, sw * 0.06, sh * 0.024),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          PillBinColors.primary,
                          PillBinColors.primaryLight
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:
                              PillBinColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          if (!formKey.currentState!.validate()) return;
                          Navigator.pop(ctx);
                          final vp = context.read<VendorProvider>();
                          final centerOk = await vp.updateCenter({
                            'name': nameCtrl.text.trim(),
                            'address': addressCtrl.text.trim(),
                            'phoneNumber': phoneCtrl.text.trim(),
                            if (emailCtrl.text.trim().isNotEmpty)
                              'email': emailCtrl.text.trim(),
                            if (websiteCtrl.text.trim().isNotEmpty)
                              'website': websiteCtrl.text.trim(),
                            'facilityType': facilityType,
                          });
                          if (!context.mounted) return;
                          if (centerOk) {
                            CustomSnackBar.show(
                                context: context,
                                icon: Icons.check_circle_outline,
                                title: 'Center updated successfully');
                          } else {
                            CustomSnackBar.show(
                                context: context,
                                icon: Icons.error_outline,
                                title: vp.lastError ??
                                    'Failed to update center');
                          }
                          // Upload if there are new images OR if existing images
                          // were removed (so the backend can delete the right ones)
                          final originalCount = center.images.length;
                          final imagesChanged = newImages.isNotEmpty ||
                              existingImages.length != originalCount;
                          if (imagesChanged) {
                            final keepIds = existingImages
                                .map((img) => img['publicId']!)
                                .toList();
                            final imgOk = await vp.updateCenterImages(
                                newImages, keepPublicIds: keepIds);
                            if (!context.mounted) return;
                            if (imgOk) {
                              CustomSnackBar.show(
                                  context: context,
                                  icon: Icons.check_circle_outline,
                                  title: 'Center images updated');
                            } else {
                              CustomSnackBar.show(
                                  context: context,
                                  icon: Icons.error_outline,
                                  title: vp.lastError ??
                                      'Failed to update images');
                            }
                          }
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: sh * 0.018),
                          child: Center(
                            child: Text('Save Changes',
                                style: PillBinMedium.style(
                                    fontSize: sw * 0.042,
                                    color: Colors.white)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

Widget _editSectionLabel(String text, double sw, double sh) {
  return Padding(
    padding: EdgeInsets.only(bottom: sh * 0.014),
    child: Row(
      children: [
        Container(
          width: sw * 0.008,
          height: sw * 0.035,
          decoration: BoxDecoration(
            color: PillBinColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: sw * 0.025),
        Text(text.toUpperCase(),
            style: PillBinMedium.style(
                fontSize: sw * 0.03, color: PillBinColors.textSecondary)),
      ],
    ),
  );
}

Widget _editPhotoSlots(
  BuildContext context,
  double sw,
  double sh,
  List<Map<String, String>> existingImages,
  List<File> newImages,
  void Function(void Function()) setSheetState,
) {
  final slot = sw * 0.24;
  final filled = <Widget>[];

  for (final img in existingImages) {
    filled.add(_editPhotoTile(
      slot,
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: img['url']!,
          width: slot,
          height: slot,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: PillBinColors.greyLight,
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (_, __, ___) => Container(
            color: PillBinColors.greyLight,
            child: Icon(Icons.broken_image_outlined,
                color: PillBinColors.textSecondary),
          ),
        ),
      ),
      () => setSheetState(() => existingImages.remove(img)),
    ));
  }

  for (final file in newImages) {
    filled.add(_editPhotoTile(
      slot,
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(file,
            width: slot, height: slot, fit: BoxFit.cover),
      ),
      () => setSheetState(() => newImages.remove(file)),
    ));
  }

  final children = <Widget>[];
  for (var i = 0; i < 3; i++) {
    if (i > 0) children.add(SizedBox(width: sw * 0.03));
    if (i < filled.length) {
      children.add(filled[i]);
    } else if (i == filled.length) {
      children.add(GestureDetector(
        onTap: () => _pickCenterImage(context, newImages, setSheetState),
        child: Container(
          width: slot,
          height: slot,
          decoration: BoxDecoration(
            color: PillBinColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: PillBinColors.primary.withValues(alpha: 0.4),
                width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined,
                  color: PillBinColors.primary, size: sw * 0.06),
              SizedBox(height: sh * 0.005),
              Text('Add',
                  style: PillBinMedium.style(
                      fontSize: sw * 0.028,
                      color: PillBinColors.primary)),
            ],
          ),
        ),
      ));
    } else {
      children.add(Container(
        width: slot,
        height: slot,
        decoration: BoxDecoration(
          color: PillBinColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PillBinColors.greyLight),
        ),
      ));
    }
  }

  return Row(children: children);
}

Widget _editPhotoTile(double slot, Widget image, VoidCallback onRemove) {
  return SizedBox(
    width: slot,
    height: slot,
    child: Stack(
      children: [
        Positioned.fill(child: image),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 13, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _editField(
  BuildContext context,
  TextEditingController ctrl,
  String label,
  IconData icon, {
  String? hint,
  bool isRequired = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  final sw = MediaQuery.of(context).size.width;
  final sh = MediaQuery.of(context).size.height;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(label,
              style: PillBinMedium.style(
                  fontSize: sw * 0.04, color: PillBinColors.textPrimary)),
          if (isRequired) ...[
            SizedBox(width: sw * 0.01),
            Text('*',
                style: PillBinMedium.style(
                    fontSize: sw * 0.04, color: PillBinColors.error)),
          ],
        ],
      ),
      SizedBox(height: sh * 0.008),
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: PillBinRegular.style(
              fontSize: sw * 0.035, color: PillBinColors.textLight),
          prefixIcon: Icon(icon, color: PillBinColors.textSecondary),
          filled: true,
          fillColor: PillBinColors.surface,
          contentPadding: EdgeInsets.all(sw * 0.04),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.greyLight)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: PillBinColors.primary, width: 2)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.error, width: 1)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: PillBinColors.error, width: 2)),
        ),
        style: PillBinRegular.style(
            fontSize: sw * 0.036, color: PillBinColors.textDark),
      ),
    ],
  );
}

