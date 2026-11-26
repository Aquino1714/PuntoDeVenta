import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../widgets/widgets.dart';
import '../../formularios/registrar_abono_screen.dart';
import '../../formularios/nuevo_cliente_screen.dart';

class FichaClienteSaldoScreen extends StatelessWidget {
  final Cliente cliente;
  const FichaClienteSaldoScreen({super.key, required this.cliente});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final c = cliente;
          return AppScaffold(
            child: ScreenBody(children: [
              const AppHeader(title: 'Ficha de Cliente', back: true),
              ProfileHeader(c.fullName, 'ID ${c.id} · Cliente activo'),
              InfoBox(children: [
                InfoRow('Teléfono', phoneFmt(c.telefono)),
                InfoRow('Correo', c.correo),
                InfoRow('Dirección', c.direccion.isEmpty ? '—' : c.direccion),
              ]),
              Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call_outlined, size: 16),
                        label: const Text('Llamar', style: TextStyle(fontSize: 12)))),
                const SizedBox(width: 10),
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                        label: const Text('Contacto', style: TextStyle(fontSize: 12)))),
              ]),
              DarkAmount(
                  label: 'Saldo pendiente · ${DateTime.now().year}',
                  amount: money(c.saldo),
                  footer: 'Crédito disponible: ${money(c.limite - c.saldo)}'),
              SectionTitle('Crédito ${c.folio}'),
              InfoBox(children: [
                InfoRow('Límite de crédito', money(c.limite)),
                InfoRow('Saldo actual', money(c.saldo)),
                InfoRow('Plazo', '${c.plazo} días'),
                InfoRow('Abonos registrados', '${c.abonos.length}'),
              ]),
              if (c.abonos.isNotEmpty) ...[
                const SectionTitle('Últimos abonos'),
                InfoBox(children: [
                  for (final m in c.abonos.take(5))
                    InfoRow('${m.fecha} · ${m.titulo}', money(m.monto)),
                ]),
              ],
              const SizedBox(height: 10),
              PrimaryButton('Registrar abono',
                  onPressed: () => go(context, RegistrarAbonoScreen(cliente: c))),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => go(context, NuevoClienteScreen(editar: c)),
                child: const Text('Editar cliente'),
              ),
            ]),
          );
        },
      );
}
