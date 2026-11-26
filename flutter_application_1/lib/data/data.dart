import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------- Utilidades de formato ----------
String money(double v) {
  final neg = v < 0;
  final parts = v.abs().toStringAsFixed(2).split('.');
  final entero = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '${neg ? '-' : ''}\$$entero.${parts[1]}';
}

String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String phoneFmt(String p) =>
    p.length == 10 ? '${p.substring(0, 2)} ${p.substring(2, 6)} ${p.substring(6)}' : p;

const meses = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
];

// ---------- Modelos ----------
class Periodo {
  String titulo, estado;
  Periodo(this.titulo, this.estado);
}

class Movimiento {
  final String titulo, fecha;
  final double monto;
  const Movimiento(this.titulo, this.monto, this.fecha);
}

class Empleado {
  final int id;
  String nombre, telefono, correo, direccion, cargo, turno, periodicidad, emergencia;
  double salario;
  bool atender, autorizar, reportes;
  final List<Periodo> periodos;
  Empleado({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.correo,
    this.direccion = '',
    required this.cargo,
    required this.turno,
    required this.salario,
    this.periodicidad = 'Quincenal',
    this.emergencia = '',
    this.atender = true,
    this.autorizar = true,
    this.reportes = false,
    List<Periodo>? periodos,
  }) : periodos = periodos ?? [];

  String get subtitulo => '$cargo · Turno ${turno.toLowerCase()}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'cargo': cargo,
        'turno': turno,
        'periodicidad': periodicidad,
        'emergencia': emergencia,
        'salario': salario,
        'atender': atender,
        'autorizar': autorizar,
        'reportes': reportes,
        'periodos': [
          for (final p in periodos) {'t': p.titulo, 'e': p.estado}
        ],
      };

  factory Empleado.fromJson(Map<String, dynamic> j) => Empleado(
        id: j['id'] as int,
        nombre: j['nombre'] as String,
        telefono: j['telefono'] as String,
        correo: j['correo'] as String,
        direccion: (j['direccion'] ?? '') as String,
        cargo: j['cargo'] as String,
        turno: j['turno'] as String,
        periodicidad: (j['periodicidad'] ?? 'Quincenal') as String,
        emergencia: (j['emergencia'] ?? '') as String,
        salario: (j['salario'] as num).toDouble(),
        atender: (j['atender'] ?? true) as bool,
        autorizar: (j['autorizar'] ?? true) as bool,
        reportes: (j['reportes'] ?? false) as bool,
        periodos: [
          for (final p in (j['periodos'] as List? ?? []))
            Periodo(p['t'] as String, p['e'] as String)
        ],
      );
}

class Cliente {
  final int id;
  String nombre, apPaterno, apMaterno, telefono, correo, direccion, tipoPago, folio;
  int plazo;
  double limite, saldo;
  final List<Movimiento> abonos;
  final List<List<String>> compras;
  Cliente({
    required this.id,
    required this.nombre,
    required this.apPaterno,
    this.apMaterno = '',
    required this.telefono,
    required this.correo,
    this.direccion = '',
    this.tipoPago = 'Contado',
    this.plazo = 15,
    this.limite = 8000,
    this.saldo = 0,
    this.folio = '',
    List<Movimiento>? abonos,
    List<List<String>>? compras,
  })  : abonos = abonos ?? [],
        compras = compras ?? [];

  String get fullName =>
      [nombre, apPaterno, apMaterno].where((e) => e.trim().isNotEmpty).join(' ');
  bool get tieneSaldo => saldo > 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'apPaterno': apPaterno,
        'apMaterno': apMaterno,
        'telefono': telefono,
        'correo': correo,
        'direccion': direccion,
        'tipoPago': tipoPago,
        'folio': folio,
        'plazo': plazo,
        'limite': limite,
        'saldo': saldo,
        'abonos': [
          for (final m in abonos) {'t': m.titulo, 'm': m.monto, 'f': m.fecha}
        ],
        'compras': compras,
      };

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
        id: j['id'] as int,
        nombre: j['nombre'] as String,
        apPaterno: j['apPaterno'] as String,
        apMaterno: (j['apMaterno'] ?? '') as String,
        telefono: j['telefono'] as String,
        correo: j['correo'] as String,
        direccion: (j['direccion'] ?? '') as String,
        tipoPago: (j['tipoPago'] ?? 'Contado') as String,
        folio: (j['folio'] ?? '') as String,
        plazo: (j['plazo'] ?? 15) as int,
        limite: (j['limite'] as num).toDouble(),
        saldo: (j['saldo'] as num).toDouble(),
        abonos: [
          for (final m in (j['abonos'] as List? ?? []))
            Movimiento(m['t'] as String, (m['m'] as num).toDouble(), m['f'] as String)
        ],
        compras: [
          for (final c in (j['compras'] as List? ?? []))
            [for (final x in (c as List)) x as String]
        ],
      );
}

// ---------- Almacén de datos en memoria ----------
class AppStore extends ChangeNotifier {
  int _next = 4524;
  int nextId() => _next++;

