import 'package:material_ui/material_ui.dart';
import '../data/data.dart';
import '../utils/validators.dart';
import '../widgets/widgets.dart';

class RegistrarNominaScreen extends StatefulWidget {
  final Empleado empleado;
  const RegistrarNominaScreen({super.key, required this.empleado});
  @override
  State<RegistrarNominaScreen> createState() => _RegistrarNominaScreenState();
}

class _RegistrarNominaScreenState extends State<RegistrarNominaScreen> {
  final _form = GlobalKey<FormState>();
  late final _monto = TextEditingController(text: widget.empleado.salario.toStringAsFixed(2));
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

  void _registrar() {
    if (!_form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisa los campos marcados en rojo')));
      return;
    }
    store.registrarPago(widget.empleado, double.parse(_monto.text.trim()));
    saveAndBack(context, 'Pago registrado');
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.empleado;
    final monto = double.tryParse(_monto.text.trim()) ?? 0.0;
    final desc = e.salario > monto ? e.salario - monto : 0.0;
    final now = DateTime.now();
    return AppScaffold(
      child: ScreenBody(children: [
        AppHeader(title: 'Registrar nómina', subtitle: e.nombre, back: true),
        DarkAmount(
            label: 'Total a pagar · ${meses[now.month - 1]} ${now.year}',
            amount: money(e.salario),
            footer: 'Periodicidad ${e.periodicidad.toLowerCase()}'),
        Form(
          key: _form,
          child: Column(children: [
            LabeledField('Monto del pago *', '0.00',
                highlight: true,
                controller: _monto,
                validator: V.monto,
                prefixText: '\$ ',
                inputFormatters: V.amountFormatters,
                onChanged: (_) => setState(() {})),
            Segmented('Método de pago', const ['Efectivo', 'Transferencia'],
                selected: _metodo, onChanged: (i) => setState(() => _metodo = i)),
            LabeledField(
                _metodo == 1 ? 'Cuenta de pago *' : 'Cuenta de pago', 'Banorte · Cuenta principal',
                controller: _cuenta,
                validator: (v) =>
                    _metodo == 1 ? V.requerido(v, 'Indica la cuenta de pago') : null),
            LabeledField('Referencia', 'Opcional', controller: _ref),
          ]),
        ),
        const SectionTitle('Resumen'),
        InfoBox(children: [
          InfoRow('Salario base', money(e.salario)),
          InfoRow('Descuentos', money(desc)),
          InfoRow('Total a pagar', money(monto), bold: true),
        ]),
        const SizedBox(height: 10),
        PrimaryButton('Registrar pago', onPressed: _registrar),
      ]),
    );
  }
}
