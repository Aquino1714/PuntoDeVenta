import 'package:material_ui/material_ui.dart';
import '../../colors/colors.dart';

import '../../widgets/barra_navegacion.dart';

/// Pantalla que muestra los productos de un proveedor, con buscador
/// por nombre y tarjetas con foto, nombre y stock. Incluye la barra
/// de navegación inferior.
class ListaProductosProveedorScreen extends StatefulWidget {
  /// Nombre del negocio que se muestra en el encabezado.
  final String businessName;

  const ListaProductosProveedorScreen({
    super.key,
    this.businessName = 'Nombre del negocio',
  });

  @override
  State<ListaProductosProveedorScreen> createState() =>
      _ListaProductosProveedorScreenState();
}

class _ListaProductosProveedorScreenState
    extends State<ListaProductosProveedorScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  /// Productos de ejemplo. Pendiente: reemplazar por los productos reales
  /// del proveedor (base de datos o API).
  final List<_Product> _productos = [
    _Product(name: 'Nombre del producto', stock: 0),
  ];

  /// Productos que coinciden con el texto buscado (sin importar
  /// mayúsculas). Si no hay búsqueda, devuelve todos.
  List<_Product> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _productos;
    return _productos.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  /// Libera el controlador del buscador al cerrar la pantalla.
  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int _navIndex = 2;

  /// Marca la sección seleccionada en la barra inferior.
  /// La barra está desconectada: solo cambia el ícono activo,
  /// no navega a otra pantalla.
  void _onNavTap(int index) {
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final productos = _filtered;

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
                          'Lista de productos del proveedor',
                          textAlign: TextAlign.center,
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

              _SearchPill(
                controller: _searchCtrl,
                onChanged: (value) => setState(() => _query = value),
              ),

              const SizedBox(height: 16),

              Expanded(
                child: productos.isEmpty
                    ? Center(
                        child: Text(
                          _productos.isEmpty
                              ? 'No hay productos registrados'
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
                        itemBuilder: (_, i) => _ProductCard(product: productos[i]),
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

/// Modelo de un producto: nombre, stock y, opcionalmente, la ruta de su foto.
/// Si [imageUrl] es null se muestra el texto "FOTO".
class _Product {
  final String name;
  final int stock;
  final String? imageUrl;

  _Product({required this.name, required this.stock}) : imageUrl = null;
}

/// Barra de búsqueda con forma de pastilla y lupa a la derecha.
/// Avisa cada cambio de texto mediante [onChanged].
class _SearchPill extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchPill({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return Container(
      height: 56,
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
                hintText: 'Buscar producto',
                hintStyle: textStyle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.search, color: AppColors.primary, size: 34),
        ],
      ),
    );
  }
}

/// Tarjeta azul de un producto: foto a la izquierda, y nombre y stock
/// al centro.
class _ProductCard extends StatelessWidget {
  final _Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 84,
            height: 84,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: product.imageUrl == null
                ? const _PhotoPlaceholder()
                : Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                  ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
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
                    'Stock: ${product.stock}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Texto "FOTO" que se muestra cuando el producto no tiene imagen
/// o la imagen no se pudo cargar.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'FOTO',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
