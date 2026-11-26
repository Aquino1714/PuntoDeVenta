// MY BUSINESS – Finanzas y Mi cuenta
// ---------------------------------------------------------------
// Vive en lib/screens/finanzas/. La app lo usa desde el menú "Más"
// (FinanzasPage y MiCuentaPage, ver barra_navegacion.dart).
// ---------------------------------------------------------------

import 'package:material_ui/material_ui.dart';
import '../acceso/home_screen.dart';

// ======================== COLORES ========================
const kPrimario = Color(0xFF6A1A28); // guinda
const kPrimarioOscuro = Color(0xFF4A111C);
const kPrimarioDegradado = Color(0xFF8A2A3C);
const kFondo = Color(0xFFF5ECDB); // fondo crema de las pantallas
const kOscuro = Color(0xFF12060A); // círculo seleccionado de la barra
const kIconoBarra = Colors.white; // pon kOscuro si prefieres íconos oscuros
const kTexto = Color(0xFF1F2937);
const kTextoSuave = Color(0xFF6B7280);
const kBorde = Color(0xFFE6DCC6);
const kVerde = Color(0xFF2E7D4F);
const kVerdeClaro = Color(0xFFDCEDE2);
const kRojo = Color(0xFF8B2E3A);
const kRojoClaro = Color(0xFFF3DDE0);
const kPrimarioClaro = Color(0xFFF3E4E7);
const kGrisClaro = Color(0xFFEDE5D3);

// ======================== UTILIDADES ========================
String dinero(double v) {
  final partes = v.abs().toStringAsFixed(2).split('.');
  final entero = partes[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (m) => ',',
  );
  return '\$$entero.${partes[1]}';
}

