import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'dart:convert';

// modelo para las preguntas frecuentes
class FaqItem {
  final String question;
  final List<String> answers;
  FaqItem({required this.question, required this.answers});
}

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Lista de preguntass cargadas desde el JSON
  List<FaqItem> _faqs = [];
  List<FaqItem> _filteredFaqs = [];
  TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchCtrl.addListener(_filterFaqs);
  }

  // Cargar las preguntas desde el archivo JSON
  Future<void> _loadFaqs() async {
    final String response = await rootBundle.rootBundle.loadString('assets/faqs.json');
    final data = json.decode(response);
    setState(() {
      _faqs = (data['faqs'] as List)
          .map((item) => FaqItem(
                question: item['question'],
                answers: List<String>.from(item['answers']),
              ))
          .toList();
      _filteredFaqs = _faqs;
    });
  }

  // filtrar segun el texto ingresado
  void _filterFaqs() {
    setState(() {
      _filteredFaqs = _faqs.where((faq) {
        return faq.question.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
            faq.answers.any((answer) =>
                answer.toLowerCase().contains(_searchCtrl.text.toLowerCase()));
      }).toList();
    });
  }

  // abrir el correo de soporte
  Future<void> _launchEmail() async {
    final emailUrl = 'mailto:languageappsign@gmail.com?subject=Soporte%20Técnico';
    final Uri _emailUri = Uri.parse(emailUrl);
    if (await canLaunchUrl(_emailUri)) {
      await launchUrl(_emailUri);
    } else {
      throw 'No se pudo abrir el enlace de correo';
    }
  }
  // funcion marcado rapido
  Future<void> _launchPhone() async {
    final phoneUrl = 'tel:+523142184467';
    final Uri _phoneUri = Uri.parse(phoneUrl);
    if (await canLaunchUrl(_phoneUri)) {
    await launchUrl(_phoneUri);
    } else {
    throw 'No se pudo realizar la llamada';
    }
  }

  // abrir el modal de las preguntas frecuentes
  Future<void> _openFaqModal(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 40, height: 5,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Preguntas frecuentes',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // lista de preguntas expandible
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                      itemCount: _filteredFaqs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _FaqTile(item: _filteredFaqs[i]),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Ayuda')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // buscador
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: 'Buscar preguntas...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),

            const Text(
              'Preguntas frecuentes (FAQ)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),

            // preguntas frecuentes principales
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredFaqs.length > 4 ? 4 : _filteredFaqs.length,
              itemBuilder: (context, index) {
                final item = _filteredFaqs[index];
                return _FaqTile(item: item);
              },
            ),

            const SizedBox(height: 16),
            // ver mas- abrir modal
            Center(
              child: TextButton(
                onPressed: () => _openFaqModal(context),
                child: const Text('Ver más'),
                style: TextButton.styleFrom(
                  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
              ),
            ),

            //seccioncontacto
            const SizedBox(height: 24),
            Center(
              child: const Text(
                '¿Necesitas más ayuda? ¡Contáctanos!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _launchEmail,
                child: const Text(
                  'languageappsign@gmail.com',
                  style: TextStyle(
                      color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _launchPhone,  // Acción al hacer clic en el número de teléfono
                child: const Text(
                  '+52 (314) 218-4467',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// expansion de cada pregunta
class _FaqTile extends StatelessWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline),
        title: Text(item.question),
        children: item.answers
            .map((answer) => ListTile(
                  title: Text(answer),
                ))
            .toList(),
      ),
    );
  }
}
