part of 'history_screen.dart';

final _historyViewDataProvider = FutureProvider<_HistoryViewData>((ref) async {
  final overview = await ref.watch(historyOverviewProvider.future);
  return _HistoryViewData.fromDomain(overview);
});

class _HistoryViewData {
  const _HistoryViewData({required this.sections});

  final List<_HistoryMonthSectionData> sections;

  int get totalCentavos =>
      sections.fold(0, (sum, section) => sum + section.totalCentavos);

  int get itemCount =>
      sections.fold(0, (sum, section) => sum + section.items.length);

  int get monthCount => sections.length;

  _HistoryViewData filterByQuery(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return this;
    }

    final filteredSections = sections
        .map((section) {
          final filteredItems = section.items.where((item) {
            final searchable =
                '${section.monthLabel} ${item.title} ${item.dateLabel} ${item.typeLabel} ${item.isActive ? 'active' : 'inactive'}'
                    .toLowerCase();
            return searchable.contains(normalizedQuery);
          }).toList();

          if (filteredItems.isEmpty) {
            return null;
          }

          final filteredTotal = filteredItems.fold<int>(
            0,
            (sum, item) => sum + item.amountCentavos,
          );
          return _HistoryMonthSectionData(
            monthLabel: section.monthLabel,
            totalCentavos: filteredTotal,
            items: filteredItems,
          );
        })
        .whereType<_HistoryMonthSectionData>()
        .toList();

    return _HistoryViewData(sections: filteredSections);
  }

  factory _HistoryViewData.fromDomain(HistoryOverview overview) {
    final sections = overview.sections.map((section) {
      return _HistoryMonthSectionData(
        monthLabel: _monthYearLabel(section.year, section.month),
        totalCentavos: section.totalCentavos,
        items: section.items.map((item) {
          return _HistoryItem(
            source: item,
            icon: _iconForBudgetType(item.type),
            title: item.name,
            dateLabel: _dateLabel(item.createdAt),
            typeLabel: _labelForBudgetType(item.type),
            isActive: item.isActive,
            amountCentavos: item.amountCentavos,
          );
        }).toList(),
      );
    }).toList();

    return _HistoryViewData(sections: sections);
  }
}

class _HistoryMonthSectionData {
  const _HistoryMonthSectionData({
    required this.monthLabel,
    required this.totalCentavos,
    required this.items,
  });

  final String monthLabel;
  final int totalCentavos;
  final List<_HistoryItem> items;
}

class _HistoryItem {
  const _HistoryItem({
    required this.source,
    required this.icon,
    required this.title,
    required this.dateLabel,
    required this.typeLabel,
    required this.isActive,
    required this.amountCentavos,
  });

  final history_domain.HistoryItem source;
  final IconData icon;
  final String title;
  final String dateLabel;
  final String typeLabel;
  final bool isActive;
  final int amountCentavos;
}

String _monthYearLabel(int year, int month) {
  return '${_monthName(month).toUpperCase()} $year';
}

String _dateLabel(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  return '${_monthName(date.month)} $day, ${date.year}';
}

String _monthName(int month) {
  const monthNames = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  if (month < 1 || month > 12) {
    return 'Unknown';
  }
  return monthNames[month - 1];
}

IconData _iconForBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return Icons.calendar_view_week_outlined;
    case 'monthly':
      return Icons.calendar_month_outlined;
    case 'shopping':
    default:
      return Icons.shopping_basket_outlined;
  }
}

String _labelForBudgetType(String type) {
  switch (type.toLowerCase()) {
    case 'weekly':
      return 'Weekly';
    case 'monthly':
      return 'Monthly';
    case 'shopping':
    default:
      return 'Shopping';
  }
}
