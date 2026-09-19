import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import Core & Data Services
import 'core/config/supabase_config.dart';
import 'data/datasources/auth_service.dart';
import 'data/datasources/data_seeder.dart';
import 'data/datasources/sync_service.dart';
import 'data/models/app_settings_model.dart';
import 'data/models/category_model.dart';
import 'data/models/customer_model.dart';
import 'data/models/item_model.dart';
import 'data/models/purchase_item_model.dart';
import 'data/models/purchase_transaction_model.dart';
import 'data/models/sale_item_model.dart';
import 'data/models/sale_transaction_model.dart';
import 'data/models/stock_movement_log_model.dart';
import 'data/models/supplier_model.dart';
import 'data/models/user_model.dart';
import 'data/repositories/purchases_repository_impl.dart';
import 'data/repositories/sales_repository_impl.dart';

// Import Domain UseCases & Services
import 'domain/repositories/purchases_repository.dart';
import 'domain/repositories/sales_repository.dart';
import 'domain/services/dashboard_calculator.dart';
import 'domain/usecases/create_purchase_transaction.dart';
import 'domain/usecases/create_sale_transaction.dart';

// Import Presentation (Bloc & UI)
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/theme/theme_controller.dart';

void main() async {
  // 1. Pastikan Flutter Binding sudah siap sebelum inisialisasi async
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Supabase SDK dengan penanganan graceful jika credential masih demo/placeholder
  try {
    if (supabaseUrl.contains('YOUR_SUPABASE_PROJECT_ID')) {
      // Menggunakan fallback URL format agar Supabase.initialize tidak melempar format exception saat demo offline
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        publishableKey: 'placeholder_anon_key_for_offline_first_mode',
      );
    } else {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnonKey,
      );
    }
  } catch (e) {
    debugPrint('Supabase initialisation fallback to offline mode: $e');
  }

  // 3. Inisialisasi Isar Database (Offline-First Storage)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      UserModelSchema,
      ItemModelSchema,
      CategoryModelSchema,
      CustomerModelSchema,
      SupplierModelSchema,
      SaleTransactionModelSchema,
      SaleItemModelSchema,
      PurchaseTransactionModelSchema,
      PurchaseItemModelSchema,
      StockMovementLogModelSchema,
      AppSettingsModelSchema,
    ],
    directory: dir.path,
    name: 'sparepart_pos_db',
  );

  // 4. Jalankan reset sekali saja untuk membuang data dummy lama,
  //    kemudian seed hanya akun user default.
  //    Flag: jika ada record user dengan uuid='__v2_clean__', skip clear.
  const cleanMarkerUuid = '__v2_clean__';
  final alreadyCleaned = await isar.userModels
      .filter()
      .uuidEqualTo(cleanMarkerUuid)
      .findFirst();
  if (alreadyCleaned == null) {
    await DataSeeder.clearAllData(isar);
    // Tulis marker agar clear tidak berjalan lagi di restart berikutnya
    await isar.writeTxn(() async {
      await isar.userModels.put(UserModel(
        uuid: cleanMarkerUuid,
        username: '__migration_marker__',
        email: '__migration__@system.internal',
        role: 'SYSTEM',
        lastLogin: DateTime.now(),
        isSynced: true,
      ));
    });
  }
  await DataSeeder.seedInitialData(isar);
  await DataSeeder.seedDefaultCategories(isar);

  // Muat preferensi tema (Terang/Gelap/Ikuti Sistem) yang tersimpan
  final initialThemeMode = await ThemeController.loadInitial(isar);
  final themeController = ThemeController(isar, initialThemeMode);

  // 5. Inisialisasi Datasources & Repositories
  final supabaseClient = Supabase.instance.client;
  final authService = AuthService(isar: isar, supabaseClient: supabaseClient);
  final syncService = SyncService(isar: isar, supabaseClient: supabaseClient);
  final salesRepository = SalesRepositoryImpl(isar);
  final purchasesRepository = PurchasesRepositoryImpl(isar);
  final createSaleTransaction = CreateSaleTransaction(salesRepository);
  final createPurchaseTransaction =
      CreatePurchaseTransaction(purchasesRepository);
  final dashboardCalculator = DashboardCalculator(isar);

  // Jalankan background sync pertama saat aplikasi mulai jika online
  syncService.syncAll().then((result) {
    if (result.isSuccess) {
      debugPrint("Initial Sync Success: ${result.message}");
    }
  });

  runApp(
    SparepartPOSApp(
      isar: isar,
      authService: authService,
      syncService: syncService,
      salesRepository: salesRepository,
      purchasesRepository: purchasesRepository,
      createSaleTransaction: createSaleTransaction,
      createPurchaseTransaction: createPurchaseTransaction,
      dashboardCalculator: dashboardCalculator,
      themeController: themeController,
    ),
  );
}

class SparepartPOSApp extends StatelessWidget {
  final Isar isar;
  final AuthService authService;
  final SyncService syncService;
  final ISalesRepository salesRepository;
  final IPurchasesRepository purchasesRepository;
  final CreateSaleTransaction createSaleTransaction;
  final CreatePurchaseTransaction createPurchaseTransaction;
  final DashboardCalculator dashboardCalculator;
  final ThemeController themeController;

  const SparepartPOSApp({
    super.key,
    required this.isar,
    required this.authService,
    required this.syncService,
    required this.salesRepository,
    required this.purchasesRepository,
    required this.createSaleTransaction,
    required this.createPurchaseTransaction,
    required this.dashboardCalculator,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Isar>.value(value: isar),
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<SyncService>.value(value: syncService),
        RepositoryProvider<ISalesRepository>.value(value: salesRepository),
        RepositoryProvider<IPurchasesRepository>.value(
            value: purchasesRepository),
        RepositoryProvider<CreateSaleTransaction>.value(
          value: createSaleTransaction,
        ),
        RepositoryProvider<CreatePurchaseTransaction>.value(
          value: createPurchaseTransaction,
        ),
        RepositoryProvider<DashboardCalculator>.value(
          value: dashboardCalculator,
        ),
        ChangeNotifierProvider<ThemeController>.value(value: themeController),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authService: authService),
          ),
        ],
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeController,
          builder: (context, mode, _) {
            return MaterialApp(
              title: 'POS Toko Sparepart',
              debugShowCheckedModeBanner: false,

              // Tema Aplikasi Modern dengan Aksesibilitas Min. Hit Target 48dp
              // & kontras teks yang lebih tegas di kedua mode.
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.light,
                ),
                scaffoldBackgroundColor: const Color(0xFFF6F6F9),
                textTheme: Typography.material2021(platform: TargetPlatform.android)
                    .black
                    .apply(
                      bodyColor: const Color(0xFF16181D),
                      displayColor: const Color(0xFF16181D),
                    ),
                cardTheme: CardThemeData(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(88, 48), // Hit target min. 48dp
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
                scaffoldBackgroundColor: const Color(0xFF121317),
                textTheme: Typography.material2021(platform: TargetPlatform.android)
                    .white
                    .apply(
                      bodyColor: const Color(0xFFF2F3F5),
                      displayColor: const Color(0xFFFFFFFF),
                    ),
                cardTheme: CardThemeData(
                  elevation: 0,
                  color: const Color(0xFF1C1E23),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade700),
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(88, 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              themeMode: mode,

              home: const LoginScreen(),
            );
          },
        ),
      ),
    );
  }
}
