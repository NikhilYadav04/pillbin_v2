import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillbin/features/donation/presentation/pages/donation_receipt_screen.dart';

DonationReceiptData sample(int count) => DonationReceiptData(
      requestId: '6a80b573866a2546a09a3eeb',
      createdAt: DateTime(2026, 7, 2),
      completedAt: DateTime(2026, 8, 14),
      medicines: List.generate(
        count,
        (i) => ReceiptMedicine(
          name: 'Paracetamol ${500 + i}mg extended release tablets',
          category: ['Tablet', 'Syrup', 'Capsule'][i % 3],
          quantity: '${(i % 5) + 1}',
          condition: ['sealed', 'opened', 'unknown'][i % 3],
        ),
      ),
      donorName: 'Nikhil Yadav',
      donorEmail: 'nikhil.yadav@naviconinfra.com',
      donorPhone: '+91 98765 43210',
      centerName: 'Sunrise Medical Center',
      centerAddress: '22 MG Road, Sector 14, Gurugram, Haryana 122001',
      centerPhone: '+91 124 400 1234',
    );

void main() {
  for (final count in [1, 14, 34]) {
    testWidgets('receipt lays out with $count medicines', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DonationReceiptScreen(data: sample(count))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('DONATION RECEIPT'), findsOneWidget);
      expect(find.text('Share Receipt'), findsOneWidget);
    });
  }

  test('receipt number matches the server formula', () {
    expect(sample(1).receiptNumber, 'PB-2026-A09A3EEB');
  });

  test('total units counts numeric quantities', () {
    expect(sample(14).totalUnits, 40);
  });
}
