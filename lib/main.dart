import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/waste_repository_dummy_impl.dart';
import 'domain/repositories/waste_repository.dart';
import 'domain/usecases/setor_sampah_usecase.dart';
import 'presentation/providers/setor_sampah_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const EcoBankSampahApp());
}

class EcoBankSampahApp extends StatelessWidget {
  const EcoBankSampahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency wiring manual (tanpa DI framework) — cukup untuk skala prototype.
    // Kalau project membesar, ini yang biasanya diganti pakai get_it/injectable.
    final WasteRepository wasteRepository = WasteRepositoryDummyImpl();
    final setorSampahUseCase = SetorSampahUseCase(wasteRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SetorSampahProvider(setorSampahUseCase),
        ),
      ],
      child: MaterialApp(
        title: 'EcoBank Sampah',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
