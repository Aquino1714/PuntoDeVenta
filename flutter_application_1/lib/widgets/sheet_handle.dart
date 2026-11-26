import 'package:material_ui/material_ui.dart';

/// Envuelve una tarjeta (hoja inferior) para que pueda bajarse arrastrando
/// la barrita blanca ([SheetHandle]) que tiene en la parte de arriba.
///
/// - La tarjeta sigue al dedo mientras se arrastra hacia abajo.
/// - Al soltar: si se bajó lo suficiente (o con un deslizamiento rápido) se
///   cierra, igual que tocar fuera de ella (devuelve null a quien la abrió).
///   Si no, regresa a su lugar con una animación.
class SheetDragScope extends StatefulWidget {
  final Widget child;

  const SheetDragScope({super.key, required this.child});

  @override
  State<SheetDragScope> createState() => _SheetDragScopeState();
}

class _SheetDragScopeState extends State<SheetDragScope>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  double _dy = 0; // cuánto se ha bajado la tarjeta
  double _animStart = 0;
  double _animEnd = 0;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      final t = Curves.easeOut.transform(_anim.value);
      setState(() => _dy = _animStart + (_animEnd - _animStart) * t);
    });
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed && _closing && mounted) {
        Navigator.of(context).maybePop();
      }
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  /// Mueve la tarjeta junto con el dedo (solo hacia abajo).
  void _onUpdate(double delta) {
    if (_closing) return;
    _anim.stop();
    setState(() => _dy = (_dy + delta).clamp(0.0, double.infinity).toDouble());
  }

  /// Al soltar: cierra la tarjeta o la regresa a su lugar.
  void _onEnd(double velocity) {
    if (_closing) return;
    final height = context.size?.height ?? 600;
    final cerrar = velocity > 700 || _dy > height * 0.25;
    _closing = cerrar;
    _animStart = _dy;
    _animEnd = cerrar ? height : 0;
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _dy),
      child: widget.child,
    );
  }
}

/// Barrita blanca de la parte de arriba de una tarjeta. Al presionarla y
/// moverla hacia abajo baja la tarjeta. Debe estar dentro de un
/// [SheetDragScope]. Ocupa el mismo espacio que la barrita anterior
/// (12 px arriba + 5 px de barra + 14 px abajo).
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = context.findAncestorStateOfType<_SheetDragScopeState>();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (d) => scope?._onUpdate(d.delta.dy),
      onVerticalDragEnd: (d) => scope?._onEnd(d.velocity.pixelsPerSecond.dy),
      onVerticalDragCancel: () => scope?._onEnd(0),
      child: SizedBox(
        width: double.infinity,
        height: 31,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 100,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }
}