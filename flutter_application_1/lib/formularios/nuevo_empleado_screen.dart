import 'package:material_ui/material_ui.dart';
import '../data/data.dart';
import '../utils/validators.dart';
import '../widgets/widgets.dart';

/// Crea un empleado, o edita uno existente si se pasa [editar].
class NuevoEmpleadoScreen extends StatefulWidget {
  final Empleado? editar;
  const NuevoEmpleadoScreen({super.key, this.editar});
  @override
  State<NuevoEmpleadoScreen> createState() => _NuevoEmpleadoScreenState();
}

class _NuevoEmpleadoScreenState extends State<NuevoEmpleadoScreen> {
  final _form = GlobalKey<FormState>();
  static const _periodos = ['Semanal', 'Quincenal', 'Mensual'];
  late final Empleado? _emp = widget.editar;

  late final _nombre = TextEditingController(text: _emp?.nombre ?? '');
  late final _telefono = TextEditingController(text: _emp?.telefono ?? '');
  late final _correo = TextEditingController(text: _emp?.correo ?? '');
  late final _direccion = TextEditingController(text: _emp?.direccion ?? '');
  late final _cargo = TextEditingController(text: _emp?.cargo ?? '');
  late final _turno = TextEditingController(text: _emp?.turno ?? '');
  late final _salario =
      TextEditingController(text: _emp == null ? '' : _emp.salario.toStringAsFixed(2));
  late final _emergencia = TextEditingController(text: _emp?.emergencia ?? '');

  late int _per = _emp == null
      ? 1
      : (!_periodos.contains(_emp.periodicidad) ? 1 : _periodos.indexOf(_emp.periodicidad));
  late bool _atender = _emp?.atender ?? true;
  late bool _autorizar = _emp?.autorizar ?? true;
  late bool _reportes = _emp?.reportes ?? false;

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _correo, _direccion, _cargo, _turno, _salario, _emergencia]) {
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
    final salario = double.parse(_salario.text.trim());
    if (_emp == null) {
      store.addEmpleado(Empleado(
        id: store.nextId(),
        nombre: _nombre.text.trim(),
        telefono: _telefono.text,
        correo: _correo.text.trim(),
        direccion: _direccion.text.trim(),
        cargo: _cargo.text.trim(),
        turno: _turno.text.trim(),
        salario: salario,
        periodicidad: _periodos[_per],
        emergencia: _emergencia.text.trim(),
        atender: _atender,
        autorizar: _autorizar,
        reportes: _reportes,
      ));
    } else {
      _emp
        ..nombre = _nombre.text.trim()
        ..telefono = _telefono.text
        ..correo = _correo.text.trim()
        ..direccion = _direccion.text.trim()
        ..cargo = _cargo.text.trim()
        ..turno = _turno.text.trim()
        ..salario = salario
        ..periodicidad = _periodos[_per]
        ..emergencia = _emergencia.text.trim()
        ..atender = _atender
        ..autorizar = _autorizar
        ..reportes = _reportes;
      store.changed();
    }
    saveAndBack(context, _emp == null ? 'Empleado guardado' : 'Empleado actualizado');
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
        child: ScreenBody(children: [
          AppHeader(
              title: _emp == null ? 'Nuevo empleado' : 'Editar empleado',
              subtitle: 'Datos personales y laborales',
              back: true),
          Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SectionTitle('Datos personales'),
              LabeledField('Nombre completo *', 'Mariana Torres Ruiz',
                  controller: _nombre, validator: V.nombre),
              LabeledField('Teléfono * (10 dígitos)', '5512345678',
                  controller: _telefono,
                  validator: (v) =>
                      V.telefono(v) ??
                      (store.telefonoEmpleadoExiste(v!, exceptId: _emp?.id)
                          ? 'Este teléfono ya está registrado'
                          : null),
                  keyboardType: TextInputType.phone,
                  inputFormatters: V.phoneFormatters),
              LabeledField('Correo electrónico *', 'correo@ejemplo.com',
                  controller: _correo,
                  validator: (v) =>
                      V.correo(v) ??
                      (store.correoEmpleadoExiste(v!, exceptId: _emp?.id)
                          ? 'Este correo ya está registrado'
                          : null),
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: V.noSpaces),
              LabeledField('Dirección', 'Calle, número y localidad', controller: _direccion),
              const SectionTitle('Datos laborales'),
              FieldRow(
                LabeledField('Cargo *', 'Cajera',
                    controller: _cargo, validator: (v) => V.requerido(v, 'Indica el cargo')),
                LabeledField('Turno *', 'Matutino',
                    controller: _turno, validator: (v) => V.requerido(v, 'Indica el turno')),
              ),
              LabeledField('Salario mensual *', '0.00',
                  controller: _salario,
                  validator: V.monto,
                  prefixText: '\$ ',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: V.amountFormatters),
              Segmented('Periodicidad', _periodos,
                  selected: _per, onChanged: (i) => _per = i),
              LabeledField('Contacto de emergencia', 'Nombre y teléfono',
                  controller: _emergencia),
              const SectionTitle('Permisos'),
              SwitchRow('Atender clientes', _atender, onChanged: (v) => _atender = v),
              SwitchRow('Autorizar créditos', _autorizar, onChanged: (v) => _autorizar = v),
              SwitchRow('Ver reportes', _reportes, onChanged: (v) => _reportes = v),
              const SizedBox(height: 14),
              PrimaryButton(_emp == null ? 'Guardar empleado' : 'Guardar cambios',
                  onPressed: _guardar),
            ]),
          ),
        ]),
      );
}
