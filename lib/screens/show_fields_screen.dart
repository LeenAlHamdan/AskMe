// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'package:ask_me/widgets/load_more_widget.dart';

import '../models/http_exception.dart';
import '../providers/field_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../models/field.dart';
import '../providers/user_provider.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_widget.dart';
import '../widgets/no_items_widget.dart';

class ShowFieldsScreen extends StatefulWidget {
  static const routeName = '/show-fields';

  const ShowFieldsScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ShowFieldsScreen> createState() => _ShowFieldsScreenState();
}

class _ShowFieldsScreenState extends State<ShowFieldsScreen> {
  late ScrollController _scrollControllerFields;

  bool loadMoreFields = false;
  bool canLoadFields = true;
  int pageNumFields = 0;

  bool _isRefresh = false;
  bool _isLoading = false;
  bool _isLoadingAdd = false;

  final _arabicTitleController = TextEditingController();
  final _englishTitleController = TextEditingController();
  final _englishFoucsNod = FocusNode();

  Field? editedField;

  void addFieldDialog({bool isEdit = false}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (cox) {
          return AlertDialog(
            backgroundColor: Theme.of(context).backgroundColor,
            scrollable: true,
            title: Text(isEdit ? 'edit_field'.tr : 'add_field'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        labelText: 'arabic_title'.tr,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        )),
                    controller: _arabicTitleController,
                    keyboardType: TextInputType.name,
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_englishFoucsNod),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                    left: 8,
                    right: 8,
                  ),
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    cursorColor: Theme.of(context).primaryColor,
                    decoration: InputDecoration(
                        labelText: 'english_title'.tr,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        )),
                    controller: _englishTitleController,
                    focusNode: _englishFoucsNod,
                    keyboardType: TextInputType.name,
                    onSubmitted: (_) {
                      Navigator.pop(context);

                      _saveField(isEdit: isEdit);
                    },
                  ),
                ),
                isEdit
                    ? TextButton.icon(
                        onPressed: () => confirmDeleteDialog(
                            context,
                            Get.locale == const Locale('ar')
                                ? editedField!.nameAr
                                : editedField!.nameEn,
                            () => deleteField(field: editedField!.id)),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'delete'.tr,
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      )
                    : Container(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  await _saveField(isEdit: isEdit);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'save'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _arabicTitleController.clear();
                  _englishTitleController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    border: Border.all(color: Theme.of(context).primaryColor),
                  ),
                  child: Text(
                    'cancel'.tr,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _saveField({bool isEdit = false}) async {
    if (_arabicTitleController.text.isEmpty ||
        _arabicTitleController.text.removeAllWhitespace.isEmpty ||
        _englishTitleController.text.isEmpty ||
        _englishTitleController.text.removeAllWhitespace.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context)
          .then((value) => addFieldDialog(isEdit: isEdit));
      return;
    }
    if (mounted) {
      setState(() {
        _isLoadingAdd = true;
      });
    }
    final userProv = Provider.of<UserProvider>(context, listen: false);

    try {
      if (isEdit) {
        await Provider.of<FieldProvider>(context, listen: false).updateField(
          editedField!.id,
          userProv.token,
          arabicTitle: _arabicTitleController.text != editedField!.nameAr
              ? _arabicTitleController.text
              : null,
          englishTitle: _englishTitleController.text != editedField!.nameEn
              ? _englishTitleController.text
              : null,
        );
      } else {
        await Provider.of<FieldProvider>(context, listen: false).addField(
          _arabicTitleController.text,
          _englishTitleController.text,
          userProv.token,
        );
      }

      _arabicTitleController.clear();
      _englishTitleController.clear();
    } on HttpException catch (_) {
      showErrorDialog(isEdit ? 'edited_failed'.tr : 'add_failed'.tr, context)
          .then((_) {
        if (mounted) {
          setState(() {
            _isLoadingAdd = false;
          });
        }
      });
    } catch (er) {
      showErrorDialog(isEdit ? 'edited_failed'.tr : 'add_failed'.tr, context)
          .then((_) {
        if (mounted) {
          setState(() {
            _isLoadingAdd = false;
          });
        }
      });
    }
    if (mounted) {
      setState(() {
        _isLoadingAdd = false;
      });
    }
  }

  Future<void> deleteField({int? field}) async {
    if (mounted) {
      setState(() {
        _isLoadingAdd = true;
      });
    }
    final token = Provider.of<UserProvider>(context, listen: false).token;

    try {
      await Provider.of<FieldProvider>(context, listen: false).deleteField(
        field ?? editedField!.id,
        token,
      );
      if (mounted) {
        setState(() {
          _isLoadingAdd = false;
        });
      }
    } on HttpException catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    } catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    }
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _isRefresh = true;
      });
    }
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;

      await Provider.of<FieldProvider>(context, listen: false)
          .fetchAndSetFields(token, 0, isRefresh: true);

      pageNumFields = 0;

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

  Future<void> _getFields() async {
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;

      await Provider.of<FieldProvider>(context, listen: false)
          .fetchAndSetFields(token, ++pageNumFields);
      canLoadFields = true;
    } on HttpException catch (error) {
      pageNumFields--;
      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreFields = false;
        });
      }
      throw error;
    } catch (error) {
      canLoadFields = true;
      pageNumFields--;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreFields = false;
        });
      }
      canLoadFields = true;

      throw error;
    }
  }

  @override
  void dispose() {
    _scrollControllerFields.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _scrollControllerFields = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    _scrollControllerFields.addListener(() {
      if (_scrollControllerFields.positions.first.atEdge) {
        if (_scrollControllerFields.positions.last.pixels ==
            _scrollControllerFields.positions.last.maxScrollExtent) {
          // You're at the bottom.
          if (canLoadFields) {
            if (mounted) {
              setState(() {
                loadMoreFields = true;
              });
            }
            if (mounted) {
              setState(() {
                loadMoreFields = true;
              });
            }
            canLoadFields = false;
            _getFields();
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

        await Provider.of<FieldProvider>(context, listen: false)
            .fetchAndSetFields(token, 0);
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

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar(
      title: Text(
        'fields'.tr,
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

    final _spinnerFieldsItems = Provider.of<FieldProvider>(context).fields;
    final userProv = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: appBar,
      body: _isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => _refresh(),
              child: SingleChildScrollView(
                controller: _scrollControllerFields,
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
                        userProv.isAdmin()
                            ? TextButton.icon(
                                onPressed: () => addFieldDialog(isEdit: false),
                                icon: Icon(
                                  Icons.add,
                                  size: 25,
                                  color: Theme.of(context).primaryColor,
                                ),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'add_field'.tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        _spinnerFieldsItems.isEmpty && !_isRefresh
                            ? const NoItemsWidget()
                            : ListView.builder(
                                shrinkWrap: true,
                                primary: false,
                                controller: _scrollControllerFields,
                                itemCount: _spinnerFieldsItems.length,
                                padding: const EdgeInsets.all(0),
                                itemBuilder: (_, index) => FieldItem(
                                    onEditPress: () {
                                      _arabicTitleController.text =
                                          _spinnerFieldsItems[index].nameAr;
                                      _englishTitleController.text =
                                          _spinnerFieldsItems[index].nameEn;

                                      editedField = _spinnerFieldsItems[index];
                                      addFieldDialog(
                                        isEdit: true,
                                      );
                                    },
                                    onDeletePress: () => confirmDeleteDialog(
                                        context,
                                        Get.locale == const Locale('ar')
                                            ? _spinnerFieldsItems[index].nameAr
                                            : _spinnerFieldsItems[index].nameEn,
                                        () => deleteField(
                                            field:
                                                _spinnerFieldsItems[index].id)),
                                    fieldItem: _spinnerFieldsItems[index],
                                    isAdmin: userProv.isAdmin()),
                              ),
                        _isLoadingAdd ? const LoadMoreWidget() : Container(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class FieldItem extends StatelessWidget {
  const FieldItem({
    Key? key,
    required this.fieldItem,
    required this.isAdmin,
    required this.onEditPress,
    required this.onDeletePress,
  }) : super(key: key);

  final Field fieldItem;
  final bool isAdmin;
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
                    ? fieldItem.nameAr
                    : fieldItem.nameEn,
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
