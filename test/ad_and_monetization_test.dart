import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_pregnancy/core/services/ad_service.dart';
import 'package:aura_pregnancy/views/widgets/clay_native_ad_card.dart';
import 'test_helper.dart';

import 'package:flutter/services.dart';
import 'package:aura_pregnancy/views/widgets/pre_att_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/google_mobile_ads'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });

  group('Aura Monetizasyon ve Reklam Testleri', () {
    test('1. AdService test kimlikleri ve başlatma kontrolü', () async {
      final service = AdService.instance;
      expect(AdService.androidAppId, 'ca-app-pub-2626843024156194~8901972198');
      expect(AdService.androidNativeProdId, 'ca-app-pub-2626843024156194/5241928781');
      expect(AdService.androidRewardedProdId, 'ca-app-pub-2626843024156194/6798553034');
      expect(AdService.iosAppId, 'ca-app-pub-2626843024156194~2005391358');
      expect(AdService.iosNativeProdId, 'ca-app-pub-2626843024156194/1254687514');
      expect(AdService.iosRewardedProdId, 'ca-app-pub-2626843024156194/8379228012');
      expect(AdService.androidRewardedTestId, isNotEmpty);
      expect(AdService.iosRewardedTestId, isNotEmpty);
      expect(AdService.androidNativeTestId, isNotEmpty);
      expect(AdService.iosNativeTestId, isNotEmpty);

      await service.initialize();
      expect(service.isInitialized, isTrue);
    });

    testWidgets('2. ClayNativeAdCard widget arayüzde doğru render edilir', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const Scaffold(
            body: SingleChildScrollView(
              child: ClayNativeAdCard(
                title: 'Özel Sponsorlu Başlık',
                description: 'Özel sponsorlu açıklama metni',
                buttonText: 'İncele',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sponsorlu Destekçi'), findsOneWidget);
      expect(find.text('Özel Sponsorlu Başlık'), findsOneWidget);
      expect(find.text('Özel sponsorlu açıklama metni'), findsOneWidget);
      expect(find.text('İncele'), findsOneWidget);
    });

    testWidgets('3. PreAttConsentDialog bileşeni doğru render edilir', (tester) async {
      await tester.pumpWidget(
        createLocalizedTestWidget(
          child: const Scaffold(
            body: PreAttConsentDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kişiselleştirilmiş ve Ücretsiz Deneyim'), findsOneWidget);
      expect(find.text('Anladım, Devam Et'), findsOneWidget);
      expect(find.text('Şimdilik Geç'), findsOneWidget);
    });
  });
}
