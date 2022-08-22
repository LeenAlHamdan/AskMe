// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'package:ask_me/models/answer.dart';
import 'package:ask_me/providers/answer_provider.dart';
import 'package:ask_me/screens/add_question_screen.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/load_more_horizontal_widget.dart';
import 'package:ask_me/widgets/load_more_widget.dart';
import 'package:ask_me/widgets/not_signed_dialog.dart';
import 'package:web_socket_channel/io.dart';

import '../models/http_exception.dart';
import '../models/question.dart';
import '../providers/question_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/circle_cached_image.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../widgets/loading_widget.dart';
import 'favorite_screen.dart';

class OneQuestionScreen extends StatefulWidget {
  static const routeName = '/one-question';
  final IOWebSocketChannel? channel;
  final Question question;
  const OneQuestionScreen(this.question, this.channel, {Key? key})
      : super(key: key);

  @override
  State<OneQuestionScreen> createState() => _OneQuestionScreenState();
}

class _OneQuestionScreenState extends State<OneQuestionScreen> {
  var _isLoading = false;
  var _isLoadingFollow = false;
  var _isLoadingRate = false;
  int? _ratedAnswerId;
  final _contentController = TextEditingController();
  final _contentFoucsNod = FocusNode();
  var _isWritingAns = false;

  late QuestionFullData _question;
  List<Answer> _answersList = [];
  bool hasError = false;

  late ScrollController _scrollController;

  bool loadMoreAnswers = false;
  bool canLoadAnswers = true;

  int pageNumAnswers = 0;

