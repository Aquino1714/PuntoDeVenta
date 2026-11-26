import 'package:material_ui/material_ui.dart';
import '../colors/colors.dart';
import '../data/data.dart' show Cliente, store, phoneFmt;
import '../screens/inventario/inventario.dart' show Producto, productosGuardados;
import 'sheet_handle.dart';

/// Abre una lista con los productos activos guardados en el inventario.
/// Devuelve el producto elegido, o null si se cierra sin elegir.
Future<Producto?> elegirProducto(BuildContext context) {
  final activos = productosGuardados.where((p) => p.activo).toList();
  return showModalBottomSheet<Producto>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SelectorLista<Producto>(
      titulo: 'Buscar producto',
      pista: 'Buscar por nombre',
      vacio: 'No hay productos guardados.\nRegístralos en Inventario.',
      icono: Icons.inventory_2_outlined,
      items: activos,
      nombre: (p) => p.nombre,
      detalle: (p) =>
          '\$${p.precioVenta.toStringAsFixed(2)} · ${p.unidades} en inventario',
      busqueda: (p) => p.nombre,
    ),
  );
}

/// Abre una lista con los clientes guardados en el programa.
/// Devuelve el cliente elegido, o null si se cierra sin elegir.
Future<Cliente?> elegirCliente(BuildContext context) {
  final clientes = List<Cliente>.of(store.clientes);
  return showModalBottomSheet<Cliente>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SelectorLista<Cliente>(
      titulo: 'Buscar cliente',
      pista: 'Buscar por nombre o teléfono',
      vacio: 'No hay clientes guardados.\nRegístralos en Clientes.',
      icono: Icons.person_outline,
      items: clientes,
      nombre: (c) => c.fullName,
      detalle: (c) {
        final tel = 'Tel. ${phoneFmt(c.telefono)}';
        return c.tieneSaldo
            ? '$tel · Saldo \$${c.saldo.toStringAsFixed(2)}'
            : tel;
      },
      busqueda: (c) => '${c.fullName} ${c.telefono}',
    ),
  );
}

/// Quita acentos y mayúsculas para que la búsqueda sea más flexible.
String _norm(String t) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  var r = t.toLowerCase().trim();
  for (var i = 0; i < from.length; i++) {
    r = r.replaceAll(from[i], to[i]);
  }
  return r;
}

/// Tarjeta con buscador y lista para elegir un elemento. Se puede bajar
/// arrastrando la barrita blanca, igual que las demás tarjetas.
class _SelectorLista<T> extends StatefulWidget {
  final String titulo;
  final String pista;
  final String vacio;
  final IconData icono;
  final List<T> items;
  final String Function(T) nombre;
  final String Function(T) detalle;
  final String Function(T) busqueda;

  const _SelectorLista({
    required this.titulo,
    required this.pista,
    required this.vacio,
    required this.icono,
    required this.items,
    required this.nombre,
    required this.detalle,
    required this.busqueda,
  });

  @override
  State<_SelectorLista<T>> createState() => _SelectorListaState<T>();
}

class _SelectorListaState<T> extends State<_SelectorLista<T>> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<T> get _filtrados {
    final q = _norm(_ctrl.text);
    if (q.isEmpty) return widget.items;
    return widget.items.where((e) => _norm(widget.busqueda(e)).contains(q)).toList();
  }

  Widget _fila(T item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context, item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(widget.icono, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.nombre(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.detalle(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final altura = (media.size.height * 0.75)
        .clamp(0.0, media.size.height - keyboard - media.padding.top)
        .toDouble();
    final lista = _filtrados;

    const borde = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(33)),
      borderSide: BorderSide(color: Colors.white, width: 3),
    );

    return SheetDragScope(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: Container(
          height: altura,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(33)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SheetHandle(),
                  Text(
                    widget.titulo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1.5, color: Colors.white),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (_) => setState(() {}),
                      cursorColor: Colors.white,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.pista,
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        enabledBorder: borde,
                        focusedBorder: borde,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: widget.items.isEmpty || lista.isEmpty
                        ? Center(
                            child: Text(
                              widget.items.isEmpty ? widget.vacio : 'Sin resultados',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 16),
                            children: [for (final item in lista) _fila(item)],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}