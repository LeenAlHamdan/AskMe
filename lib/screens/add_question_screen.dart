import 'package:ask_me/models/field.dart';
import 'package:ask_me/models/http_exception.dart';
import 'package:ask_me/providers/field_provider.dart';
import 'package:ask_me/providers/question_provider.dart';
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

import '../models/question.dart';
import '../widgets/paginationed_drop_dwon.dart';
import '../widgets/screen_bottom_navigation_bar.dart';
import 'favorite_screen.dart';

class AddQuestionScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;

  final QuestionFullData? editedQuestion;
  const AddQuestionScreen(this.channel, {Key? key, this.editedQuestion})
      : super(key: key);

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  //List<Field> _spinnerFieldItems = [];

  List<Field> _filedsList = [];
  Field? _selectedFiledValue;
  var prevSearchKey = '';

  late ScrollController _scrollController;
  final _contentFoucsNod = FocusNode();

  bool _isLoading = false;
  bool _isEdit = false;

  String _enterdSubject = '';
  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    if (widget.editedQuestion != null) {
      _isEdit = true;
      _subjectController.text = widget.editedQuestion!.subject;
      _contentController.text = widget.editedQuestion!.question;
      var field = Field(
          widget.editedQuestion!.fieldId,
          widget.editedQuestion!.fieldNameAr,
          widget.editedQuestion!.fieldNameEn);
      Provider.of<FieldProvider>(context, listen: false).checkAndAdd(field);
      _selectedFiledValue = field;
    }
  }

  Future<void> _refreshQuestion() async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;

      await Provider.of<QuestionProvider>(context, listen: false)
          .fetchAndSetQuestions(
        token,
        0,
        isRefresh: true,
      );
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);

      throw HttpException('error');
    } catch (error) {
      showErrorDialog('error'.tr, context);
      rethrow;
    }
  }

  Future<void> _saveQuestion(UserProvider userProv) async {
    if (_selectedFiledValue == null ||
        _subjectController.text.isEmpty ||
        _contentController.text.isEmpty) {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }

    if (_isEdit &&
        (_contentController.text == widget.editedQuestion!.question &&
            _subjectController.text == widget.editedQuestion!.subject &&
            _selectedFiledValue!.id == widget.editedQuestion!.fieldId)) {
      Navigator.of(context).pop();
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      var questionProvider =
          Provider.of<QuestionProvider>(context, listen: false);

      if (_isEdit) {
        await questionProvider.updateQuestion(
          widget.editedQuestion!.id,
          userProv.token,
          subject: _subjectController.text == widget.editedQuestion!.subject
              ? null
              : _subjectController.text,
          fieldId: _selectedFiledValue!.id == widget.editedQuestion!.fieldId
              ? null
              : _selectedFiledValue!.id,
          question: _contentController.text == widget.editedQuestion!.question
              ? null
              : _contentController.text,
        );
      } else {
        await questionProvider.addQuestion(
          _subjectController.text,
          _selectedFiledValue!.id,
          _contentController.text,
          userProv.token,
        );
      }

      await _refreshQuestion();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEdit ? 'question_edited'.tr : 'question_added'.tr),
          duration: const Duration(seconds: 2)));

      Navigator.of(context).pop();
      if (_isEdit) Navigator.of(context).pop();
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
        onTap: () => _saveQuestion(userProv),
        enabled: !_isLoading,
        text: _isEdit ? 'edit' : 'send',
      ),
      //   appBar: _isLoadingAll ? emptyAppBar(context) : appBar,
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
        child: SingleChildScrollView(
          controller: _scrollController,
          child: _isLoading
              ? const LoadingWidget()
              : Column(
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
                            bottom: BorderSide(color: Colors.grey, width: 1.0),
                          )),
                      child: Text(
                        'ask_question_subtitle'.tr,
                        style: Theme.of(context).textTheme.headline6,
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
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                        ),
                        color: Theme.of(context).primaryColor.withOpacity(0.25),
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
                                            fontWeight: FontWeight.normal))))
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
                                            fontWeight: FontWeight.normal))),
                        searchHintText: 'search'.tr,
                        hintText: Text(
                          'choose_field'.tr,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(
                                  fontSize: 14, fontWeight: FontWeight.normal),
                        ),
                        noRecordText: 'no_items_to_show'.tr,
                        margin: const EdgeInsets.all(15),
                        paginatedRequest: (int page, String? searchKey) async {
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
                                              fontWeight: FontWeight.normal))))
                              .toList();
                        },
                        requestItemCount: fieldsProvider.limit + 1,
                        onChanged: (int? value) {
                          debugPrint('$value');
                          prevSearchKey = '';

                          if (value == null) {
                            _selectedFiledValue = null;
                          } else {
                            _selectedFiledValue = _filedsList
                                .firstWhere((element) => element.id == value);
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
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        left: 8,
                        right: 8,
                      ),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 8, bottom: 30),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        scrollPadding: EdgeInsets.zero,
                        decoration: InputDecoration(
                          labelText: 'subject'.tr,
                          suffixText: '${_enterdSubject.length.toString()}/100',
                          counterText: '',
                          contentPadding: const EdgeInsets.only(top: 4),
                          border: const UnderlineInputBorder(
                              borderSide: BorderSide.none),
                          labelStyle: TextStyle(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        controller: _subjectController,
                        cursorColor: Theme.of(context).primaryColor,
                        maxLength: 100,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        onChanged: (value) {
                          if (mounted) {
                            setState(() {
                              _enterdSubject = value;
                            });
                          }
                        },
                        onSubmitted: (_) {
                          FocusScope.of(context).requestFocus(_contentFoucsNod);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        bottom: 8,
                        left: 8,
                        right: 8,
                      ),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, top: 8, bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 200,
                            ),
                            child: TextField(
                              maxLines: null,
                              scrollPadding: EdgeInsets.zero,
                              decoration: InputDecoration(
                                labelText: 'write_your_ques'.tr,
                                counterText: '',
                                contentPadding: const EdgeInsets.only(top: 4),
                                border: const UnderlineInputBorder(
                                    borderSide: BorderSide.none),
                                labelStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              keyboardType: TextInputType.multiline,
                              controller: _contentController,
                              focusNode: _contentFoucsNod,
                              cursorColor: Theme.of(context).primaryColor,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      )),
    );
  }
}
