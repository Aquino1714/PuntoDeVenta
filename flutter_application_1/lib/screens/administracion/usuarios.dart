import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';

/// Datos de un usuario del negocio.
class Usuario {
  String nombre;
  String correo;
  String rol;
  bool activo;

  // Permisos de acceso
  bool registrarVentas;
  bool registrarPagos;
  bool consultarClientes;
  bool registrarPedidos;

  /// Solo se llena al crear/cambiar la contraseña. Nunca se muestra en pantalla.
  /// TODO: enviarla a tu API por HTTPS y guardarla con hash en el servidor.
  String? contrasena;

  Usuario({
    required this.nombre,
    required this.correo,
    required this.rol,
    this.activo = true,
    this.registrarVentas = true,
    this.registrarPagos = true,
    this.consultarClientes = false,
    this.registrarPedidos = false,
    this.contrasena,
  });
}

// ===========================================================================
// Lista de usuarios
// ===========================================================================

class UsuariosScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const UsuariosScreen({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  // TODO: reemplazar estos datos de ejemplo por los usuarios reales
  // (base de datos / API).
  final List<Usuario> _usuarios = [
    Usuario(
      nombre: 'Ander Salinas Romero',
      correo: 'ander.admin@correo.com',
      rol: 'Administrador',
    ),
    Usuario(
      nombre: 'Eliut Mariano',
      correo: 'eliut.ventas@correo.com',
      rol: 'Empleado',
    ),
  ];

  Future<void> _nuevo() async {
    final u = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(builder: (_) => const ConfigurarUsuarioScreen()),
    );
    if (u == null || !mounted) return;
    // TODO: además de la lista en pantalla, guardar el usuario en tu API.
    setState(() => _usuarios.add(u));
  }

  Future<void> _editar(Usuario usuario) async {
    final u = await Navigator.push<Usuario>(
      context,
      MaterialPageRoute(
        builder: (_) => ConfigurarUsuarioScreen(usuario: usuario),
      ),
    );
    if (u == null || !mounted) return;
    // TODO: además de la lista en pantalla, actualizar el usuario en tu API.
    setState(() {
      usuario.nombre = u.nombre;
      usuario.correo = u.correo;
      usuario.rol = u.rol;
      usuario.registrarVentas = u.registrarVentas;
      usuario.registrarPagos = u.registrarPagos;
      usuario.consultarClientes = u.consultarClientes;
      usuario.registrarPedidos = u.registrarPedidos;
      if (u.contrasena != null) usuario.contrasena = u.contrasena;
    });
  }

  void _toggleActivo(Usuario usuario, bool v) {
    // TODO: además del estado en pantalla, actualizar el usuario en tu API.
    setState(() => usuario.activo = v);
  }

  int _navIndex = 4; // se llega desde el menú "Más"

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
              _Header(
                title: widget.businessName,
                subtitle: 'Usuarios y permisos',
              ),

              const SizedBox(height: 16),

              // ---------- Registrar nuevo usuario ----------
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
                  onPressed: _nuevo,
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '+ Registrar nuevo usuario',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ---------- Lista de usuarios ----------
              Expanded(
                child: _usuarios.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay usuarios registrados',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 18, color: AppColors.text),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _usuarios.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final u = _usuarios[i];
                          return _UserCard(
                            usuario: u,
                            onToggle: (v) => _toggleActivo(u, v),
                            onEdit: () => _editar(u),
                          );
                        },
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

// ===========================================================================
// Configurar usuario (nuevo / editar)
// ===========================================================================

/// Si [usuario] es null se está creando uno nuevo.
/// Al guardar devuelve un [Usuario] con `Navigator.pop`.
class ConfigurarUsuarioScreen extends StatefulWidget {
  final Usuario? usuario;

  const ConfigurarUsuarioScreen({super.key, this.usuario});

  @override
  State<ConfigurarUsuarioScreen> createState() =>
      _ConfigurarUsuarioScreenState();
}

class _ConfigurarUsuarioScreenState extends State<ConfigurarUsuarioScreen> {
  static const _roles = ['Administrador', 'Empleado'];

  late final _nombre = TextEditingController(text: widget.usuario?.nombre);
  late final _correo = TextEditingController(text: widget.usuario?.correo);
  final _contrasena = TextEditingController();

  late String _rol = widget.usuario?.rol ?? 'Empleado';
  late bool _pVentas = widget.usuario?.registrarVentas ?? true;
  late bool _pPagos = widget.usuario?.registrarPagos ?? true;
  late bool _pClientes = widget.usuario?.consultarClientes ?? false;
  late bool _pPedidos = widget.usuario?.registrarPedidos ?? false;

  bool _obscure = true;

  bool get _esNuevo => widget.usuario == null;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  void _msg(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto)));
  }

  void _guardar() {
    final nombre = _nombre.text.trim();
    final correo = _correo.text.trim();
    final pass = _contrasena.text;

    if (nombre.isEmpty || correo.isEmpty || (_esNuevo && pass.isEmpty)) {
      _msg('Completa los campos obligatorios');
      return;
    }
    if (!correo.contains('@')) {
      _msg('Escribe un correo válido');
      return;
    }

    Navigator.pop(
      context,
      Usuario(
        nombre: nombre,
        correo: correo,
        rol: _rol,
        activo: widget.usuario?.activo ?? true,
        registrarVentas: _pVentas,
        registrarPagos: _pPagos,
        consultarClientes: _pClientes,
        registrarPedidos: _pPedidos,
        contrasena: pass.isEmpty ? null : pass,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              _Header(
                title: 'Configurar usuario',
                subtitle: _esNuevo ? 'Nuevo usuario' : 'Editar usuario',
              ),

              const SizedBox(height: 28),

              // ---------- Datos ----------
              const _FieldLabel('Nombre completo *'),
              const SizedBox(height: 8),
              _RoundedTextField(
                controller: _nombre,
                keyboardType: TextInputType.name,
                capitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Correo electrónico *'),
              const SizedBox(height: 8),
              _RoundedTextField(
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              _FieldLabel(_esNuevo ? 'Contraseña *' : 'Nueva contraseña'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _RoundedTextField(
                      controller: _contrasena,
                      obscureText: _obscure,
                      hint: _esNuevo ? null : 'Déjala vacía para no cambiarla',
                      textInputAction: TextInputAction.done,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _EyeButton(
                    obscured: _obscure,
                    onTap: () => setState(() => _obscure = !_obscure),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const _FieldLabel('Rol'),
              const SizedBox(height: 8),
              Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(33),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _rol,
                    isExpanded: true,
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary, size: 34),
                    style: const TextStyle(
                        fontSize: 18, color: AppColors.text),
                    items: [
                      for (final r in _roles)
                        DropdownMenuItem(value: r, child: Text(r)),
                    ],
                    onChanged: (v) => setState(() => _rol = v!),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Permisos ----------
              const Text(
                'Permisos de acceso',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              _PermisoRow('Registrar ventas', _pVentas,
                  (v) => setState(() => _pVentas = v)),
              _PermisoRow('Registrar métodos de pago', _pPagos,
                  (v) => setState(() => _pPagos = v)),
              _PermisoRow('Consultar clientes', _pClientes,
                  (v) => setState(() => _pClientes = v)),
              _PermisoRow('Registrar pedidos', _pPedidos,
                  (v) => setState(() => _pPedidos = v)),

              const SizedBox(height: 24),

              // ---------- Guardar ----------
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
                  onPressed: _guardar,
                  child: const Text(
                    'Guardar cambios',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 32),
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

/// Encabezado: botón de regreso a la izquierda, título y subtítulo al centro.
class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                child: Icon(Icons.keyboard_return,
                    color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 58, right: 58),
          child: Column(
            children: [
              Text(
                title,
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
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de usuario: nombre, rol, correo, interruptor activo y botón Editar.
class _UserCard extends StatelessWidget {
  final Usuario usuario;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;

  const _UserCard({
    required this.usuario,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final u = usuario;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  u.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  u.rol,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            u.correo,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1.5, color: Colors.white),
          const SizedBox(height: 4),
          Row(
            children: [
              Switch(
                value: u.activo,
                onChanged: onToggle,
                thumbColor: const WidgetStatePropertyAll(Colors.white),
                trackColor: WidgetStateProperty.resolveWith(
                  (s) => s.contains(WidgetState.selected)
                      ? AppColors.green
                      : Colors.white38,
                ),
                trackOutlineColor:
                    const WidgetStatePropertyAll(Colors.transparent),
              ),
              Text(
                u.activo ? 'Activo' : 'Inactivo',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  onPressed: onEdit,
                  child: const Text(
                    'Editar',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Fila de permiso: texto y interruptor (mismo estilo que SwitchRow).
class _PermisoRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermisoRow(this.label, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 18)),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

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

class _RoundedTextField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization capitalization;

  const _RoundedTextField({
    required this.controller,
    this.obscureText = false,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: AppColors.primary, width: 3),
    );

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: capitalization,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 15, color: AppColors.muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        enabledBorder: border,
        focusedBorder: border,
        border: border,
      ),
    );
  }
}