import 'package:material_ui/material_ui.dart';
import '../../data/data.dart';
import '../../utils/navigation.dart';
import '../../widgets/widgets.dart';
import '../empleados/empleados_screen.dart';
import '../../formularios/nuevo_cliente_screen.dart';

class ClientesSaldoScreen extends StatefulWidget {
  const ClientesSaldoScreen({super.key});
  @override
  State<ClientesSaldoScreen> createState() => _ClientesSaldoScreenState();
}

class _ClientesSaldoScreenState extends State<ClientesSaldoScreen> {
  String _q = '';
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        final list = store.clientes.where((c) {
          if (_tab == 1 && !c.tieneSaldo) return false;
          if (_tab == 2 && c.tieneSaldo) return false;
          return startsWithInitial(c.fullName, _q);
        }).toList();
        return AppScaffold(
          subTabs: const ['Empleados', 'Clientes'],
          subIndex: 1,
          onSubTap: (i) {
            if (i == 0) goReplace(context, const EmpleadosScreen());
          },
          child: ScreenBody(children: [
            const AppHeader(
                title: 'Clientes',
                subtitle: 'Comercial Centro',
                back: true),
            DarkAmount(label: 'Saldo por cobrar', amount: money(store.saldoTotal)),
            SearchBox('Buscar por nombre o teléfono', onChanged: (v) => setState(() => _q = v)),
            PrimaryButton('Agregar cliente',
                icon: Icons.add, onPressed: () => go(context, const NuevoClienteScreen())),
            PillTabs(const ['Todos', 'Con saldo', 'Al corriente'],
                selected: _tab, onSelected: (i) => setState(() => _tab = i)),
            for (final c in list)
              PersonTile(
                  c.fullName,
                  c.tieneSaldo
                      ? 'Crédito ${c.folio} · plazo ${c.plazo} días'
                      : (c.tipoPago == 'Crédito' ? 'Al corriente' : 'Pago de contado'),
                  trailing: money(c.saldo),
                  trailingSub: 'Saldo',
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
