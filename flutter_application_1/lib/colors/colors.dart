import 'package:material_ui/material_ui.dart';

/// Paleta de colores global de la app.
/// Todas las pantallas toman de aquí sus colores para mantener un diseño uniforme.
class AppColors {
  /// Vino principal: botones, encabezados, bordes y barra inferior.
  static const primary = Color(0xFF6A1A28);

  /// Vino muy oscuro (casi burdeos) para fondos de contraste.
  static const navy = Color(0xFF2B0A10);

  /// Gris cálido muy claro para superficies y tarjetas.
  static const surface = Color(0xFFF8F4F5);

  /// Gris cálido claro para bordes y divisiones.
  static const border = Color(0xFFEBE0E2);

  /// Color del texto normal.
  static const text = Color.fromARGB(255, 204, 69, 59);

  /// Gris casi negro para textos de formularios, fichas y tarjetas (widgets.dart).
  static const textDark = Color(0xFF111827);

  /// Gris para textos secundarios.
  static const muted = Color(0xFF6B7280);

  /// Verde para estados positivos (activo, pagado).
  static const green = Color(0xFF16A34A);

  /// Fondo verde claro para chips de estado.
  static const greenBg = Color(0xFFDCFCE7);

  /// Fondo vino claro (rosado suave) para avisos y degradados.
  static const infoBg = Color(0xFFF7E6E9);
}