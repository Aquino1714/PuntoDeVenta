import 'package:material_ui/material_ui.dart';
import '../data/data.dart';
import '../utils/validators.dart';
import '../widgets/widgets.dart';

/// Crea un cliente, o edita uno existente si se pasa [editar].
class NuevoClienteScreen extends StatefulWidget {
  final Cliente? editar;
  const NuevoClienteScreen({super.key, this.editar});
  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  final _form = GlobalKey<FormState>();
  static const _plazos = [8, 15, 30];
  late final Cliente? _cli = widget.editar;

  late final _nombre = TextEditingController(text: _cli?.nombre ?? '');
  late final _apP = TextEditingController(text: _cli?.apPaterno ?? '');
  late final _apM = TextEditingController(text: _cli?.apMaterno ?? '');
  late final _telefono = TextEditingController(text: _cli?.telefono ?? '');
  late final _correo = TextEditingController(text: _cli?.correo ?? '');
  late final _direccion = TextEditingController(text: _cli?.direccion ?? '');

  late int _tipo = (_cli?.tipoPago ?? 'Contado') == 'Crédito' ? 1 : 0;
  late int _plazo = _cli == null
      ? 1
      : (!_plazos.contains(_cli.plazo) ? 1 : _plazos.indexOf(_cli.plazo));

  @override
  void dispose() {
    for (final c in [_nombre, _apP, _apM, _telefono, _correo, _direccion]) {
      c.dispose();
    }
    super.dispose();
  }

  void _guardar() {
    if (!_form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisa los campos marcados en rojo')));
      return;
    }
    final tipo = _tipo == 1 ? 'Crédito' : 'Contado';
    if (_cli == null) {
      final id = store.nextId();
      store.addCliente(Cliente(
        id: id,
        nombre: _nombre.text.trim(),
        apPaterno: _apP.text.trim(),
        apMaterno: _apM.text.trim(),
        telefono: _telefono.text,
        correo: _correo.text.trim(),
        direccion: _direccion.text.trim(),
        tipoPago: tipo,
        plazo: _plazos[_plazo],
        folio: tipo == 'Crédito' ? 'CR-${id - 4497}' : '',
      ));
    } else {
      _cli
        ..nombre = _nombre.text.trim()
        ..apPaterno = _apP.text.trim()
        ..apMaterno = _apM.text.trim()
        ..telefono = _telefono.text
        ..correo = _correo.text.trim()
        ..direccion = _direccion.text.trim()
        ..tipoPago = tipo
        ..plazo = _plazos[_plazo];
      if (tipo == 'Crédito' && _cli.folio.isEmpty) _cli.folio = 'CR-${_cli.id - 4497}';
      store.changed();
    }
    saveAndBack(context, _cli == null ? 'Cliente guardado' : 'Cliente actualizado');
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        child: ScreenBody(children: [
          AppHeader(
              title: _cli == null ? 'Nuevo cliente' : 'Editar cliente',
              subtitle: 'Registra un cliente en Comercial Centro',
              back: true),
          Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('Datos del cliente'),
              LabeledField('Nombre *', 'Ana', controller: _nombre, validator: V.nombre),
              FieldRow(
                LabeledField('Apellido paterno *', 'López',
                    controller: _apP, validator: V.nombre),
                LabeledField('Apellido materno', 'Martínez', controller: _apM),
              ),
              LabeledField('Teléfono * (10 dígitos)', '5512345678',
                  controller: _telefono,
                  validator: (v) =>
                      V.telefono(v) ??
                      (store.telefonoClienteExiste(v!, exceptId: _cli?.id)
                          ? 'Este teléfono ya está registrado'
                          : null),
                  keyboardType: TextInputType.phone,
                  inputFormatters: V.phoneFormatters),
              LabeledField('Correo electrónico *', 'correo@ejemplo.com',
                  controller: _correo,
                  validator: (v) =>
                      V.correo(v) ??
                      (store.correoClienteExiste(v!, exceptId: _cli?.id)
                          ? 'Este correo ya está registrado'
                          : null),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: V.noSpaces),
              LabeledField('Dirección', 'Calle, número y colonia', controller: _direccion),
              const SectionTitle('Condiciones de pago'),
              Segmented('Tipo de pago', const ['Contado', 'Crédito'],
                  selected: _tipo, onChanged: (i) => setState(() => _tipo = i)),
              if (_tipo == 1)
                Segmented('Plazo de crédito', const ['8 días', '15 días', '30 días'],
                    selected: _plazo, onChanged: (i) => _plazo = i),
              const SizedBox(height: 14),
              PrimaryButton(_cli == null ? 'Guardar cliente' : 'Guardar cambios',
                  onPressed: _guardar),
            ]),
          ),
        ]),
      );
}
