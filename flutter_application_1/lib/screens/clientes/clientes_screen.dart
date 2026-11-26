import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../utils/navigation.dart';
import '../../widgets/widgets.dart';
import '../empleados/empleados_screen.dart';
import 'clientes_saldo_screen.dart';
import '../../formularios/nuevo_cliente_screen.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final list = store.clientes.where((c) => startsWithInitial(c.fullName, _q)).toList();
        return AppScaffold(
          subTabs: const ['Empleados', 'Clientes'],
          subIndex: 1,
          onSubTap: (i) {
            if (i == 0) goReplace(context, const EmpleadosScreen());
          },
          child: ScreenBody(children: [
            const AppHeader(title: 'Clientes', subtitle: 'Comercial Centro'),
            const SizedBox(height: 10),
            const Text('Tus clientes, a la mano.',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text('Consulta los datos de tus clientes y su historial de compras.',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
            SearchBox('Buscar por nombre o teléfono', onChanged: (v) => setState(() => _q = v)),
            PrimaryButton('Agregar cliente',
                icon: Icons.add, onPressed: () => go(context, const NuevoClienteScreen())),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => go(context, const ClientesSaldoScreen()),
              child: const BannerNote('Ver clientes con saldo pendiente  →'),
            ),
            PillTabs(['Todos · ${list.length}']),
            for (final c in list)
              PersonTile(c.fullName, 'Tel. ${phoneFmt(c.telefono)}',
                  onTap: () => openCliente(context, c)),
            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Sin resultados', style: TextStyle(color: Colors.grey))),
              ),
          ]),
        );
      },
    );
  }
}
