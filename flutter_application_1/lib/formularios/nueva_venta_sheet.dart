import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../colors/colors.dart';
import '../widgets/sheet_handle.dart';
import '../widgets/selectores.dart';
import '../data/data.dart' show Cliente;
import '../screens/inventario/inventario.dart' show Producto;

/// Hoja inferior (bottom sheet) para registrar una nueva venta: permite
/// agregar uno o varios productos (cada uno con su cantidad), elegir el
/// cliente, aplicar un descuento y ver el total.
///
/// Uso:
/// ```dart
/// final sale = await showModalBottomSheet<Map<String, dynamic>>(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const NewSaleSheet(),
/// );
/// ```
/// Devuelve un Map con la venta, o null si el usuario cierra la hoja.
///
/// El Map incluye `articulos`: una lista con un Map por producto
/// (`producto`, `cantidad`, `precioUnitario`, `subtotal`), además de
/// `subtotal`, `descuento`, `total`, `fecha` y `cliente`.
class NewSaleSheet extends StatefulWidget {
  const NewSaleSheet({super.key});

  @override
  State<NewSaleSheet> createState() => _NewSaleSheetState();
}

class _NewSaleSheetState extends State<NewSaleSheet> {
  /// Productos agregados a la venta (cada uno con su cantidad).
  final List<_LineaVenta> _lineas = [];

  /// Productos quitados de la venta: se guardan solo para liberar sus
  /// controladores de texto al cerrar la hoja.
  final List<_LineaVenta> _descartadas = [];

  /// Cliente elegido en la lista de búsqueda.
  Cliente? _cliente;

  final DateTime _fecha = DateTime.now();

  /// Campo de texto del descuento (en pesos).
  final TextEditingController _descuentoCtrl = TextEditingController();

  @override
  void dispose() {
    _descuentoCtrl.dispose();
    for (final l in _lineas) {
      l.dispose();
    }
    for (final l in _descartadas) {
      l.dispose();
    }
    super.dispose();
  }

  /// Subtotal de la venta: suma de (precio unitario x cantidad) de cada producto.
  double get _subtotal => _lineas.fold<double>(0, (s, l) => s + l.subtotal);

  /// Total de piezas en la venta.
  int get _piezas => _lineas.fold<int>(0, (s, l) => s + l.cantidad);

  /// Descuento capturado por el usuario (0 si está vacío o inválido).
  double get _descuento => double.tryParse(_descuentoCtrl.text) ?? 0;

  /// Total final con el descuento aplicado (nunca menor a 0).
  double get _total => (_subtotal - _descuento).clamp(0, double.infinity).toDouble();

  /// Fecha de la venta en formato dd/mm/aaaa.
  String get _fechaTexto {
    final d = _fecha.day.toString().padLeft(2, '0');
    final m = _fecha.month.toString().padLeft(2, '0');
    return '$d/$m/${_fecha.year}';
  }

  /// Abre la lista de productos guardados y agrega el elegido a la venta
  /// con su precio de venta. Si ya estaba agregado, suma una pieza.
  Future<void> _searchProduct() async {
    final elegido = await elegirProducto(context);
    if (elegido == null || !mounted) return;
    setState(() {
      final i = _lineas.indexWhere((l) =>
          l.producto.nombre == elegido.nombre &&
          l.producto.codigoBarras == elegido.codigoBarras);
      if (i >= 0) {
        _lineas[i].setCantidad(_lineas[i].cantidad + 1);
      } else {
        _lineas.add(_LineaVenta(elegido));
      }
    });
  }

  /// Abre la lista de clientes guardados.
  Future<void> _searchClient() async {
    final elegido = await elegirCliente(context);
    if (elegido == null || !mounted) return;
    setState(() => _cliente = elegido);
  }

  /// Cierra la hoja y devuelve los datos de la venta (productos con su
  /// cantidad, subtotal, descuento, total, fecha y cliente).
  void _confirm() {
    Navigator.pop(context, {
      'articulos': [
        for (final l in _lineas)
          {
            'producto': l.producto.nombre,
            'cantidad': l.cantidad,
            'precioUnitario': l.precioUnitario,
            'subtotal': l.subtotal,
          },
      ],
      // Resumen (compatibilidad): nombres unidos y total de piezas.
      'producto': _lineas.isEmpty
          ? null
          : _lineas.map((l) => l.producto.nombre).join(', '),
      'cantidad': _piezas,
      'subtotal': _subtotal,
      'descuento': _descuento,
      'total': _total,
      'fecha': _fecha,
      'cliente': _cliente?.fullName,
    });
  }

  /// Botón blanco de borde y esquinas muy redondeadas, usado para
  /// "Buscar producto" y "Buscar cliente".
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

