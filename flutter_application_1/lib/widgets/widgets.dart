import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../colors/colors.dart';
import 'barra_navegacion.dart';

/// Navega a otra pantalla.
void go(BuildContext context, Widget screen) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));

/// Reemplaza la pantalla actual (para cambiar de pestaña sin apilar).
void goReplace(BuildContext context, Widget screen) =>
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));

/// Regresa a la pantalla anterior mostrando un mensaje.
void saveAndBack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  Navigator.maybePop(context);
}

/// Búsqueda por inicial: coincide si el nombre EMPIEZA con lo escrito.
bool startsWithInitial(String name, String query) {
  String norm(String t) {
    const from = 'áàäâéèëêíìïîóòöôúùüûñ';
    const to = 'aaaaeeeeiiiioooouuuun';
    var r = t.toLowerCase().trim();
    for (var i = 0; i < from.length; i++) {
      r = r.replaceAll(from[i], to[i]);
    }
    return r;
  }

  final q = norm(query);
  return q.isEmpty || norm(name).startsWith(q);
}

/// Scaffold base: contenido + (opcional) botones Empleados/Clientes + barra azul inferior.
class AppScaffold extends StatelessWidget {
  final Widget child;
  final List<String>? subTabs;
  final int subIndex;
  final void Function(int)? onSubTap;

  /// Ícono de la barra azul que se ilumina en esta pantalla
  /// (0 casa, 1 carrito, 2 cuadritos, 3 personas). Por defecto: personas.
  final int navIndex;
  const AppScaffold(
      {super.key,
      required this.child,
      this.subTabs,
      this.subIndex = 0,
      this.onSubTap,
      this.navIndex = 3});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: Column(mainAxisSize: MainAxisSize.min, children: [
        if (subTabs != null)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Row(children: [
              for (int i = 0; i < subTabs!.length; i++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _SubTabButton(
                      label: subTabs![i],
                      icon: i == 0 ? Icons.badge_outlined : Icons.people_outline,
                      selected: i == subIndex,
                      onTap: () => onSubTap?.call(i),
                    ),
                  ),
                ),
            ]),
          ),
        // La propia barra se encarga de navegar; aquí solo se marca el ícono.
        BottomNavBar(currentIndex: navIndex, onTap: (_) {}),
      ]),
    );
  }
}

/// Botón Empleados / Clientes: mismo estilo que la barra azul (se agranda al elegirlo)
/// y además navega a su sección.
class _SubTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SubTabButton(
      {required this.label, required this.icon, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 46,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.primary, width: 1.4),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: selected ? 24 : 19,
                  color: selected ? Colors.white : AppColors.primary),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      fontSize: selected ? 13 : 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.primary)),
            ]),
          ),
        ),
      );
}

/// Encabezado. Con `back: true` muestra la flecha que regresa a la pantalla anterior.
class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool back;
  final IconData? trailing;
  const AppHeader(
      {super.key, required this.title, this.subtitle, this.back = false, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (back)
        Padding(
          padding: const EdgeInsets.only(right: 6, top: 2),
          child: Tooltip(
            message: 'Regresar',
            child: InkWell(
              onTap: () => Navigator.maybePop(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 38,
                height: 38,
                decoration:
                    const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
              ),
            ),
          ),
        ),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MY BUSINESS',
              style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
          const SizedBox(height: 2),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          if (subtitle != null)
            Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
        ]),
      ),
      if (trailing != null)
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Icon(trailing, size: 20, color: AppColors.textDark),
        ),
    ]);
  }
}

class ScreenBody extends StatelessWidget {
  final List<Widget> children;
  const ScreenBody({super.key, required this.children});
  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20), children: children);
}

class DarkCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const DarkCard({super.key, required this.child, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration:
              BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(14)),
          child: child,
        ),
      );
}

class DarkAmount extends StatelessWidget {
  final String label, amount;
  final String? footer;
  final VoidCallback? onTap;
  const DarkAmount(
      {super.key, required this.label, required this.amount, this.footer, this.onTap});
  @override
  Widget build(BuildContext context) => DarkCard(
        onTap: onTap,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(amount,
              style: const TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
          if (footer != null) ...[
            const SizedBox(height: 4),
            Text(footer!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ],
        ]),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  const PrimaryButton(this.label, {super.key, this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: onPressed ?? () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder()),
          icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
          label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      );
}

class SearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  const SearchBox(this.hint, {super.key, this.onChanged});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: TextField(
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            suffixIcon: const Icon(Icons.search, size: 18, color: AppColors.muted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      );
}

/// Campo editable con validación opcional (se valida dentro de un `Form`).
class LabeledField extends StatefulWidget {
  final String label, value; // `value` es el texto de ejemplo (hint)
  final bool highlight;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  const LabeledField(this.label, this.value,
      {super.key,
      this.highlight = false,
      this.controller,
      this.validator,
      this.keyboardType,
      this.inputFormatters,
      this.prefixText,
      this.onChanged});
  @override
  State<LabeledField> createState() => _LabeledFieldState();
}

class _LabeledFieldState extends State<LabeledField> {
  late final TextEditingController _c = widget.controller ??
      TextEditingController(text: widget.highlight ? widget.value : '');
  @override
  void dispose() {
    if (widget.controller == null) _c.dispose();
    super.dispose();
  }