  void changeState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(
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

          if (canLoadAnswers) {
            if (mounted) {
              setState(() {
                loadMoreAnswers = true;
              });
            }
            canLoadAnswers = false;
            getAnswers();
          }
        } else {
          // You're at the top.

        }
      }
    });

    Future.delayed(Duration.zero).then((value) async {
      try {
        final userProv = Provider.of<UserProvider>(context, listen: false);

        if (mounted) {
          setState(() {
            _isLoading = true;
          });
        }

        _question = await Provider.of<QuestionProvider>(context, listen: false)
            .fetchAndSetQuestionData(
          userProv.token,
          widget.question.id,
          userProv.userId,
        );

        var answerProv = Provider.of<AnswerProvider>(context, listen: false);
        await answerProv.fetchAndSetAnswers(
          userProv.token,
          0,
          userProv.userId,
          isRefresh: true,
          questionId: widget.question.id,
        );
        _answersList = answerProv.answers;

        if (mounted) {
          setState(() {
            _question;
            _answersList;
          });
        }
      } on HttpException catch (error) {
        showErrorDialog('error'.tr, context)
            .then((value) => Navigator.of(context).pop());

        hasError = true;

        throw error;
      } catch (error) {
        showErrorDialog('error'.tr, context)
            .then((value) => Navigator.of(context).pop());

        hasError = true;
        throw error;
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> getAnswers() async {
    final answerProv = Provider.of<AnswerProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    if (_answersList.length == answerProv.total) {
      canLoadAnswers = false;
      if (mounted) {
        setState(() {
          loadMoreAnswers = false;
        });
      }
      return;
    }
    try {
      await answerProv.fetchAndSetAnswers(
        userProv.token,
        ++pageNumAnswers,
        userProv.userId,
        questionId: widget.question.id,
      );

      canLoadAnswers = true;
    } on HttpException catch (error) {
      pageNumAnswers--;
      canLoadAnswers = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreAnswers = false;
        });
      }
      throw error;
    } catch (error) {
      pageNumAnswers--;
      canLoadAnswers = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreAnswers = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMoreAnswers = false;
      });
    }
  }

  Future<void> delete(String token) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Provider.of<QuestionProvider>(context, listen: false)
          .deleteQuestion(
        widget.question.id,
        token,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      Navigator.pop(context);
    } on HttpException catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    } catch (_) {
      showErrorDialog('deleting_failed'.tr, context);
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
  }

  Future<void> answerRateUp(int answerId) async {
    if (mounted) {
      setState(() {
        _isLoadingRate = true;
        _ratedAnswerId = answerId;
      });
    }
    try {
      var answerProv = Provider.of<AnswerProvider>(context, listen: false);
      final userProv = Provider.of<UserProvider>(context, listen: false);

      await answerProv.answerRateUp(
        answerId,
        userProv.token,
      );

      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }

      showErrorDialog('add_failed'.tr, context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
      showErrorDialog('add_failed'.tr, context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> answerIsSolution(int answerId, bool isSolution) async {
    if (mounted) {
      setState(() {
        _isLoadingRate = true;
        _ratedAnswerId = answerId;
      });
    }
    try {
      var answerProv = Provider.of<AnswerProvider>(context, listen: false);
      final userProv = Provider.of<UserProvider>(context, listen: false);

      await answerProv.setAnswerAsSolution(
        answerId,
        isSolution,
        userProv.token,
      );

      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }

      showErrorDialog('add_failed'.tr, context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
      showErrorDialog('add_failed'.tr, context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> answerRateDown(int answerId) async {
    if (mounted) {
      setState(() {
        _isLoadingRate = true;
        _ratedAnswerId = answerId;
      });
    }
    try {
      var answerProv = Provider.of<AnswerProvider>(context, listen: false);
      final userProv = Provider.of<UserProvider>(context, listen: false);

      await answerProv.answerRateDown(
        answerId,
        userProv.token,
      );

      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }

      showErrorDialog('add_failed'.tr, context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingRate = false;
        });
      }
      showErrorDialog('add_failed'.tr, context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> addAnswer() async {
    if (_contentController.text == '') {
      var errorMessage = 'fill_all_info'.tr;
      showErrorDialog(errorMessage, context);
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      await Provider.of<QuestionProvider>(context, listen: false)
          .answerQuestion(
        _contentController.text,
        widget.question.id,
        userProv.token,
      );

      var answerProv = Provider.of<AnswerProvider>(context, listen: false);
      await answerProv.fetchAndSetAnswers(
        userProv.token,
        0,
        userProv.userId,
        isRefresh: true,
        questionId: widget.question.id,
      );
      _answersList = answerProv.answers;

      _contentController.clear();

      if (mounted) {
        setState(() {
          _answersList;
          _isLoading = false;
          _isWritingAns = false;
        });
      }
    } on HttpException catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      showErrorDialog('add_failed'.tr, context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      showErrorDialog('add_failed'.tr, context);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFoucsNod.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final questionProv = Provider.of<QuestionProvider>(context);
    var answerProv = Provider.of<AnswerProvider>(context);
    _answersList = answerProv.answers;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Get.locale == const Locale('ar')
              ? 'assets/images/logo_text_ar.png'
              : 'assets/images/logo_text_en.png',
          fit: BoxFit.contain,
          width: 120,
          height: AppBar().preferredSize.height,
        ),
        centerTitle: true,
        elevation: 2,
        actions: [
          /*   userProv.isAdmin()
              ? IconButton(
                  alignment: Get.locale == const Locale('ar')
                      ? Alignment.topLeft
                      : Alignment.topRight,
                  onPressed: () => confirmDeleteDialog(context,
                      widget.question.subject, () => delete(userProv.token)),
                  icon: SvgPicture.asset(
                    'assets/images/delete.svg',
                    color: Theme.of(context).textTheme.headline4?.color,
                    fit: BoxFit.scaleDown,
                    height: 30,
                  ),
                )
              : Container(),
        */
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
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_outlined,
            size: 32,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading || hasError
            ? const LoadingWidget()
            : SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              _question.subject,
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          userProv.userId == _question.userId
                              ? IconButton(
                                  onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => AddQuestionScreen(
                                              widget.channel,
                                              editedQuestion: _question))),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  icon: Icon(Icons.edit,
                                      size: MediaQuery.of(context).size.width *
                                          0.05,
                                      color:
                                          Theme.of(context).primaryColorDark))
                              : Container(),
                          userProv.userId == _question.userId ||
                                  userProv.isAdmin()
                              ? IconButton(
                                  onPressed: () => confirmDeleteDialog(
                                      context,
                                      widget.question.subject,
                                      () => delete(userProv.token)),
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  icon: Icon(Icons.delete,
                                      size: MediaQuery.of(context).size.width *
                                          0.05,
                                      color:
                                          Theme.of(context).primaryColorDark))
                              : Container(),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ItemInfoWidget(
                            title: 'ques_date'.tr,
                            content: (intl.DateFormat('yyyy/MM/dd'))
                                .format(DateTime.parse(_question.createdAt))),
                        _isLoadingFollow
                            ? const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: LoadMoreHorizontalWidget(),
                              )
                            : TextButton(
                                onPressed: userProv.userIsSignd()
                                    ? () async {
                                        if (_isLoadingFollow) {
                                          return;
                                        }
                                        if (mounted) {
                                          setState(() {
                                            _isLoadingFollow = true;
                                          });
                                        }
                                        try {
                                          await questionProv
                                              .toggleFavoriteStatus(
                                                  userProv.token, _question);
                                        } on HttpException catch (_) {
                                          showErrorDialog('error'.tr, context);
                                          if (mounted) {
                                            setState(() {
                                              _isLoadingFollow = false;
                                            });
                                          }
                                        } catch (_) {
                                          showErrorDialog('error'.tr, context);
                                          if (mounted) {
                                            setState(() {
                                              _isLoadingFollow = false;
                                            });
                                          }
                                        }
                                        if (mounted) {
                                          setState(() {
                                            _isLoadingFollow = false;
                                          });
                                        }
                                      }
                                    : () => notSignedDialog(context),
                                child: Text(
                                  _question.isFavorite
                                      ? 'followed'.tr
                                      : 'follow'.tr,
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColorDark,
                                  ),
                                ),
                              ),
                      ],
                    ),
                    const Divider(),
                    QuesInfoWidget(
                      content: _question.question,
                      color: Theme.of(context).primaryColor,
                    ),
                    ListTile(
                      dense: true,
                      title: Text(_question.userName),
                      subtitle: Text(_question.userEmail),
                      leading: CircleCachedImage(
                        image: _question.userProfileImageUrl,
                        radius: 35,
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${answerProv.total} ${'total_answers'.tr}',
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                    ..._answersList.map(
                      (answer) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: Get.locale == const Locale('ar')
                                          ? 8
                                          : 0,
                                      right: Get.locale == const Locale('ar')
                                          ? 0
                                          : 8,
                                    ),
                                    child: _isLoadingRate &&
                                            _ratedAnswerId == answer.id
                                        ? const LoadMoreHorizontalWidget()
                                        : Column(
                                            children: [
                                              IconButton(
                                                  onPressed: userProv
                                                          .userIsSignd()
                                                      ? userProv.userId ==
                                                              _question.userId
                                                          ? () =>
                                                              answerIsSolution(
                                                                  answer.id,
                                                                  !answer
                                                                      .isSolution)
                                                          : () => answer.isRated
                                                              ? answerRateDown(
                                                                  answer.id)
                                                              : answerRateUp(
                                                                  answer.id)
                                                      : () => notSignedDialog(
                                                          context),
                                                  alignment: Alignment.center,
                                                  icon: Icon(Icons.thumb_up,
                                                      color: answer.isRated
                                                          ? Theme.of(context)
                                                              .primaryColorDark
                                                          : Theme.of(context)
                                                              .primaryColor)),
                                              Text(
                                                getDoubleNum(answer.rating)
                                                    .toString(),
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                ),
                                              ),
                                              answer.isSolution
                                                  ? Icon(Icons.done,
                                                      color: Theme.of(context)
                                                          .primaryColorDark)
                                                  : Container(),
                                            ],
                                          ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      answer.answer,
                                      softWrap: true,
                                      maxLines: null,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              ListTile(
                                dense: true,
                                title: Text(answer.userName),
                                subtitle: Text(answer.userEmail),
                                leading: CircleCachedImage(
                                  image: answer.userProfileImageUrl,
                                  radius: 35,
                                ),
                              ),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                    !_isWritingAns
                        ? Padding(
                            padding: EdgeInsets.only(
                              right:
                                  (Get.locale == const Locale('ar')) ? 16 : 0,
                              left: (Get.locale == const Locale('ar')) ? 0 : 16,
                              top: 8,
                              bottom: 8,
                            ),
                            child: ListTile(
                              title: Text('add_answer'.tr),
                              leading: CircleAvatar(
                                radius: 15,
                                backgroundColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.5),
                                child: Icon(
                                  Icons.add,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  size: 30,
                                ),
                              ),
                              onTap: userProv.userIsSignd()
                                  ? () {
                                      if (mounted) {
                                        setState(() {
                                          _isWritingAns = true;
                                        });
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(_contentFoucsNod);
                                    }
                                  : () => notSignedDialog(context),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 32.0, vertical: 16),
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
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height *
                                            0.25,
                                  ),
                                  child: TextField(
                                    decoration: InputDecoration(
                                      labelText: 'write_your_answer'.tr,
                                      counterText: '',
                                      contentPadding:
                                          const EdgeInsets.only(top: 4),
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    !_isWritingAns
                        ? Container()
                        : Row(
                            children: [
                              //cancel
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: () {
                                      if (mounted) {
                                        setState(() {
                                          _isWritingAns = false;
                                        });
                                      }
                                      _contentController.clear();
                                    },
                                    child: Ink(
                                      padding: const EdgeInsets.all(8),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          color: Theme.of(context)
                                              .backgroundColor),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'cancel'.tr,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1,
                                        ),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              //save
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: addAnswer,
                                    child: Ink(
                                      padding: const EdgeInsets.all(8),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'save'.tr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Theme.of(context)
                                                .backgroundColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.all(8),
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    (loadMoreAnswers) ? const LoadMoreWidget() : Container(),
                  ],
                ),
              ),
      ),
    );
  }

  getDoubleNum(double rating) {
    if (rating.toInt() == rating) {
      return rating.toInt();
    }
    return rating;
  }
}

class QuesInfoWidget extends StatelessWidget {
  const QuesInfoWidget({
    Key? key,
    required this.content,
    required this.color,
  }) : super(key: key);
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyText1!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}

class ItemInfoWidget extends StatelessWidget {
  const ItemInfoWidget({
    Key? key,
    required this.content,
    required this.title,
    this.textDirection,
  }) : super(key: key);

  final String content;
  final String title;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              content,
              textDirection: textDirection,
              textAlign: Get.locale == const Locale('ar')
                  ? TextAlign.left
                  : TextAlign.right,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
              ),
            ),
          )
        ],
      ),
    );
  }
}
