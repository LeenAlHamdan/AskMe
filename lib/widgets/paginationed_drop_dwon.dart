import 'package:ask_me/widgets/searchable_dropdown_controller.dart';
import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

import 'custom_inkwell.dart';
import 'custom_search_bar.dart';

class PaginationedDropDwon<T> extends StatefulWidget {
  final EdgeInsetsGeometry? margin;
  final Text hintText;
  final String? searchHintText;
  final String? noRecordText;
  final void Function(T? value)? onChanged;
  final Future<List<SearchableDropdownMenuItem<T>>?> Function(
      int page, String? searchKey)? paginatedRequest;
  final int? requestItemCount;
  final List<SearchableDropdownMenuItem<T>> initList;
  final SearchableDropdownMenuItem<T>? selectedItem;
  const PaginationedDropDwon(
      {Key? key,
      required this.initList,
      this.onChanged,
      this.margin,
      this.selectedItem,
      required this.hintText,
      this.searchHintText,
      this.paginatedRequest,
      this.requestItemCount,
      this.noRecordText})
      : super(key: key);

  @override
  State<PaginationedDropDwon<T>> createState() =>
      _PaginationedDropDwonState<T>();
}

class _PaginationedDropDwonState<T> extends State<PaginationedDropDwon<T>> {
  late ScrollController _scrollControllerFields;

  late SearcableDropdownController<T> controller;

