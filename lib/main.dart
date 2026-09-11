import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/network/connectivity_service.dart';
import 'core/network/network_resilience.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'data/local/secure_session_storage.dart';
import 'data/repositories/auth_repository_supabase_impl.dart';
import 'data/repositories/payment_repository_simulated_impl.dart';
import 'data/repositories/waste_repository_hive_impl.dart';
import 'domain/entities/waste_transaction.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/repositories/waste_repository.dart';
import 'domain/usecases/setor_sampah_usecase.dart';
import 'domain/usecases/sign_in_with_email_usecase.dart';
import 'domain/usecases/sign_in_with_google_usecase.dart';
import 'domain/usecases/sign_out_usecase.dart';
import 'domain/usecases/sign_up_with_email_usecase.dart';
import 'domain/usecases/subscribe_premium_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/payment_provider.dart';
import 'presentation/providers/setor_sampah_provider.dart';
import 'presentation/providers/transaksi_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // CPMK 4: inisialisasi Hive sebelum app jalan.
  await HiveService.init();

  // CPMK 5: inisialisasi Supabase — dibungkus try/catch supaya app TETAP
  // BISA JALAN walau kelompok belum sempat isi SupabaseConfig (fitur
  // cloud akan menampilkan pesan error yang jelas, bukan bikin app
  // force-close saat baru dibuka).
  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(url: SupabaseConfig.url, anonKey: SupabaseConfig.anonKey);
    } catch (_) {
      // Biarkan app tetap jalan; AuthRepositorySupabaseImpl & sync akan
      // mengembalikan Failure yang jelas saat benar-benar dipakai.
    }
  }

  runApp(const EcoBankSampahApp());
}

/// Upload satu transaksi ke tabel `waste_transactions` di Supabase.
/// Dipakai sebagai `remoteSync` callback oleh [WasteRepositoryHiveImpl] —
/// kalau ini melempar exception, transaksi tetap tersimpan lokal dan
/// ditandai belum sinkron (lihat waste_repository_hive_impl.dart).
Future<void> _uploadTransactionToSupabase(WasteTransaction transaction) async {
  if (!SupabaseConfig.isConfigured) {
    throw Exception('Supabase belum dikonfigurasi.');
  }

  final result = await NetworkResilience.guard(() {
    return Supabase.instance.client.from('waste_transactions').insert({
      'jenis_sampah': transaction.jenisSampah,
      'berat_kg': transaction.beratKg,
      'nilai_rupiah': transaction.nilaiRupiah,
      'tanggal': transaction.tanggal.toIso8601String(),
    });
  });

  result.when(
    success: (_) {},
    failure: (f) => throw Exception(f.message),
  );
}

class EcoBankSampahApp extends StatelessWidget {
  const EcoBankSampahApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Dependency wiring manual (tanpa DI framework) — cukup untuk skala prototype.
    final ConnectivityService connectivityService = ConnectivityServiceImpl();
    final WasteRepository wasteRepository = WasteRepositoryHiveImpl(
      HiveService.wasteTransactionsBox,
      connectivityService,
      remoteSync: SupabaseConfig.isConfigured ? _uploadTransactionToSupabase : null,
    );
    final setorSampahUseCase = SetorSampahUseCase(wasteRepository);

    final AuthRepository authRepository = AuthRepositorySupabaseImpl();
    final PaymentRepository paymentRepository = PaymentRepositorySimulatedImpl();
    final secureSessionStorage = SecureSessionStorage();

    return MultiProvider(
      providers: [
        Provider<ConnectivityService>.value(value: connectivityService),
        ChangeNotifierProvider(
          create: (_) => SetorSampahProvider(setorSampahUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => TransaksiProvider(wasteRepository, connectivityService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            signUpUseCase: SignUpWithEmailUseCase(authRepository),
            signInUseCase: SignInWithEmailUseCase(authRepository),
            signInWithGoogleUseCase: SignInWithGoogleUseCase(authRepository),
            signOutUseCase: SignOutUseCase(authRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PaymentProvider(
            SubscribePremiumUseCase(paymentRepository),
            secureSessionStorage,
          ),
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
