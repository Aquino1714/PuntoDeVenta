import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';
import '../../widgets/sheet_handle.dart';
import 'categorias.dart' show CategoriasScreen;
import 'proveedores.dart' show ProveedoresScreen;

/// Modelo de un producto del inventario.
class Producto {
  final String nombre;
  final String descripcion;
  final String? imagePath; // ruta de la imagen elegida en la galería
  final Map<String, List<String>> variantes; // categoría → opciones elegidas
  final String? categoria;
  final String? proveedor;
  final String codigoBarras;
  final double precioVenta;
  final double precioCosto;
  final int unidades;
  final bool activo;

  const Producto({
    required this.nombre,
    this.descripcion = '',
    this.imagePath,
    this.variantes = const {},
    this.categoria,
    this.proveedor,
    this.codigoBarras = '',
    this.precioVenta = 0,
    this.precioCosto = 0,
    this.unidades = 1,
    this.activo = true,
  });
}

// TODO: reemplazar por las opciones reales (base de datos / API).
/// Variantes disponibles, agrupadas por tipo.
/// TODO: reemplazar por las variantes reales (base de datos / API).
const Map<String, List<String>> _kVariantesOpciones = {
  'Color': [
    'Amarillo',
    'Azul',
    'Rojo',
    'Verde',
    'Negro',
    'Blanco',
    'Naranja',
    'Morado',
    'Rosa',
    'Gris',
    'Café',
  ],
  'Talla': ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Única'],
  'Marca': [
    'Marca propia',
    'Genérica',
    'Nacional',
    'Importada',
    'Premium',
    'Económica',
  ],
  'Sabor': [
    'Natural',
    'Vainilla',
    'Chocolate',
    'Fresa',
    'Limón',
    'Naranja',
    'Uva',
    'Mango',
    'Menta',
  ],
  'Material': [
    'Algodón',
    'Poliéster',
    'Plástico',
    'Metal',
    'Madera',
    'Vidrio',
    'Cuero',
    'Papel',
    'Cerámica',
  ],
};

/// Color del círculo que se muestra junto a cada variante de color.
const Map<String, Color> _kColoresVariante = {
  'Amarillo': Color(0xFFFFCC00),
  'Azul': Color(0xFF0A84FF),
  'Rojo': Color(0xFFFF3B30),
  'Verde': Color(0xFF34C759),
  'Negro': Color(0xFF1C1C1E),
  'Blanco': Color(0xFFFFFFFF),
  'Naranja': Color(0xFFFF9500),
  'Morado': Color(0xFFAF52DE),
  'Rosa': Color(0xFFFF6FA5),
  'Gris': Color(0xFF8E8E93),
  'Café': Color(0xFF8B5E3C),
};
const List<String> _kCategorias = ['Opciones de categorías'];
const List<String> _kProveedores = ['Opciones de proveedores'];

/// Productos guardados en el programa. Los comparte la pantalla de
/// Inventario con las tarjetas de nueva venta y nuevo pedido (selector
/// "Buscar producto").
/// TODO: reemplazar estos datos de ejemplo por los reales (base de datos / API).
final List<Producto> productosGuardados = [
  const Producto(nombre: 'Nombre del producto'),
  const Producto(nombre: 'Producto inactivo', activo: false),
];

class InventarioScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const InventarioScreen({super.key, this.businessName = '*Nombre del negocio*'});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {

  final _searchController = TextEditingController();

  // Todos los productos (activos e inactivos). El campo `activo` de cada
  // producto decide en qué lista se muestra.
  // TODO: reemplazar estos datos de ejemplo por los reales (base de datos / API).
  List<Producto> get _productos => productosGuardados;

  // true = muestra activos, false = muestra inactivos
  bool _mostrarActivos = true;

