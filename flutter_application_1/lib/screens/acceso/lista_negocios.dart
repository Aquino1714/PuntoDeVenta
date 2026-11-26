import 'dart:async';
import 'dart:io';
import '../../colors/colors.dart';
import '../negocio/screen5.dart';
import '../../widgets/barra_navegacion.dart' show nombreNegocioActual;

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/sheet_handle.dart';

class Screen4 extends StatefulWidget {
  const Screen4({super.key});

  @override
  State<Screen4> createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {

  final _searchController = TextEditingController();

  // Listas de negocios registrados. Mientras estén vacías se muestra el mensaje.
  // TODO: reemplazar por los datos reales (base de datos / API).
  final List<_Business> _negociosActivos = [];
  final List<_Business> _negociosInactivos = [];

  // true = muestra negocios activos, false = muestra inactivos
  bool _mostrarActivos = true;

  // Aviso verde que aparece encima del botón de registrar.
  _Notice? _notice;
  Timer? _noticeTimer;

  List<_Business> get _listaActual =>
      _mostrarActivos ? _negociosActivos : _negociosInactivos;

  List<_Business> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    final base = _listaActual;
    if (query.isEmpty) return base;
    return base.where((n) => n.name.toLowerCase().contains(query)).toList();
  }

  @override
  void dispose() {
    _noticeTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ---------- Aviso ----------

  void _showNotice(String name, String message) {
    _noticeTimer?.cancel();
    setState(() => _notice = _Notice(name: name, message: message));
    _noticeTimer = Timer(const Duration(seconds: 4), _hideNotice);
  }

  void _hideNotice() {
    _noticeTimer?.cancel();
    if (mounted) setState(() => _notice = null);
  }

  // ---------- Registrar / modificar ----------

  /// Abre las dos pestañas del formulario. Si [original] es null registra un
  /// negocio nuevo; si no, abre las mismas pestañas con sus datos para
  /// modificarlo.
  Future<void> _openBusinessForm({_Business? original}) async {
    // Primera pestaña: datos obligatorios
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterBusinessSheet(initial: original),
    );

    if (result == null) return; // el usuario cerró la tabla sin continuar
    if (!mounted) return;

    // Segunda pestaña: datos opcionales del negocio.
    // Recibe el estado (activo/inactivo) elegido en la primera.
    final optional = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionalBusinessSheet(
        initial: original,
        initialActivo: result['activo'] != '0',
      ),
    );

    if (!mounted) return;

    // Si al modificar se cierra la segunda pestaña sin guardar, se conservan
    // los datos opcionales que ya tenía el negocio.
    final data = optional != null
        ? {...result, ...optional}
        : {...?original?.toMap(), ...result};

    final negocio = _Business.fromMap(data);

    // TODO: guardar / actualizar el negocio en tu base de datos / API
    setState(() {
      final destino = negocio.activo ? _negociosActivos : _negociosInactivos;

      if (original == null) {
        destino.add(negocio);
      } else {
        final origen =
            original.activo ? _negociosActivos : _negociosInactivos;
        final index = origen.indexOf(original);
        if (negocio.activo == original.activo && index != -1) {
          origen[index] = negocio; // misma lista: conserva la posición
        } else {
          origen.remove(original);
          destino.add(negocio);
        }
      }

      // Muestra la lista donde quedó el negocio
      _mostrarActivos = negocio.activo;
    });

