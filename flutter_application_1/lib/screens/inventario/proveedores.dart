import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';
import '../../widgets/sheet_handle.dart';

class ProveedoresScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const ProveedoresScreen({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // TODO: reemplazar estos datos de ejemplo por los proveedores reales
  // (base de datos / API).
  final List<_Supplier> _proveedores = [
    _Supplier(
      name: 'Nombre del proveedor',
      phone: 'Teléfono del proveedor',
      email: 'Correo del proveedor',
      address: 'Dirección del proveedor',
      paymentTerm: 'Pago al contado',
      active: true,
    ),
    _Supplier(
      name: 'Nombre del proveedor',
      phone: 'Teléfono del proveedor',
      email: 'Correo del proveedor',
      address: 'Dirección del proveedor',
      paymentTerm: 'Pago al contado',
      active: false,
    ),
  ];

  List<_Supplier> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _proveedores;
    return _proveedores
        .where((p) =>
            p.name.toLowerCase().contains(q) || p.phone.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _editSupplier(_Supplier supplier) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSupplierSheet(supplier: supplier),
    );

    if (result == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: además de la lista en pantalla, actualizar el proveedor en tu
    // base de datos / API.
    setState(() {
      supplier.name = result['nombre'] as String;
      supplier.phone = result['telefono'] as String;
      supplier.email = result['correo'] as String;
      supplier.address = result['direccion'] as String;
      supplier.paymentTerm = result['condicionPago'] as String;
      supplier.active = result['activo'] as bool;
    });
  }

  void _openSupplier(_Supplier supplier) {
    // TODO: abrir el detalle del proveedor
  }

  void _toggleActive(_Supplier supplier) {
    // TODO: además del estado en pantalla, actualizar el proveedor en tu
    // base de datos / API.
    setState(() => supplier.active = !supplier.active);
  }

  Future<void> _newSupplier() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewSupplierSheet(),
    );

    if (result == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: además de la lista en pantalla, guardar el proveedor en tu base
    // de datos / API.
    setState(() {
      _proveedores.add(
        _Supplier(
          name: result['nombre'] as String,
          phone: result['telefono'] as String,
          email: result['correo'] as String,
          address: result['direccion'] as String,
          paymentTerm: result['condicionPago'] as String,
          active: result['activo'] as bool,
        ),
      );
    });
  }

  // ---------- Menú al mantener presionada una tarjeta ----------

  Future<void> _showCardMenu(_Supplier proveedor, Offset position) async {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final action = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'modificar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Modificar', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Eliminar', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;

    if (action == 'modificar') {
      _editSupplier(proveedor);
    } else if (action == 'eliminar') {
      _confirmDelete(proveedor);
    }
  }

  // ---------- Eliminar ----------

  Future<void> _confirmDelete(_Supplier proveedor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: proveedor.name),
    );

    if (confirmed != true || !mounted) return;

    // TODO: eliminar el proveedor de tu base de datos / API
    setState(() => _proveedores.remove(proveedor));
  }

  int _navIndex = 2;

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final proveedores = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(currentIndex: _navIndex, onTap: _onNavTap),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // ---------- Encabezado ----------
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.maybePop(context),
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: Icon(
                            Icons.keyboard_return,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 58, right: 58),
                    child: Column(
                      children: [
                        Text(
                          widget.businessName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Proveedores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------- Buscar proveedor ----------
              _SearchPill(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
              ),

              const SizedBox(height: 16),

              // ---------- Lista de proveedores ----------
              Expanded(
                child: proveedores.isEmpty
                    ? Center(
                        child: Text(
                          _proveedores.isEmpty
                              ? 'No hay proveedores registrados'
                              : 'No se encontraron proveedores',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: proveedores.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _SupplierCard(
                          supplier: proveedores[i],
                          onOpen: () => _openSupplier(proveedores[i]),
                          onToggleActive: () => _toggleActive(proveedores[i]),
                          onLongPress: (position) =>
                              _showCardMenu(proveedores[i], position),
                        ),
                      ),
              ),

              const SizedBox(height: 12),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Registrar proveedor ----------
              SizedBox(
                height: 66,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  onPressed: _newSupplier,
                  child: const Text(
                    '+ Registrar proveedor',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: reemplazar por las condiciones de pago reales (base de datos / API).
const List<String> _kCondicionesPago = [
  'Pago al contado',
  'Crédito a 15 días',
  'Crédito a 30 días',
  'Crédito a 60 días',
];

// ---------------------------------------------------------------------------
// Modelo de ejemplo
// ---------------------------------------------------------------------------

class _Supplier {
  String name;
  String phone;
  String email;
  String address;
  String paymentTerm;
  bool active;

  _Supplier({
    required this.name,
    required this.phone,
    this.email = '',
    this.address = '',
    this.paymentTerm = 'Pago al contado',
    this.active = true,
  });
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

/// Barra de búsqueda con forma de pastilla y lupa a la derecha.
class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchPill({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: 20, right: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              cursorColor: AppColors.primary,
              style: textStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Buscar proveedor',
                hintStyle: textStyle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.search, color: AppColors.primary, size: 34),
        ],
      ),
    );
  }
}

/// Tarjeta de proveedor: nombre y teléfono, abrir y estado.
/// Para modificarla o eliminarla se mantiene presionada (onLongPress).
class _SupplierCard extends StatelessWidget {
  final _Supplier supplier;
  final VoidCallback onOpen;
  final VoidCallback onToggleActive;

  /// Se llama al mantener presionada la tarjeta, con la posición del dedo.
  final void Function(Offset globalPosition) onLongPress;

  const _SupplierCard({
    required this.supplier,
    required this.onOpen,
    required this.onToggleActive,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final active = supplier.active;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- Datos / abrir ----------
          Row(
            children: [
              // Espacio igual al de la flecha para que el texto quede centrado.
              const SizedBox(width: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(
                        supplier.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        supplier.phone,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              InkWell(
                customBorder: const CircleBorder(),
                onTap: onOpen,
                child: const SizedBox(
                  width: 44,
                  height: 54,
                  child: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white),
          const SizedBox(height: 10),

          // ---------- Estado: activo / inactivo ----------
          SizedBox(
            height: 54,
            child: active
                ? ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: onToggleActive,
                    child: const Text(
                      'Proveedor activo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: onToggleActive,
                    child: const Text(
                      'Proveedor inactivo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ventana de confirmación para eliminar
// ---------------------------------------------------------------------------

/// Devuelve true si el usuario confirma que quiere eliminar un proveedor.
class _DeleteDialog extends StatelessWidget {
  final String name;

  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Eliminar proveedor',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1.5, color: Colors.white),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.white),
                children: [
                  const TextSpan(
                    text: '¿Estás seguro de que quieres eliminar al proveedor ',
                  ),
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción no se puede deshacer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta "Editar proveedor"
// ---------------------------------------------------------------------------

class _EditSupplierSheet extends StatefulWidget {
  final _Supplier supplier;

  const _EditSupplierSheet({required this.supplier});

  @override
  State<_EditSupplierSheet> createState() => _EditSupplierSheetState();
}

class _EditSupplierSheetState extends State<_EditSupplierSheet> {
  // TODO: reemplazar por las condiciones de pago reales (base de datos / API).
  static const List<String> _condicionesBase = _kCondicionesPago;

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _correoCtrl;
  late final TextEditingController _direccionCtrl;

  late String _condicionPago;
  late bool _active;
  late final List<String> _condiciones;

  bool _nombreVacio = false;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nombreCtrl = TextEditingController(text: s.name);
    _telefonoCtrl = TextEditingController(text: s.phone);
    _correoCtrl = TextEditingController(text: s.email);
    _direccionCtrl = TextEditingController(text: s.address);
    _active = s.active;

    // Si el proveedor trae una condición que no está en la lista, se agrega
    // para que el menú desplegable no falle.
    _condiciones = [..._condicionesBase];
    if (!_condiciones.contains(s.paymentTerm)) {
      _condiciones.add(s.paymentTerm);
    }
    _condicionPago = s.paymentTerm;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      setState(() => _nombreVacio = true);
      return;
    }

    Navigator.pop(context, {
      'nombre': nombre,
      'telefono': _telefonoCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'condicionPago': _condicionPago,
      'activo': _active,
    });
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Campo de texto en forma de pastilla. Solo se puede editar después de
  /// tocar el lápiz de la derecha.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    return _EditableField(
      controller: controller,
      hint: hint,
      keyboardType: keyboardType,
      capitalization: capitalization,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    const inputStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // La tarjeta se achica cuando aparece el teclado para no quedar tapada.
    final sheetHeight = (media.size.height * 0.85)
        .clamp(0.0, media.size.height - keyboard - media.padding.top)
        .toDouble();

    return SheetDragScope(child: Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                      const SheetHandle(),

                      const Text(
                        'Editar proveedor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Container(height: 1.5, color: Colors.white),
                      const SizedBox(height: 20),

                      // ---------- Nombre del proveedor ----------
                      _label('Nombre del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _nombreCtrl,
                        hint: 'Nombre del proveedor',
                        capitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_nombreVacio) {
                            setState(() => _nombreVacio = false);
                          }
                        },
                      ),
                      if (_nombreVacio)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            'Escribe el nombre del proveedor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ---------- Teléfono del proveedor ----------
                      _label('Teléfono del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _telefonoCtrl,
                        hint: 'Teléfono del proveedor',
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Correo del proveedor ----------
                      _label('Correo del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _correoCtrl,
                        hint: 'Correo del proveedor',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Dirección del proveedor ----------
                      _label('Dirección del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _direccionCtrl,
                        hint: 'Dirección del proveedor',
                        keyboardType: TextInputType.streetAddress,
                        capitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Condición de pago ----------
                      _label('Condición de pago'),
                      const SizedBox(height: 8),
                      Container(
                        height: 58,
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(33),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _condicionPago,
                            isExpanded: true,
                            dropdownColor: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 38,
                            ),
                            style: inputStyle,
                            items: _condiciones
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(c, style: inputStyle),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _condicionPago = value);
                            },
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),
                      Container(height: 1, color: Colors.white),
                      const SizedBox(height: 16),

                      // ---------- Estado: activo / inactivo ----------
                      SizedBox(
                        height: 66,
                        child: _active
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                ),
                                onPressed: () => setState(() => _active = false),
                                child: const Text(
                                  'Proveedor activo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.white, width: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                ),
                                onPressed: () => setState(() => _active = true),
                                child: const Text(
                                  'Proveedor inactivo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 14),

                      // ---------- Guardar cambios ----------
                      SizedBox(
                        height: 66,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          onPressed: _save,
                          child: const Text(
                            'Guardar cambios',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

/// Campo en forma de pastilla bloqueado por defecto. Al tocar el lápiz se
/// habilita la edición y se abre el teclado; al tocar el check (o al salir del
/// campo) vuelve a bloquearse.
class _EditableField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;

  const _EditableField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
  });

  @override
  State<_EditableField> createState() => _EditableFieldState();
}

class _EditableFieldState extends State<_EditableField> {
  final FocusNode _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      // Si el campo pierde el foco (por ejemplo, al tocar otro campo),
      // se vuelve a bloquear.
      if (!_focus.hasFocus && _editing) {
        setState(() => _editing = false);
      }
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    if (_editing) {
      _focus.unfocus();
      setState(() => _editing = false);
    } else {
      setState(() => _editing = true);
      // Se pide el foco hasta que el campo ya esté habilitado.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focus.requestFocus();
        widget.controller.selection = TextSelection.collapsed(
          offset: widget.controller.text.length,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const inputStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 20, right: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              enabled: _editing,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.capitalization,
              onChanged: widget.onChanged,
              onSubmitted: (_) => _toggleEditing(),
              cursorColor: Colors.white,
              style: inputStyle,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: widget.hint,
                hintStyle: inputStyle.copyWith(color: Colors.white70),
              ),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: _toggleEditing,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                _editing ? Icons.check : Icons.drive_file_rename_outline,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta "Registrar proveedor"
// ---------------------------------------------------------------------------

class _NewSupplierSheet extends StatefulWidget {
  const _NewSupplierSheet();

  @override
  State<_NewSupplierSheet> createState() => _NewSupplierSheetState();
}

class _NewSupplierSheetState extends State<_NewSupplierSheet> {
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  String _condicionPago = _kCondicionesPago.first;
  bool _active = true;
  bool _nombreVacio = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      setState(() => _nombreVacio = true);
      return;
    }

    Navigator.pop(context, {
      'nombre': nombre,
      'telefono': _telefonoCtrl.text.trim(),
      'correo': _correoCtrl.text.trim(),
      'direccion': _direccionCtrl.text.trim(),
      'condicionPago': _condicionPago,
      'activo': _active,
    });
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Campo de texto en forma de pastilla, editable directamente.
  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
  }) {
    const inputStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: 58,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        onChanged: onChanged,
        cursorColor: Colors.white,
        style: inputStyle,
        decoration: InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
          hintText: hint,
          hintStyle: inputStyle.copyWith(color: Colors.white70),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    const inputStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // La tarjeta se achica cuando aparece el teclado para no quedar tapada.
    final sheetHeight = (media.size.height * 0.85)
        .clamp(0.0, media.size.height - keyboard - media.padding.top)
        .toDouble();

    return SheetDragScope(child: Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                      const SheetHandle(),

                      const Text(
                        '+ Registrar proveedor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Container(height: 1.5, color: Colors.white),
                      const SizedBox(height: 20),

                      // ---------- Nombre del proveedor ----------
                      _label('Nombre del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _nombreCtrl,
                        capitalization: TextCapitalization.words,
                        onChanged: (_) {
                          if (_nombreVacio) {
                            setState(() => _nombreVacio = false);
                          }
                        },
                      ),
                      if (_nombreVacio)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            'Escribe el nombre del proveedor',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // ---------- Teléfono del proveedor ----------
                      _label('Teléfono del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _telefonoCtrl,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Correo del proveedor ----------
                      _label('Correo del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _correoCtrl,
                        hint: 'ejemplo@gmail.com',
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Dirección del proveedor ----------
                      _label('Dirección del proveedor'),
                      const SizedBox(height: 8),
                      _field(
                        controller: _direccionCtrl,
                        keyboardType: TextInputType.streetAddress,
                        capitalization: TextCapitalization.sentences,
                      ),

                      const SizedBox(height: 16),

                      // ---------- Condición de pago ----------
                      _label('Condición de pago'),
                      const SizedBox(height: 8),
                      Container(
                        height: 58,
                        padding: const EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(33),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _condicionPago,
                            isExpanded: true,
                            dropdownColor: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.white,
                              size: 38,
                            ),
                            style: inputStyle,
                            items: _kCondicionesPago
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Text(c, style: inputStyle),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _condicionPago = value);
                            },
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 20),
                      Container(height: 1, color: Colors.white),
                      const SizedBox(height: 16),

                      // ---------- Estado: activo / inactivo ----------
                      SizedBox(
                        height: 66,
                        child: _active
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                ),
                                onPressed: () => setState(() => _active = false),
                                child: const Text(
                                  'Proveedor activo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.white, width: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(33),
                                  ),
                                ),
                                onPressed: () => setState(() => _active = true),
                                child: const Text(
                                  'Proveedor inactivo',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),

                      const SizedBox(height: 14),

                      // ---------- Registrar proveedor ----------
                      SizedBox(
                        height: 66,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          onPressed: _confirm,
                          child: const Text(
                            'Registrar proveedor',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}