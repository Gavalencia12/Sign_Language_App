import 'package:flutter/material.dart';
import '../../models/faq_item.dart';
import 'faq_tile.dart';

// A widget that displays a list of Frequently Asked Questions (FAQs)
// using [FaqTile] widgets for each entry.
// This widget can optionally limit the number of displayed items
// through the [maxItems] parameter — useful when showing a preview
// (e.g., top 4 FAQs on the Help screen).
class FaqList extends StatelessWidget {
  // The list of FAQ items to be displayed.
  final List<FaqItem> items;

  // Optional maximum number of items to display.
  // If null, all items will be shown.
  final int? maxItems;

  const FaqList({super.key, required this.items, this.maxItems});

  @override
  Widget build(BuildContext context) {
    // Determine how many items to show (respecting maxItems if provided)
    final count =
        (maxItems != null && items.length > maxItems!)
            ? maxItems!
            : items.length;

    return ListView.builder(
      // Allows embedding inside scrollable parents like SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, i) => FaqTile(item: items[i]),
    );
  }
}