  final List<Empleado> empleados = [
    Empleado(
      id: 1,
      nombre: 'Mariana Torres Ruiz',
      telefono: '5512345678',
      correo: 'mariana@correo.mx',
      direccion: 'Av. Juárez 12, Centro',
      cargo: 'Cajera',
      turno: 'Matutino',
      salario: 6800,
      periodos: [
        Periodo('Quincena 1 · Mayo', 'Pagada'),
        Periodo('Quincena 2 · Abril', 'Pagada'),
        Periodo('Quincena 1 · Abril', 'Pagada'),
        Periodo('Quincena 2 · Marzo', 'Pendiente'),
      ],
    ),
    Empleado(
      id: 2,
      nombre: 'Diego Ramírez',
      telefono: '5598765432',
      correo: 'diego@correo.mx',
      direccion: 'Calle Hidalgo 8, Centro',
      cargo: 'Almacén',
      turno: 'Vespertino',
      salario: 6200,
    ),
  ];

  final List<Cliente> clientes = [
    Cliente(
      id: 4521,
      nombre: 'Ana',
      apPaterno: 'López',
      apMaterno: 'Martínez',
      telefono: '5512345678',
      correo: 'ana.lopez@correo.mx',
      direccion: 'Calle Morelos 45, Tlaxcala',
      tipoPago: 'Crédito',
      plazo: 15,
      limite: 8000,
      saldo: 3200,
      folio: 'CR-024',
      compras: [
        ['Compra #1024', '\$4,200.00'],
        ['Compra #1018', '\$1,350.00'],
        ['Compra #1009', '\$780.00'],
      ],
    ),
    Cliente(
      id: 4522,
      nombre: 'Luis',
      apPaterno: 'Hernández',
      apMaterno: 'Díaz',
      telefono: '5587654321',
      correo: 'luis.hernandez@correo.mx',
      direccion: 'Av. Reforma 20, Tlaxcala',
      tipoPago: 'Crédito',
      plazo: 30,
      limite: 10000,
      saldo: 4250,
      folio: 'CR-025',
    ),
    Cliente(
      id: 4523,
      nombre: 'Sofía',
      apPaterno: 'Ramos',
      apMaterno: 'Pérez',
      telefono: '5524681357',
      correo: 'sofia.ramos@correo.mx',
      direccion: 'Calle Allende 3, Tlaxcala',
      tipoPago: 'Crédito',
      plazo: 15,
      limite: 8000,
      saldo: 5200,
      folio: 'CR-026',
    ),
  ];

  // ---------- Persistencia (SharedPreferences) ----------
  static const _prefsKey = 'my_business_store_v1';

  /// Carga los datos guardados. Si no hay, se quedan los datos de ejemplo.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final m = jsonDecode(raw) as Map<String, dynamic>;
      _next = m['next'] as int;
      empleados
        ..clear()
        ..addAll((m['empleados'] as List).map((e) => Empleado.fromJson(e as Map<String, dynamic>)));
      clientes
        ..clear()
        ..addAll((m['clientes'] as List).map((e) => Cliente.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      // Datos dañados: se ignoran y se usan los de ejemplo.
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode({
          'next': _next,
          'empleados': empleados.map((e) => e.toJson()).toList(),
          'clientes': clientes.map((c) => c.toJson()).toList(),
        }),
      );
    } catch (_) {}
  }

  /// Cada cambio avisa a las pantallas y se guarda en el dispositivo.
  @override
  void notifyListeners() {
    super.notifyListeners();
    _save();
  }

  // ---------- Duplicados (se ignora el propio registro al editar) ----------
  static String _mail(String v) => v.trim().toLowerCase();

  bool telefonoEmpleadoExiste(String tel, {int? exceptId}) =>
      empleados.any((e) => e.id != exceptId && e.telefono == tel);
  bool correoEmpleadoExiste(String mail, {int? exceptId}) =>
      empleados.any((e) => e.id != exceptId && _mail(e.correo) == _mail(mail));
  bool telefonoClienteExiste(String tel, {int? exceptId}) =>
      clientes.any((c) => c.id != exceptId && c.telefono == tel);
  bool correoClienteExiste(String mail, {int? exceptId}) =>
      clientes.any((c) => c.id != exceptId && _mail(c.correo) == _mail(mail));

  double get nominaMensual => empleados.fold(0.0, (s, e) => s + e.salario);
  double get saldoTotal => clientes.fold(0.0, (s, c) => s + c.saldo);

  void addEmpleado(Empleado e) {
    empleados.add(e);
    notifyListeners();
  }

  void addCliente(Cliente c) {
    clientes.add(c);
    notifyListeners();
  }

  /// Llamar después de editar los campos de un empleado/cliente existente.
  void changed() => notifyListeners();

  void registrarPago(Empleado e, double monto) {
    e.periodos.insert(
        0, Periodo('Pago del ${fmtDate(DateTime.now())} · ${money(monto)}', 'Pagada'));
    notifyListeners();
  }

  void registrarAbono(Cliente c, double monto, String metodo) {
    final nuevo = c.saldo - monto;
    c.saldo = nuevo < 0 ? 0.0 : nuevo;
    c.abonos.insert(0, Movimiento(metodo, monto, fmtDate(DateTime.now())));
    notifyListeners();
  }
}

final AppStore store = AppStore();
