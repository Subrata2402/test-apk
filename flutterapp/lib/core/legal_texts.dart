class LegalSection {
  final String title;
  final List<String> paragraphs;

  const LegalSection({required this.title, required this.paragraphs});
}

class LegalTexts {
  static const String privacyPolicyLastUpdated = 'July 18, 2026';

  static const List<LegalSection> privacyPolicy = [
    LegalSection(
      title: '1. Introduction',
      paragraphs: [
        'Welcome to TestAPK. We respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our web dashboard, mobile application, and command line interface (CLI).',
      ],
    ),
    LegalSection(
      title: '2. Information We Collect',
      paragraphs: [
        'We collect information that you provide directly to us when using our services:',
        '• Account Information: When you sign in using Google OAuth, we receive your name, email address, and profile picture.',
        '• Google Drive Integration: To enable APK storage and management, our application requests permission to access your Google Drive. We only access, create, and modify files that are created by or uploaded through the TestAPK application (using the drive.file scope). We do not access or read any other files in your Google Drive.',
        '• Application Metadata: We collect metadata about the APK files you upload (such as package name, version code, version name, and release notes) to display them in your dashboard and mobile app.',
      ],
    ),
    LegalSection(
      title: '3. How We Use Your Information',
      paragraphs: [
        'We use the collected information for the following purposes:',
        '• To authenticate your identity and manage your account.',
        '• To facilitate the upload, storage, and retrieval of APK files directly to/from your own Google Drive storage.',
        '• To display application release history and details on your dashboard and mobile client.',
        '• To support the CLI tool\'s authentication and upload flows.',
      ],
    ),
    LegalSection(
      title: '4. Data Sharing and Disclosure',
      paragraphs: [
        'We do not sell, trade, or share your personal data or Google Drive files with third parties. All APK files are stored directly in your own Google Drive account. The TestAPK server only stores metadata (such as file IDs, version numbers, and release notes) to coordinate downloads and installations.',
      ],
    ),
    LegalSection(
      title: '5. Data Security',
      paragraphs: [
        'We implement industry-standard security measures to protect your account metadata and authentication tokens. Your Google OAuth tokens are transmitted securely and stored using encryption.',
      ],
    ),
    LegalSection(
      title: '6. Your Rights and Choices',
      paragraphs: [
        'You have full control over your data:',
        '• You can disconnect your Google Drive integration at any time through the dashboard settings.',
        '• You can revoke TestAPK\'s access to your Google Account entirely by visiting the Google Account Permissions page.',
        '• You can request the deletion of your TestAPK account and associated metadata by contacting us.',
      ],
    ),
    LegalSection(
      title: '7. Contact Us',
      paragraphs: [
        'If you have any questions or concerns about this Privacy Policy, please contact us at subrata3250das@gmail.com.',
      ],
    ),
  ];

  static const String termsOfServiceLastUpdated = 'July 18, 2026';

  static const List<LegalSection> termsOfService = [
    LegalSection(
      title: '1. Agreement to Terms',
      paragraphs: [
        'By accessing or using TestAPK, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use our services.',
      ],
    ),
    LegalSection(
      title: '2. Description of Service',
      paragraphs: [
        'TestAPK provides a platform for developers to host, distribute, and manage Android application packages (APKs). The service includes a web dashboard, a mobile client for testing/installation, and a command line interface (CLI) for automated uploads.',
      ],
    ),
    LegalSection(
      title: '3. User Accounts and Security',
      paragraphs: [
        'To use certain features of the service, you must sign in using Google OAuth. You are responsible for maintaining the security of your account credentials and for all activities that occur under your account. You must notify us immediately of any unauthorized use of your account.',
      ],
    ),
    LegalSection(
      title: '4. Google Drive Integration',
      paragraphs: [
        'Our service integrates with Google Drive to store your uploaded APK files. By linking your Google Drive account, you grant TestAPK permission to create, read, and delete files within the specific folder created by the application. You retain full ownership and control of all files stored in your Google Drive.',
      ],
    ),
    LegalSection(
      title: '5. Acceptable Use',
      paragraphs: [
        'You agree not to use the service to:',
        '• Upload or distribute malicious software, viruses, or any code designed to damage or disrupt devices.',
        '• Infringe upon the intellectual property rights of others.',
        '• Violate any applicable local, state, national, or international laws.',
        '• Attempt to gain unauthorized access to the service or its related systems.',
      ],
    ),
    LegalSection(
      title: '6. Limitation of Liability',
      paragraphs: [
        'To the maximum extent permitted by law, TestAPK and its developers shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from your use of the service.',
      ],
    ),
    LegalSection(
      title: '7. Changes to Terms',
      paragraphs: [
        'We reserve the right to modify or replace these Terms of Service at any time. We will notify you of any changes by posting the new terms on this page. Your continued use of the service after any changes constitutes acceptance of the new terms.',
      ],
    ),
    LegalSection(
      title: '8. Contact Us',
      paragraphs: [
        'If you have any questions about these Terms of Service, please contact us at subrata3250das@gmail.com.',
      ],
    ),
  ];
}