    _showNotice(
      negocio.name,
      original == null ? 'se registró correctamente' : 'se modificó correctamente',
    );
  }

  // ---------- Abrir un negocio ----------

  /// Abre la pantalla de inicio del negocio (Screen5) con su nombre.
  void _openBusiness(_Business negocio) {
    nombreNegocioActual = negocio.name; // lo usa la barra de navegación
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: '/inicio'),
        builder: (_) => Screen5(businessName: negocio.name),
      ),
    );
  }

  // ---------- Menú al mantener presionada una tarjeta ----------

  Future<void> _showCardMenu(_Business negocio, Offset position) async {
    HapticFeedback.mediumImpact();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final action = await showMenu<String>(
      context: context,
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(position.dx, position.dy, 0, 0),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(
          value: 'modificar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Modificar', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'eliminar',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Eliminar', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );

    if (!mounted || action == null) return;

    if (action == 'modificar') {
      _openBusinessForm(original: negocio);
    } else if (action == 'eliminar') {
      _confirmDelete(negocio);
    }
  }

  // ---------- Eliminar ----------

  Future<void> _confirmDelete(_Business negocio) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: negocio.name),
    );

    if (confirmed != true || !mounted) return;

    // TODO: eliminar el negocio de tu base de datos / API
    setState(() {
      _negociosActivos.remove(negocio);
      _negociosInactivos.remove(negocio);
    });

    _showNotice(negocio.name, 'se eliminó correctamente');
  }

  @override
  Widget build(BuildContext context) {
    final negocios = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      // El teclado se muestra encima para que el botón inferior no se mueva.
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),

              // ---------- Encabezado ----------
              const Column(
                children: [
                  Text(
                    'Lista de Negocios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Administrador',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ---------- Buscador ----------
              _SearchField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 12),

              // ---------- Selector: negocios activos / inactivos ----------
              Align(
                alignment: Alignment.centerLeft,
                child: PopupMenuButton<bool>(
                  initialValue: _mostrarActivos,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) => setState(() => _mostrarActivos = value),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: true,
                      child: Text(
                        'Lista de negocios: activos',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    PopupMenuItem(
                      value: false,
                      child: Text(
                        'Lista de negocios: inactivos',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _mostrarActivos
                            ? 'Lista de negocios: activos'
                            : 'Lista de negocios: inactivos',
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ---------- Lista de negocios + aviso flotante ----------
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: negocios.isEmpty
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  _listaActual.isEmpty
                                      ? (_mostrarActivos
                                          ? 'No hay ningún negocio registrado'
                                          : 'No hay ningún negocio inactivo')
                                      : 'No se encontraron negocios',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.text,
                                  ),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.only(top: 8, bottom: 8),
                              itemCount: negocios.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (_, i) => _BusinessCard(
                                business: negocios[i],
                                onTap: () => _openBusiness(negocios[i]),
                                onLongPress: (position) =>
                                    _showCardMenu(negocios[i], position),
                              ),
                            ),
                    ),

                    // Aviso justo encima del botón de registrar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.25),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: _notice == null
                            ? const SizedBox.shrink(key: ValueKey('sin-aviso'))
                            : _NoticeBanner(
                                key: ValueKey(_notice),
                                notice: _notice!,
                                onTap: _hideNotice,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- Botón registrar nuevo negocio (fijo abajo) ----------
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
                  onPressed: () => _openBusinessForm(),
                  child: const Text(
                    'Registrar nuevo negocio',
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
// Widgets auxiliares
// ---------------------------------------------------------------------------

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _SearchField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: AppColors.primary, width: 3),
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 18),
      decoration: const InputDecoration(
        hintText: 'Buscar negocio',
        hintStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        // Mismo ancho a ambos lados para que el texto quede centrado
        prefixIcon: SizedBox(width: 48),
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.search, color: AppColors.primary, size: 36),
        ),
        enabledBorder: border,
        focusedBorder: border,
        border: border,
      ),
    );
  }
}

/// Mensaje del aviso verde: "El negocio {name} {message}".
class _Notice {
  final String name;
  final String message;

  const _Notice({required this.name, required this.message});
}

class _NoticeBanner extends StatelessWidget {
  final _Notice notice;
  final VoidCallback onTap;

