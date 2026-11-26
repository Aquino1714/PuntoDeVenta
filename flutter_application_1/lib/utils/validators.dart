import 'package:flutter/services.dart';
import '../data/data.dart';

class V {
  static final phoneFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];
  static final amountFormatters = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
  ];
  static final noSpaces = <TextInputFormatter>[
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];

  static String? requerido(String? v, [String msg = 'Campo obligatorio']) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  static String? nombre(String? v) {
    final r = requerido(v, 'Escribe el nombre');
    if (r != null) return r;
    if (v!.trim().length < 3) return 'Escribe al menos 3 letras';
    if (!RegExp(r"^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s.'-]+$").hasMatch(v.trim())) {
      return 'Solo se permiten letras';
    }
    return null;
  }

  static String? telefono(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa el teléfono';
    if (!RegExp(r'^\d+$').hasMatch(v)) return 'Solo se permiten números';
    if (v.length != 10) return 'Debe tener 10 dígitos (${v.length}/10)';
    return null;
  }

  static String? correo(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa el correo electrónico';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())) {
      return 'Correo no válido (ej. nombre@correo.com)';
    }
    return null;
  }

  static String? monto(String? v, {double? max}) {
    if (v == null || v.trim().isEmpty) return 'Ingresa un monto';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Monto no válido';
    if (n <= 0) return 'El monto debe ser mayor a 0';
    if (max != null && n > max) return 'No puede ser mayor a ${money(max)}';
    return null;
  }
}
