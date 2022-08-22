import 'package:ask_me/models/field.dart';
import 'package:ask_me/models/http_exception.dart';
import 'package:ask_me/models/specialization.dart';
import 'package:ask_me/providers/field_provider.dart';
import 'package:ask_me/providers/specialization_provider.dart';
import 'package:ask_me/providers/user_provider.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/error_dialog.dart';
import 'package:ask_me/widgets/loading_widget.dart';
import 'package:ask_me/widgets/not_signed_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:web_socket_channel/io.dart';

import '../widgets/confirm_delete_dialog.dart';
import '../widgets/paginationed_drop_dwon.dart';
import '../widgets/screen_bottom_navigation_bar.dart';
import 'favorite_screen.dart';

class AddSpecializationScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;
  final Specialization? editedSpecialization;
  const AddSpecializationScreen(this.channel,
      {Key? key, this.editedSpecialization})
      : super(key: key);

  @override
  State<AddSpecializationScreen> createState() =>
      _AddSpecializationScreenState();
}

class _AddSpecializationScreenState extends State<AddSpecializationScreen> {
  final _arabicTitleController = TextEditingController();
  final _englishTitleController = TextEditingController();
  final _englishFoucsNod = FocusNode();

  List<Field> _filedsList = [];
  Field? _selectedFiledValue;
  var prevSearchKey = '';

  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();

