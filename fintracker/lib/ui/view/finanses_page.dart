import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:fintracker/l10n/app_localizations.dart';

import '../view_models/finanses_view_model.dart';
import '../widgets/custom_loader.dart';
import '../widgets/budget_bar.dart';
import '../widgets/receipt_card.dart';

class FinansesPage extends StatelessWidget {
  const FinansesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<FinansesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CustomLoader(size: 80));
            }

            return RefreshIndicator(
              onRefresh: () async => await viewModel.fetchData(),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16.0),
                    sliver: SliverToBoxAdapter(
                      child: _buildDateHeader(context, viewModel),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverToBoxAdapter(
                      child: BudgetBar(
                        spent: viewModel.totalSpent,
                        limit: viewModel.monthlyBudgetLimit,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    sliver: SliverToBoxAdapter(
                      child: SizedBox(
                        height: 250,
                        child: _ChartsCarousel(viewModel: viewModel),
                      ),
                    ),
                  ),
                  _buildGroupedList(context, viewModel),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                  SliverAppBar(
                    title: const Text('Finanse'),
                    floating: true,
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.file_download),
                        tooltip: "Eksportuj raport",
                        onPressed: () => _showExportDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, FinansesViewModel vm) {
    final dateStr =
        DateFormat.yMMMM(Intl.getCurrentLocale()).format(vm.currentDate);
    final capitalizedDate = dateStr[0].toUpperCase() + dateStr.substring(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => vm.changeMonth(-1),
        ),
        Text(
          capitalizedDate,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => vm.changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildGroupedList(BuildContext context, FinansesViewModel vm) {
    final grouped = vm.groupedReceipts;
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    if (sortedKeys.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              AppLocalizations.of(context)!.noExpenses,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final dateKey = sortedKeys[index];
          final receipts = grouped[dateKey]!;

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: Text(
                    _formatFriendlyDate(context, dateKey),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...receipts.map((receipt) => ReceiptCard(
                      receipt: receipt,
                      onTap: () {
                        context.push('/receipt-details/${receipt.id}');
                      },
                    )),
              ],
            ),
          );
        },
        childCount: sortedKeys.length,
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => const _ExportBottomSheet(),
    );
  }

  String _formatFriendlyDate(BuildContext context, String dateStr) {
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    final l10n = AppLocalizations.of(context)!;

    if (checkDate == today) return l10n.today;
    if (checkDate == yesterday) return l10n.yesterday;

    return DateFormat.EEEE(Intl.getCurrentLocale()).format(date) +
        ', ' +
        DateFormat.MMMd(Intl.getCurrentLocale()).format(date);
  }
}

class _ChartsCarousel extends StatefulWidget {
  final FinansesViewModel viewModel;
  const _ChartsCarousel({required this.viewModel});

  @override
  State<_ChartsCarousel> createState() => _ChartsCarouselState();
}

class _ChartsCarouselState extends State<_ChartsCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      padEnds: false,
      children: [
        _ChartCard(
          title: AppLocalizations.of(context)!.chartTime,
          child: _buildBarChart(context),
        ),
        _ChartCard(
          title: AppLocalizations.of(context)!.chartCategories,
          child: _buildPieChart(context),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final data = widget.viewModel.summaryData;
    final theme = Theme.of(context);

    if (data.isEmpty) return Center(child: Text(l10n.noData));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2,
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) return const SizedBox();
                if (data.length > 15 && index % 3 != 0) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    data[index].label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.total,
                color: theme.colorScheme.primary,
                width: 12,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY:
                      data.map((e) => e.total).reduce((a, b) => a > b ? a : b) *
                          1.2,
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stats = widget.viewModel.categoryStats;

    if (stats.isEmpty) return Center(child: Text(l10n.noData));

    final theme = Theme.of(context);
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.orange,
      Colors.purple,
      Colors.blue,
    ];

    int colorIndex = 0;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: stats.entries.map((entry) {
                final color = colors[colorIndex % colors.length];
                colorIndex++;
                return PieChartSectionData(
                  value: entry.value,
                  color: color,
                  title: '',
                  radius: 40,
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ListView(
            padding: EdgeInsets.zero,
            children: stats.entries.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final mapEntry = entry.value;
              final color = colors[index % colors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration:
                          BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mapEntry.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      NumberFormat.simpleCurrency(
                              locale: 'pl_PL', decimalDigits: 0)
                          .format(mapEntry.value),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16, left: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _ExportBottomSheet extends StatefulWidget {
  const _ExportBottomSheet();

  @override
  State<_ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<_ExportBottomSheet> {
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.read<FinansesViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Eksportuj dane",
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text("Wybierz okres"),
            subtitle: Text(
              "${DateFormat('dd.MM.yyyy').format(_selectedRange!.start)} - ${DateFormat('dd.MM.yyyy').format(_selectedRange!.end)}",
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: _selectedRange,
              );
              if (picked != null) {
                setState(() {
                  _selectedRange = picked;
                });
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    vm.exportData(
                        _selectedRange!.start, _selectedRange!.end, false);
                  },
                  icon: const Icon(Icons.table_chart),
                  label: const Text("CSV (Excel)"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    vm.exportData(
                        _selectedRange!.start, _selectedRange!.end, true);
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("PDF"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
