import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pillbin/features/medicines/presentation/widgets/medicine_item.dart';
import 'package:pillbin/network/models/medicine_model.dart';

Medicine build({
  required String name,
  required MedicineStatus status,
  required DateTime expiry,
  String? dosage,
  ProductLinks? links,
}) =>
    Medicine(
      id: 'm1',
      userId: 'u1',
      name: name,
      purchaseDate: DateTime(2026, 1, 1),
      expiryDate: expiry,
      status: status,
      dosage: dosage,
      productLinks: links,
    );

Widget host(Medicine m, {double width = 360}) => MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: width,
          child: MedicineListItem(
            medicine: m,
            sw: width,
            sh: 800,
            onTap: () {},
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

void main() {
  testWidgets('active medicine lays out', (tester) async {
    await tester.pumpWidget(host(build(
      name: 'Paracetamol 500mg',
      status: MedicineStatus.active,
      expiry: DateTime.now().add(const Duration(days: 200)),
      dosage: '500mg',
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('Paracetamol 500mg'), findsOneWidget);
  });

  testWidgets('very long name on a narrow screen does not overflow',
      (tester) async {
    await tester.pumpWidget(host(
      build(
        name: 'Amoxicillin and Clavulanate Potassium Extended Release 875mg',
        status: MedicineStatus.expired,
        expiry: DateTime.now().subtract(const Duration(days: 30)),
        dosage: '875mg / 125mg twice daily after meals',
      ),
      width: 320,
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('expired medicine shows rebuy links', (tester) async {
    await tester.pumpWidget(host(build(
      name: 'Crocin',
      status: MedicineStatus.expired,
      expiry: DateTime.now().subtract(const Duration(days: 5)),
      links: ProductLinks(
        tata1mg: 'https://example.com/1mg',
        pharmeasy: 'https://example.com/pe',
        netmeds: 'https://example.com/nm',
      ),
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('Rebuy'), findsOneWidget);
    expect(find.text('PharmEasy'), findsOneWidget);
  });

  testWidgets('active medicine hides rebuy links', (tester) async {
    await tester.pumpWidget(host(build(
      name: 'Crocin',
      status: MedicineStatus.active,
      expiry: DateTime.now().add(const Duration(days: 120)),
      links: ProductLinks(tata1mg: 'https://example.com/1mg'),
    )));
    expect(tester.takeException(), isNull);
    expect(find.text('Rebuy'), findsNothing);
  });

  testWidgets('menu exposes edit and delete', (tester) async {
    await tester.pumpWidget(host(build(
      name: 'Crocin',
      status: MedicineStatus.active,
      expiry: DateTime.now().add(const Duration(days: 90)),
    )));
    await tester.tap(find.byIcon(Icons.more_vert_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });
}
