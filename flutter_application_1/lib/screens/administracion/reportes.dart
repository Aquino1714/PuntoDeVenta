import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';

class ReportesScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const ReportesScreen({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

enum _Filtro { todos, ingresos, gastos }

class _ReportesScreenState extends State<ReportesScreen> {
  static const _red = Color(0xFF8B2E3A); // mismo rojo que Finanzas

  // TODO: reemplazar estos datos de ejemplo por los reales (base de datos / API).
  final List<String> _negocios = ['Negocio Principal', 'Sucursal Centro'];
  late String _negocio = _negocios.first;

  final double _ingresos = 25000;
  final double _egresos = 8500;

  final List<_Movimiento> _movimientos = [
    _Movimiento('Venta de varios productos', DateTime(2026, 11, 10), 1200, true),
    _Movimiento('Nombre de algún producto', DateTime(2026, 10, 15), 850, false),
  ];

  _Filtro _filtro = _Filtro.todos;
  late DateTimeRange _rango = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );

  double get _balance => _ingresos - _egresos;

  List<_Movimiento> get _filtrados {
    switch (_filtro) {
      case _Filtro.ingresos:
        return _movimientos.where((m) => m.ingreso).toList();
      case _Filtro.gastos:
        return _movimientos.where((m) => !m.ingreso).toList();
      case _Filtro.todos:
        return _movimientos;
    }
  }

  String get _rangoTexto {
    final a = _rango.start, b = _rango.end;
    String dd(DateTime d) => d.day.toString().padLeft(2, '0');
    if (a.month == b.month && a.year == b.year) {
      return '${dd(a)} - ${dd(b)} ${_mesesCortos[a.month - 1]}';
    }
    return '${dd(a)} ${_mesesCortos[a.month - 1]} - '
        '${dd(b)} ${_mesesCortos[b.month - 1]}';
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _rango,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    // TODO: volver a consultar los reportes con el nuevo rango de fechas.
    setState(() => _rango = picked);
  }

  int _navIndex = 4; // se llega desde el menú "Más"

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final movimientos = _filtrados;

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
                          'Reportes',
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

              // ---------- Contenido con scroll ----------
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Negocio
                    _PillDropdown(
                      value: _negocio,
                      items: _negocios,
                      onChanged: (v) {
                        // TODO: volver a consultar los reportes de este negocio.
                        setState(() => _negocio = v);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Rango de fechas
                    SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(33),
                          ),
                        ),
                        onPressed: _pickRange,
                        icon: const Icon(Icons.calendar_today, size: 22),
                        label: Text(
                          _rangoTexto,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Balance total
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Balance total • MXN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _money(_balance),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ingresos / egresos
                    Row(
                      children: [
                        Expanded(
                          child: _TotalCard(
                              label: 'Ingresos totales',
                              amount: _money(_ingresos),
                              color: AppColors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TotalCard(
                              label: 'Egresos totales',
                              amount: _money(_egresos),
                              color: _red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Filtros
                    Row(
                      children: [
                        for (final entry in const {
                          _Filtro.todos: 'Todos',
                          _Filtro.ingresos: 'Ingresos',
                          _Filtro.gastos: 'Gastos',
                        }.entries) ...[
                          Expanded(
                            child: _FilterPill(
                              label: entry.value,
                              selected: _filtro == entry.key,
                              onTap: () => setState(() => _filtro = entry.key),
                            ),
                          ),
                          if (entry.key != _Filtro.gastos)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Movimientos
                    if (movimientos.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No hay movimientos',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 18, color: AppColors.text),
                        ),
                      )
                    else
                      for (final m in movimientos) ...[
                        _MovimientoCard(movimiento: m, red: _red),
                        const SizedBox(height: 12),
                      ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utilidades y modelo de ejemplo
// ---------------------------------------------------------------------------

const _mesesCortos = [
  'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

String _money(double v) {
  final p = v.abs().toStringAsFixed(2).split('.');
  final e = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return '\$$e.${p[1]}';
}

String _fecha(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} ${_mesesCortos[d.month - 1]} ${d.year}';

class _Movimiento {
  final String titulo;
  final DateTime fecha;
  final double monto; // siempre positivo; el signo lo da [ingreso]
  final bool ingreso;

  _Movimiento(this.titulo, this.fecha, this.monto, this.ingreso);
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

/// Selector desplegable con forma de pastilla.
class _PillDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary, size: 34),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          items: [
            for (final e in items) DropdownMenuItem(value: e, child: Text(e)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Tarjeta con borde: etiqueta y monto (ingresos / egresos).
class _TotalCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _TotalCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón de filtro: relleno cuando está seleccionado, contorno si no.
class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: selected ? AppColors.primary : Colors.white,
          foregroundColor: selected ? Colors.white : AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(33),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Tarjeta de movimiento: título, fecha y monto con signo.
class _MovimientoCard extends StatelessWidget {
  final _Movimiento movimiento;
  final Color red;

  const _MovimientoCard({required this.movimiento, required this.red});

  @override
  Widget build(BuildContext context) {
    final m = movimiento;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fecha(m.fecha),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Chip blanco para que el verde/rojo se lea sobre el fondo azul.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${m.ingreso ? '+' : '-'}${_money(m.monto)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: m.ingreso ? AppColors.green : red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}