import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fittin_v2/src/application/active_session_provider.dart';
import 'package:fittin_v2/src/application/auth_provider.dart';
import 'package:fittin_v2/src/application/app_locale_provider.dart';
import 'package:fittin_v2/src/application/sync_provider.dart';
import 'package:fittin_v2/src/application/supabase_bootstrap.dart';
import 'package:fittin_v2/src/application/theme_provider.dart';
import 'package:fittin_v2/src/data/database_repository.dart';
import 'package:fittin_v2/src/data/models/app_state_collection.dart';
import 'package:fittin_v2/src/data/models/instance_collection.dart';
import 'package:fittin_v2/src/data/models/template_collection.dart';
import 'package:fittin_v2/src/data/models/workout_log_collection.dart';
import 'package:fittin_v2/src/data/models/body_metric_collection.dart';
import 'package:fittin_v2/src/data/progress_repository.dart';
import 'package:fittin_v2/src/data/remote/supabase_remote_repository.dart';
import 'package:fittin_v2/src/data/sync/sync_service.dart';
import 'package:fittin_v2/src/presentation/screens/app_shell_screen.dart';
import 'package:fittin_v2/src/presentation/theme/app_colors.dart';
import 'package:fittin_v2/src/presentation/theme/app_styles.dart';
import 'package:fittin_v2/src/data/models/sync_queue_collection.dart';
import 'package:fittin_v2/src/data/web_database_repository.dart';
import 'package:fittin_v2/src/data/web_local_store.dart';
import 'package:fittin_v2/src/data/web_progress_repository.dart';
import 'package:fittin_v2/src/data/web_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final supabaseBootstrap = await initializeSupabase();
  final persistence = await _createLocalPersistence();
  await persistence.databaseRepository.ensureDefaultProgramSeeded();

  runApp(
    ProviderScope(
      overrides: [
        databaseRepositoryProvider.overrideWithValue(
          persistence.databaseRepository,
        ),
        progressRepositoryProvider.overrideWithValue(
          persistence.progressRepository,
        ),
        if (persistence.webDatabaseRepository != null &&
            persistence.webProgressRepository != null)
          syncServiceProvider.overrideWith((ref) {
            return WebSyncService(
              databaseRepository: persistence.webDatabaseRepository!,
              progressRepository: persistence.webProgressRepository!,
              remoteRepository: ref.watch(supabaseRemoteRepositoryProvider),
              ownerUserId: ref.watch(currentUserIdProvider),
            );
          }),
        supabaseBootstrapProvider.overrideWithValue(supabaseBootstrap),
      ],
      child: const FittinApp(),
    ),
  );
}

Future<_LocalPersistenceBundle> _createLocalPersistence() async {
  if (kIsWeb) {
    final store = await WebLocalStore.open();
    final databaseRepository = WebDatabaseRepository(store);
    final progressRepository = WebProgressRepository(store);
    return _LocalPersistenceBundle(
      databaseRepository: databaseRepository,
      progressRepository: progressRepository,
      webDatabaseRepository: databaseRepository,
      webProgressRepository: progressRepository,
    );
  }

  const schemas = [
    AppStateCollectionSchema,
    TemplateCollectionSchema,
    InstanceCollectionSchema,
    WorkoutLogCollectionSchema,
    BodyMetricCollectionSchema,
    ProgressPhotoCollectionSchema,
    SyncQueueCollectionSchema,
  ];

  final appDirectory = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(schemas, directory: appDirectory.path);
  return _LocalPersistenceBundle(
    databaseRepository: DatabaseRepository(isar),
    progressRepository: ProgressRepository(isar),
  );
}

class _LocalPersistenceBundle {
  const _LocalPersistenceBundle({
    required this.databaseRepository,
    required this.progressRepository,
    this.webDatabaseRepository,
    this.webProgressRepository,
  });

  final DatabaseRepository databaseRepository;
  final ProgressRepository progressRepository;
  final WebDatabaseRepository? webDatabaseRepository;
  final WebProgressRepository? webProgressRepository;
}

class FittinApp extends ConsumerWidget {
  const FittinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeType = ref.watch(themeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    final colorScheme = AppColors.getThemeScheme(themeType);

    return MaterialApp(
      title: 'Fittin V2',
      locale: appLocale.locale,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: AppStyles.getTextTheme(colorScheme),
        scaffoldBackgroundColor: colorScheme.surface,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: colorScheme.onSurface,
        ),
      ),
      home: const SyncLifecycleGate(child: AppShellScreen()),
    );
  }
}