String fechaCorta(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')} / ${d.month.toString().padLeft(2, '0')} / ${d.year}';

String horaActual() {
  final n = DateTime.now();
  final h = n.hour % 12 == 0 ? 12 : n.hour % 12;
  final m = n.minute.toString().padLeft(2, '0');
  return '$h:$m ${n.hour >= 12 ? 'p. m.' : 'a. m.'}';
}

const _meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String mesActual() {
  final n = DateTime.now();
  return '${_meses[n.month - 1]} ${n.year}';
}

String iniciales(String nombre) {
  final p = nombre.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  if (p.length == 1) return p[0][0].toUpperCase();
  return (p[0][0] + p[1][0]).toUpperCase();
}

// ======================== MODELOS Y ESTADO ========================
class Movimiento {
  Movimiento(this.titulo, this.subtitulo, this.monto, this.ingreso);
  final String titulo;
  final String subtitulo;
  final double monto;
  final bool ingreso;
}

class Cuenta {
  Cuenta(this.nombre, this.detalle, this.icono, this.saldo);
  final String nombre;
  final String detalle;
  final IconData icono;
  double saldo;
}

class AppEstado extends ChangeNotifier {
  // Perfil
  String nombre = 'María José Saldaña';
  String correo = 'maria.saldana@correo.com';
  String telefono = '246 123 4567';
  String rol = 'Administrador';

  // Negocio
  String negocio = '*Nombre del negocio*';
  String giro = 'Abarrotes';
  String telNegocio = '246 123 4567';
  String direccion = 'Centro, Tlaxcala';

  // Finanzas
  String periodo = 'Este mes';
  double ingresos = 24780;
  double egresos = 6330;

  final List<Cuenta> cuentas = [
    Cuenta('Efectivo', 'Cuenta principal', Icons.attach_money, 7250),
    Cuenta('Cuenta bancaria', 'Terminación •4821', Icons.credit_card, 11200),
  ];

  final List<Movimiento> movimientos = [
    Movimiento('Venta #1048', 'Hoy, 12:35 p. m.', 1250, true),
    Movimiento('Pago a proveedor', 'Hoy, 10:10 a. m.', 480, false),
    Movimiento('Abono de cliente', 'Ayer, 4:20 p. m.', 650, true),
  ];

  double get saldoTotal => cuentas.fold(0.0, (s, c) => s + c.saldo);

  Cuenta cuentaPorNombre(String n) => cuentas.firstWhere((c) => c.nombre == n);

  void cambiarPeriodo(String p) {
    periodo = p;
    notifyListeners();
  }

  void registrarIngreso(String concepto, String cuenta, double monto) {
    cuentaPorNombre(cuenta).saldo += monto;
    ingresos += monto;
    movimientos.insert(0, Movimiento(concepto, 'Hoy, ${horaActual()}', monto, true));
    notifyListeners();
  }

  /// Devuelve false si la cuenta no tiene saldo suficiente.
  bool registrarEgreso(String concepto, String cuenta, double monto) {
    final c = cuentaPorNombre(cuenta);
    if (c.saldo < monto) return false;
    c.saldo -= monto;
    egresos += monto;
    movimientos.insert(0, Movimiento(concepto, 'Hoy, ${horaActual()}', monto, false));
    notifyListeners();
    return true;
  }

  /// Registra una venta como ingreso (aparece en "Movimientos recientes").
  /// El método de pago decide a qué cuenta entra el dinero:
  /// transferencia o tarjeta → "Cuenta bancaria"; efectivo (o sin
  /// especificar) → "Efectivo".
  void registrarVenta(String concepto, String metodoPago, double monto) {
    final pago = metodoPago.toLowerCase();
    final aBanco = pago.contains('transfer') || pago.contains('tarjeta');
    registrarIngreso(concepto, aBanco ? 'Cuenta bancaria' : 'Efectivo', monto);
  }

  void agregarCuenta(String nombre, double saldo) {
    cuentas.add(Cuenta(nombre, 'Cuenta adicional', Icons.account_balance_wallet_outlined, saldo));
    notifyListeners();
  }

  void guardarPerfil(String n, String c, String t, String r) {
    nombre = n;
    correo = c;
    telefono = t;
    rol = r;
    notifyListeners();
  }

  void guardarNegocio(String n, String g, String t, String d) {
    negocio = n;
    giro = g;
    telNegocio = t;
    direccion = d;
    notifyListeners();
  }
}

final estado = AppEstado();

// ======================== COMPONENTES BASE ========================
class Pantalla extends StatelessWidget {
  const Pantalla({
    super.key,
    required this.titulo,
    required this.hijo,
    this.atras = true,
  });
  final String titulo;
  final Widget hijo;
  final bool atras;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kFondo,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: atras
                        ? InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.maybePop(context),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: kPrimario,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_return,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: estado,
                      builder: (context, _) => Column(
                        children: [
                          Text(
                            estado.negocio,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: kPrimario,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            titulo,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kPrimario,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ),
            Expanded(child: hijo),
          ],
        ),
      ),
    );
  }
}

class Tarjeta extends StatelessWidget {
  const Tarjeta({super.key, required this.hijo, this.padding = EdgeInsets.zero});
  final Widget hijo;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorde),
      ),
      child: hijo,
    );
  }
}

/// Botón tipo píldora (como "Venta 1 →"). Con flecha=true muestra la flecha a la derecha.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    required this.alPresionar,
    this.flecha = false,
  });
  final String texto;
  final VoidCallback alPresionar;
  final bool flecha;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: alPresionar,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimario,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: const StadiumBorder(),
        ),
        child: Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            SizedBox(
              width: 24,
              child: flecha
                  ? const Icon(Icons.arrow_forward, color: Colors.white, size: 24)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class BotonSecundario extends StatelessWidget {
  const BotonSecundario({super.key, required this.texto, required this.alPresionar});
  final String texto;
  final VoidCallback alPresionar;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton(
        onPressed: alPresionar,
        style: OutlinedButton.styleFrom(
          foregroundColor: kPrimario,
          side: const BorderSide(color: kPrimario, width: 1.5),
          shape: const StadiumBorder(),
        ),
        child: Text(texto, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
    );
  }
}

InputDecoration decoracion([String? pista]) {
  OutlineInputBorder borde(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    hintText: pista,
    hintStyle: const TextStyle(color: Color(0xFFB0B5BD), fontSize: 14),
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: borde(kBorde),
    enabledBorder: borde(kBorde),
    focusedBorder: borde(kPrimario),
  );
}

class Etiquetado extends StatelessWidget {
  const Etiquetado({super.key, required this.etiqueta, required this.hijo});
  final String etiqueta;
  final Widget hijo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 12, color: kTextoSuave)),
          const SizedBox(height: 6),
          hijo,
        ],
      ),
    );
  }
}

