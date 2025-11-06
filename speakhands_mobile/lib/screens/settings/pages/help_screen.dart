import 'package:flutter/material.dart';
import 'package:speakhands_mobile/theme/app_colors.dart';
import 'package:speakhands_mobile/widgets/custom_text_field.dart';
import '../models/faq_item.dart';
import '../services/faq_service.dart';
import '../widgets/faq/faq_modal.dart';
import '../widgets/faq/faq_list.dart';
import '../widgets/help_contact_section.dart';
import '../widgets/section_title.dart';
import '../widgets/empty_state.dart';
import 'package:speakhands_mobile/l10n/app_localizations.dart';

// The **HelpScreen** provides users with access to frequently asked questions (FAQ)
// and a contact section for additional support.

// Features:
// - Displays a searchable list of FAQ items.
// - Allows users to filter questions dynamically as they type.
// - Includes a modal to view all results.
// - Offers contact options for direct assistance.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  // Service that loads FAQ data from local or remote sources.
  final _service = FaqService();

  // Controller for the search text field.
  final _searchCtrl = TextEditingController();

  // List of all FAQ items loaded from the service.
  List<FaqItem> _faqs = [];

  // Filtered list based on the current search input.
  List<FaqItem> _filtered = [];

  // Indicates whether data is still being loaded.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(); // Load FAQs on startup
    _searchCtrl.addListener(_applyFilter);
     WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  // Loads FAQ items asynchronously using the [FaqService].
  Future<void> _load() async {
    final items = await _service.loadFaqs(context);
    setState(() {
      _faqs = items;
      _filtered = items;
      _loading = false;
    });
  }

  // Applies a real-time filter to FAQs based on the text entered by the user.
  void _applyFilter() {
    setState(() {
      _filtered = _service.filter(_faqs, _searchCtrl.text);
    });
  }

  // Opens a modal bottom sheet that displays all filtered FAQs.
  Future<void> _openFaqModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface(context),
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
    final loc = AppLocalizations.of(context)!; 

    return Scaffold(
      backgroundColor: AppColors.surface(context),

      // Top navigation bar with a custom back arrow color.
      appBar: AppBar(
        title: Text(
          loc.help_title,
          style: TextStyle(color: AppColors.onSurface(context)),
        ),
        backgroundColor: AppColors.surface(context),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onSurface(context)),
      ),

      // Main content body — either a loading indicator or the FAQ list.
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: CustomTextField(
                        controller: _searchCtrl,
                        label: loc.search_questions,
                        icon: Icons.search,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Section title
                    SectionTitle(title: loc.faq_title),

                    const SizedBox(height: 8),

                    // List of top FAQs or empty state message
                    if (_filtered.isEmpty)
                      EmptyState(
                        message: loc.no_results_found,
                      )
                    else
                      FaqList(items: _filtered, maxItems: 4),

                    const SizedBox(height: 16),

                    // Button to view all FAQs (opens modal)
                    Center(
                      child: TextButton(
                        onPressed: _openFaqModal,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary(context),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        child: Text(loc.see_more),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Contact support section
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