    if (widget.editedSpecialization != null) {
      _isEdit = true;
      _arabicTitleController.text = widget.editedSpecialization!.nameAr;
      _englishTitleController.text = widget.editedSpecialization!.nameEn;
      var field = Field(
          widget.editedSpecialization!.fieldId,
          widget.editedSpecialization!.fieldNameAr,
          widget.editedSpecialization!.fieldNameEn);
      Provider.of<FieldProvider>(context, listen: false).checkAndAdd(field);
      _selectedFiledValue = field;
    }
  }

  Future<void> _saveSpecialization(UserProvider userProv) async {
    if (_selectedFiledValue == null ||
        _arabicTitleController.text.isEmpty ||
        _englishTitleController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_isEdit &&
        (_arabicTitleController.text == widget.editedSpecialization!.nameAr &&
            _englishTitleController.text ==
                widget.editedSpecialization!.nameEn &&
            _selectedFiledValue!.id == widget.editedSpecialization!.fieldId)) {
      Navigator.of(context).pop();
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      var specializationProvider =
          Provider.of<SpecializationProvider>(context, listen: false);

      if (_isEdit) {
        await specializationProvider.updateSpecialization(
          widget.editedSpecialization!.id,
          userProv.token,
          arabicTitle:
              _arabicTitleController.text == widget.editedSpecialization!.nameAr
                  ? null
                  : _arabicTitleController.text,
          englishTitle: _englishTitleController.text ==
                  widget.editedSpecialization!.nameEn
              ? null
              : _englishTitleController.text,
          fieldId:
              _selectedFiledValue!.id == widget.editedSpecialization!.fieldId
                  ? null
                  : _selectedFiledValue!.id,
          fieldNameAr:
              _selectedFiledValue!.id == widget.editedSpecialization!.fieldId
                  ? null
                  : _selectedFiledValue!.nameAr,
          fieldNameEn:
              _selectedFiledValue!.id == widget.editedSpecialization!.fieldId
                  ? null
                  : _selectedFiledValue!.nameEn,
        );
      } else {
        await specializationProvider.addSpecialization(
          arabicTitle: _arabicTitleController.text,
          englishTitle: _englishTitleController.text,
          fieldId: _selectedFiledValue!.id,
          fieldNameAr: _selectedFiledValue!.nameAr,
          fieldNameEn: _selectedFiledValue!.nameEn,
          token: userProv.token,
        );
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              _isEdit ? 'specialization_edited'.tr : 'specialization_added'.tr),
          duration: const Duration(seconds: 2)));

      Navigator.of(context).pop();
    } on HttpException catch (_) {
      showErrorDialog(_isEdit ? 'edited_failed'.tr : 'add_failed'.tr, context);
    } catch (er) {
      showErrorDialog(_isEdit ? 'edited_failed'.tr : 'add_failed'.tr, context);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteSpecialization() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    final token = Provider.of<UserProvider>(context, listen: false).token;

    try {
      await Provider.of<SpecializationProvider>(context, listen: false)
          .deleteSpecialization(
        widget.editedSpecialization!.id,
        token,
      );
      Navigator.of(context).pop();
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
    final userProv = Provider.of<UserProvider>(context);
    final fieldsProvider = Provider.of<FieldProvider>(context);
    if (_filedsList.isEmpty) {
      _filedsList = fieldsProvider.fields;
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: ScreenBottomNavigationBar(
        onTap: () => _saveSpecialization(userProv),
        text: _isEdit ? 'edit' : 'add',
        enabled: !_isLoading,
      ),
      appBar: AppBar(
        elevation: 1,
        title: Image.asset(
          Get.locale == const Locale('ar')
              ? 'assets/images/logo_text_ar.png'
              : 'assets/images/logo_text_en.png',
          fit: BoxFit.contain,
          width: 120,
          height: AppBar().preferredSize.height,
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              if (_isLoading) return;
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 32,
            )),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScreen(widget.channel))),
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: () => userProv.userIsSignd()
                  ? Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FavoriteScreen(widget.channel)))
                  : notSignedDialog(context),
              icon: const Icon(Icons.favorite)),
        ],
      ),
      body: SafeArea(
          child: WillPopScope(
        onWillPop: () async {
          if (_isLoading) return false;
          return true;
        },
        child: _isLoading
            ? const LoadingWidget()
            : Column(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            right: (Get.locale == const Locale('ar')) ? 8 : 0,
                            left: (Get.locale == const Locale('ar')) ? 0 : 8,
                            top: 8,
                            bottom: 8,
                          ),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: const Border(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0),
                              )),
                          child: Text(
                            _isEdit
                                ? 'edit_specialization'.tr
                                : 'add_specialization'.tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          width: 150,
                          padding: EdgeInsets.only(
                            left: Get.locale == const Locale('ar') ? 0 : 8,
                            right: Get.locale == const Locale('ar') ? 8 : 0,
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.5,
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                            ),
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: PaginationedDropDwon<int>(
                            initList: fieldsProvider.fields
                                .map((item) => SearchableDropdownMenuItem(
                                    value: item.id,
                                    label: Get.locale == const Locale('ar')
                                        ? item.nameAr
                                        : item.nameEn,
                                    child: Text(
                                        Get.locale == const Locale('ar')
                                            ? item.nameAr
                                            : item.nameEn,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal))))
                                .toList(),
                            selectedItem: _selectedFiledValue == null
                                ? null
                                : SearchableDropdownMenuItem(
                                    value: _selectedFiledValue!.id,
                                    label: Get.locale == const Locale('ar')
                                        ? _selectedFiledValue!.nameAr
                                        : _selectedFiledValue!.nameEn,
                                    child: Text(
                                        Get.locale == const Locale('ar')
                                            ? _selectedFiledValue!.nameAr
                                            : _selectedFiledValue!.nameEn,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                fontSize: 14,
                                                fontWeight:
                                                    FontWeight.normal))),
                            searchHintText: 'search'.tr,
                            hintText: Text(
                              'choose_field'.tr,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline6!
                                  .copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal),
                            ),
                            noRecordText: 'no_items_to_show'.tr,
                            margin: const EdgeInsets.all(15),
                            paginatedRequest:
                                (int page, String? searchKey) async {
                              _filedsList = searchKey == null
                                  ? await fieldsProvider.fetchAndSetFields(
                                      userProv.token,
                                      page,
                                    )
                                  : await fieldsProvider.search(
                                      userProv.token, searchKey, page,
                                      isRefresh: prevSearchKey != searchKey);
                              if (searchKey != null) {
                                prevSearchKey = searchKey;
                              }
                              if (mounted) {
                                setState(() {
                                  _filedsList;
                                });
                              }
                              return _filedsList
                                  .map((item) => SearchableDropdownMenuItem(
                                      value: item.id,
                                      label: Get.locale == const Locale('ar')
                                          ? item.nameAr
                                          : item.nameEn,
                                      child: Text(
                                          Get.locale == const Locale('ar')
                                              ? item.nameAr
                                              : item.nameEn,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .copyWith(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.normal))))
                                  .toList();
                            },
                            requestItemCount: fieldsProvider.limit + 1,
                            onChanged: (int? value) {
                              debugPrint('$value');
                              prevSearchKey = '';

                              if (value == null) {
                                _selectedFiledValue = null;
                              } else {
                                _selectedFiledValue = _filedsList.firstWhere(
                                    (element) => element.id == value);
                              }
                              if (mounted) {
                                setState(() {
                                  _selectedFiledValue;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: Get.locale == const Locale('ar') ? 0 : 8,
                            right: Get.locale == const Locale('ar') ? 8 : 0,
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 30),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'arabic_title'.tr,
                                focusedBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            controller: _arabicTitleController,
                            keyboardType: TextInputType.name,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_englishFoucsNod),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: Get.locale == const Locale('ar') ? 0 : 8,
                            right: Get.locale == const Locale('ar') ? 8 : 0,
                          ),
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 8, bottom: 30),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            cursorColor: Theme.of(context).primaryColor,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'english_title'.tr,
                                focusedBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                )),
                            controller: _englishTitleController,
                            keyboardType: TextInputType.name,
                            focusNode: _englishFoucsNod,
                            onSubmitted: (_) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  //delete
                  _isEdit
                      ? TextButton.icon(
                          onPressed: () => confirmDeleteDialog(
                              context,
                              Get.locale == const Locale('ar')
                                  ? widget.editedSpecialization!.nameAr
                                  : widget.editedSpecialization!.nameEn,
                              () => deleteSpecialization()),
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
      )),
    );
  }
}
