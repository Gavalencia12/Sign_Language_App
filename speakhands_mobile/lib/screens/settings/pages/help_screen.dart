import 'package:flutter/material.dart';
import 'package:speakhands_mobile/widgets/custom_text_field.dart';
import '../models/faq_item.dart';
import '../services/faq_service.dart';
import '../widgets/faq/faq_modal.dart';
import '../widgets/faq/faq_list.dart';
import '../widgets/help_contact_section.dart';
import '../widgets/section_title.dart';
import '../widgets/empty_state.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _service = FaqService();
  final _searchCtrl = TextEditingController();

  List<FaqItem> _faqs = [];
  List<FaqItem> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_applyFilter);
  }

  Future<void> _load() async {
    final items = await _service.loadFaqs();
    setState(() {
      _faqs = items;
      _filtered = items;
      _loading = false;
    });
  }

  void _applyFilter() {
    setState(() {
      _filtered = _service.filter(_faqs, _searchCtrl.text);
    });
  }

  Future<void> _openFaqModal() async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => FaqModal(items: _filtered),
    );
  }

  @override
  void dispose() {
    _searchCtrl
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // buscador
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: CustomTextField(
                        controller: _searchCtrl,
                        label: 'Buscar preguntas…',
                        icon: Icons.search,
                      ),
                    ),

                    // Titulo sección
                    SectionTitle(title: 'Preguntas frecuentes (FAQ)'),

                    const SizedBox(height: 8),

                    // Lista top 4 o estado vacío
                    if (_filtered.isEmpty)
                      const EmptyState(
                        message: 'No encontramos resultados para tu búsqueda.',
                      )
                    else
                      FaqList(items: _filtered, maxItems: 4),

                    const SizedBox(height: 16),

                    // Ver más (abre modal con lista completa filtrada)
                    Center(
                      child: TextButton(
                        onPressed: _openFaqModal,
                        child: const Text('Ver más'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Contacto (usa helpers internos para abrir mail/phone)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: HelpContactSection(),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
    );
  }
}
