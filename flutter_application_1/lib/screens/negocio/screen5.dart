import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';
import '../../formularios/nueva_venta_sheet.dart';
import '../../widgets/sheet_handle.dart';
import '../../widgets/selectores.dart';
import '../../data/data.dart' show Cliente;
import '../inventario/inventario.dart' show Producto;

class Screen5 extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const Screen5({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<Screen5> createState() => _Screen5State();
}

class _Screen5State extends State<Screen5> {

  int _currentIndex = 0;

  // TODO: reemplazar estos datos de ejemplo por los reales (base de datos / API).
  final List<_Debtor> _porCobrar = const [
    _Debtor(name: 'Nombre del cliente', products: 3, amount: 150.0),
  ];

  final List<_LowStock> _stockBajo = const [
    _LowStock(name: 'Nombre del producto', quantity: 2),
  ];

  Future<void> _newSale() async {
    final sale = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewSaleSheet(),
    );

    if (sale == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: guardar la venta en tu base de datos / API
  }

  Future<void> _newOrder() async {
    final order = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewOrderSheet(),
    );

    if (order == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: guardar el pedido en tu base de datos / API
  }

  Future<void> _registerPayment() async {
    final payment = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RegisterPaymentSheet(),
    );

    if (payment == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: guardar el abono en tu base de datos / API
  }

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
    // TODO: navegar a Clientes / Más
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          'Inicio',
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

              const SizedBox(height: 24),

              // ---------- Nueva venta / Nuevo pedido ----------
              Row(
                children: [
                  Expanded(
                    child: _BigActionButton(
                      label: '+ Nueva venta',
                      onPressed: _newSale,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigActionButton(
                      label: '+ Nuevo pedido',
                      onPressed: _newOrder,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------- Registrar abono ----------
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
                  onPressed: _registerPayment,
                  child: const Text(
                    'Registrar abono',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Por cobrar ----------
              const _SectionTitle('Por cobrar'),
              const SizedBox(height: 8),
              if (_porCobrar.isEmpty)
                const _EmptyText('No hay cuentas por cobrar')
              else
                for (final cliente in _porCobrar) ...[
                  _FramedCard(
                    child: Column(
                      children: [
                        Text(
                          cliente.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cliente.products} productos',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              'Cobrar: \$${cliente.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

              const SizedBox(height: 12),

              // ---------- Stock bajo ----------
              const _SectionTitle('Stock bajo'),
              const SizedBox(height: 8),
              if (_stockBajo.isEmpty)
                const _EmptyText('No hay productos con stock bajo')
              else
                for (final producto in _stockBajo) ...[
                  _FramedCard(
                    child: Column(
                      children: [
                        Text(
                          producto.name,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quedan ${producto.quantity}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tarjeta "Nuevo pedido"
// ---------------------------------------------------------------------------

class _NewOrderSheet extends StatefulWidget {
  const _NewOrderSheet();

  @override
  State<_NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<_NewOrderSheet> {
  static const double _pasoMonto = 10;

  Producto? _producto;
  Cliente? _cliente;

  int _cantidad = 1;
  double _montoTotal = 0;
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaFin = DateTime.now();

  // El subtotal es el monto total capturado.
  double get _subtotal => _montoTotal;

  /// Formato d/M/aa (ej. 1/12/26).
  String _formatFecha(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '${d.day}/${d.month}/$yy';
  }

  /// Abre la lista de productos guardados.
  Future<void> _searchProduct() async {
    final elegido = await elegirProducto(context);
    if (elegido == null || !mounted) return;
    setState(() => _producto = elegido);
  }

  /// Abre la lista de clientes guardados.
  Future<void> _searchClient() async {
    final elegido = await elegirCliente(context);
    if (elegido == null || !mounted) return;
    setState(() => _cliente = elegido);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _fechaInicio : _fechaFin;
    final first = isStart ? DateTime(2020) : _fechaInicio;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _fechaInicio = picked;
        // La fecha final nunca puede quedar antes de la inicial.
        if (_fechaFin.isBefore(picked)) _fechaFin = picked;
      } else {
        _fechaFin = picked;
      }
    });
  }

  Future<void> _editMonto() async {
    final controller = TextEditingController(
      text: _montoTotal == 0 ? '' : _montoTotal.toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Monto total'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(
              ctx,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result == null || !mounted) return;
    setState(() => _montoTotal = result < 0 ? 0 : result);
  }

  void _confirm() {
    Navigator.pop(context, {
      'cantidad': _cantidad,
      'montoTotal': _montoTotal,
      'fechaInicio': _fechaInicio,
      'fechaFin': _fechaFin,
      'subtotal': _subtotal,
      'producto': _producto?.nombre,
      'cliente': _cliente?.fullName,
    });
  }

  Widget _outlinedPill(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(
        side: BorderSide(color: Colors.white, width: 3),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(icon, color: Colors.white, size: 34),
        ),
      ),
    );
  }

  /// Pastilla central con texto (Cantidad / Monto total).
  Widget _valuePill(String text, {VoidCallback? onTap}) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(33),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Pastilla de fecha con icono de calendario.
  Widget _datePill(DateTime date, VoidCallback onTap) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(33),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_month, color: Colors.white, size: 30),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _formatFecha(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SheetDragScope(child: Container(
      height: media.size.height * 0.85,
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
                      '+ Nuevo pedido',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 14),
                    Container(height: 1.5, color: Colors.white),
                    const SizedBox(height: 24),

                    // ---------- Buscar producto / cliente ----------
                    _outlinedPill(_producto?.nombre ?? 'Buscar producto', _searchProduct),
                    const SizedBox(height: 12),
                    _outlinedPill(_cliente?.fullName ?? 'Buscar cliente', _searchClient),

                    const SizedBox(height: 20),

                    // ---------- Cantidad ----------
                    _label('Cantidad:'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _circleButton(Icons.remove, () {
                          if (_cantidad > 1) setState(() => _cantidad--);
                        }),
                        const SizedBox(width: 12),
                        Expanded(child: _valuePill('${_cantidad}pz')),
                        const SizedBox(width: 12),
                        _circleButton(
                          Icons.add,
                          () => setState(() => _cantidad++),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------- Monto total ----------
                    _label('Monto total:'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _circleButton(Icons.remove, () {
                          setState(() {
                            _montoTotal = (_montoTotal - _pasoMonto)
                                .clamp(0, double.infinity)
                                .toDouble();
                          });
                        }),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _valuePill(
                            '\$${_montoTotal.toStringAsFixed(2)}',
                            onTap: _editMonto,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _circleButton(
                          Icons.add,
                          () => setState(() => _montoTotal += _pasoMonto),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---------- Plazo del crédito ----------
                    _label('Plazo del crédito:'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _datePill(
                            _fechaInicio,
                            () => _pickDate(isStart: true),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _datePill(
                            _fechaFin,
                            () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),
                    const SizedBox(height: 24),

                    // ---------- Subtotal ----------
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '\$ ${_subtotal.toStringAsFixed(2)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------- Confirmar venta ----------
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
                          'Confirmar venta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// Tarjeta "Registrar abono"
// ---------------------------------------------------------------------------

class _RegisterPaymentSheet extends StatefulWidget {
  const _RegisterPaymentSheet();

  @override
  State<_RegisterPaymentSheet> createState() => _RegisterPaymentSheetState();
}

class _RegisterPaymentSheetState extends State<_RegisterPaymentSheet> {
  static const List<String> _metodos = ['Efectivo', 'Transferencia'];

  final _cuentaCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _referenciaCtrl = TextEditingController();

  final _cuentaFocus = FocusNode();
  final _montoFocus = FocusNode();
  final _referenciaFocus = FocusNode();

  String? _metodoPago;
  Cliente? _cliente;
  final DateTime _fecha = DateTime.now();

  /// Formato d/M/aa (ej. 1/12/26).
  String get _fechaTexto {
    final yy = (_fecha.year % 100).toString().padLeft(2, '0');
    return '${_fecha.day}/${_fecha.month}/$yy';
  }

  @override
  void dispose() {
    _cuentaCtrl.dispose();
    _montoCtrl.dispose();
    _referenciaCtrl.dispose();
    _cuentaFocus.dispose();
    _montoFocus.dispose();
    _referenciaFocus.dispose();
    super.dispose();
  }

  /// Abre la lista de clientes guardados.
  Future<void> _searchClient() async {
    final elegido = await elegirCliente(context);
    if (elegido == null || !mounted) return;
    setState(() => _cliente = elegido);
  }

  void _confirm() {
    Navigator.pop(context, {
      'numeroCuenta': _cuentaCtrl.text.trim(),
      'monto': double.tryParse(_montoCtrl.text) ?? 0.0,
      'metodoPago': _metodoPago,
      'referencia': _referenciaCtrl.text.trim(),
      'fecha': _fecha,
      'cliente': _cliente?.fullName,
    });
  }

  Widget _outlinedPill(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
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

  /// Campo de texto con forma de pastilla y borde blanco.
  Widget _textPill({
    required TextEditingController controller,
    required FocusNode focusNode,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    const style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: TextAlign.center,
      cursorColor: Colors.white,
      style: style,
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: focusNode.requestFocus,
      child: Container(
      height: 58,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      // Con prefijo (ej. "$"), el símbolo queda fijo y el número se escribe
      // a su lado, todo centrado en la pastilla.
      child: prefix == null
          ? field
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(prefix, style: style),
                const SizedBox(width: 4),
                // minWidth evita que el campo mida ~0 cuando está vacío
                // (así sí se puede tocar y escribir).
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 80),
                    child: IntrinsicWidth(child: field),
                  ),
                ),
              ],
            ),
      ),
    );
  }

  /// Selector desplegable con forma de pastilla.
  Widget _dropdownPill() {
    const textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: 58,
      padding: const EdgeInsets.only(left: 20, right: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _metodoPago,
          isExpanded: true,
          dropdownColor: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
          alignment: AlignmentDirectional.center,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 34,
          ),
          hint: const Center(
            child: Text('Efectivo / Transferencia', style: textStyle),
          ),
          selectedItemBuilder: (context) => [
            for (final m in _metodos)
              Center(child: Text(m, style: textStyle)),
          ],
          items: [
            for (final m in _metodos)
              DropdownMenuItem<String>(
                value: m,
                alignment: AlignmentDirectional.center,
                child: Text(m, style: textStyle),
              ),
          ],
          onChanged: (value) => setState(() => _metodoPago = value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

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
                        'Registrar abono',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Container(height: 1.5, color: Colors.white),
                      const SizedBox(height: 24),

                      // ---------- Buscar cliente ----------
                      _outlinedPill(_cliente?.fullName ?? 'Buscar cliente', _searchClient),

                      const SizedBox(height: 20),

                      // ---------- Número de cuenta ----------
                      _label('Número de cuenta:'),
                      const SizedBox(height: 8),
                      _textPill(
                        controller: _cuentaCtrl,
                        focusNode: _cuentaFocus,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),

                      const SizedBox(height: 20),

                      // ---------- Monto ----------
                      _label('Monto:'),
                      const SizedBox(height: 8),
                      _textPill(
                        controller: _montoCtrl,
                        focusNode: _montoFocus,
                        prefix: '\$',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ---------- Método de pago ----------
                      _label('Método de pago:'),
                      const SizedBox(height: 8),
                      _dropdownPill(),

                      const SizedBox(height: 20),

                      // ---------- Referencia ----------
                      _label('Referencia:'),
                      const SizedBox(height: 8),
                      _textPill(
                        controller: _referenciaCtrl,
                        focusNode: _referenciaFocus,
                      ),

                      const SizedBox(height: 20),

                      // ---------- Fecha ----------
                      Text(
                        'Fecha: $_fechaTexto',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),

                      // ---------- Confirmar abono ----------
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
                            'Confirmar abono',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
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

// ---------------------------------------------------------------------------
// Modelos de ejemplo
// ---------------------------------------------------------------------------

class _Debtor {
  final String name;
  final int products;
  final double amount;

  const _Debtor({
    required this.name,
    required this.products,
    required this.amount,
  });
}

class _LowStock {
  final String name;
  final int quantity;

  const _LowStock({required this.name, required this.quantity});
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _BigActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BigActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, color: AppColors.muted),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final String text;
  const _EmptyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, color: AppColors.muted),
      ),
    );
  }
}

/// Tarjeta con marco azul y centro blanco (Por cobrar / Stock bajo).
class _FramedCard extends StatelessWidget {
  final Widget child;
  const _FramedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(33),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: child,
      ),
    );
  }
}