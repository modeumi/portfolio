import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/app_router.dart';
import 'package:portfolio/core/firebase_options.dart';
import 'package:utility/import_package.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ko_KR', null);

  await dotenv.load(fileName: 'cryption.env');

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final route = ref.watch(routerProvider);
    return OKToast(
      child: MaterialApp.router(
        supportedLocales: const [Locale('ko', 'KR')],
        debugShowCheckedModeBanner: false,
        // 뷰포트 크기를 그대로 전달 → 각 레이아웃이 스스로 스케일(phone_layout은 FittedBox)
        builder: (context, child) => child ?? const SizedBox.shrink(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: route,
      ),
    );
  }
}
