import 'package:material_ui/material_ui.dart';
import 'colors/colors.dart';
import 'data/data.dart';

import 'screens/acceso/home_screen.dart';
import 'screens/acceso/inicio_sesion.dart';
import 'screens/acceso/inicio_sesion_empleado.dart';
import 'screens/acceso/registrarse.dart';
import 'screens/acceso/lista_negocios.dart';

import 'screens/negocio/screen5.dart';
import 'screens/negocio/ventas.dart';
import 'screens/inventario/inventario.dart';
import 'screens/inventario/categorias.dart';
import 'screens/inventario/proveedores.dart';
import 'screens/inventario/lista_productos_proveedor.dart';
import 'formularios/nueva_venta_sheet.dart';

import 'screens/clientes/clientes_screen.dart';
import 'screens/clientes/clientes_saldo_screen.dart';
import 'screens/clientes/ficha_cliente_screen.dart';
import 'screens/clientes/ficha_cliente_saldo_screen.dart';
import 'formularios/nuevo_cliente_screen.dart';
import 'formularios/registrar_abono_screen.dart';
import 'screens/empleados/empleados_screen.dart';
import 'screens/empleados/ficha_empleado_screen.dart';
import 'formularios/nuevo_empleado_screen.dart';
import 'formularios/registrar_nomina_screen.dart';

import 'screens/administracion/reportes.dart';
import 'screens/administracion/usuarios.dart';
import 'screens/finanzas/finanzas_cuenta.dart' show FinanzasPage, MiCuentaPage;

/// Punto de entrada alterno, solo para previsualizar pantallas.
/// Se ejecuta con: flutter run -t lib/preview_screen.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await store.load();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      fontFamily: 'Roboto',
    ),
    home: const PreviewScreen(),
  ));
}

/// Menú de desarrollo que lista todas las pantallas agrupadas por sección
/// para abrirlas con un toque y revisarlas sin pasar por el login.
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  /// Abre una pantalla completa encima de la actual.
  void _abrir(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  /// Abre un widget como hoja modal inferior (bottom sheet).
  Future<void> _abrirSheet(BuildContext context, Widget sheet) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => sheet,
      );

  @override
  Widget build(BuildContext context) {
    final grupos = <String, List<_Item>>{
      'Acceso': [
        _Item('Inicio (home)', () => _abrir(context, const HomeScreen())),
        _Item('Login administrador', () => _abrir(context, const Screen1())),
        _Item('Login empleado', () => _abrir(context, const Screen2())),
        _Item('Crear cuenta', () => _abrir(context, const Screen3())),
        _Item('Lista de negocios', () => _abrir(context, const Screen4())),
      ],
      'Negocio': [
        _Item('Inicio del negocio', () => _abrir(context, const Screen5())),
        _Item('Ventas', () => _abrir(context, const VentasScreen())),
        _Item('Nueva venta (sheet)',
            () => _abrirSheet(context, const NewSaleSheet())),
      ],
      'Inventario': [
        _Item('Inventario', () => _abrir(context, const InventarioScreen())),
        _Item('Categorías', () => _abrir(context, const CategoriasScreen())),
        _Item('Proveedores', () => _abrir(context, const ProveedoresScreen())),
        _Item('Productos del proveedor',
            () => _abrir(context, const ListaProductosProveedorScreen())),
      ],
      'Clientes': [
        _Item('Clientes', () => _abrir(context, const ClientesScreen())),
        _Item('Clientes con saldo',
            () => _abrir(context, const ClientesSaldoScreen())),
        _Item('Ficha de cliente',
            () => _abrir(context, FichaClienteScreen(cliente: store.clientes.last))),
        _Item('Ficha cliente con saldo',
            () => _abrir(context, FichaClienteSaldoScreen(cliente: store.clientes.first))),
        _Item('Nuevo cliente',
            () => _abrir(context, const NuevoClienteScreen())),
        _Item('Registrar abono',
            () => _abrir(context, RegistrarAbonoScreen(cliente: store.clientes.first))),
      ],
      'Empleados': [
        _Item('Empleados', () => _abrir(context, const EmpleadosScreen())),
        _Item('Ficha de empleado',
            () => _abrir(context, FichaEmpleadoScreen(empleado: store.empleados.first))),
        _Item('Nuevo empleado',
            () => _abrir(context, const NuevoEmpleadoScreen())),
        _Item('Registrar nómina',
            () => _abrir(context, RegistrarNominaScreen(empleado: store.empleados.first))),
      ],
      'Finanzas y cuenta': [
        _Item('Finanzas', () => _abrir(context, const FinanzasPage())),
        _Item('Mi cuenta', () => _abrir(context, const MiCuentaPage())),
      ],
      'Más (reportes y usuarios)': [
        _Item('Reportes', () => _abrir(context, const ReportesScreen())),
        _Item('Usuarios y permisos',
            () => _abrir(context, const UsuariosScreen())),
        _Item('Configurar usuario',
            () => _abrir(context, const ConfigurarUsuarioScreen())),
      ],
    };

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const Center(
              child: Text(
                'PREVIEW',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Toca una pantalla para abrirla',
                style: TextStyle(fontSize: 16, color: AppColors.muted),
              ),
            ),
            const SizedBox(height: 12),
            for (final g in grupos.entries) ...[
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 8),
                child: Text(
                  g.key,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 10),
              for (final item in g.value)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: item.onTap,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Elemento del menú de preview: texto del botón y acción al tocarlo.
class _Item {
  final String label;
  final VoidCallback onTap;
  const _Item(this.label, this.onTap);
}
