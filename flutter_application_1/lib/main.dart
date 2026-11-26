import 'package:material_ui/material_ui.dart';
import 'colors/colors.dart';
import 'data/data.dart';
import 'screens/acceso/home_screen.dart';

/// Punto de entrada de la app: carga los datos guardados en el dispositivo
/// y arranca Flutter con [MyApp].
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(const MyApp());
}

/// Widget raíz de la aplicación.
/// Define el título, el tema (Material 3 con el color primario de la app)
/// y la pantalla inicial, que es [HomeScreen].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Business',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.4),
            minimumSize: const Size(0, 44),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
