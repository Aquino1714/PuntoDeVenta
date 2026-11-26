import 'package:material_ui/material_ui.dart';
import '../colors/colors.dart';
import '../screens/empleados/empleados_screen.dart';
import '../screens/finanzas/finanzas_cuenta.dart' show FinanzasPage, MiCuentaPage;
import '../screens/acceso/lista_negocios.dart';
import '../screens/administracion/reportes.dart';
import '../screens/administracion/usuarios.dart';
import '../screens/negocio/ventas.dart' show VentasScreen;
import '../screens/inventario/inventario.dart' show InventarioScreen;
import '../screens/clientes/clientes_screen.dart' show ClientesScreen;
import '../screens/negocio/screen5.dart' show Screen5;

/// Nombre del negocio abierto actualmente. Se guarda al entrar a un negocio
/// (ver lista_negocios.dart) para que las pantallas abiertas desde la barra
/// sigan mostrando el mismo nombre.
String nombreNegocioActual = 'Nombre del negocio';

/// Crea una ruta de navegación sin animación de transición.
/// Se usa para cambiar de pantalla de forma instantánea.
Route<T> sinAnimacion<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
  );
}

/// Opción del menú flotante "Más": texto, ícono, acción al tocarla
/// y, opcionalmente, un puntito indicador (badge).
class MoreMenuItem {
  final String label;
  final IconData icon;
  final bool showBadge;
  final void Function(BuildContext context) onTap;

  const MoreMenuItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });
}

