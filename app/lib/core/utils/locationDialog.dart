import 'package:flutter/material.dart';
import 'package:pillbin/config/theme/appColors.dart';

Future<bool> showLocationDisclosure(BuildContext context) async {
  final bool? userResponse = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('Location Access Required'),
        content: const Text(
          'PillBin uses your location to help you find nearby medicine disposal centers.\n\n'
          'Your location is used only when you choose to search for disposal centers '
          'and is not stored or tracked continuously.\n\n'
          'The app does not access your location in the background at any time.\n\n'
          'You can continue without granting location access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Not Now',
              style: TextStyle(color: PillBinColors.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue',
                style: TextStyle(color: PillBinColors.primary)),
          ),
        ],
      );
    },
  );

  return userResponse ?? false;
}
