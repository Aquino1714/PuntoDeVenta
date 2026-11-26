import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../widgets/widgets.dart';
import '../../formularios/nuevo_cliente_screen.dart';

class FichaClienteScreen extends StatelessWidget {
  final Cliente cliente;
  const FichaClienteScreen({super.key, required this.cliente});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: store,
        builder: (context, _) {
          final c = cliente;
          return AppScaffold(
            child: ScreenBody(children: [
              const AppHeader(title: 'Ficha de cliente', back: true),
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
                        icon: const Icon(Icons.mail_outline, size: 16),
                        label: const Text('Correo', style: TextStyle(fontSize: 12)))),
              ]),
              BannerNote(c.tipoPago == 'Crédito'
                  ? 'Crédito ${c.folio} al corriente · sin saldo pendiente.'
                  : 'Este cliente paga de contado y no tiene crédito activo.'),
              const SectionTitle('Últimas compras'),
              InfoBox(
                children: c.compras.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(6),
                          child: Text('Sin compras registradas',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        )
                      ]
                    : [for (final p in c.compras) InfoRow(p[0], p[1])],
              ),
              if (c.abonos.isNotEmpty) ...[
                const SectionTitle('Abonos registrados'),
                InfoBox(children: [
                  for (final m in c.abonos.take(5))
                    InfoRow('${m.fecha} · ${m.titulo}', money(m.monto)),
                ]),
              ],
              const SizedBox(height: 10),
              PrimaryButton('Ver historial completo', onPressed: () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Próximamente')));
              }),
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