  @override
  void dispose() {
    _scrollControllerFields.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = SearcableDropdownController<T>();
    controller.paginatedRequest = widget.paginatedRequest;
    controller.requestItemCount = widget.requestItemCount ?? 0;
    controller.items = widget.initList;
    if (widget.selectedItem != null) {
      controller.selectedItem.value = widget.selectedItem;
    }
    controller.searchedItems.value = [];
    // widget.initList;
    if (widget.initList != []) {
      controller.onInit();
    }

    _scrollControllerFields = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  @override
  void didChangeDependencies() {
    controller.selectedItem.value = widget.selectedItem;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (controller.selectedItem.value != widget.selectedItem) {
      controller.selectedItem.value = widget.selectedItem;
    }
    return SizedBox(
      key: controller.key,
      width: MediaQuery.of(context).size.width,
      child: buildDropDown(context, controller),
    );
  }

  GestureDetector buildDropDown(
      BuildContext context, SearcableDropdownController<T> controller) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _dropDownOnTab(context, controller);
      },
      child: Padding(
        padding: widget.margin ??
            EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
        child: Row(
          children: [
            Expanded(child: dropDownText(controller)),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: MediaQuery.of(context).size.height * 0.033,
            ),
          ],
        ),
      ),
    );
  }

  _dropDownOnTab(
      BuildContext context, SearcableDropdownController<T> controller) {
    bool isReversed = false;
    double? possitionFromBottom = controller.key.globalPaintBounds != null
        ? MediaQuery.of(context).size.height -
            controller.key.globalPaintBounds!.bottom
        : null;
    double alertDialogMaxHeight = MediaQuery.of(context).size.height * 0.3;
    double? dialogPossitionFromBottom = possitionFromBottom != null
        ? possitionFromBottom - alertDialogMaxHeight
        : null;
    if (dialogPossitionFromBottom != null) {
      //Dialog ekrana sığmıyor ise reverseler
      //If dialog couldn't fit the screen, reverse it
      if (dialogPossitionFromBottom <= 0) {
        isReversed = true;
        dialogPossitionFromBottom += alertDialogMaxHeight +
            controller.key.globalPaintBounds!.height +
            MediaQuery.of(context).size.height * 0.005;
      } else {
        dialogPossitionFromBottom -= MediaQuery.of(context).size.height * 0.005;
      }
    }
    if (controller.items == null || controller.items!.isEmpty) {
      controller.getItemsWithPaginatedRequest(page: 0, isNewSearch: true);
    } else {
      controller.paginatedItemList.value = controller.items;

      /* if (widget.paginatedRequest != null)
        controller.paginatedItemList.value = controller.items;
      */
      //  controller.searchedItems.value = controller.items;
    }
    //Hesaplamaları yaptıktan sonra dialogu göster
    //Show the dialog
    showDialog(
      context: context,
      builder: (context) {
        double? reCalculatePosition = dialogPossitionFromBottom;
        double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        //Keyboard varsa digalogu ofsetler
        //If keyboard pushes the dialog, recalculate the dialog's possition.
        if (reCalculatePosition != null &&
            reCalculatePosition <= keyboardHeight) {
          reCalculatePosition =
              (keyboardHeight - reCalculatePosition) + reCalculatePosition;
        }
        return Padding(
          padding: EdgeInsets.only(
              bottom: reCalculatePosition ?? 0,
              left: MediaQuery.of(context).size.height * 0.02,
              right: MediaQuery.of(context).size.height * 0.02),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: alertDialogMaxHeight,
                child: _buildStatefullDropdownCard(
                    context, controller, isReversed),
              ),
            ],
          ),
        );
      },
      barrierDismissible: true,
      barrierColor: Colors.transparent,
    );
  }

  Widget dropDownText(SearcableDropdownController<T> controller) {
    return ValueListenableBuilder(
      valueListenable: controller.selectedItem,
      builder: (context, SearchableDropdownMenuItem<T>? selectedItem, child) =>
          selectedItem?.child ??
          (selectedItem?.label != null
              ? Text(
                  selectedItem!.label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: widget.hintText.style!,
                )
              : widget.hintText) /* ??
          const SizedBox.shrink() */
      ,
    );
  }

  Widget _buildStatefullDropdownCard(BuildContext context,
      SearcableDropdownController<T> controller, bool isReversed) {
    return Column(
      mainAxisAlignment:
          isReversed ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(
                    MediaQuery.of(context).size.height * 0.015))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection:
                  isReversed ? VerticalDirection.up : VerticalDirection.down,
              children: [
                buildSearchBar(context, controller),
                Flexible(
                  child: buildListView(controller, isReversed),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Padding buildSearchBar(
      BuildContext context, SearcableDropdownController controller) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
      child: CustomSearchBar(
        focusNode: controller.searchFocusNode,
        changeCompletionDelay: const Duration(milliseconds: 200),
        hintText: widget.searchHintText ?? 'Search',
        isOutlined: true,
        leadingIcon: Icon(Icons.search,
            size: MediaQuery.of(context).size.height * 0.033),
        onChangeComplete: (value) {
          controller.searchText = value;
          /* if (controller.items != null) {
            controller.fillSearchedList(value);
            return;
          } */

          if (value == '') {
            controller.getItemsWithPaginatedRequest(page: 0, isNewSearch: true);
          } else {
            controller.getItemsWithPaginatedRequest(
                page: 0, key: value, isNewSearch: true);
          }
        },
      ),
    );
  }

  Widget buildListView(
      SearcableDropdownController<T> controller, bool isReversed) {
    return ValueListenableBuilder(
      valueListenable:
          (/* widget.paginatedRequest != null
          ? controller.paginatedItemList
          :  */
              controller.paginatedItemList),
      builder: (context, List<SearchableDropdownMenuItem<T>>? itemList,
              child) =>
          itemList == null
              ? const Center(child: CircularProgressIndicator())
              : itemList.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.015),
                      child: Text(widget.noRecordText ?? 'No record'),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      controller: controller.scrollController,
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: _listviewPadding(context, isReversed),
                        itemCount: itemList.length + 1,
                        shrinkWrap: true,
                        reverse: isReversed,
                        itemBuilder: (context, index) {
                          if (index < itemList.length) {
                            final item = itemList.elementAt(index);
                            return CustomInkwell(
                              child: item.child,
                              onTap: () {
                                controller.selectedItem.value = item;
                                if (widget.onChanged != null) {
                                  widget.onChanged!(item.value);
                                }
                                Navigator.pop(context);
                                if (item.onTap != null) item.onTap!();
                              },
                            );
                          } else {
                            return ValueListenableBuilder(
                              valueListenable: controller.state,
                              builder: (context, SearcableDropdownState state,
                                      child) =>
                                  state == SearcableDropdownState.Busy
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : const SizedBox(),
                            );
                          }
                        },
                      ),
                    ),
    );
  }

  EdgeInsets _listviewPadding(BuildContext context, bool isReversed) {
    return EdgeInsets.only(
        left: MediaQuery.of(context).size.height * 0.01,
        right: MediaQuery.of(context).size.height * 0.01,
        bottom: !isReversed ? MediaQuery.of(context).size.height * 0.06 : 0,
        top: isReversed ? MediaQuery.of(context).size.height * 0.06 : 0);
  }
}

extension CustomGlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}