class Campo extends StatelessWidget {
  const Campo({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.pista,
    this.teclado,
    this.oculto = false,
  });
  final String etiqueta;
  final TextEditingController controlador;
  final String? pista;
  final TextInputType? teclado;
  final bool oculto;

  @override
  Widget build(BuildContext context) {
    return Etiquetado(
      etiqueta: etiqueta,
      hijo: TextField(
        controller: controlador,
        keyboardType: teclado,
        obscureText: oculto,
        decoration: decoracion(pista),
      ),
    );
  }
}

class Selector extends StatelessWidget {
  const Selector({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.opciones,
    required this.alCambiar,
  });
  final String etiqueta;
  final String valor;
  final List<String> opciones;
  final ValueChanged<String> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Etiquetado(
      etiqueta: etiqueta,
      hijo: InputDecorator(
        decoration: decoracion(),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: valor,
            isExpanded: true,
            isDense: true,
            items: [
              for (final o in opciones) DropdownMenuItem(value: o, child: Text(o)),
            ],
            onChanged: (v) {
              if (v != null) alCambiar(v);
            },
          ),
        ),
      ),
    );
  }
}

class CampoFecha extends StatelessWidget {
  const CampoFecha({super.key, required this.fecha, required this.alCambiar});
  final DateTime fecha;
  final ValueChanged<DateTime> alCambiar;

  @override
  Widget build(BuildContext context) {
    return Etiquetado(
      etiqueta: 'Fecha',
      hijo: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final f = await showDatePicker(
            context: context,
            initialDate: fecha,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (f != null) alCambiar(f);
        },
        child: InputDecorator(
          decoration: decoracion(),
          child: Text(fechaCorta(fecha)),
        ),
      ),
    );
  }
}

void aviso(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto), behavior: SnackBarBehavior.floating));
}

class FilaMovimiento extends StatelessWidget {
  const FilaMovimiento({super.key, required this.m});
  final Movimiento m;

