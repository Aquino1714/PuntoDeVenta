import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';
import 'inicio_sesion.dart';
import 'inicio_sesion_empleado.dart';
import 'registrarse.dart';

/// Pantalla de bienvenida de la app. Ofrece dos caminos: dueño de negocio
/// (iniciar sesión o crear cuenta) y empleado (iniciar sesión con su cuenta).
/// Los botones abren el inicio de sesión del administrador, el registro
/// y el inicio de sesión del empleado.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -90,
            child: _DecorShape(
              width: 220,
              height: 150,
              angle: 0.55,
              color: AppColors.border.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            top: 30,
            right: -110,
            child: _DecorShape(
              width: 220,
              height: 150,
              angle: 0.55,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.42,
            left: -110,
            child: _DecorShape(
              width: 200,
              height: 160,
              angle: 0.55,
              color: AppColors.border.withValues(alpha: 0.55),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.46,
            left: -60,
            child: _DecorShape(
              width: 180,
              height: 160,
              angle: 0.55,
              color: AppColors.infoBg.withValues(alpha: 0.7),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                const _AppTitle(),
                const SizedBox(height: 12),
                const Text(
                  'Todos tus negocios en una App',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.text,
                  ),
                ),

                const Spacer(flex: 3),

                const Text(
                  '¿Eres dueño de algún negocio?',
                  style: TextStyle(fontSize: 18, color: AppColors.text),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      _OutlinedPillButton(
                        text: 'Iniciar sesión',
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Screen1())),
                      ),
                      const SizedBox(height: 16),
                      _OutlinedPillButton(
                        text: 'Crear cuenta',
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const Screen3())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(height: 3, color: AppColors.primary),
                ),

                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, AppColors.infoBg],
                        stops: [0.0, 0.55],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        const Text(
                          '¿Eres empleado?',
                          style: TextStyle(fontSize: 18, color: AppColors.text),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: SizedBox(
                            width: double.infinity,
                            height: 78,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Screen2())),
                              child: const Text(
                                'Iniciar sesión con cuenta empleado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Título grande "MY BUSINESS" con sombra, usado en la pantalla de inicio.
class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 72,
      height: 0.95,
      fontWeight: FontWeight.w900,
      color: AppColors.primary,
      letterSpacing: -1,
      shadows: [
        Shadow(
          color: Color(0x66000000),
          offset: Offset(0, 4),
          blurRadius: 4,
        ),
      ],
    );

    return const Text(
      'MY\nBUSINESS',
      textAlign: TextAlign.center,
      style: style,
    );
  }
}

/// Botón ancho de borde azul y esquinas muy redondeadas (forma de pastilla).
class _OutlinedPillButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _OutlinedPillButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Rectángulo redondeado y rotado que se usa como adorno de fondo.
class _DecorShape extends StatelessWidget {
  final double width;
  final double height;
  final double angle;
  final Color color;

  const _DecorShape({
    required this.width,
    required this.height,
    required this.angle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
}
