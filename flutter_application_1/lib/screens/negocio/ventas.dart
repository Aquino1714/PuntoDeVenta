import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';
import '../../formularios/nueva_venta_sheet.dart';
import '../finanzas/finanzas_cuenta.dart' show estado;

class VentasScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const VentasScreen({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<VentasScreen> createState() => _VentasScreenState();
}

enum _Period { dia, semana, mes }

// ---------------------------------------------------------------------------
// Ventas guardadas (global)
// ---------------------------------------------------------------------------

// TODO: reemplazar estos datos de ejemplo por las ventas reales (base de datos / API).
final List<Sale> ventasGuardadas = [
  Sale(
    title: 'Venta 1',
    date: DateTime.now(),
    items: [
      SaleItem(product: 'Nombre del producto', quantity: 2, unitPrice: 50),
    ],
    discount: 10,
    paymentMethod: 'Efectivo',
    clientName: 'Nombre del cliente',
  ),
  Sale(
    title: 'Venta 2',
    date: DateTime.now(),
    items: [
      SaleItem(product: 'Nombre del producto', quantity: 1, unitPrice: 120),
    ],
    paymentMethod: 'Transferencia',
    clientName: 'Nombre del cliente',
  ),
  Sale(
    title: 'Venta 3',
    date: DateTime.now(),
    items: [
      SaleItem(product: 'Nombre del producto', quantity: 3, unitPrice: 35.5),
    ],
    paymentMethod: 'Efectivo',
    clientName: 'Nombre del cliente',
  ),
];


class _VentasScreenState extends State<VentasScreen> {

  _Period _period = _Period.dia;

  /// Las ventas viven en [ventasGuardadas] (lista global), así no se pierden
  /// al cambiar de sección y volver a esta pantalla.
  List<Sale> get _ventas => ventasGuardadas;

  String _periodLabel(_Period p) {
    switch (p) {
      case _Period.dia:
        return 'Día';
      case _Period.semana:
        return 'Semana';
      case _Period.mes:
        return 'Mes';
    }
  }

  bool _inPeriod(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);

    switch (_period) {
      case _Period.dia:
        return day == today;
      case _Period.semana:
        return !day.isBefore(today.subtract(const Duration(days: 6))) &&
            !day.isAfter(today);
      case _Period.mes:
        return date.year == now.year && date.month == now.month;
    }
  }

  List<Sale> get _filtered => _ventas.where((v) => _inPeriod(v.date)).toList();

  void _openSale(Sale sale) {
    showDialog<void>(
      context: context,
      builder: (_) => _SaleDetailDialog(sale: sale),
    );
  }

  Future<void> _newSale() async {
    final sale = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewSaleSheet(),
    );

    if (sale == null || !mounted) return; // el usuario cerró la tarjeta

    // TODO: además de la lista en pantalla, guardar la venta en tu base de
    // datos / API.
    // Productos de la venta (uno o varios) que devuelve la tarjeta.
    final articulos = (sale['articulos'] as List? ?? const [])
        .map((a) => a as Map<String, dynamic>)
        .map((a) => SaleItem(
              product: a['producto'] as String? ?? 'Sin especificar',
              quantity: a['cantidad'] as int? ?? 1,
              unitPrice: (a['precioUnitario'] as num?)?.toDouble() ?? 0,
            ))
        .toList();

    final nueva = Sale(
      title: 'Venta ${_ventas.length + 1}',
      date: sale['fecha'] as DateTime? ?? DateTime.now(),
      items: articulos,
      // Descuento en pesos que devuelve la tarjeta de nueva venta.
      discount: (sale['descuento'] as num?)?.toDouble() ?? 0,
      // Estos datos se llenarán cuando conectes los buscadores de la
      // tarjeta (cliente / método de pago).
      paymentMethod: sale['metodoPago'] as String? ?? 'Sin especificar',
      clientName: sale['cliente'] as String? ?? 'Sin especificar',
    );

    setState(() => _ventas.add(nueva));

    // Registra la venta como ingreso en Finanzas: aparece en "Movimientos
    // recientes", suma a los ingresos y al saldo de la cuenta que
    // corresponda al método de pago.
    estado.registrarVenta(nueva.title, nueva.paymentMethod, nueva.total);
  }

  int _navIndex = 1;

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ventas = _filtered;

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
                          'Ventas',
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

              const SizedBox(height: 20),

              // ---------- Historial de ventas por: Día / Semana / Mes ----------
              Row(
                children: [
                  const Text(
                    'Historial de ventas por:',
                    style: TextStyle(fontSize: 18, color: AppColors.muted),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<_Period>(
                    initialValue: _period,
                    onSelected: (p) => setState(() => _period = p),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    itemBuilder: (_) => [
                      for (final p in _Period.values)
                        PopupMenuItem(
                          value: p,
                          child: Text(
                            _periodLabel(p),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _periodLabel(_period),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.text,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------- Lista de ventas ----------
              Expanded(
                child: ventas.isEmpty
                    ? Center(
                        child: Text(
                          _ventas.isEmpty
                              ? 'No hay ventas registradas'
                              : 'No hay ventas en este periodo',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: ventas.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _SaleTile(
                          title: ventas[i].title,
                          onTap: () => _openSale(ventas[i]),
                        ),
                      ),
              ),

              const SizedBox(height: 12),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Nueva venta ----------
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
                  onPressed: _newSale,
                  child: const Text(
                    '+ Nueva venta',
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

// ---------------------------------------------------------------------------
// Modelo de ejemplo
// ---------------------------------------------------------------------------

/// Un producto dentro de una venta, con su cantidad y precio unitario.
class SaleItem {
  final String product;
  final int quantity;
  final double unitPrice;

  const SaleItem({
    required this.product,
    this.quantity = 1,
    this.unitPrice = 0,
  });

  /// Precio unitario por cantidad.
  double get subtotal => unitPrice * quantity;
}

class Sale {
  final String title;
  final DateTime date;

  /// Productos incluidos en la venta (puede haber varios).
  final List<SaleItem> items;

  /// Descuento en pesos aplicado a la venta.
  final double discount;
  final String paymentMethod;
  final String clientName;

  /// Foto opcional de la venta (si es null se muestra "FOTO (OPCIONAL)").
  final ImageProvider? photo;

  const Sale({
    required this.title,
    required this.date,
    this.items = const [],
    this.discount = 0,
    this.paymentMethod = 'Efectivo',
    this.clientName = 'Nombre del cliente',
  }) : photo = null;

  /// Total antes de aplicar el descuento (suma de todos los productos).
  double get subtotal => items.fold<double>(0, (s, i) => s + i.subtotal);

  /// Total final con el descuento aplicado (nunca menor a 0).
  double get total =>
      (subtotal - discount).clamp(0, double.infinity).toDouble();
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _SaleTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SaleTile({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        onPressed: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.arrow_forward, color: Colors.white, size: 34),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ventana "Detalles de la venta"
// ---------------------------------------------------------------------------

class _SaleDetailDialog extends StatelessWidget {
  final Sale sale;

  const _SaleDetailDialog({required this.sale});

  /// Formato d/M/aa (ej. 1/12/26).
  String _formatFecha(DateTime d) {
    final yy = (d.year % 100).toString().padLeft(2, '0');
    return '${d.day}/${d.month}/$yy';
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$label $value',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Renglón de un producto cuando la venta tiene varios:
  /// "2pz Nombre ........ $100.00" y debajo el precio unitario.
  Widget _itemLine(SaleItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.quantity}pz  ${item.product}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            '\$${item.unitPrice.toStringAsFixed(2)} c/u',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- Encabezado ----------
              const Text(
                'Detalles de la venta:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                sale.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
              ),

              const SizedBox(height: 16),

              if (sale.items.length <= 1)
                _line('Producto:',
                    sale.items.isEmpty ? 'Sin especificar' : sale.items.first.product)
              else
                _line('Productos:', '${sale.items.length}'),

              // ---------- Foto (opcional) ----------
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 8),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: sale.photo != null
                    ? Image(image: sale.photo!, fit: BoxFit.cover)
                    : const Center(
                        child: Text(
                          'FOTO\n(OPCIONAL)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),

              const SizedBox(height: 8),

              // ---------- Datos ----------
              if (sale.items.length <= 1) ...[
                _line('Cantidad:',
                    '${sale.items.isEmpty ? 1 : sale.items.first.quantity}pz'),
                _line(
                  'Precio unitario:',
                  '\$${(sale.items.isEmpty ? 0 : sale.items.first.unitPrice).toStringAsFixed(2)}',
                ),
              ] else
                for (final item in sale.items) _itemLine(item),
              if (sale.discount > 0 || sale.items.length > 1)
                _line('Subtotal:', '\$${sale.subtotal.toStringAsFixed(2)}'),
              if (sale.discount > 0)
                _line('Descuento:', '-\$${sale.discount.toStringAsFixed(2)}'),
              _line('Fecha:', _formatFecha(sale.date)),
              _line('Método del pago:', sale.paymentMethod),
              _line('Cliente:', sale.clientName),

              const SizedBox(height: 28),

              // ---------- Precio total (ya con descuento) ----------
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$ ${sale.total.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}