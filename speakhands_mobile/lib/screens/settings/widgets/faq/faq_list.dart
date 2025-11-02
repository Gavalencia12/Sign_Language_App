import 'package:flutter/material.dart';
import '../../models/faq_item.dart';
import 'faq_tile.dart';

class FaqList extends StatelessWidget {
  final List<FaqItem> items;
  final int? maxItems;

  const FaqList({super.key, required this.items, this.maxItems});

  @override
  Widget build(BuildContext context) {
    final count = (maxItems != null && items.length > maxItems!)
        ? maxItems!
        : items.length;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, i) => FaqTile(item: items[i]),
    );
  }
}
