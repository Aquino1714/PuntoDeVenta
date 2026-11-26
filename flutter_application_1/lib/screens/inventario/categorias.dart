import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';
import '../../widgets/sheet_handle.dart';

class CategoriasScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const CategoriasScreen({super.key, this.businessName = 'Nombre del negocio'});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  // TODO: reemplazar estos datos de ejemplo por las categorías reales
  // (base de datos / API).
  final List<_Category> _categorias = [
    _Category(
      name: 'Nombre de la categoría',
      description: 'Descripción de la categoría',
    ),
    _Category(
      name: 'Nombre de la categoría 2',
      description: 'Descripción de la categoría',
    ),
  ];

  List<_Category> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _categorias;
    return _categorias.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Abre la tarjeta de categoría. Si [original] es null registra una
  /// categoría nueva; si no, abre la misma tarjeta con sus datos para
  /// modificarla.
  Future<void> _openCategoryForm({_Category? original}) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewCategorySheet(initial: original),
    );

    if (result == null || !mounted) return; // el usuario cerró la tarjeta

    final categoria = _Category(
      name: result['nombre']!,
      description: result['descripcion'] ?? '',
    );

    // TODO: además de la lista en pantalla, guardar / actualizar la categoría
    // en tu base de datos / API.
    setState(() {
      if (original == null) {
        _categorias.add(categoria);
      } else {
        final index = _categorias.indexOf(original);
        if (index != -1) {
          _categorias[index] = categoria; // conserva la posición
        } else {
          _categorias.add(categoria);
        }
      }
    });
  }

  // ---------- Menú al mantener presionada una tarjeta ----------

  Future<void> _showCardMenu(_Category categoria, Offset position) async {
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
      _openCategoryForm(original: categoria);
    } else if (action == 'eliminar') {
      _confirmDelete(categoria);
    }
  }

  // ---------- Eliminar ----------

  Future<void> _confirmDelete(_Category categoria) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: categoria.name),
    );

    if (confirmed != true || !mounted) return;

    // TODO: eliminar la categoría de tu base de datos / API
    setState(() => _categorias.remove(categoria));
  }

  int _navIndex = 2;

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = _filtered;

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
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 58, right: 58),
                    child: Column(
                      children: [
                        Text(
                          widget.businessName,
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
                        const Text(
                          'Categorías',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---------- Buscar categoría ----------
              _SearchPill(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
              ),

              const SizedBox(height: 16),

              // ---------- Lista de categorías ----------
              Expanded(
                child: categorias.isEmpty
                    ? Center(
                        child: Text(
                          _categorias.isEmpty
                              ? 'No hay categorías registradas'
                              : 'No se encontraron categorías',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: categorias.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _CategoryCard(
                          category: categorias[i],
                          onLongPress: (position) =>
                              _showCardMenu(categorias[i], position),
                        ),
                      ),
              ),

              const SizedBox(height: 12),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Registrar categoría ----------
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
                  onPressed: () => _openCategoryForm(),
                  child: const Text(
                    '+ Registrar categoría',
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
// Modelo de ejemplo
// ---------------------------------------------------------------------------

class _Category {
  final String name;
  final String description;

  const _Category({
    required this.name,
    required this.description,
  });
}

// ---------------------------------------------------------------------------
// Widgets auxiliares
// ---------------------------------------------------------------------------

/// Barra de búsqueda con forma de pastilla y lupa a la derecha.
class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchPill({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return Container(
      height: 62,
      padding: const EdgeInsets.only(left: 20, right: 14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 3),
        borderRadius: BorderRadius.circular(33),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              cursorColor: AppColors.primary,
              style: textStyle,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Buscar categoría',
                hintStyle: textStyle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.search, color: AppColors.primary, size: 36),
        ],
      ),
    );
  }
}

/// Tarjeta de categoría: nombre y descripción.
/// Al mantenerla presionada avisa con [onLongPress] para abrir el menú.
class _CategoryCard extends StatelessWidget {
  final _Category category;

  /// Se llama al mantener presionada la tarjeta, con la posición del dedo.
  final void Function(Offset globalPosition) onLongPress;

  const _CategoryCard({required this.category, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (category.description.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                category.description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ventana flotante para confirmar que se quiere eliminar una categoría.
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Eliminar categoría',
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
                  const TextSpan(
                    text: '¿Estás seguro de que quieres eliminar la categoría ',
                  ),
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

// ---------------------------------------------------------------------------
// Tarjeta "Registrar categoría" / "Modificar categoría"
// ---------------------------------------------------------------------------

class _NewCategorySheet extends StatefulWidget {
  /// Categoría a modificar. Si es null, se está registrando una nueva.
  final _Category? initial;

  const _NewCategorySheet({this.initial});

  @override
  State<_NewCategorySheet> createState() => _NewCategorySheetState();
}

class _NewCategorySheetState extends State<_NewCategorySheet> {
  late final _nombreCtrl = TextEditingController(text: widget.initial?.name);
  late final _descripcionCtrl =
      TextEditingController(text: widget.initial?.description);

  bool _nombreVacio = false;

  bool get _isEditing => widget.initial != null;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      setState(() => _nombreVacio = true);
      return;
    }

    Navigator.pop(context, {
      'nombre': nombre,
      'descripcion': _descripcionCtrl.text.trim(),
    });
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;

    const inputStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // La tarjeta se achica cuando aparece el teclado para no quedar tapada.
    final sheetHeight = (media.size.height * 0.85)
        .clamp(0.0, media.size.height - keyboard - media.padding.top)
        .toDouble();

    return SheetDragScope(child: Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
        ),
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                      const SheetHandle(),

                      Text(
                        _isEditing
                            ? 'Modificar categoría'
                            : '+ Registrar categoría',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 14),
                      Container(height: 1.5, color: Colors.white),
                      const SizedBox(height: 24),

                      // ---------- Nombre de la categoría ----------
                      _label('Nombre de la categoría'),
                      const SizedBox(height: 8),
                      Container(
                        height: 58,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(33),
                        ),
                        child: TextField(
                          controller: _nombreCtrl,
                          textAlign: TextAlign.center,
                          textCapitalization: TextCapitalization.sentences,
                          cursorColor: Colors.white,
                          style: inputStyle,
                          onChanged: (_) {
                            if (_nombreVacio) {
                              setState(() => _nombreVacio = false);
                            }
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                      if (_nombreVacio)
                        const Padding(
                          padding: EdgeInsets.only(top: 6, left: 12),
                          child: Text(
                            'Escribe el nombre de la categoría',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ---------- Descripción de la categoría ----------
                      _label('Descripción de la categoría'),
                      const SizedBox(height: 8),
                      Container(
                        height: 150,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _descripcionCtrl,
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          cursorColor: Colors.white,
                          style: inputStyle,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 24),
                      Container(height: 1, color: Colors.white),
                      const SizedBox(height: 20),

                      // ---------- Registrar / guardar categoría ----------
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
                          onPressed: _confirm,
                          child: Text(
                            _isEditing ? 'Guardar cambios' : 'Registrar categoría',
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
        ),
      ),
    ));
  }
}