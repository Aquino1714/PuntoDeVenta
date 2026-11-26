import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../widgets/widgets.dart';
import '../clientes/clientes_screen.dart';
import '../../formularios/nuevo_empleado_screen.dart';
import 'ficha_empleado_screen.dart';

class EmpleadosScreen extends StatefulWidget {
  const EmpleadosScreen({super.key});
  @override
  State<EmpleadosScreen> createState() => _EmpleadosScreenState();
}

class _EmpleadosScreenState extends State<EmpleadosScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final list = store.empleados.where((e) => startsWithInitial(e.nombre, _q)).toList();
        return AppScaffold(
          subTabs: const ['Empleados', 'Clientes'],
          subIndex: 0,
          onSubTap: (i) {
            if (i == 1) goReplace(context, const ClientesScreen());
          },
          child: ScreenBody(children: [
            const AppHeader(title: 'Comercial Centro'),
            const SizedBox(height: 6),
            DarkCard(
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _Stat('Liquidación', '${store.empleados.length} empleados'),
                _Stat('Nómina mensual', money(store.nominaMensual)),
              ]),
            ),
            SearchBox('Buscar por nombre o teléfono', onChanged: (v) => setState(() => _q = v)),
            PrimaryButton('Agregar empleado',
                icon: Icons.add, onPressed: () => go(context, const NuevoEmpleadoScreen())),
            PillTabs(['Todos · ${list.length}']),
            for (final e in list)
              PersonTile(e.nombre, e.subtitulo,
                  trailing: 'Activo',
                  chip: true,
                  onTap: () => go(context, FichaEmpleadoScreen(empleado: e))),
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

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat(this.label, this.value);
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ]);
}
