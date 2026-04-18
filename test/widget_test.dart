import 'package:flutter_test/flutter_test.dart';
import 'package:highway_app/app/app.dart';

void main() {
  testWidgets('renders calculator home screen', (tester) async {
    await tester.pumpWidget(const HighwayApp());

    expect(find.text('고속 통행료 할인 계산기'), findsOneWidget);
    expect(find.text('출차 시간 계산하기'), findsOneWidget);
    expect(find.text('IC 선택'), findsOneWidget);
  });
}