/// Barra de navegación inferior de la app. Muestra cuatro íconos de sección
/// y un botón "Más" que abre un menú flotante con opciones adicionales
/// (Finanzas, Empleados, Reportes, Usuarios y permisos, Mi cuenta,
/// Ver lista de negocios).
class BottomNavBar extends StatefulWidget {
  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.shopping_cart,
    Icons.grid_view_rounded,
    Icons.groups_rounded,
  ];

  /// Nombre de ruta de cada sección de la barra. Sirve para saber si ya
  /// estamos en la pantalla a la que se quiere ir y para volver a Inicio.
  static const List<String> _routeNames = [
    '/inicio', // 0 Casa
    '/ventas', // 1 Carrito
    '/inventario', // 2 Cuadritos
    '/clientes', // 3 Personas
  ];

  /// Construye la pantalla de cada sección.
  static Widget _pageFor(int index) {
    switch (index) {
      case 1:
        return VentasScreen(businessName: nombreNegocioActual);
      case 2:
        return InventarioScreen(businessName: nombreNegocioActual);
      case 3:
        return const ClientesScreen();
      default:
        return Screen5(businessName: nombreNegocioActual);
    }
  }

  /// Ruta sin animación con el nombre de la sección.
  static Route<void> _routeFor(int index) {
    return PageRouteBuilder<void>(
      settings: RouteSettings(name: _routeNames[index]),
      pageBuilder: (_, _, _) => _pageFor(index),
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  /// Opciones del menú "Más". Aquí se define a qué pantalla va cada una.
  static final List<MoreMenuItem> moreItems = [
    MoreMenuItem(
      label: 'Finanzas',
      icon: Icons.show_chart_rounded,
      showBadge: true,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const FinanzasPage()));
      },
    ),
    MoreMenuItem(
      label: 'Empleados',
      icon: Icons.people_alt_rounded,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const EmpleadosScreen()));
      },
    ),
    MoreMenuItem(
      label: 'Reportes',
      icon: Icons.description_rounded,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const ReportesScreen()));
      },
    ),
    MoreMenuItem(
      label: 'Usuarios y permisos',
      icon: Icons.vpn_key_rounded,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const UsuariosScreen()));
      },
    ),
    MoreMenuItem(
      label: 'Mi cuenta',
      icon: Icons.settings_rounded,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const MiCuentaPage()));
      },
    ),
    MoreMenuItem(
      label: 'Ver lista de negocios',
      icon: Icons.home_rounded,
      onTap: (context) {
        Navigator.push(context, sinAnimacion(const Screen4()));
      },
    ),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final List<int> _jumpCounts = List.filled(5, 0);
  final GlobalKey _barKey = GlobalKey();

  /// Al iniciar, hace saltar el ícono de la sección actual.
  @override
  void initState() {
    super.initState();
    _triggerJumpFor(widget.currentIndex);
  }

  /// Cuando cambia la sección seleccionada, activa el salto de su ícono.
  @override
  void didUpdateWidget(covariant BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _triggerJumpFor(widget.currentIndex);
    }
  }

  /// Incrementa el contador de salto del ícono indicado para
  /// disparar su animación de rebote.
  void _triggerJumpFor(int index) {
    if (index < 0 || index >= _jumpCounts.length) return;
    _jumpCounts[index]++;
  }

  /// Navega a la sección tocada (como pestañas: la pila no crece).
  /// - Si ya estás en esa pantalla, no hace nada.
  /// - Inicio (casa): regresa a la pantalla de inicio que ya estaba abierta.
  ///   Si no existe en la pila, la abre.
  /// - Las demás secciones reemplazan lo que haya encima de Inicio.
  void _goToSection(int index) {
    final actual = ModalRoute.of(context)?.settings.name;
    if (actual == BottomNavBar._routeNames[index]) return;

    final nav = Navigator.of(context);

    if (index == 0) {
      var hayInicio = false;
      nav.popUntil((route) {
        if (route.settings.name == '/inicio') hayInicio = true;
        return hayInicio || route.isFirst;
      });
      if (!hayInicio) nav.push(BottomNavBar._routeFor(0));
      return;
    }

    nav.pushAndRemoveUntil(
      BottomNavBar._routeFor(index),
      (route) => route.settings.name == '/inicio' || route.isFirst,
    );
  }

  /// Abre el menú flotante "Más" justo encima de la barra, con fondo
  /// oscurecido y animación de aparición. Al elegir una opción se cierra
  /// el menú y se ejecuta la acción de esa opción.
  void _openMoreMenu() {
    final screenHeight = MediaQuery.of(context).size.height;
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    final barTop = box?.localToGlobal(Offset.zero).dy ?? (screenHeight - 100);
    final bottomOffset = screenHeight - barTop + 12;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar menú',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (dialogContext, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                right: 20,
                bottom: bottomOffset,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final item in BottomNavBar.moreItems)
                      _MoreMenuRow(
                        item: item,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          if (mounted) item.onTap(context);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (_, animation, _, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _barKey,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < BottomNavBar._icons.length; i++)
                _JumpTap(
                  jumpTrigger: _jumpCounts[i],
                  onTap: () => _goToSection(i),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      BottomNavBar._icons[i],
                      size: 44,
                      color: i == widget.currentIndex
                          ? Colors.white
                          : AppColors.text,
                    ),
                  ),
                ),

              _JumpTap(
                jumpTrigger: _jumpCounts[4],
                onTap: _openMoreMenu,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: widget.currentIndex == 4
                        ? Colors.white
                        : AppColors.text,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    size: 30,
                    color: widget.currentIndex == 4
                        ? AppColors.primary
                        : Colors.white,
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

/// Fila del menú "Más": texto a la izquierda e ícono en cuadro blanco
/// a la derecha, con puntito opcional en la esquina.
class _MoreMenuRow extends StatelessWidget {
  final MoreMenuItem item;
  final VoidCallback onTap;

  const _MoreMenuRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 14),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: AppColors.text, size: 28),
                ),
                if (item.showBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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

/// Envuelve un widget para darle una animación de salto (rebote) al
/// tocarlo o cuando cambia [jumpTrigger]. La acción [onTap] se ejecuta
/// una fracción de segundo después, para que se alcance a ver la animación.
class _JumpTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final int jumpTrigger;

  const _JumpTap({
    required this.child,
    required this.onTap,
    required this.jumpTrigger,
  });

  @override
  State<_JumpTap> createState() => _JumpTapState();
}

class _JumpTapState extends State<_JumpTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(begin: 0, end: -14)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(begin: -14, end: 0)
          .chain(CurveTween(curve: Curves.bounceOut)),
      weight: 65,
    ),
  ]).animate(_controller);

  /// Si ya había un disparo pendiente, lanza la animación tras el primer frame.
  @override
  void initState() {
    super.initState();
    if (widget.jumpTrigger > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward(from: 0);
      });
    }
  }

  /// Reinicia la animación cuando el contador de salto cambia.
  @override
  void didUpdateWidget(covariant _JumpTap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.jumpTrigger != widget.jumpTrigger) {
      _controller.forward(from: 0);
    }
  }

  /// Libera el controlador de animación.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Al tocar: inicia el salto, espera 180 ms y luego ejecuta la acción.
  void _handleTap() async {
    _controller.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _offset,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}