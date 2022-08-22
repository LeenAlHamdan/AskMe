// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'package:ask_me/widgets/load_more_widget.dart';
import 'package:web_socket_channel/io.dart';

import '../models/http_exception.dart';
import '../models/specialization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../providers/specialization_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_widget.dart';
import '../widgets/no_items_widget.dart';
import 'add_specialization_screen.dart';

class ShowSpecializationsScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;

  const ShowSpecializationsScreen(
    this.channel, {
    Key? key,
  }) : super(key: key);

  @override
  State<ShowSpecializationsScreen> createState() =>
      _ShowSpecializationsScreenState();
}

class _ShowSpecializationsScreenState extends State<ShowSpecializationsScreen> {
  late ScrollController _scrollControllerSpecializations;

  bool loadMoreSpecializations = false;
  bool canLoadSpecializations = true;
  int pageNumSpecializations = 0;

  bool _isRefresh = false;
  bool _isLoading = false;

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isRefresh = true;
      });
    }
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;

      await Provider.of<SpecializationProvider>(context, listen: false)
          .fetchAndSetSpecializations(token, 0, isRefresh: true);

      pageNumSpecializations = 0;

      if (mounted) {
        setState(() {
          _isRefresh = false;
        });
      }
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          _isRefresh = false;
        });
      }
      throw HttpException('error');
    } catch (error) {
      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          _isRefresh = false;
        });
      }
      throw error;
    }
  }

  Future<void> _getSpecializations() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;

      await Provider.of<SpecializationProvider>(context, listen: false)
          .fetchAndSetSpecializations(token, ++pageNumSpecializations);
      canLoadSpecializations = true;
    } on HttpException catch (error) {
      pageNumSpecializations--;
      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecializations = false;
        });
      }
      throw error;
    } catch (error) {
      canLoadSpecializations = true;
      pageNumSpecializations--;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecializations = false;
        });
      }
      canLoadSpecializations = true;

      throw error;
    }
  }

  @override
  void dispose() {
    _scrollControllerSpecializations.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollControllerSpecializations = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    _scrollControllerSpecializations.addListener(() {
      if (_scrollControllerSpecializations.positions.first.atEdge) {
        if (_scrollControllerSpecializations.positions.last.pixels ==
            _scrollControllerSpecializations.positions.last.maxScrollExtent) {
          // You're at the bottom.
          if (canLoadSpecializations) {
            if (mounted) {
              setState(() {
                loadMoreSpecializations = true;
              });
            }
            if (mounted) {
              setState(() {
                loadMoreSpecializations = true;
              });
            }
            canLoadSpecializations = false;
            _getSpecializations();
          }
        } else {
          // You're at the top.
        }
      }
    });
    Future.delayed(Duration.zero).then((value) async {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }
      try {
        final token = Provider.of<UserProvider>(context, listen: false).token;

        await Provider.of<SpecializationProvider>(context, listen: false)
            .fetchAndSetSpecializations(token, 0, isRefresh: true);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } on HttpException catch (error) {
        showErrorDialog('error'.tr, context);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw error;
      } catch (error) {
        showErrorDialog('error'.tr, context);
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        throw error;
      }
    });
  }

  Future<void> deleteSpecialization(int specializationId) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final token = Provider.of<UserProvider>(context, listen: false).token;

    try {
      await Provider.of<SpecializationProvider>(context, listen: false)
          .deleteSpecialization(
        specializationId,
        token,
      );
    } on HttpException catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    } catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(
        'specializations'.tr,
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: const Icon(
          Icons.arrow_back_ios_outlined,
          size: 32,
        ),
      ),
      elevation: 2,
      centerTitle: true,
    );

    final _spinnerSpecializationsItems =
        Provider.of<SpecializationProvider>(context).specializations;

    return Scaffold(
      appBar: appBar,
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => _refresh(),
              child: SingleChildScrollView(
                controller: _scrollControllerSpecializations,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width,
                    minHeight: MediaQuery.of(context).size.height -
                        appBar.preferredSize.height,
                  ),
                  child: Container(
                    color: Theme.of(context).backgroundColor,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                      top: 15,
                      left: Get.locale == const Locale('ar') ? 15 : 0,
                      right: Get.locale == const Locale('ar') ? 15 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) =>
                                      AddSpecializationScreen(widget.channel))),
                          icon: Icon(
                            Icons.add,
                            size: 25,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'add_specialization'.tr,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                        _spinnerSpecializationsItems.isEmpty && !_isRefresh
                            ? const NoItemsWidget()
                            : ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                controller: _scrollControllerSpecializations,
                                itemCount: _spinnerSpecializationsItems.length,
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (_, index) => SpecializationItem(
                                  onEditPress: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AddSpecializationScreen(
                                                widget.channel,
                                                editedSpecialization:
                                                    _spinnerSpecializationsItems[
                                                        index],
                                              ))),
                                  onDeletePress: () => confirmDeleteDialog(
                                      context,
                                      Get.locale == const Locale('ar')
                                          ? _spinnerSpecializationsItems[index]
                                              .nameAr
                                          : _spinnerSpecializationsItems[index]
                                              .nameEn,
                                      () => deleteSpecialization(
                                          _spinnerSpecializationsItems[index]
                                              .id)),
                                  specializationItem:
                                      _spinnerSpecializationsItems[index],
                                ),
                              ),
                        (loadMoreSpecializations)
                            ? const LoadMoreWidget()
                            : Container()
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class SpecializationItem extends StatelessWidget {
  const SpecializationItem({
    Key? key,
    required this.specializationItem,
    required this.onEditPress,
    required this.onDeletePress,
  }) : super(key: key);

  final Specialization specializationItem;
  final Function onEditPress;
  final Function onDeletePress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Get.locale == const Locale('ar')
                    ? specializationItem.nameAr
                    : specializationItem.nameEn,
                style: TextStyle(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 18,
                ),
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: IconButton(
                  onPressed: () => onEditPress(),
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: IconButton(
                  onPressed: () => onDeletePress(),
                  icon: Icon(
                    Icons.delete,
                    color: Theme.of(context).primaryColor,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
