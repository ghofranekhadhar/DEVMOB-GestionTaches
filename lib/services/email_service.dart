import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  static const String username = 'ghofrane.khadarr@gmail.com';
  static const String password = 'gamyguktlffktojp';

  static Future<String?> sendOTP(String recipientEmail, String code) async {
    // Use the reliable pre-configured gmail() helper which uses Port 465 (SSL)
    // This bypasses Android Emulator port restrictions that block port 587 STARTTLS.
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Task-y App')
      ..recipients.add(recipientEmail)
      ..subject = 'Task-y: Your Password Reset Code'
      ..text =
          '''
Hello,

Your 4-digit password reset code is: $code

Enter this code in the application.

Task-y Team
''';

    try {
      final sendReport = await send(message, smtpServer);
      print(sendReport.toString());
      return null; // Return null if successful
    } catch (e) {
      print('EMAIL ERROR: $e');
      return e.toString();
    }
  }
}
