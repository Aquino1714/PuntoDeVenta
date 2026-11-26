import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../widgets/widgets.dart';
import '../../formularios/registrar_nomina_screen.dart';
import '../../formularios/nuevo_empleado_screen.dart';

class FichaEmpleadoScreen extends StatelessWidget {
  final Empleado empleado;
  const FichaEmpleadoScreen({super.key, required this.empleado});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final e = empleado;
          return AppScaffold(
            child: ScreenBody(children: [
              const AppHeader(title: 'Ficha de empleado', back: true),
              ProfileHeader(e.nombre, '${e.cargo} · Activo'),
              const SectionTitle('Información general'),
              InfoBox(children: [
                InfoRow('Teléfono', phoneFmt(e.telefono)),
                InfoRow('Correo', e.correo),
                InfoRow('Dirección', e.direccion.isEmpty ? '—' : e.direccion),
                InfoRow('Turno', e.turno),
                InfoRow('Periodicidad', e.periodicidad),
              ]),
              DarkAmount(label: 'Salario mensual · ${DateTime.now().year}', amount: money(e.salario)),
              const SectionTitle('Periodos de cobro'),
              InfoBox(
                children: e.periodos.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text('Aún no hay pagos registrados',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        )
                      ]
                    : [for (final p in e.periodos) InfoRow(p.titulo, p.estado)],
              ),
              const SizedBox(height: 10),
              PrimaryButton('Registrar nómina',
                  onPressed: () => go(context, RegistrarNominaScreen(empleado: e))),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => go(context, NuevoEmpleadoScreen(editar: e)),
                child: const Text('Editar empleado'),
              ),
            ]),
          );
        },
      );
}