  List<Producto> get _listaActual =>
      _productos.where((p) => p.activo == _mostrarActivos).toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Producto> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    final base = _listaActual;
    if (query.isEmpty) return base;
    return base.where((p) => p.nombre.toLowerCase().contains(query)).toList();
  }

  void _openProduct(Producto producto) {
    // TODO: abrir el detalle del producto
  }

  /// Abre la vista de Categorías.
  void _openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriasScreen(businessName: widget.businessName),
      ),
    );
  }

  /// Abre la vista de Proveedores.
  void _openSuppliers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProveedoresScreen(businessName: widget.businessName),
      ),
    );
  }

  Future<void> _registerProduct() async {
    final nuevo = await showModalBottomSheet<Producto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterProductSheet(
        businessName: widget.businessName,
      ),
    );

    if (nuevo == null || !mounted) return;

    setState(() {
      _productos.add(nuevo);
      _mostrarActivos = nuevo.activo; // para ver de inmediato el producto
      _searchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${nuevo.nombre}" registrado')),
    );
  }

  /// Menú que aparece al mantener presionada la tarjeta de un producto.
  Future<void> _showProductOptions(Producto producto, Offset position) async {
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

    if (action == null || !mounted) return;

    if (action == 'modificar') {
      await _editProduct(producto);
    } else if (action == 'eliminar') {
      await _deleteProduct(producto);
    }
  }

  Future<void> _editProduct(Producto producto) async {
    final editado = await showModalBottomSheet<Producto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RegisterProductSheet(
        businessName: widget.businessName,
        producto: producto,
      ),
    );

    if (editado == null || !mounted) return;

    // TODO: además de la lista en pantalla, actualizar el producto en tu
    // base de datos / API.
    final index = _productos.indexOf(producto);
    if (index == -1) return;

    setState(() {
      _productos[index] = editado;
      _mostrarActivos = editado.activo;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${editado.nombre}" actualizado')),
    );
  }

  Future<void> _deleteProduct(Producto producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteDialog(name: producto.nombre),
    );

    if (confirmar != true || !mounted) return;

    // TODO: además de la lista en pantalla, eliminar el producto de tu
    // base de datos / API.
    setState(() => _productos.remove(producto));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${producto.nombre}" eliminado')),
    );
  }

  int _navIndex = 2;

  // La barra está desconectada: solo marca la sección seleccionada,
  // no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final productos = _filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      // El teclado se muestra encima para que la barra inferior no se mueva.
      resizeToAvoidBottomInset: false,
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
                          'Inventario',
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

              const SizedBox(height: 20),

              // ---------- Buscador ----------
              _SearchField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
              ),

              const SizedBox(height: 12),

              // ---------- Selector: Productos activos / inactivos ----------
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
                        'Productos activos',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    PopupMenuItem(
                      value: false,
                      child: Text(
                        'Productos inactivos',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _mostrarActivos
                            ? 'Productos activos'
                            : 'Productos inactivos',
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

              // ---------- Lista de productos ----------
              Expanded(
                child: productos.isEmpty
                    ? Center(
                        child: Text(
                          _listaActual.isEmpty
                              ? (_mostrarActivos
                                  ? 'No hay productos activos'
                                  : 'No hay productos inactivos')
                              : 'No se encontraron productos',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.text,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: productos.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _ProductPill(
                          key: ObjectKey(productos[i]),
                          producto: productos[i],
                          onTap: () => _openProduct(productos[i]),
                          onLongPress: (position) =>
                              _showProductOptions(productos[i], position),
                        ),
                      ),
              ),

              const SizedBox(height: 12),
              Container(height: 3, color: AppColors.primary),
              const SizedBox(height: 16),

              // ---------- Categorías / Proveedores ----------
              Row(
                children: [
                  Expanded(
                    child: _SmallButton(
                      label: 'Categorías',
                      onPressed: _openCategories,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallButton(
                      label: 'Proveedores',
                      onPressed: _openSuppliers,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ---------- Registrar producto ----------
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
                  onPressed: _registerProduct,
                  child: const Text(
                    '+ Registrar producto',
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
        hintText: 'Buscar producto',
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

/// Tarjeta de producto: imagen arriba (solo si tiene), nombre, descripción
/// (solo si tiene) y, en la parte de abajo, el precio de venta a la izquierda,
/// el estado activo / inactivo al centro y el stock a la derecha.
/// La flecha de la esquina superior derecha despliega las variantes del
/// producto. Al mantener presionada la tarjeta se abre el menú
/// Modificar / Eliminar.
class _ProductPill extends StatefulWidget {
  final Producto producto;
  final VoidCallback onTap;

  /// Se llama al mantener presionada la tarjeta, con la posición del dedo.
  final void Function(Offset globalPosition) onLongPress;

  const _ProductPill({
    super.key,
    required this.producto,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<_ProductPill> createState() => _ProductPillState();
}

class _ProductPillState extends State<_ProductPill> {
  static const double _imageHeight = 130;

  bool _mostrarVariantes = false;

  /// Lista de variantes del producto, una línea por tipo.
  Widget _variantes(Producto producto) {
    final grupos =
        producto.variantes.entries.where((e) => e.value.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 1, color: Colors.white54),
          const SizedBox(height: 10),
          if (grupos.isEmpty)
            const Text(
              'Este producto no tiene variantes',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white70),
            )
          else
            for (final g in grupos)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                    children: [
                      TextSpan(
                        text: '${g.key}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: g.value.join(', ')),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final path = producto.imagePath;
    final hasImage = path != null && File(path).existsSync();
    final descripcion = producto.descripcion.trim();
    final activo = producto.activo;
    final precio = '\$${producto.precioVenta.toStringAsFixed(2)}';

    const cornerStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) =>
          widget.onLongPress(details.globalPosition),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias, // recorta la imagen a las esquinas
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagen en la parte superior (si no hay, no se muestra nada)
                  if (hasImage)
                    Image.file(
                      File(path),
                      height: _imageHeight,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Sin imagen, la flecha queda junto al nombre: se deja
                        // espacio para que no se encimen.
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: hasImage ? 0 : 24,
                          ),
                          child: Text(
                            producto.nombre,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (descripcion.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            descripcion,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),

                        // Precio (izquierda) · estado (centro) · stock (derecha)
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(precio, style: cornerStyle),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    activo ? Colors.white : Colors.transparent,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                activo ? 'Producto activo' : 'Producto inactivo',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      activo ? AppColors.primary : Colors.white,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Stock: ${producto.unidades}',
                                    style: cornerStyle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Variantes (se despliegan con la flecha)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: _mostrarVariantes
                              ? _variantes(producto)
                              : const SizedBox(width: double.infinity),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Flecha de la esquina superior derecha
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: hasImage ? Colors.black38 : Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () =>
                        setState(() => _mostrarVariantes = !_mostrarVariantes),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: AnimatedRotation(
                        turns: _mostrarVariantes ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
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

class _SmallButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SmallButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Ventana de confirmación para eliminar
// ---------------------------------------------------------------------------

/// Devuelve true si el usuario confirma que quiere eliminar un producto.
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
              'Eliminar producto',
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
                    text: '¿Estás seguro de que quieres eliminar el producto ',
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
// Tarjeta "Registrar producto" / "Modificar producto"
// ---------------------------------------------------------------------------

class _RegisterProductSheet extends StatefulWidget {
  final String businessName;

  /// Si viene un producto, la tarjeta funciona en modo edición.
  final Producto? producto;

  const _RegisterProductSheet({
    required this.businessName,
    this.producto,
  });

  @override
  State<_RegisterProductSheet> createState() =>
      _RegisterProductSheetState();
}

class _RegisterProductSheetState
    extends State<_RegisterProductSheet> {

  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _precioCostoController = TextEditingController();

  final _picker = ImagePicker();

  final _unidadesController = TextEditingController(text: '1');
  final _unidadesFocus = FocusNode();
  String? _imagePath; // imagen elegida de la galería
  Map<String, List<String>> _variantes = {};
  String? _categoria;
  String? _proveedor;
  bool _activo = true;
  String? _errorNombre;

  bool get _editando => widget.producto != null;

  @override
  void initState() {
    super.initState();

    // Al tocar el cuadro de unidades se selecciona todo para escribir rápido;
    // al salir, si quedó vacío o en 0, vuelve a 1.
    _unidadesFocus.addListener(() {
      if (_unidadesFocus.hasFocus) {
        _unidadesController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _unidadesController.text.length,
        );
      } else {
        _setUnidades(_unidadesActuales);
      }
    });

    final p = widget.producto;
    if (p == null) return;

    _nombreController.text = p.nombre;
    _descripcionController.text = p.descripcion;
    _codigoController.text = p.codigoBarras;
    _precioVentaController.text =
        p.precioVenta == 0 ? '' : _formatNumber(p.precioVenta);
    _precioCostoController.text =
        p.precioCosto == 0 ? '' : _formatNumber(p.precioCosto);
    _unidadesController.text = '${p.unidades}';
    _imagePath = p.imagePath;
    _variantes = {
      for (final e in p.variantes.entries) e.key: List<String>.of(e.value),
    };
    _categoria = p.categoria;
    _proveedor = p.proveedor;
    _activo = p.activo;
  }

  /// Unidades escritas en el cuadro (mínimo 1).
  int get _unidadesActuales {
    final v = int.tryParse(_unidadesController.text.trim());
    return (v == null || v < 1) ? 1 : v;
  }

  void _setUnidades(int value) {
    final v = value < 1 ? 1 : value;
    _unidadesController.value = TextEditingValue(
      text: '$v',
      selection: TextSelection.collapsed(offset: '$v'.length),
    );
  }

  String _formatNumber(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    _precioVentaController.dispose();
    _precioCostoController.dispose();
    _unidadesController.dispose();
    _unidadesFocus.dispose();
    super.dispose();
  }

  /// Abre la galería de fotos del celular.
  Future<void> _seleccionarImagen() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        setState(() => _imagePath = picked.path);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la galería')),
      );
    }
  }

  /// Valida y devuelve el producto a la pantalla de inventario.
  void _guardar() {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty) {
      setState(() => _errorNombre = 'Escribe el nombre del producto');
      return;
    }

    double parse(TextEditingController c) =>
        double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;

    Navigator.of(context).pop(
      Producto(
        nombre: nombre,
        descripcion: _descripcionController.text.trim(),
        imagePath: _imagePath,
        variantes: _variantes,
        categoria: _categoria,
        proveedor: _proveedor,
        codigoBarras: _codigoController.text.trim(),
        precioVenta: parse(_precioVentaController),
        precioCosto: parse(_precioCostoController),
        unidades: _unidadesActuales,
        activo: _activo,
      ),
    );
  }

  InputDecoration _decoration({String? hint, String? errorText}) {
    const border = OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(33),
      ),
      borderSide: BorderSide(
        color: Colors.white,
        width: 3,
      ),
    );

    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      errorStyle: const TextStyle(color: Colors.white),
      hintStyle: const TextStyle(
        color: Colors.white70,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 18,
      ),
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      border: border,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Abre la ventana de variantes y guarda lo que se elija.
  Future<void> _abrirVariantes() async {
    FocusScope.of(context).unfocus();
    final nombre = _nombreController.text.trim();

    final result = await Navigator.of(context).push<Map<String, List<String>>>(
      MaterialPageRoute(
        builder: (_) => _VariantesScreen(
          productName: nombre.isEmpty ? 'Nombre del producto' : nombre,
          initial: _variantes,
        ),
      ),
    );

    if (result == null || !mounted) return; // el usuario regresó sin guardar
    setState(() => _variantes = result);
  }

  /// Botón con forma de campo que muestra las variantes elegidas.
  Widget _variantesField() {
    final elegidas = _variantes.values.expand((l) => l).toList();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(33),
        onTap: _abrirVariantes,
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.only(left: 24, right: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(33),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    elegidas.isEmpty
                        ? 'Opciones de variantes'
                        : elegidas.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: elegidas.isEmpty ? Colors.white70 : Colors.white,
                    ),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> opciones,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.primary,
      decoration: _decoration(),
      iconEnabledColor: Colors.white,
      hint: Text(hint, style: const TextStyle(color: Colors.white70)),
      items: opciones
          .map(
            (o) => DropdownMenuItem(
              value: o,
              child: Text(o, style: const TextStyle(color: Colors.white)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final imagePath = _imagePath;
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return SheetDragScope(child: Container(
      constraints: BoxConstraints(
        maxHeight: media.size.height * .90,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(33),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: media.viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------- Barra superior (arrastra hacia abajo para cerrar) ----------
                const SheetHandle(),

                Text(
                  _editando ? 'Modificar producto' : '+ Registrar producto',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  height: 1.5,
                  color: Colors.white,
                ),

                const SizedBox(height: 24),

                Text(
                  'Negocio: ${widget.businessName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 20),

                _label('Nombre del producto'),
                const SizedBox(height: 8),

                TextField(
                  controller: _nombreController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {
                    if (_errorNombre != null) {
                      setState(() => _errorNombre = null);
                    }
                  },
                  decoration: _decoration(errorText: _errorNombre),
                ),

                const SizedBox(height: 20),

                _label('Descripción del producto'),
                const SizedBox(height: 8),

                TextField(
                  controller: _descripcionController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  minLines: 3,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _decoration(hint: 'Describe el producto'),
                ),

                const SizedBox(height: 20),

                _label('Imagen del producto'),
                const SizedBox(height: 8),

                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.file(
                      File(imagePath),
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                SizedBox(
                  height: 64,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.white,
                        width: 3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(33),
                      ),
                    ),
                    onPressed: _seleccionarImagen,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.file_upload_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          hasImage ? 'Cambiar imagen' : 'Subir archivo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (hasImage)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() => _imagePath = null),
                      child: const Text(
                        'Quitar imagen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                _label('Variante del producto'),
                const SizedBox(height: 8),

                _variantesField(),

                const SizedBox(height: 20),

                _label('Categoría del producto'),
                const SizedBox(height: 8),

                _dropdown(
                  hint: 'Opciones de categorías',
                  value: _categoria,
                  opciones: _kCategorias,
                  onChanged: (v) => setState(() => _categoria = v),
                ),

                const SizedBox(height: 20),

                _label('Proveedor'),
                const SizedBox(height: 8),

                _dropdown(
                  hint: 'Opciones de proveedores',
                  value: _proveedor,
                  opciones: _kProveedores,
                  onChanged: (v) => setState(() => _proveedor = v),
                ),

                const SizedBox(height: 20),

                _label('Código de barras'),
                const SizedBox(height: 8),

                TextField(
                  controller: _codigoController,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: _decoration(),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _label('Precio venta'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _precioVentaController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: _decoration().copyWith(
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          _label('Precio costo'),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _precioCostoController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: _decoration().copyWith(
                              prefixText: '\$ ',
                              prefixStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _label('Unidades del producto'),

                const SizedBox(height: 8),

                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _setUnidades(_unidadesActuales - 1);
                      },
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white,
                        size: 65,
                      ),
                    ),
                    // Al tocar el cuadro del medio se abre el teclado numérico.
                    Expanded(
                      child: Container(
                        height: 58,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          borderRadius:
                              BorderRadius.circular(33),
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _unidadesController,
                          focusNode: _unidadesFocus,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          cursorColor: Colors.white,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _setUnidades(_unidadesActuales + 1);
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 65,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Container(
                  height: 3,
                  color: Colors.white,
                ),

                const SizedBox(height: 24),

                // ---------- Estado: activo / inactivo ----------
                SizedBox(
                  height: 66,
                  child: _activo
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          onPressed: () => setState(() => _activo = false),
                          child: const Text(
                            'Producto activo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.white,
                              width: 3,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(33),
                            ),
                          ),
                          onPressed: () => setState(() => _activo = true),
                          child: const Text(
                            'Producto inactivo',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),

                const SizedBox(height: 14),

                // ---------- Registrar / guardar ----------
                SizedBox(
                  height: 66,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(33),
                      ),
                    ),
                    onPressed: _guardar,
                    child: Text(
                      _editando ? 'Guardar cambios' : 'Registrar producto',
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
    ));
  }
}

// ---------------------------------------------------------------------------
// Ventana "Variantes"
// ---------------------------------------------------------------------------

/// Pantalla para elegir las variantes de un producto. Devuelve un mapa
/// tipo → opciones elegidas (solo los tipos con al menos una opción), o null
/// si el usuario regresa sin guardar.
class _VariantesScreen extends StatefulWidget {
  final String productName;
  final Map<String, List<String>> initial;

  const _VariantesScreen({required this.productName, required this.initial});

  @override
  State<_VariantesScreen> createState() => _VariantesScreenState();
}

class _VariantesScreenState extends State<_VariantesScreen> {
  late final Map<String, Set<String>> _sel = {
    for (final k in _kVariantesOpciones.keys)
      k: <String>{...?widget.initial[k]},
  };

  // Secciones desplegadas: la primera y las que ya tengan algo elegido.
  late final Set<String> _abiertas = {
    _kVariantesOpciones.keys.first,
    for (final e in widget.initial.entries)
      if (e.value.isNotEmpty) e.key,
  };

  int get _total => _sel.values.fold(0, (sum, set) => sum + set.length);

  void _toggle(String cat, String op) {
    setState(() {
      final set = _sel[cat]!;
      if (!set.remove(op)) set.add(op);
    });
  }

  void _guardar() {
    final result = <String, List<String>>{};
    _kVariantesOpciones.forEach((cat, opciones) {
      final elegidas = opciones.where(_sel[cat]!.contains).toList();
      if (elegidas.isNotEmpty) result[cat] = elegidas;
    });
    Navigator.pop(context, result);
  }

  Widget _seccion(String cat) {
    final abierta = _abiertas.contains(cat);
    final n = _sel[cat]!.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() {
            if (!_abiertas.remove(cat)) _abiertas.add(cat);
          }),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Variantes de ${cat.toLowerCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      children: [
                        if (n > 0)
                          TextSpan(
                            text: '  ($n)',
                            style: const TextStyle(color: AppColors.primary),
                          ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  abierta
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.muted,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
        Container(height: 3, color: AppColors.muted),
        if (abierta)
          for (final op in _kVariantesOpciones[cat]!) _opcion(cat, op),
        SizedBox(height: abierta ? 28 : 4),
      ],
    );
  }

  Widget _opcion(String cat, String op) {
    final marcado = _sel[cat]!.contains(op);
    final color = cat == 'Color' ? _kColoresVariante[op] : null;

    return Column(
      children: [
        InkWell(
          onTap: () => _toggle(cat, op),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
            child: Row(
              children: [
                if (color != null) ...[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    op,
                    style: TextStyle(
                      fontSize: 18,
                      color: marcado ? Colors.black87 : AppColors.muted,
                    ),
                  ),
                ),
                Checkbox(
                  value: marcado,
                  onChanged: (_) => _toggle(cat, op),
                  activeColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.muted, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(height: 1, color: Colors.black45),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                          widget.productName,
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
                          'Variantes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Text(
                'Selecciona qué variantes quieres asignarle a este producto',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: AppColors.muted),
              ),

              const SizedBox(height: 16),

              // ---------- Secciones de variantes ----------
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final cat in _kVariantesOpciones.keys) _seccion(cat),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---------- Agregar variantes ----------
              SizedBox(
                height: 66,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _total > 0 ? AppColors.primary : AppColors.muted,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(33),
                    ),
                  ),
                  onPressed: _guardar,
                  child: const Text(
                    'Agregar variantes',
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