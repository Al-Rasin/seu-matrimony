import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:seu_matrimony/modules/auth/login/login_screen.dart';
import 'package:seu_matrimony/modules/auth/login/login_controller.dart';
import 'package:seu_matrimony/data/repositories/auth_repository.dart';

@GenerateNiceMocks([MockSpec<AuthRepository>()])
import 'login_screen_test.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    Get.put<AuthRepository>(mockAuthRepository);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LoginScreen should display username and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
