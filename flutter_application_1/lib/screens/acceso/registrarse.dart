import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';
import '../../utils/validators.dart';
import '../finanzas/finanzas_cuenta.dart' show estado;
import 'lista_negocios.dart';

/// Pantalla para crear la cuenta de administrador: nombre, apellidos,
/// correo y contraseña con confirmación.
///
/// Cada campo se valida al escribir (el error aparece debajo del campo) y
/// al final, si todo es correcto, crea la cuenta y abre la lista de negocios.
class Screen3 extends StatefulWidget {
  const Screen3({super.key});

  @override
  State<Screen3> createState() => _Screen3State();
}

class _Screen3State extends State<Screen3> {
  final _formKey = GlobalKey<FormState>();

  /// Llave del campo "Confirmar contraseña" para volver a validarlo cuando
  /// cambia la contraseña de arriba.
  final _confirmKey = GlobalKey<FormFieldState<String>>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  /// Libera los controladores de texto al cerrar la pantalla.
  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _motherLastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Validaciones
  // ---------------------------------------------------------------------

  /// Solo letras, espacios, punto, apóstrofo y guion (se aplica al escribir
  /// y al pegar texto).
  static final _soloLetrasFormatter = FilteringTextInputFormatter.allow(
    RegExp(r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s.'-]"),
  );

  /// Valida un nombre o apellido: obligatorio (salvo que [obligatorio] sea
  /// false), con al menos 2 letras.
  String? _validarNombre(
    String? v, {
    required String campo,
    bool obligatorio = true,
  }) {
    final texto = (v ?? '').trim();
    if (texto.isEmpty) return obligatorio ? 'Escribe $campo' : null;
    final letras = texto.replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ]'), '');
    if (letras.length < 2) return 'Escribe al menos 2 letras';
    return null;
  }

  /// Contraseña: mínimo 8 caracteres, con al menos una letra y un número.
  String? _validarPassword(String? v) {
    final p = v ?? '';
    if (p.isEmpty) return 'Crea una contraseña';
    if (p.length < 8) return 'Mínimo 8 caracteres (${p.length}/8)';
    if (!RegExp(r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]').hasMatch(p)) {
      return 'Incluye al menos una letra';
    }
    if (!RegExp(r'\d').hasMatch(p)) return 'Incluye al menos un número';
    return null;
  }

  /// Confirmación: obligatoria y debe ser igual a la contraseña.
  String? _validarConfirmacion(String? v) {
    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  // ---------------------------------------------------------------------
  // Crear cuenta
  // ---------------------------------------------------------------------

  /// Valida todos los campos. Si hay errores, avisa y se detiene; si todo
  /// está bien, crea la cuenta y abre la lista de negocios.
  void _createAccount() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Revisa los campos marcados en rojo')),
        );
      return;
    }

    final name = _nameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final motherLastName = _motherLastNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    // TODO: crear la cuenta de verdad (servidor / servicio de usuarios) y
    // guardar la contraseña de forma segura (nunca en texto plano). Por
    // ahora solo se actualiza el perfil que se muestra en "Mi cuenta".
    final nombreCompleto =
        [name, lastName, motherLastName].where((e) => e.isNotEmpty).join(' ');
    estado.guardarPerfil(nombreCompleto, email, estado.telefono, estado.rol);

    // Se toma el messenger antes de navegar para que el aviso se vea en la
    // pantalla siguiente.
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Screen4()),
    );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Cuenta creada correctamente')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

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
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Column(
                        children: [
                          Text(
                            'MY BUSINESS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Crear cuenta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                const Text(
                  '¡Bienvenido administrador!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: AppColors.muted),
                ),

                const SizedBox(height: 40),

                const _FieldLabel('Nombre'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    _soloLetrasFormatter,
                    LengthLimitingTextInputFormatter(40),
                  ],
                  validator: (v) => _validarNombre(v, campo: 'tu nombre'),
                ),

                const SizedBox(height: 16),

                const _FieldLabel('Apellido Paterno'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    _soloLetrasFormatter,
                    LengthLimitingTextInputFormatter(40),
                  ],
                  validator: (v) =>
                      _validarNombre(v, campo: 'tu apellido paterno'),
                ),

                const SizedBox(height: 16),

                // El apellido materno es opcional (igual que en el registro
                // de clientes): si se escribe, se valida.
                const _FieldLabel('Apellido Materno'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _motherLastNameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [
                    _soloLetrasFormatter,
                    LengthLimitingTextInputFormatter(40),
                  ],
                  validator: (v) => _validarNombre(
                    v,
                    campo: 'tu apellido materno',
                    obligatorio: false,
                  ),
                ),

                const SizedBox(height: 16),

                const _FieldLabel('Correo electrónico'),
                const SizedBox(height: 8),
                _RoundedTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    ...V.noSpaces,
                    LengthLimitingTextInputFormatter(100),
                  ],
                  validator: V.correo,
                ),

                const SizedBox(height: 16),

                const _FieldLabel('Crear contraseña'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoundedTextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        helperText: 'Mínimo 8 caracteres, con letras y números',
                        inputFormatters: [
                          ...V.noSpaces,
                          LengthLimitingTextInputFormatter(64),
                        ],
                        validator: _validarPassword,
                        // Si ya hay algo en "Confirmar", lo revalida para
                        // que el aviso de coincidencia esté al día.
                        onChanged: (_) {
                          if (_confirmController.text.isNotEmpty) {
                            _confirmKey.currentState?.validate();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _EyeButton(
                      obscured: _obscurePassword,
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                const _FieldLabel('Confirmar contraseña'),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoundedTextField(
                        fieldKey: _confirmKey,
                        controller: _confirmController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          ...V.noSpaces,
                          LengthLimitingTextInputFormatter(64),
                        ],
                        validator: _validarConfirmacion,
                        onSubmitted: (_) => _createAccount(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _EyeButton(
                      obscured: _obscureConfirm,
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(height: 3, color: AppColors.primary),
                const SizedBox(height: 24),

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
                    onPressed: _createAccount,
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta en negritas que se coloca arriba de cada campo de texto.
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}

/// Botón circular con ícono de ojo para mostrar u ocultar la contraseña.
class _EyeButton extends StatelessWidget {
  final bool obscured;
  final VoidCallback onTap;

  const _EyeButton({required this.obscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.primary, width: 3),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 58,
          height: 58,
          child: Icon(
            obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primary,
            size: 30,
          ),
        ),
      ),
    );
  }
}

/// Campo de texto con borde vino y esquinas muy redondeadas. Valida al
/// interactuar y muestra el error en rojo debajo del campo.
class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final GlobalKey<FormFieldState<String>>? fieldKey;

  const _RoundedTextField({
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    this.helperText,
    this.fieldKey,
  });

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: AppColors.primary, width: 3),
    );
    final errorColor = Colors.red.shade700;
    final errorBorder = OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: errorColor, width: 3),
    );

    return TextFormField(
      key: fieldKey,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        enabledBorder: border,
        focusedBorder: border,
        border: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        errorStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: errorColor,
        ),
        errorMaxLines: 2,
        helperText: helperText,
        helperMaxLines: 2,
        helperStyle: const TextStyle(fontSize: 13, color: AppColors.muted),
      ),
    );
  }
}
