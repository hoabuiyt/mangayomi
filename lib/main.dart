import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mangayomi/constant.dart';
import 'package:mangayomi/models/manga_history.dart';
import 'package:mangayomi/models/model_manga.dart';
import 'package:mangayomi/router/router.dart';
import 'package:mangayomi/source/source_model.dart';
import 'package:mangayomi/views/manga/reader/providers/reader_controller_provider.dart';
import 'package:mangayomi/views/more/settings/appearance/providers/blend_level_state_provider.dart';
import 'views/more/settings/appearance/providers/flex_scheme_color_state_provider.dart';
import 'views/more/settings/appearance/providers/theme_mode_state_provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ModelMangaAdapter());
  Hive.registerAdapter(MangaHistoryModelAdapter());
  Hive.registerAdapter(SourceModelAdapter());
  Hive.registerAdapter(ReaderModeAdapter());
  Hive.registerAdapter(TypeSourceAdapter());
  await Hive.openBox<ModelManga>(HiveConstant.hiveBoxManga);
  await Hive.openBox<MangaHistoryModel>(HiveConstant.hiveBoxMangaHistory);
  await Hive.openBox<ReaderMode>(HiveConstant.hiveBoxReaderMode);
  await Hive.openBox<SourceModel>(HiveConstant.hiveBoxMangaSource);
  await Hive.openBox(HiveConstant.hiveBoxMangaInfo);
  await Hive.openBox(HiveConstant.hiveBoxMangaFilter);
  await Hive.openBox(HiveConstant.hiveBoxAppSettings);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isThemeLight = ref.watch(themeModeStateProvider);
    final blendLevel = ref.watch(blendLevelStateProvider);
    ThemeData themeLight = FlexThemeData.light(
      colors: ref.watch(flexSchemeColorStateProvider),
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: blendLevel.toInt(),
      appBarOpacity: 0.00,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 24,
        thinBorderWidth: 2.0,
        unselectedToggleIsColored: true,
        inputDecoratorRadius: 24.0,
        chipRadius: 24.0,
        dialogBackgroundSchemeColor: SchemeColor.background,
      ),
      useMaterial3ErrorColors: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.aBeeZee().fontFamily,
    );
    ThemeData themeDark = FlexThemeData.dark(
      colors: ref.watch(flexSchemeColorStateProvider),
      surfaceMode: FlexSurfaceMode.highScaffoldLevelSurface,
      blendLevel: blendLevel.toInt(),
      appBarOpacity: 0.00,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 24,
        thinBorderWidth: 2.0,
        unselectedToggleIsColored: true,
        inputDecoratorRadius: 24.0,
        chipRadius: 24.0,
        dialogBackgroundSchemeColor: SchemeColor.background,
      ),
      useMaterial3ErrorColors: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.aBeeZee().fontFamily,
    );
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: isThemeLight ? themeLight : themeDark,
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      title: 'MangaYomi',
    );
  }
}
