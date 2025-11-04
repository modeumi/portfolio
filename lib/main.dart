import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portfolio/app_router.dart';
import 'package:portfolio/core/app_setting.dart';
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
    return MaterialApp.router(
      supportedLocales: const [Locale('ko', 'KR')],
      debugShowCheckedModeBanner: false,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          final double width = app_width + 40;
          final double height = app_height + 50;
          return Center(
            child: Container(
              constraints: BoxConstraints(minWidth: width, minHeight: height),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SizedBox(
                    width: constraints.maxWidth < width ? width : constraints.maxWidth,
                    height: constraints.maxHeight < height ? height : constraints.maxHeight,
                    child: child,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: route,
    );
  }
}