  const _NoticeBanner({super.key, required this.notice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.green,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 18, color: Colors.white),
            children: [
              const TextSpan(
                text: 'El negocio ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: notice.name),
              TextSpan(
                text: '\n${notice.message}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Ventana flotante para confirmar que se quiere eliminar un negocio.
/// Devuelve true si el usuario confirma.
class _DeleteDialog extends StatelessWidget {
  final String name;

  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.primary,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(33)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Eliminar negocio',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1.5, color: Colors.white),
            const SizedBox(height: 20),
            Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 18, color: Colors.white),
                children: [
                  const TextSpan(text: '¿Estás seguro de que quieres eliminar el negocio '),
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción no se puede deshacer.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
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

/// Botón que alterna el estado del negocio: "Negocio activo" (relleno blanco)
/// o "Negocio inactivo" (solo contorno blanco). Se usa en las dos pestañas.
class _StatusButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  const _StatusButton({required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(33),
    );

    return SizedBox(
      height: 56,
      child: active
          ? ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: shape,
              ),
              onPressed: onPressed,
              child: const Text(
                'Negocio activo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            )
          : OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 3),
                foregroundColor: Colors.white,
                shape: shape,
              ),
              onPressed: onPressed,
              child: const Text(
                'Negocio inactivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Primera pestaña: datos obligatorios
// ---------------------------------------------------------------------------

class _RegisterBusinessSheet extends StatefulWidget {
  /// Negocio a modificar. Si es null, se está registrando uno nuevo.
  final _Business? initial;

  const _RegisterBusinessSheet({this.initial});

  @override
  State<_RegisterBusinessSheet> createState() => _RegisterBusinessSheetState();
}

class _RegisterBusinessSheetState extends State<_RegisterBusinessSheet> {
  static const List<String> _giros = [
    'Abarrotes',
    'Ropa',
    'Papelería',
    'Otro',
  ];

  late final _nameController =
      TextEditingController(text: widget.initial?.name);
  late final _phoneController =
      TextEditingController(text: widget.initial?.phoneDigits);
  late String? _giro = widget.initial?.type;
  late bool _activo = widget.initial?.activo ?? true;
  bool _showError = false;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _next() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || _giro == null || phone.length != 10) {
      setState(() => _showError = true);
      return;
    }

    Navigator.pop(context, {
      'nombre': name,
      'giro': _giro!,
      'telefono': '+52 $phone',
      'activo': _activo ? '1' : '0',
    });
  }

  InputDecoration _decoration() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: Colors.white, width: 3),
    );
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: border,
      focusedBorder: border,
      border: border,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SheetDragScope(child: Container(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                const SheetHandle(),

                Text(
                  _isEditing ? 'Modificar negocio' : 'Registrar nuevo negocio',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 14),
                Container(height: 1.5, color: Colors.white),
                const SizedBox(height: 24),

                const Text(
                  'Estos campos son obligatorios',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),

                const SizedBox(height: 24),

                // ---------- Nombre comercial ----------
                _label('Nombre comercial'),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  cursorColor: Colors.white,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  decoration: _decoration(),
                ),

                const SizedBox(height: 20),

                // ---------- Giro de negocio ----------
                _label('Giro de negocio'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _giro,
                  isExpanded: true,
                  dropdownColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  hint: const Text(
                    'Abarrotes, ropa, papelería, otro',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                  items: [
                    for (final giro in _giros)
                      DropdownMenuItem(value: giro, child: Text(giro)),
                  ],
                  onChanged: (value) => setState(() => _giro = value),
                  decoration: _decoration(),
                ),

                const SizedBox(height: 20),

                // ---------- Teléfono ----------
                _label('Teléfono del negocio'),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  // Solo dígitos y máximo 10 caracteres
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: _decoration().copyWith(
                    prefixText: '+52 ',
                    prefixStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onSubmitted: (_) => _next(),
                ),

                if (_showError && _phoneController.text.length != 10)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 16),
                    child: Text(
                      'El teléfono debe tener 10 dígitos',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),

                if (_showError) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Completa todos los campos para continuar',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],

                const SizedBox(height: 24),
                Container(height: 1.5, color: Colors.white),
                const SizedBox(height: 20),

                // ---------- Estado del negocio ----------
                _StatusButton(
                  active: _activo,
                  onPressed: () => setState(() => _activo = !_activo),
                ),

                const SizedBox(height: 16),

                // ---------- Botón siguiente ----------
                SizedBox(
                  height: 66,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(33),
                      ),
                    ),
                    onPressed: _next,
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// Segunda pestaña: datos opcionales
// ---------------------------------------------------------------------------

class _OptionalBusinessSheet extends StatefulWidget {
  /// Negocio a modificar. Si es null, se está registrando uno nuevo.
  final _Business? initial;

  /// Estado (activo/inactivo) elegido en la primera pestaña.
  final bool initialActivo;

  const _OptionalBusinessSheet({this.initial, this.initialActivo = true});

  @override
  State<_OptionalBusinessSheet> createState() => _OptionalBusinessSheetState();
}

class _OptionalBusinessSheetState extends State<_OptionalBusinessSheet> {

  late final _emailController =
      TextEditingController(text: widget.initial?.email);
  late final _addressController =
      TextEditingController(text: widget.initial?.address);
  late final _rfcController = TextEditingController(text: widget.initial?.rfc);

  late bool _activo = widget.initialActivo;

  // Ruta y nombre del logotipo (al modificar, parte del logotipo actual).
  late String? _logoPath = widget.initial?.logoPath;
  late String? _logoName = _logoPath?.split(RegExp(r'[\\/]')).last;
  String? _logoError;
  bool _submitted = false;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _emailController.dispose();
    _addressController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  bool get _hasData =>
      _emailController.text.trim().isNotEmpty ||
      _addressController.text.trim().isNotEmpty ||
      _rfcController.text.trim().isNotEmpty ||
      _logoName != null;

  String? get _emailError {
    final email = _emailController.text.trim();
    if (email.isEmpty) return null;
    if (!email.contains('@')) return 'El correo debe contener "@"';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    return valid ? null : 'Escribe un correo electrónico válido';
  }

  String? get _rfcError {
    final rfc = _rfcController.text.trim();
    if (rfc.isEmpty) return null;
    return (rfc.length == 12 || rfc.length == 13)
        ? null
        : 'El RFC debe tener 12 o 13 caracteres';
  }

  Future<void> _uploadLogo() async {
    try {
      // Abre la galería de fotos del dispositivo
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null || !mounted) return; // el usuario canceló
      setState(() {
        _logoPath = image.path;
        _logoName = image.name;
        _logoError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _logoError = 'No se pudo abrir la galería');
    }
  }

  void _removeLogo() => setState(() {
        _logoName = null;
        _logoPath = null;
      });

  void _finish() {
    setState(() => _submitted = true);
    if (_emailError != null || _rfcError != null) return;

    final data = <String, String>{
      'activo': _activo ? '1' : '0',
      if (_emailController.text.trim().isNotEmpty)
        'correo': _emailController.text.trim(),
      if (_addressController.text.trim().isNotEmpty)
        'direccion': _addressController.text.trim(),
      if (_rfcController.text.trim().isNotEmpty)
        'rfc': _rfcController.text.trim().toUpperCase(),
      'logo': ?_logoPath,
    };
    Navigator.pop(context, data);
  }

  Widget _error(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 16),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
    );
  }

  InputDecoration _decoration() {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: Colors.white, width: 3),
    );
    return const InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      enabledBorder: border,
      focusedBorder: border,
      border: border,
    );
  }

  Widget _label(String text, {String? suffix}) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        children: [
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: const TextStyle(fontWeight: FontWeight.normal),
            ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      cursorColor: Colors.white,
      style: const TextStyle(fontSize: 18, color: Colors.white),
      decoration: _decoration(),
      onChanged: (_) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    // La tarjeta se ajusta al contenido y crece (con animación) cuando
    // aparecen errores o el logotipo seleccionado, hasta un 92 % de la pantalla.
    return SheetDragScope(child: AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                  const SheetHandle(),

                  Text(
                    _isEditing ? 'Modificar negocio' : 'Registrar nuevo negocio',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 14),
                  Container(height: 1.5, color: Colors.white),
                  const SizedBox(height: 20),

                  const Text(
                    'Estos campos no son obligatorios',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // ---------- Correo electrónico ----------
                  _label('Correo electrónico', suffix: '(del negocio)'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  if (_submitted && _emailError != null) _error(_emailError!),

                  const SizedBox(height: 20),

                  // ---------- Dirección ----------
                  _label('Dirección del negocio'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _addressController,
                    keyboardType: TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 20),

                  // ---------- RFC ----------
                  _label('RFC'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _rfcController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  if (_submitted && _rfcError != null) _error(_rfcError!),

                  const SizedBox(height: 20),

                  // ---------- Logotipo ----------
                  _label('Logotipo del negocio'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 64,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: _uploadLogo,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_download_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Subir archivo',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_logoError != null) _error(_logoError!),

                  // Archivo seleccionado (hace crecer la tarjeta)
                  if (_logoName != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.only(left: 20, right: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(33),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined,
                              color: Colors.white, size: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _logoName!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _removeLogo,
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  Container(height: 1.5, color: Colors.white),
                  const SizedBox(height: 20),

                  // ---------- Estado del negocio ----------
                  _StatusButton(
                    active: _activo,
                    onPressed: () => setState(() => _activo = !_activo),
                  ),

                  const SizedBox(height: 16),

                  // ---------- Botón completar después / guardar ----------
                  SizedBox(
                    height: 66,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(33),
                        ),
                      ),
                      onPressed: _finish,
                      child: Text(
                        (_hasData || _isEditing) ? 'Guardar' : 'Completar después',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

// ---------------------------------------------------------------------------
// Modelo y tarjeta de negocio
// ---------------------------------------------------------------------------

class _Business {
  final String name;
  final String type;
  final String phone; // con prefijo, ej. "+52 5512345678"
  final bool activo;
  final String? email;
  final String? address;
  final String? rfc;
  final String? logoPath;

  const _Business({
    required this.name,
    required this.type,
    required this.phone,
    this.activo = true,
    this.email,
    this.address,
    this.rfc,
    this.logoPath,
  });

  /// Teléfono sin el prefijo "+52 ", para mostrarlo en el formulario.
  String get phoneDigits => phone.replaceFirst('+52 ', '');

  factory _Business.fromMap(Map<String, String> map) {
    return _Business(
      name: map['nombre']!,
      type: map['giro']!,
      phone: map['telefono']!,
      activo: map['activo'] != '0',
      email: map['correo'],
      address: map['direccion'],
      rfc: map['rfc'],
      logoPath: map['logo'],
    );
  }

  Map<String, String> toMap() {
    return {
      'nombre': name,
      'giro': type,
      'telefono': phone,
      'activo': activo ? '1' : '0',
      'correo': ?email,
      'direccion': ?address,
      'rfc': ?rfc,
      'logo': ?logoPath,
    };
  }
}

class _BusinessCard extends StatelessWidget {

  final _Business business;

  /// Se llama al tocar la tarjeta (abre el negocio).
  final VoidCallback onTap;

  /// Se llama al mantener presionada la tarjeta, con la posición del dedo.
  final void Function(Offset globalPosition) onLongPress;

  const _BusinessCard({
    required this.business,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final logoPath = business.logoPath;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(33),
        ),
        child: Row(
          children: [
            // Logo: si no se eligió imagen, queda un cuadro blanco en blanco
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoPath == null
                  ? null
                  : Image.file(
                      File(logoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    business.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    business.type,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}