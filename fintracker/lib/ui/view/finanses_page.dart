import 'package:fintracker/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../view_models/finanses_view_model.dart';
import '../widgets/custom_loader.dart';
import '../../data/models/summary_data.dart';

class FinansesPage extends StatefulWidget {
  const FinansesPage({super.key});

  @override
  State<FinansesPage> createState() => _FinansesPageState();
}

class _FinansesPageState extends State<FinansesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final viewModel = context.read<FinansesViewModel>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.9 &&
          !viewModel.isLoadingMore &&
          viewModel.hasMore) {
        viewModel.loadMoreReceipts();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<FinansesViewModel>(
      builder: (context, viewModel, child) {
        return SafeArea(
          child: Column(
            children: [
              _DateFilterSelector(
                selectedFilter: viewModel.selectedFilter,
                onFilterChanged: (filter) {
                  if (filter != null) {
                    viewModel.setFilter(filter);
                  }
                },
              ),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: l10n.finansesSummaryTab),
                  Tab(text: l10n.finansesAllTab),
                ],
              ),
              Expanded(
                child: _buildContent(context, viewModel, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, FinansesViewModel viewModel,
      AppLocalizations l10n) {
    if (viewModel.isLoading) {
      return const Center(
        child: CustomLoader(size: 100),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Text(
          l10n.errorFetchingData,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (viewModel.receipts.isEmpty && viewModel.summaryData.isEmpty) {
      return Center(
        child: Text(
          l10n.noReceiptsAdded,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _SummaryView(summaryData: viewModel.summaryData, viewModel: viewModel),
        _AllReceiptsView(
          controller: _scrollController,
          viewModel: viewModel,
        ),
      ],
    );
  }
}

class _DateFilterSelector extends StatelessWidget {
  final DateFilter selectedFilter;
  final ValueChanged<DateFilter?> onFilterChanged;

  const _DateFilterSelector({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSmallScreen = MediaQuery.of(context).size.width < 500;

    final String allLabelText;
    if (isSmallScreen) {
      final locale = Localizations.localeOf(context).languageCode;
      allLabelText = (locale == 'pl') ? 'Wsz.' : 'All';
    } else {
      allLabelText = l10n.filterAll;
    }

    final segments = <ButtonSegment<DateFilter>>[
      ButtonSegment(
        value: DateFilter.week,
        label: Text(l10n.filterWeek, overflow: TextOverflow.ellipsis),
      ),
      ButtonSegment(
        value: DateFilter.month,
        label: Text(l10n.filterMonth, overflow: TextOverflow.ellipsis),
      ),
      ButtonSegment(
        value: DateFilter.sixMonths,
        label: Text(isSmallScreen ? '6M' : l10n.filter6Months,
            overflow: TextOverflow.ellipsis),
      ),
      ButtonSegment(
        value: DateFilter.year,
        label: Text(l10n.filterYear, overflow: TextOverflow.ellipsis),
      ),
      ButtonSegment(
        value: DateFilter.all,
        label: Text(allLabelText, overflow: TextOverflow.ellipsis),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SegmentedButton<DateFilter>(
            segments: segments,
            selected: {selectedFilter},
            onSelectionChanged: (Set<DateFilter> newSelection) {
              onFilterChanged(newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6.0 : 10.0,
              ),
              textStyle: isSmallScreen ? const TextStyle(fontSize: 12) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  final List<SummaryData> summaryData;
  final FinansesViewModel viewModel;

  const _SummaryView({required this.summaryData, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    if (summaryData.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noReceiptsAdded));
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = summaryData.fold(0.0, (sum, item) => sum + item.total);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
              '${l10n.finansesTotal}: ${NumberFormat.simpleCurrency(locale: 'pl_PL').format(total)}',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: summaryData
                        .map((d) => d.total)
                        .reduce((a, b) => a > b ? a : b) *
                    1.2,
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= summaryData.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                              viewModel
                                  .getFormattedDate(summaryData[index].label),
                              style: theme.textTheme.bodySmall),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == meta.max)
                          return const SizedBox();
                        return Text(
                            NumberFormat.compactSimpleCurrency(locale: 'pl_PL')
                                .format(value),
                            style: theme.textTheme.bodySmall);
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: summaryData
                            .map((d) => d.total)
                            .reduce((a, b) => a > b ? a : b) /
                        4,
                    getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          strokeWidth: 1,
                        )),
                barGroups: summaryData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                          toY: data.total,
                          color: theme.colorScheme.primary,
                          width: 16,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllReceiptsView extends StatelessWidget {
  final ScrollController controller;
  final FinansesViewModel viewModel;

  const _AllReceiptsView({required this.controller, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final receipts = viewModel.receipts;

    if (receipts.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noReceiptsAdded));
    }

    return ListView.builder(
      controller: controller,
      itemCount: receipts.length + (viewModel.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == receipts.length) {
          return viewModel.isLoadingMore
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CustomLoader(size: 40),
                ))
              : const SizedBox();
        }

        final receipt = receipts[index];
        return ListTile(
          leading: const Icon(Icons.receipt_long),
          title: Text(receipt.storeName),
          subtitle: Text(
            DateFormat.yMd(Intl.systemLocale).format(receipt.dateShopping),
          ),
          trailing: Text(
            NumberFormat.simpleCurrency(locale: 'pl_PL')
                .format(receipt.totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // TODO: Nawigacja do szczegółów paragonu
          },
        );
      },
    );
  }
}