  @override
  Widget build(BuildContext context) {
    final color = m.ingreso ? kVerde : kRojo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: m.ingreso ? kVerdeClaro : kRojoClaro,
            child: Icon(
              m.ingreso ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.titulo,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: kTexto)),
                const SizedBox(height: 2),
                Text(m.subtitulo,
                    style: const TextStyle(fontSize: 12, color: kTextoSuave)),
              ],
            ),
          ),
          Text(
            '${m.ingreso ? '+' : '-'} ${dinero(m.monto)}',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// ======================== FINANZAS ========================
class FinanzasPage extends StatelessWidget {
  const FinanzasPage({super.key});

  void _elegirPeriodo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final p in ['Hoy', 'Esta semana', 'Este mes', 'Este año'])
              ListTile(
                title: Text(p),
                trailing: p == estado.periodo
                    ? const Icon(Icons.check, color: kPrimario)
                    : null,
                onTap: () {
                  estado.cambiarPeriodo(p);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) {
        final recientes = estado.movimientos.take(3).toList();
        return Pantalla(
          titulo: 'Finanzas',
          atras: Navigator.canPop(context),
          hijo: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tarjetaSaldo(),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen del periodo',
                            style: TextStyle(fontSize: 12, color: kTextoSuave)),
                        const SizedBox(height: 2),
                        Text(mesActual(),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: kTexto)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _elegirPeriodo(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Periodo: ',
                            style: TextStyle(fontSize: 13, color: kTextoSuave)),
                        Text(estado.periodo,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kTexto)),
                        const Icon(Icons.arrow_drop_down, size: 20, color: kTexto),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              BotonPrincipal(
                texto: 'Registrar ingreso',
                flecha: true,
                alPresionar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegistrarMovimientoPage(ingreso: true)),
                ),
              ),
              const SizedBox(height: 12),
              BotonPrincipal(
                texto: 'Registrar egreso',
                flecha: true,
                alPresionar: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegistrarMovimientoPage(ingreso: false)),
                ),
              ),
              const SizedBox(height: 12),
              BotonPrincipal(
                texto: 'Ver cuentas',
                flecha: true,
                alPresionar: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MisCuentasPage()),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Movimientos recientes',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700, color: kTexto)),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MovimientosPage()),
                    ),
                    child: const Text('Ver todos',
                        style: TextStyle(
                            color: kPrimario, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Tarjeta(
                hijo: Column(
                  children: [
                    for (var i = 0; i < recientes.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: kBorde),
                      FilaMovimiento(m: recientes[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _tarjetaSaldo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimarioDegradado, kPrimarioOscuro],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x336A1A28), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text('Saldo total', style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          Text(dinero(estado.saldoTotal),
              style: const TextStyle(
                  color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Actualizado hoy, ${horaActual()}',
              style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
          const SizedBox(height: 14),
          const Divider(color: Color(0x44FFFFFF), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _resumen(Icons.arrow_upward, kVerde, kVerdeClaro, 'Ingresos',
                    estado.ingresos),
              ),
              Expanded(
                child: _resumen(Icons.arrow_downward, kRojo, kRojoClaro, 'Egresos',
                    estado.egresos),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resumen(IconData i, Color c, Color f, String t, double v) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundColor: f, child: Icon(i, color: c, size: 18)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t, style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text(dinero(v),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

// ======================== MOVIMIENTOS (VER TODOS) ========================
class MovimientosPage extends StatelessWidget {
  const MovimientosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) => Pantalla(
        titulo: 'Movimientos',
        hijo: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Tarjeta(
              hijo: Column(
                children: [
                  for (var i = 0; i < estado.movimientos.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: kBorde),
                    FilaMovimiento(m: estado.movimientos[i]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================== REGISTRAR INGRESO / EGRESO ========================
class RegistrarMovimientoPage extends StatefulWidget {
  const RegistrarMovimientoPage({super.key, required this.ingreso});
  final bool ingreso;

  @override
  State<RegistrarMovimientoPage> createState() => _RegistrarMovimientoPageState();
}

class _RegistrarMovimientoPageState extends State<RegistrarMovimientoPage> {
  final _monto = TextEditingController();
  final _concepto = TextEditingController();
  final _notas = TextEditingController();
  late String _cuenta = estado.cuentas.first.nombre;
  String _categoria = 'Gastos operativos';
  DateTime _fecha = DateTime.now();

  static const _categorias = [
    'Gastos operativos',
    'Inventario',
    'Servicios',
    'Nómina',
    'Otros',
  ];

  @override
  void dispose() {
    _monto.dispose();
    _concepto.dispose();
    _notas.dispose();
    super.dispose();
  }

  void _guardar() {
    final monto = double.tryParse(_monto.text.replaceAll(',', '.')) ?? 0;
    if (monto <= 0) {
      aviso(context, 'Ingresa un monto mayor a 0');
      return;
    }
    final concepto = _concepto.text.trim().isEmpty
        ? (widget.ingreso ? 'Ingreso' : _categoria)
        : _concepto.text.trim();

    if (widget.ingreso) {
      estado.registrarIngreso(concepto, _cuenta, monto);
    } else if (!estado.registrarEgreso(concepto, _cuenta, monto)) {
      aviso(context, 'Saldo insuficiente en la cuenta seleccionada');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(
      content: Text(widget.ingreso ? 'Ingreso registrado' : 'Egreso registrado'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ingreso = widget.ingreso;
    final nombres = estado.cuentas.map((c) => c.nombre).toList();
    return Pantalla(
      titulo: ingreso ? 'Registrar ingreso' : 'Registrar egreso',
      hijo: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: ingreso ? kPrimarioClaro : kGrisClaro,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: SizedBox(
                width: 220,
                child: TextField(
                  controller: _monto,
                  textAlign: TextAlign.center,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: ingreso ? kPrimario : kTexto,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixText: '\$ ',
                    prefixStyle: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: ingreso ? kPrimario : kTexto,
                    ),
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: ingreso ? const Color(0xFFC99AA3) : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Campo(
            etiqueta: 'Concepto',
            controlador: _concepto,
            pista: ingreso ? 'Ej. Venta del día' : 'Ej. Pago de servicios',
          ),
          if (!ingreso)
            Selector(
              etiqueta: 'Categoría',
              valor: _categoria,
              opciones: _categorias,
              alCambiar: (v) => setState(() => _categoria = v),
            ),
          Selector(
            etiqueta: ingreso ? 'Cuenta de destino' : 'Cuenta de origen',
            valor: _cuenta,
            opciones: nombres,
            alCambiar: (v) => setState(() => _cuenta = v),
          ),
          CampoFecha(fecha: _fecha, alCambiar: (f) => setState(() => _fecha = f)),
          if (ingreso)
            Campo(
              etiqueta: 'Notas (opcional)',
              controlador: _notas,
              pista: 'Agrega una descripción',
            ),
          const SizedBox(height: 6),
          BotonPrincipal(
            texto: ingreso ? 'Registrar ingreso' : 'Registrar egreso',
            alPresionar: _guardar,
          ),
        ],
      ),
    );
  }
}

// ======================== MIS CUENTAS ========================
class MisCuentasPage extends StatelessWidget {
  const MisCuentasPage({super.key});

  Future<void> _agregar(BuildContext context) async {
    final datos = await showDialog<(String, double)>(
      context: context,
      builder: (_) => const _DialogoNuevaCuenta(),
    );
    if (datos == null) return; // canceló
    estado.agregarCuenta(datos.$1, datos.$2);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) => Pantalla(
        titulo: 'Mis cuentas',
        hijo: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [kPrimarioDegradado, kPrimarioOscuro],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Saldo disponible',
                      style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text(dinero(estado.saldoTotal),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('En todas tus cuentas',
                      style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Cuentas registradas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextoSuave)),
            const SizedBox(height: 10),
            Tarjeta(
              hijo: Column(
                children: [
                  for (var i = 0; i < estado.cuentas.length; i++) ...[
                    if (i > 0) const Divider(height: 1, color: kBorde),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kPrimarioClaro,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(estado.cuentas[i].icono, color: kPrimario),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(estado.cuentas[i].nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, color: kTexto)),
                                Text(estado.cuentas[i].detalle,
                                    style: const TextStyle(
                                        fontSize: 12, color: kTextoSuave)),
                              ],
                            ),
                          ),
                          Text(dinero(estado.cuentas[i].saldo),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, color: kTexto)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: () => _agregar(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimario,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: kPrimario),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('+ Agregar nueva cuenta',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Diálogo para agregar una cuenta. Los controladores viven dentro de su
/// propio State y se liberan cuando el diálogo termina de cerrarse; así no
/// se usan después de liberarlos (eso era lo que cerraba la app).
class _DialogoNuevaCuenta extends StatefulWidget {
  const _DialogoNuevaCuenta();

  @override
  State<_DialogoNuevaCuenta> createState() => _DialogoNuevaCuentaState();
}

class _DialogoNuevaCuentaState extends State<_DialogoNuevaCuenta> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _saldo = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _saldo.dispose();
    super.dispose();
  }

  /// Valida y cierra el diálogo devolviendo (nombre, saldo inicial).
  void _guardar() {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      setState(() => _error = 'Escribe el nombre de la cuenta');
      return;
    }
    final repetida = estado.cuentas
        .any((c) => c.nombre.toLowerCase() == nombre.toLowerCase());
    if (repetida) {
      setState(() => _error = 'Ya existe una cuenta con ese nombre');
      return;
    }
    final saldo = double.tryParse(_saldo.text.trim().replaceAll(',', '.')) ?? 0;
    Navigator.pop(context, (nombre, saldo));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar nueva cuenta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration:
                decoracion('Nombre de la cuenta').copyWith(errorText: _error),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _saldo,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: decoracion('Saldo inicial'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _guardar, child: const Text('Agregar')),
      ],
    );
  }
}

// ======================== MI CUENTA ========================
class MiCuentaPage extends StatelessWidget {
  const MiCuentaPage({super.key});

  void _ir(BuildContext context, Widget pagina) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estado,
      builder: (context, _) => Pantalla(
        titulo: 'Mi cuenta',
        // Botón de salir (arriba a la izquierda): regresa a la vista anterior.
        atras: true,
        hijo: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: kPrimario,
                child: Text(iniciales(estado.nombre),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(estado.nombre,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800, color: kTexto)),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: kPrimarioClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(estado.rol,
                    style: const TextStyle(
                        fontSize: 11, color: kPrimario, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(estado.correo,
                  style: const TextStyle(fontSize: 12, color: kTextoSuave)),
            ),
            const SizedBox(height: 22),
            const Text('Configuración de cuenta',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextoSuave)),
            const SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Información personal',
              flecha: true,
              alPresionar: () => _ir(context, const InfoPersonalPage()),
            ),
            const SizedBox(height: 12),
            BotonPrincipal(
              texto: 'Mi negocio',
              flecha: true,
              alPresionar: () => _ir(context, const MiNegocioPage()),
            ),
            const SizedBox(height: 12),
            BotonPrincipal(
              texto: 'Seguridad',
              flecha: true,
              alPresionar: () => _ir(context, const SeguridadPage()),
            ),
            const SizedBox(height: 20),
            const Text('Administración',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextoSuave)),
            const SizedBox(height: 10),
            BotonPrincipal(
              texto: 'Finanzas',
              flecha: true,
              alPresionar: () => _ir(context, const FinanzasPage()),
            ),
            const SizedBox(height: 12),
            BotonSecundario(
              texto: 'Cerrar sesión',
              alPresionar: () => _ir(context, const CerrarSesionPage()),
            ),
            const SizedBox(height: 14),
            const Center(
              child: Text('MY BUSINESS · Versión 1.0.0',
                  style: TextStyle(fontSize: 10, color: kTextoSuave)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ======================== INFORMACIÓN PERSONAL ========================
class InfoPersonalPage extends StatefulWidget {
  const InfoPersonalPage({super.key});

  @override
  State<InfoPersonalPage> createState() => _InfoPersonalPageState();
}

class _InfoPersonalPageState extends State<InfoPersonalPage> {
  final _nombre = TextEditingController(text: estado.nombre);
  final _correo = TextEditingController(text: estado.correo);
  final _telefono = TextEditingController(text: estado.telefono);
  final _rol = TextEditingController(text: estado.rol);

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _telefono.dispose();
    _rol.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombre.text.trim().isEmpty || !_correo.text.contains('@')) {
      aviso(context, 'Revisa tu nombre y correo electrónico');
      return;
    }
    estado.guardarPerfil(
        _nombre.text.trim(), _correo.text.trim(), _telefono.text.trim(), _rol.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(
        content: Text('Cambios guardados'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Pantalla(
      titulo: 'Información personal',
      hijo: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: kPrimario,
                  child: Text(iniciales(estado.nombre),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: () => aviso(context, 'Cambiar foto (pendiente)'),
                    child: const CircleAvatar(
                      radius: 11,
                      backgroundColor: kTexto,
                      child: Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Campo(etiqueta: 'Nombre completo', controlador: _nombre),
          Campo(
              etiqueta: 'Correo electrónico',
              controlador: _correo,
              teclado: TextInputType.emailAddress),
          Campo(etiqueta: 'Teléfono', controlador: _telefono, teclado: TextInputType.phone),
          Campo(etiqueta: 'Rol', controlador: _rol),
          const SizedBox(height: 6),
          BotonPrincipal(texto: 'Guardar cambios', alPresionar: _guardar),
        ],
      ),
    );
  }
}

// ======================== MI NEGOCIO ========================
class MiNegocioPage extends StatefulWidget {
  const MiNegocioPage({super.key});

  @override
  State<MiNegocioPage> createState() => _MiNegocioPageState();
}

class _MiNegocioPageState extends State<MiNegocioPage> {
  final _nombre = TextEditingController(text: estado.negocio);
  final _giro = TextEditingController(text: estado.giro);
  final _telefono = TextEditingController(text: estado.telNegocio);
  final _direccion = TextEditingController(text: estado.direccion);

  @override
  void dispose() {
    _nombre.dispose();
    _giro.dispose();
    _telefono.dispose();
    _direccion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombre.text.trim().isEmpty) {
      aviso(context, 'Escribe el nombre comercial');
      return;
    }
    estado.guardarNegocio(_nombre.text.trim(), _giro.text.trim(), _telefono.text.trim(),
        _direccion.text.trim());
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(
        content: Text('Cambios guardados'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Pantalla(
      titulo: 'Mi negocio',
      hijo: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: kPrimarioClaro,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.storefront_outlined, color: kPrimario, size: 32),
            ),
          ),
          const SizedBox(height: 20),
          Campo(etiqueta: 'Nombre comercial', controlador: _nombre),
          Campo(etiqueta: 'Giro del negocio', controlador: _giro),
          Campo(etiqueta: 'Teléfono', controlador: _telefono, teclado: TextInputType.phone),
          Campo(etiqueta: 'Dirección', controlador: _direccion),
          const SizedBox(height: 6),
          BotonPrincipal(texto: 'Guardar cambios', alPresionar: _guardar),
        ],
      ),
    );
  }
}

// ======================== SEGURIDAD ========================
class SeguridadPage extends StatefulWidget {
  const SeguridadPage({super.key});

  @override
  State<SeguridadPage> createState() => _SeguridadPageState();
}

class _SeguridadPageState extends State<SeguridadPage> {
  final _actual = TextEditingController();
  final _nueva = TextEditingController();
  final _confirmar = TextEditingController();

  @override
  void dispose() {
    _actual.dispose();
    _nueva.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_actual.text.isEmpty) {
      aviso(context, 'Escribe tu contraseña actual');
      return;
    }
    if (_nueva.text.length < 8) {
      aviso(context, 'La nueva contraseña debe tener mínimo 8 caracteres');
      return;
    }
    if (_nueva.text != _confirmar.text) {
      aviso(context, 'Las contraseñas no coinciden');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(const SnackBar(
        content: Text('Contraseña actualizada'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Pantalla(
      titulo: 'Seguridad',
      hijo: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kPrimarioClaro,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: kPrimario),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Protege tu cuenta',
                          style: TextStyle(
                              color: kPrimario, fontWeight: FontWeight.w700, fontSize: 13)),
                      Text('Actualiza tu contraseña periódicamente.',
                          style: TextStyle(color: kTextoSuave, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Campo(etiqueta: 'Contraseña actual', controlador: _actual, oculto: true),
          Campo(
              etiqueta: 'Nueva contraseña',
              controlador: _nueva,
              oculto: true,
              pista: 'Mínimo 8 caracteres'),
          Campo(
              etiqueta: 'Confirmar contraseña',
              controlador: _confirmar,
              oculto: true,
              pista: 'Repite la contraseña'),
          const SizedBox(height: 6),
          BotonPrincipal(texto: 'Guardar cambios', alPresionar: _guardar),
        ],
      ),
    );
  }
}

// ======================== CERRAR SESIÓN ========================
class CerrarSesionPage extends StatelessWidget {
  const CerrarSesionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Pantalla(
      titulo: 'Cerrar sesión',
      hijo: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: kPrimarioClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.logout, color: kPrimario, size: 34),
            ),
            const SizedBox(height: 20),
            const Text('¿Deseas cerrar sesión?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: kTexto)),
            const SizedBox(height: 8),
            const Text(
              'Tendrás que ingresar nuevamente tus datos para acceder a MY BUSINESS.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: kTextoSuave),
            ),
            const SizedBox(height: 28),
            BotonPrincipal(
              texto: 'Sí, cerrar sesión',
              alPresionar: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SesionCerradaPage()),
                (_) => false,
              ),
            ),
            const SizedBox(height: 10),
            BotonSecundario(texto: 'Cancelar', alPresionar: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}

class SesionCerradaPage extends StatelessWidget {
  const SesionCerradaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: kPrimario, size: 64),
              const SizedBox(height: 16),
              const Text('Sesión cerrada',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 24),
              BotonPrincipal(
                texto: 'Iniciar sesión',
                alPresionar: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}