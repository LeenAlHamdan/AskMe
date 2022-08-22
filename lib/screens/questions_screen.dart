// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'package:ask_me/models/question.dart';
import 'package:ask_me/providers/field_provider.dart';
import 'package:ask_me/providers/question_provider.dart';
import 'package:ask_me/screens/add_question_screen.dart';
import 'package:ask_me/screens/one_question_screen.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/not_signed_dialog.dart';
import 'package:ask_me/widgets/question_item.dart';
import 'package:web_socket_channel/io.dart';

import '../models/field.dart';
import '../models/http_exception.dart';
import '../providers/user_provider.dart';
import '../widgets/error_dialog.dart';
import '../widgets/load_more_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../widgets/app_bar_item.dart';
import '../widgets/load_more_horizontal_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/no_items_widget.dart';

class QuestionsScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;

  const QuestionsScreen(this.channel, {Key? key}) : super(key: key);

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool search = false;
  final _searchController = TextEditingController();
  Widget? searchBox;
  var searchIcon = Icons.search;

  int pageNumField = 0;
  int pageNumFieldSearched = 0;

  bool _isLoading = false;
  bool loadMoreFields = false;
  bool canLoadFields = false;

  bool loadMoreQuestions = false;
  bool canLoadQuestions = true;

  int pageNumQuestions = 0;
  int pageNumSearched = 0;
  int? fieldId;

  List<Field> fileds = [];
  List<Question> questions = [];

  String prev = '';

  late ScrollController _scrollController;
  late ScrollController _horizontalScrollController;

  bool hasError = false;

  void _searchPressed() {
    if (mounted) {
      setState(() {
        if (searchIcon == Icons.search) {
          searchIcon = Icons.close;
          searchBox = Container(
            color: Theme.of(context).primaryColor,
            child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(
                      color: Theme.of(context).backgroundColor,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).backgroundColor,
                    ),
                    hintText: 'search'.tr),
                style: TextStyle(
                  color: Theme.of(context).backgroundColor,
                ),
                // onChanged: (value) => _getNames(searchController.text),
                onSubmitted: (value) {}
                //    _getSchemeNames(), // _getNames(searchController.text),
                ),
          );

          /* //TODOif (_scrollController != null) {
            _scrollController.jumpTo(0);
          } */
        } else {
          search = false;
          //  _selectedIndex = 0;
          searchIcon = Icons.search;
          searchBox = null;
          //     _getSchemeNames();

          _searchController.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _getNames() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final userProv = Provider.of<UserProvider>(context, listen: false);
    final fieldProv = Provider.of<FieldProvider>(context, listen: false);
    final questionProv = Provider.of<QuestionProvider>(context, listen: false);
    try {
      if (_searchController.text.isNotEmpty &&
          _searchController.text.removeAllWhitespace.isNotEmpty) {
        await fieldProv.search(userProv.token, _searchController.text, 0,
            isRefresh: true);
        await questionProv.search(userProv.token, _searchController.text, 0,
            fieldId: fieldId, isRefresh: true);
        pageNumFieldSearched = 0;
        pageNumSearched = 0;
        fileds = fieldProv.searched;
        questions = questionProv.searched;
      } else {
        fileds = [];
        questions = [];
        await fieldProv.fetchAndSetFields(
          userProv.token,
          0,
        );
        await questionProv.fetchAndSetQuestions(
          userProv.token,
          0,
          fieldId: fieldId,
        );
      }
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);
    } catch (error) {
      showErrorDialog('error'.tr, context);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) async {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true;
            canLoadQuestions = false;
          });
        }
        final userProv = Provider.of<UserProvider>(context, listen: false);
        final token = userProv.token;

        await Provider.of<QuestionProvider>(context, listen: false)
            .fetchAndSetQuestions(token, 0, isRefresh: true);

        if (mounted) {
          setState(() {
            _isLoading = false;
            canLoadQuestions = true;
          });
        }
      } on HttpException catch (_) {
        canLoadQuestions = true;
        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      } catch (error) {
        canLoadQuestions = true;

        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      }
    });

    if (search) {
      setState(() {
        pageNumFieldSearched = 0;
      });
    }

    _searchController.addListener(() {
      if (_searchController.text.isNotEmpty &&
          _searchController.text.removeAllWhitespace.isNotEmpty &&
          mounted) {
        setState(() {
          search = true;
        });
      }
      if (prev != _searchController.text) {
        prev = _searchController.text;
        _getNames();
      }
    });

    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    _horizontalScrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    // Setup the listener.
    _scrollController.addListener(() {
      if (_scrollController.positions.first.atEdge) {
        if (_scrollController.positions.last.pixels ==
            _scrollController.positions.last.maxScrollExtent) {
          // You're at the bottom.
          if (hasError) return;

          if (canLoadQuestions) {
            if (mounted) {
              setState(() {
                loadMoreQuestions = true;
              });
            }
            canLoadQuestions = false;
            getQuestions();
          }
        } else {
          // You're at the top.

        }
      }
    });

    _horizontalScrollController.addListener(() {
      if (_horizontalScrollController.positions.first.atEdge) {
        if (_horizontalScrollController.positions.last.pixels ==
            _horizontalScrollController.positions.last.maxScrollExtent) {
          // You're at the end.
          if (canLoadFields) {
            if (mounted) {
              setState(() {
                loadMoreFields = true;
              });
            }
            canLoadFields = false;
            getFields();
          }
        } else {
          // You're at the start.
        }
      }
    });
  }

  Future<void> getQuestions() async {
    final questionProv = Provider.of<QuestionProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    if (!search && questions.length == questionProv.total) {
      canLoadQuestions = false;
      if (mounted) {
        setState(() {
          loadMoreQuestions = false;
        });
      }
      return;
    }
    try {
      if (search) {
        await questionProv.search(
          userProv.token,
          _searchController.text,
          ++pageNumSearched,
          fieldId: fieldId,
        );
      } else {
        await questionProv.fetchAndSetQuestions(
          userProv.token,
          ++pageNumQuestions,
          fieldId: fieldId,
        );
      }

      canLoadQuestions = true;
    } on HttpException catch (error) {
      search ? pageNumSearched-- : pageNumQuestions--;
      canLoadQuestions = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreQuestions = false;
        });
      }
      throw error;
    } catch (error) {
      search ? pageNumSearched-- : pageNumQuestions--;
      canLoadQuestions = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreQuestions = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMoreQuestions = false;
      });
    }
  }

  Future<void> getFields() async {
    final fieldProv = Provider.of<FieldProvider>(context, listen: false);

    if (!search && fileds.length == fieldProv.total) {
      canLoadFields = true;

      if (mounted) {
        setState(() {
          loadMoreFields = false;
        });
      }
      return;
    }
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;

      !search
          ? await fieldProv.fetchAndSetFields(
              token,
              ++pageNumField,
            )
          : await fieldProv.search(
              token, _searchController.text, ++pageNumFieldSearched);
      canLoadFields = true;
    } on HttpException catch (error) {
      pageNumField--;
      canLoadFields = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreFields = false;
        });
      }
      throw error;
    } catch (error) {
      pageNumField--;
      canLoadFields = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreFields = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMoreFields = false;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;

      if (!search) {
        await Provider.of<QuestionProvider>(context, listen: false)
            .fetchAndSetQuestions(
          token,
          0,
          isRefresh: true,
        );
        await Provider.of<FieldProvider>(context, listen: false)
            .fetchAndSetFields(
          token,
          0,
          isRefresh: true,
        );
      }
      canLoadFields = true;
      pageNumField = 0;
      pageNumQuestions = 0;
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);

      throw HttpException('error');
    } catch (error) {
      showErrorDialog('error'.tr, context);
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final fieldProv = Provider.of<FieldProvider>(context);
    final questionsProv = Provider.of<QuestionProvider>(context);

    if (!search) {
      questions = questionsProv.questions;
      fileds = fieldProv.fields;
    } else {
      fileds = fieldProv.searched;
      //questions = questionsProv.searched;

    }

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height * 2),
      child: Container(
        padding: EdgeInsets.only(
          right: (Get.locale == const Locale('ar')) ? 4 : 0,
          left: (Get.locale == const Locale('ar')) ? 0 : 4,
        ),
        width: double.infinity,
        height: AppBar().preferredSize.height * 2,
        color: Theme.of(context).backgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              height: AppBar().preferredSize.height,
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              )),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fieldId == null || fieldProv.findById(fieldId!) == null
                        ? 'all_questions'.tr
                        : Get.locale == const Locale('ar')
                            ? fieldProv.findById(fieldId!)!.nameAr
                            : fieldProv.findById(fieldId!)!.nameEn,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 22),
                  ),
                  TextButton(
                    onPressed: userProv.userIsSignd()
                        ? () => Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => AddQuestionScreen(widget.channel)))
                        : () => notSignedDialog(context),
                    child: Ink(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'ask_now'.tr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).primaryColorDark,
                          ),
                        ),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppBar().preferredSize.height,
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: _horizontalScrollController,
                child: Row(
                  children: [
                    ...fileds.map((field) {
                      return AppBarItem(
                        backgroundColor: field.id == fieldId
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).backgroundColor,
                        textColor: field.id != fieldId
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).backgroundColor,
                        onTap: () async {
                          pageNumQuestions = 0;

                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                              canLoadQuestions = false;
                              if (fieldId == field.id) {
                                fieldId = null;
                              } else {
                                fieldId = field.id;
                              }
                            });
                          }
                          try {
                            await questionsProv.fetchAndSetQuestions(
                              userProv.token,
                              pageNumQuestions,
                              fieldId: fieldId,
                              isRefresh: true,
                            );
                            canLoadQuestions = true;
                          } on HttpException catch (error) {
                            canLoadQuestions = true;

                            showErrorDialog('error'.tr, context);
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                            throw error;
                          } catch (error) {
                            canLoadQuestions = true;

                            showErrorDialog('error'.tr, context);
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                            }
                            throw error;
                          }
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        title: Get.locale == const Locale('ar')
                            ? field.nameAr
                            : field.nameEn,
                      );
                    }).toList(),
                    (loadMoreFields)
                        ? const LoadMoreHorizontalWidget()
                        : Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      key: scaffoldKey,
      primary: true,
      appBar: AppBar(
        elevation: 1,
        title: searchBox ??
            Image.asset(
              Get.locale == const Locale('ar')
                  ? 'assets/images/logo_text_ar.png'
                  : 'assets/images/logo_text_en.png',
              fit: BoxFit.contain,
              width: 120,
              height: AppBar().preferredSize.height,
            ),
        centerTitle: true,
        leading: searchBox != null
            ? Container()
            : IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_outlined,
                  size: 32,
                )),
        actions: [
          IconButton(
              onPressed: () => _searchPressed(),
              icon: Icon(
                searchIcon,
                size: 32,
              )),
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScreen(widget.channel))),
              icon: const Icon(Icons.person)),
        ],
        bottom: /*  searchBox != null ? null : */ appBar,
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: () => _refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: questions.isEmpty
                      ? const NoItemsWidget()
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                            minHeight: MediaQuery.of(context).size.height -
                                appBar.preferredSize.height * 2 -
                                50,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${questionsProv.total} ${'total_questions'.tr}',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ),
                                  questions.isEmpty
                                      ? const NoItemsWidget()
                                      : Container(),
                                  ...questions
                                      .map((question) => Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                border: Border(
                                              bottom: BorderSide(
                                                color: Theme.of(context)
                                                    .dividerColor,
                                              ),
                                            )),
                                            child: QuestionItem(
                                              question,
                                              onPr: () => Navigator.of(context)
                                                  .push(MaterialPageRoute(
                                                      builder: (_) =>
                                                          OneQuestionScreen(
                                                              question,
                                                              widget.channel))),
                                            ),
                                          ))
                                      .toList(),
                                  (loadMoreQuestions)
                                      ? const LoadMoreWidget()
                                      : Container(),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ),
      ),
    );
  }
}
