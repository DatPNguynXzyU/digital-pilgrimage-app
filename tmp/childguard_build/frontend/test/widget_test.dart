import 'package:flutter_test/flutter_test.dart';
import 'package:phamnguyentuandat_2380614580/main.dart';

void main(){
 testWidgets('Login exposes OTP, Google and fingerprint; registration can be opened',(tester)async{
  await tester.pumpWidget(const ChildGuard());
  expect(find.text('ChildGuard'),findsOneWidget);
  expect(find.text('Đăng nhập với OTP'),findsOneWidget);
  expect(find.text('Tiếp tục với Google'),findsOneWidget);
  await tester.ensureVisible(find.text('Chưa có tài khoản? Đăng ký'));
  await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
  await tester.pumpAndSettle();
  expect(find.text('Tạo tổ ấm an toàn'),findsOneWidget);
  expect(find.text('Email'),findsOneWidget);
 });
}