  OutlineInputBorder _border(Color color, double w) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(30), borderSide: BorderSide(color: color, width: w));

  @override
  Widget build(BuildContext context) {
    final h = widget.highlight;
    final red = Colors.red.shade600;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 4),
        TextFormField(
          controller: _c,
          validator: widget.validator,
          onChanged: widget.onChanged,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: widget.keyboardType ??
              (h ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
          inputFormatters: widget.inputFormatters,
          style: TextStyle(
              fontSize: h ? 18 : 13,
              fontWeight: h ? FontWeight.w700 : FontWeight.w400,
              color: AppColors.textDark),
          decoration: InputDecoration(
            isDense: true,
            hintText: widget.value,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixText: widget.prefixText,
            errorStyle: const TextStyle(fontSize: 11),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            enabledBorder: _border(h ? AppColors.primary : AppColors.border, h ? 1.6 : 1),
            focusedBorder: _border(AppColors.primary, 1.6),
            errorBorder: _border(red, 1.4),
            focusedErrorBorder: _border(red, 1.8),
          ),
        ),
      ]),
    );
  }
}

class FieldRow extends StatelessWidget {
  final Widget a, b;
  const FieldRow(this.a, this.b, {super.key});
  @override
  Widget build(BuildContext context) =>
      Row(children: [Expanded(child: a), const SizedBox(width: 10), Expanded(child: b)]);
}

/// Selector de opciones (se puede tocar para cambiar).
class Segmented extends StatefulWidget {
  final String label;
  final List<String> options;
  final int selected;
  final ValueChanged<int>? onChanged;
  const Segmented(this.label, this.options, {super.key, this.selected = 0, this.onChanged});
  @override
  State<Segmented> createState() => _SegmentedState();
}

class _SegmentedState extends State<Segmented> {
  late int _sel = widget.selected;
  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: 4),
        Row(children: [
          for (int i = 0; i < options.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _sel = i);
                  widget.onChanged?.call(i);
                },
                child: Container(
                  margin: EdgeInsets.only(right: i == options.length - 1 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == _sel ? AppColors.infoBg : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: i == _sel ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(options[i],
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: i == _sel ? AppColors.primary : AppColors.textDark)),
                ),
              ),
            ),
        ]),
      ]),
    );
  }
}

class PillTabs extends StatelessWidget {
  final List<String> items;
  final int selected;
  final void Function(int)? onSelected;
  const PillTabs(this.items, {super.key, this.selected = 0, this.onSelected});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (int i = 0; i < items.length; i++)
              GestureDetector(
                onTap: () => onSelected?.call(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: i == selected ? AppColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: i == selected ? AppColors.navy : AppColors.border),
                  ),
                  child: Text(items[i],
                      style: TextStyle(
                          fontSize: 12, color: i == selected ? Colors.white : AppColors.textDark)),
                ),
              ),
          ]),
        ),
      );
}

class PersonTile extends StatelessWidget {
  final String name, subtitle;
  final String? trailing, trailingSub;
  final bool chip;
  final VoidCallback? onTap;
  const PersonTile(this.name, this.subtitle,
      {super.key, this.trailing, this.trailingSub, this.chip = false, this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: AppColors.primary, borderRadius: BorderRadius.circular(30)),
          child: Row(children: [
            const Icon(Icons.person, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ]),
            ),
            if (trailing != null && chip)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Text(trailing!,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
              )
            else if (trailing != null)
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(trailing!,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                if (trailingSub != null)
                  Text(trailingSub!,
                      style: const TextStyle(fontSize: 10, color: Colors.white70)),
              ]),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
          ]),
        ),
      );
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
      );
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final bool bold;
  const InfoRow(this.label, this.value, {super.key, this.bold = false});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          Text(value,
              style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}

class InfoBox extends StatelessWidget {
  final List<Widget> children;
  const InfoBox({super.key, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration:
            BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
        child: Column(children: children),
      );
}

class BannerNote extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const BannerNote(this.text, {super.key, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration:
              BoxDecoration(color: AppColors.infoBg, borderRadius: BorderRadius.circular(10)),
          child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.primary)),
        ),
      );
}

class ProfileHeader extends StatelessWidget {
  final String name, sub;
  const ProfileHeader(this.name, this.sub, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.infoBg,
            child: Text(name.substring(0, 1),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          ]),
        ]),
      );
}

class SwitchRow extends StatefulWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  const SwitchRow(this.label, this.value, {super.key, this.onChanged});
  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  late bool _v = widget.value;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(widget.label, style: const TextStyle(fontSize: 12))),
        Switch(value: _v, activeThumbColor: AppColors.primary, onChanged: (v) {
          setState(() => _v = v);
          widget.onChanged?.call(v);
        }),
      ]);
}