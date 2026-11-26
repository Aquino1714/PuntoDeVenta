import 'package:material_ui/material_ui.dart';
import '../data/data.dart';
import '../utils/validators.dart';
import '../widgets/widgets.dart';

class RegistrarAbonoScreen extends StatefulWidget {
  final Cliente cliente;
  const RegistrarAbonoScreen({super.key, required this.cliente});
  @override
  State<RegistrarAbonoScreen> createState() => _RegistrarAbonoScreenState();
}

class _RegistrarAbonoScreenState extends State<RegistrarAbonoScreen> {
  final _form = GlobalKey<FormState>();
  final _monto = TextEditingController();
  final _cuenta = TextEditingController();
  final _ref = TextEditingController();
  int _metodo = 0;

  @override
  void dispose() {
    _monto.dispose();
    _cuenta.dispose();
    _ref.dispose();
    super.dispose();
  }

  void _confirmar() {
    if (!_form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisa los campos marcados en rojo')));
      return;
    }
    store.registrarAbono(widget.cliente, double.parse(_monto.text.trim()),
        _metodo == 0 ? 'Efectivo' : 'Transferencia');
    saveAndBack(context, 'Abono registrado');
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.cliente;
    final abono = double.tryParse(_monto.text.trim()) ?? 0.0;
    final nuevo = (c.saldo - abono) < 0 ? 0.0 : c.saldo - abono;
    return AppScaffold(
      child: ScreenBody(children: [
        AppHeader(
            title: 'Registrar abono',
            subtitle: 'Crédito ${c.folio} · ${c.fullName}',
            back: true),
        DarkAmount(label: 'Saldo pendiente', amount: money(c.saldo)),
        Form(
          key: _form,
          child: Column(children: [
            LabeledField('Monto del abono *', '0.00',
                highlight: true,
                controller: _monto,
                validator: (v) => V.monto(v, max: c.saldo),
                prefixText: '\$ ',
                inputFormatters: V.amountFormatters,
                onChanged: (_) => setState(() {})),
            Segmented('Método de pago', const ['Efectivo', 'Transferencia'],
                selected: _metodo, onChanged: (i) => setState(() => _metodo = i)),
            LabeledField(_metodo == 1 ? 'Cuenta de destino *' : 'Cuenta de destino',
                'Banorte · Cuenta principal',
                controller: _cuenta,
                validator: (v) =>
                    _metodo == 1 ? V.requerido(v, 'Indica la cuenta de destino') : null),
            LabeledField('Referencia', 'Opcional', controller: _ref),
          ]),
        ),
        const SectionTitle('Resumen'),
        InfoBox(children: [
          InfoRow('Saldo anterior', money(c.saldo)),
          InfoRow('Abono', money(abono)),
          InfoRow('Nuevo saldo', money(nuevo), bold: true),
        ]),
        const SizedBox(height: 10),
        PrimaryButton('Confirmar abono', onPressed: _confirmar),
      ]),
    );
  }
}
