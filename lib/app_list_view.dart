import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppListView extends StatefulWidget {
  final EdgeInsets? padding;
  final Axis scrollDirection;
  final int itemCount;
  final NullableIndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder separatorBuilder;
  final Function()? refresh;
  final VoidCallback? loadMore;
  final bool isLoadMore;
  final bool isLoading;
  final bool shrinkWrap;
  final String? emptyMessage;

  const AppListView({
    super.key,
    this.padding,
    this.scrollDirection = Axis.vertical,
    required this.itemCount,
    required this.itemBuilder,
    required this.separatorBuilder,
    this.refresh,
    this.loadMore,
    this.isLoadMore = false,
    this.isLoading = false,
    this.shrinkWrap = true,
    this.emptyMessage,
  });

  @override
  State<StatefulWidget> createState() {
    return _AppListViewState();
  }
}

class _AppListViewState extends State<AppListView>
    with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Add listener to scroll controller
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        // Trigger loadMore when scrolled to the bottom
        if (!widget.isLoadMore) widget.loadMore?.call();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return widget.itemCount > 0
        ? RefreshIndicator(
      onRefresh: () async {
        widget.refresh?.call();
      },
      child: Stack(
        children: [
          if (widget.isLoading) ...[
            const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator())
          ] else ...[
            widget.itemCount == 0
                ? _emptyView()
                : ListView.separated(
              controller: _scrollController,
              shrinkWrap: widget.shrinkWrap,
              padding: widget.padding ?? EdgeInsets.zero,
              scrollDirection: widget.scrollDirection,
              itemCount: widget.itemCount,
              separatorBuilder: widget.separatorBuilder,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: widget.itemBuilder,
            ),
            widget.isLoadMore
                ? Align(
              alignment: widget.scrollDirection == Axis.vertical
                  ? Alignment.bottomCenter
                  : Alignment.centerRight,
              child: _buildLoading(),
            )
                : const SizedBox()
          ]
        ],
      ),
    )
        : LayoutBuilder(
        builder: (context, constraints) => RefreshIndicator(
          onRefresh: () async {
            widget.refresh?.call();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight,
              ),
              child: Center(
                child: Text(
                  "No data",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ));
    // : RefreshIndicator(
    //     onRefresh: () async {
    //       widget.refresh?.call();
    //     },
    //     child: const SingleChildScrollView(
    //         physics: AlwaysScrollableScrollPhysics(), child: EmptyData()));
  }

  Widget _buildLoading() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: Colors.white70),
      child: const Center(
          child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ))),
    );
  }

  Widget _emptyView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          (((Get.height - 352) / 2) - 32).toInt() > 0
              ? SizedBox(
              height: (((Get.height - 352) / 2) - 32).toInt().toDouble())
              : const SizedBox(),
          Center(
              child: Text(
                widget.emptyMessage ?? "Không có dữ liệu",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              )),
        ],
      ),
    );
  }
}