  /// Botón circular con ícono, usado para sumar o restar cantidad.
  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    double size = 58,
    double iconSize = 34,
    double borderWidth = 3,
  }) {
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(color: Colors.white, width: borderWidth),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }

  /// Tarjeta de un producto agregado: nombre, precio unitario, cantidad
  /// (con + y -), total de la línea y botón para quitarlo de la venta.
  Widget _lineaCard(int i) {
    final l = _lineas[i];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.producto.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Quitar producto',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  onPressed: () => setState(() => _descartadas.add(_lineas.removeAt(i))),
                ),
              ],
            ),
            Text(
              '\$${l.precioUnitario.toStringAsFixed(2)} c/u',
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                children: [
                  _circleButton(
                    Icons.remove,
                    () {
                      if (l.cantidad > 1) {
                        setState(() => l.setCantidad(l.cantidad - 1));
                      }
                    },
                    size: 40,
                    iconSize: 24,
                    borderWidth: 2,
                  ),
                  const SizedBox(width: 8),
                  // Cantidad editable: toca el recuadro y escribe con el teclado numérico.
                  Container(
                    width: 96,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: l.ctrl,
                            focusNode: l.focus,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            textAlignVertical: TextAlignVertical.center,
                            cursorColor: Colors.white,
                            inputFormatters: [
                              // Solo dígitos, máximo 6 (hasta 999,999 piezas).
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            // Al tocar, selecciona todo para escribir encima.
                            onTap: () => l.ctrl.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: l.ctrl.text.length,
                            ),
                            // Solo acepta cantidades mayores a 0; si queda
                            // vacío o en 0 se conserva la cantidad anterior.
                            onChanged: (t) {
                              final n = int.tryParse(t);
                              if (n != null && n > 0) {
                                setState(() => l.cantidad = n);
                              }
                            },
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(left: 8, right: 2),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text(
                            'pz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _circleButton(
                    Icons.add,
                    () => setState(() => l.setCantidad(l.cantidad + 1)),
                    size: 40,
                    iconSize: 24,
                    borderWidth: 2,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$${l.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Campo de texto con el mismo estilo de los demás controles
  /// (borde blanco grueso y esquinas muy redondeadas).
  Widget _descuentoField() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: Colors.white, width: 3),
    );

    return SizedBox(
      height: 58,
      child: TextField(
        controller: _descuentoCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          // Solo números con hasta 2 decimales.
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: (_) => setState(() {}),
        cursorColor: Colors.white,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          labelText: 'Agregar descuento',
          labelStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          floatingLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          prefixText: '\$ ',
          prefixStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24),
          enabledBorder: border,
          focusedBorder: border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    // La hoja ocupa el 85% de la pantalla, pero se encoge si el teclado
    // está abierto para no quedar tapada.
    final maxHeight = media.size.height - keyboard - media.padding.top;
    final sheetHeight = (media.size.height * 0.85).clamp(0.0, maxHeight).toDouble();

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
                        '+ Nueva venta',
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

                      // ---------- Productos de la venta ----------
                      _outlinedPill(
                        _lineas.isEmpty ? 'Buscar producto' : '+ Agregar otro producto',
                        _searchProduct,
                      ),
                      if (_lineas.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        for (var i = 0; i < _lineas.length; i++) _lineaCard(i),
                      ],

                      const SizedBox(height: 12),
                      _outlinedPill(_cliente?.fullName ?? 'Buscar cliente', _searchClient),

                      const SizedBox(height: 20),

                      // ---------- Descuento ----------
                      _descuentoField(),

                      const SizedBox(height: 20),

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

                      // Subtotal y descuento (solo si hay descuento).
                      if (_descuento > 0) ...[
                        Text(
                          'Subtotal: \$${_subtotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Descuento: -\$${_descuento.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Total final (ya con descuento).
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '\$ ${_total.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

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
      ),
    ));
  }
}

/// Un producto dentro de la venta, con la cantidad que se lleva el cliente.
class _LineaVenta {
  final Producto producto;
  int cantidad;

  /// Controlador y foco del campo de cantidad (se puede escribir con el
  /// teclado numérico).
  final TextEditingController ctrl;
  final FocusNode focus = FocusNode();

  _LineaVenta(this.producto, [this.cantidad = 1])
      : ctrl = TextEditingController(text: '$cantidad') {
    // Al salir del campo, muestra de nuevo la cantidad válida (por si
    // quedó vacío o en 0).
    focus.addListener(() {
      if (!focus.hasFocus) ctrl.text = '$cantidad';
    });
  }

  /// Cambia la cantidad (con los botones + y -) y actualiza el campo.
  void setCantidad(int n) {
    cantidad = n;
    ctrl.text = '$n';
  }

  void dispose() {
    ctrl.dispose();
    focus.dispose();
  }

  double get precioUnitario => producto.precioVenta;
  double get subtotal => precioUnitario * cantidad;
}
