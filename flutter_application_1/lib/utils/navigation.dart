import 'package:material_ui/material_ui.dart';
import '../data/data.dart';
import '../widgets/widgets.dart';
import '../screens/clientes/ficha_cliente_screen.dart';
import '../screens/clientes/ficha_cliente_saldo_screen.dart';

/// Abre la ficha que corresponde: con saldo pendiente o simple.
void openCliente(BuildContext context, Cliente c) {
  go(context,
      (c.tipoPago == 'Crédito' && c.tieneSaldo)
          ? FichaClienteSaldoScreen(cliente: c)
          : FichaClienteScreen(cliente: c));
}
