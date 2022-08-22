import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';

// ignore: constant_identifier_names
enum SearcableDropdownState { Initial, Busy, Error, Loaded }

class SearcableDropdownController<T> {
  final ValueNotifier<SearcableDropdownState> state =
      ValueNotifier<SearcableDropdownState>(SearcableDropdownState.Initial);

  ScrollController scrollController = ScrollController();
  GlobalKey key = GlobalKey();
  FocusNode searchFocusNode = FocusNode();

  final ValueNotifier<SearchableDropdownMenuItem<T>?> selectedItem =
      ValueNotifier<SearchableDropdownMenuItem<T>?>(null);

  final ValueNotifier<List<SearchableDropdownMenuItem<T>>?> paginatedItemList =
      ValueNotifier<List<SearchableDropdownMenuItem<T>>?>(null);

  late Future<List<SearchableDropdownMenuItem<T>>?> Function(
      int page, String? key)? paginatedRequest;
  late Future<List<SearchableDropdownMenuItem<T>>?> Function()? futureRequest;

  late int requestItemCount;

  late List<SearchableDropdownMenuItem<T>>? items;

  ValueNotifier<List<SearchableDropdownMenuItem<T>>?> searchedItems =
      ValueNotifier<List<SearchableDropdownMenuItem<T>>?>(null);

  bool _hasMoreData = true;
  int _page = 1;
  String searchText = '';

  void onInit() {
    scrollController.addListener(() {
      if (scrollController.position.atEdge &&
          scrollController.position.pixels != 0) {
        if (searchText.isNotEmpty) {
          getItemsWithPaginatedRequest(page: _page, key: searchText);
        } else {
          getItemsWithPaginatedRequest(page: _page);
        }
      }
    });
  }

  void dispose() {
    searchFocusNode.dispose();
    scrollController.dispose();
  }

  Future<void> getItemsWithPaginatedRequest(
      {required int page, String? key, bool isNewSearch = false}) async {
    if (isNewSearch) {
      _page = 0;
      paginatedItemList.value = null;
      _hasMoreData = true;
    }

    if (!_hasMoreData) return;
    state.value = SearcableDropdownState.Busy;
    final response = await paginatedRequest!(page, key);
    if (response is! List<SearchableDropdownMenuItem<T>>) return;

    paginatedItemList.value ??= [];
    paginatedItemList.value = response;
    if (response.length < requestItemCount) {
      _hasMoreData = false;
    } else {
      _page = _page + 1;
    }
    state.value = SearcableDropdownState.Loaded;
    debugPrint('searchable dropdown has more data: $_hasMoreData');
  }

  void fillSearchedList(String? value) {
    if (value == null || value.isEmpty) searchedItems.value = items;

    List<SearchableDropdownMenuItem<T>> tempList = [];
    for (var element in items ?? <SearchableDropdownMenuItem<T>>[]) {
      if (element.label.containsWithTurkishChars(value!)) tempList.add(element);
    }
    searchedItems.value = tempList;
  }
}

extension CustomStringExtension on String {
  bool containsWithTurkishChars(String key) {
    return replaceTurkishChars.contains(key.replaceTurkishChars);
  }

  String get replaceTurkishChars {
    var replaced = toLowerCase();
    replaced = replaced.replaceAll('ş', 's');
    replaced = replaced.replaceAll('ı', 'i');
    replaced = replaced.replaceAll('ğ', 'g');
    replaced = replaced.replaceAll('ç', 'c');
    replaced = replaced.replaceAll('ö', 'o');
    replaced = replaced.replaceAll('ü', 'u');
    return replaced;
  }
}
