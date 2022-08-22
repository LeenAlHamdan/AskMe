// ignore_for_file: use_rethrow_when_possible, invalid_use_of_protected_member

import 'dart:async';

import 'package:ask_me/providers/field_provider.dart';
import 'package:ask_me/providers/specialization_provider.dart';
import 'package:ask_me/screens/consultancy_screen.dart';
import 'package:ask_me/widgets/circle_cached_image.dart';
import 'package:latlong2/latlong.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/app_drawer.dart';
import 'package:web_socket_channel/io.dart';

import '../functions/init_location_service.dart';
import '../models/field.dart';
import '../models/http_exception.dart';
import '../models/specialist.dart';
import '../models/specialization.dart';
import '../providers/specialist_provider.dart';
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
import '../widgets/show_information_dialog.dart';

class SpecialistsScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;
  final StreamController streamController;

  const SpecialistsScreen(this.channel, this.streamController, {Key? key})
      : super(key: key);

  @override
  State<SpecialistsScreen> createState() => _SpecialistsScreenState();
}

class _SpecialistsScreenState extends State<SpecialistsScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  int pageNumField = 0;

  int pageNumSpecialization = 0;

  bool _isLoading = false;
  bool _isLoadingSpecialization = false;
  bool loadMoreFields = false;
  bool canLoadFields = false;

  bool loadMoreSpecialization = false;
  bool canLoadSpecialization = false;

  bool loadMoreSpecialists = false;
  bool canLoadSpecialists = true;

  int pageNumSpecialists = 0;
  int? fieldId;
  int? specializationId;
  bool _theClosestSelected = false;

  List<Field> fileds = [];
  List<Specialization> specializations = [];
  List<Specialist> specialists = [];

  late ScrollController _scrollController;
  late ScrollController _horizontalScrollController;
  late ScrollController _horizontalScrollControllerSpecialization;

  bool hasError = false;

  @override
  void dispose() {
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _horizontalScrollControllerSpecialization.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero).then((value) async {
      try {
        if (mounted) {
          setState(() {
            _isLoading = true;
            _isLoadingSpecialization = true;

            canLoadSpecialists = false;
            canLoadSpecialization = false;
          });
        }
        final userProv = Provider.of<UserProvider>(context, listen: false);
        final token = userProv.token;

        await Provider.of<SpecialistProvider>(context, listen: false)
            .fetchAndSetSpecialists(token, 0, isRefresh: true);

        await Provider.of<SpecializationProvider>(context, listen: false)
            .fetchAndSetSpecializations(token, 0, isRefresh: true);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isLoadingSpecialization = false;
            canLoadSpecialists = true;
            canLoadSpecialization = true;
          });
        }
      } on HttpException catch (_) {
        canLoadSpecialists = true;
        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      } catch (error) {
        canLoadSpecialists = true;

        Future.delayed(Duration.zero)
            .then((_) => showErrorDialog('error'.tr, context));
      }
    });

    _scrollController = ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );

    _horizontalScrollControllerSpecialization = ScrollController(
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

          if (canLoadSpecialists) {
            if (mounted) {
              setState(() {
                loadMoreSpecialists = true;
              });
            }
            canLoadSpecialists = false;
            getSpecialists();
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

    _horizontalScrollControllerSpecialization.addListener(() {
      if (_horizontalScrollControllerSpecialization.positions.first.atEdge) {
        if (_horizontalScrollControllerSpecialization.positions.last.pixels ==
            _horizontalScrollControllerSpecialization
                .positions.last.maxScrollExtent) {
          // You're at the end.
          if (canLoadSpecialization) {
            if (mounted) {
              setState(() {
                loadMoreSpecialization = true;
              });
            }
            canLoadSpecialization = false;
            getFields();
          }
        } else {
          // You're at the start.
        }
      }
    });
  }

  Future<void> getSpecialists() async {
    final specialistProv =
        Provider.of<SpecialistProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    if (specialists.length == specialistProv.total) {
      canLoadSpecialists = false;
      if (mounted) {
        setState(() {
          loadMoreSpecialists = false;
        });
      }
      return;
    }
    try {
      await specialistProv.fetchAndSetSpecialists(
        userProv.token,
        ++pageNumSpecialists,
        fieldId: fieldId,
      );

      canLoadSpecialists = true;
    } on HttpException catch (error) {
      pageNumSpecialists--;
      canLoadSpecialists = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecialists = false;
        });
      }
      throw error;
    } catch (error) {
      pageNumSpecialists--;
      canLoadSpecialists = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecialists = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMoreSpecialists = false;
      });
    }
  }

  Future<void> getFields() async {
    final fieldProv = Provider.of<FieldProvider>(context, listen: false);

    if (fileds.length == fieldProv.total) {
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

      await fieldProv.fetchAndSetFields(
        token,
        ++pageNumField,
      );
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

  Future<void> getSpecializations() async {
    final specializationProv =
        Provider.of<SpecializationProvider>(context, listen: false);

    if (specializations.length == specializationProv.total) {
      canLoadSpecialization = true;

      if (mounted) {
        setState(() {
          loadMoreSpecialization = false;
        });
      }
      return;
    }
    try {
      final token = Provider.of<UserProvider>(context, listen: false).token;

      await specializationProv.fetchAndSetSpecializations(
        token,
        ++pageNumSpecialization,
      );
      canLoadSpecialization = true;
    } on HttpException catch (error) {
      pageNumSpecialization--;
      canLoadSpecialization = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecialization = false;
        });
      }
      throw error;
    } catch (error) {
      pageNumSpecialization--;

      canLoadSpecialization = true;

      showErrorDialog('error'.tr, context);
      if (mounted) {
        setState(() {
          loadMoreSpecialization = false;
        });
      }
      throw error;
    }
    if (mounted) {
      setState(() {
        loadMoreSpecialization = false;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final userProv = Provider.of<UserProvider>(context, listen: false);
      final token = userProv.token;
      specializationId = null;
      fieldId = null;
      canLoadFields = false;
      canLoadSpecialization = false;
      canLoadSpecialists = false;

      await Provider.of<FieldProvider>(context, listen: false)
          .fetchAndSetFields(
        token,
        0,
        isRefresh: true,
      );
      await Provider.of<SpecializationProvider>(context, listen: false)
          .fetchAndSetSpecializations(
        token,
        0,
        isRefresh: true,
      );
      await Provider.of<SpecialistProvider>(context, listen: false)
          .fetchAndSetSpecialists(
        token,
        0,
        isRefresh: true,
      );
      pageNumField = 0;
      pageNumSpecialization = 0;
      pageNumSpecialists = 0;
    } on HttpException catch (_) {
      showErrorDialog('error'.tr, context);
    } catch (error) {
      showErrorDialog('error'.tr, context);
    }
    canLoadFields = true;
    canLoadSpecialization = true;
    canLoadSpecialists = true;
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final fieldProv = Provider.of<FieldProvider>(context);
    final specialistProvider = Provider.of<SpecialistProvider>(context);
    final specializationProvider = Provider.of<SpecializationProvider>(context);

    specialists = Provider.of<SpecialistProvider>(context).specialists;
    fileds = fieldProv.fields;
    specializations = specializationProvider.specializations;

    final appBar = PreferredSize(
      preferredSize: Size.fromHeight(AppBar().preferredSize.height * 3),
      child: Container(
        padding: EdgeInsets.only(
          right: (Get.locale == const Locale('ar')) ? 4 : 0,
          left: (Get.locale == const Locale('ar')) ? 0 : 4,
        ),
        width: double.infinity,
        height: AppBar().preferredSize.height * 3,
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
                    getTitle(fieldProv, specializationProvider),
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .copyWith(fontSize: 22),
                  ),
                  AppBarItem(
                    backgroundColor: _theClosestSelected
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).backgroundColor,
                    textColor: Theme.of(context).primaryColorDark,
                    onTap: () async {
                      pageNumSpecialists = 0;

                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                          _theClosestSelected = !_theClosestSelected;
                          canLoadSpecialists = false;
                        });
                      }
                      try {
                        LatLng? currentLatLng;
                        if (_theClosestSelected) {
                          currentLatLng = await initLocationService(context);
                          if (currentLatLng == null) {
                            showErrorDialog('PERMISSION_DENIED'.tr, context);
                            setState(() {
                              _isLoading = false;
                              _theClosestSelected = !_theClosestSelected;
                              canLoadSpecialists = true;
                            });
                            return;
                          }
                        }

                        await specialistProvider.fetchAndSetSpecialists(
                          userProv.token,
                          pageNumSpecialists,
                          fieldId: fieldId,
                          specializationId: specializationId,
                          isRefresh: true,
                          startLat: currentLatLng?.latitude,
                          startLng: currentLatLng?.longitude,
                        );
                        canLoadSpecialists = true;
                      } on HttpException catch (error) {
                        canLoadSpecialists = true;

                        showErrorDialog('error'.tr, context);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        throw error;
                      } catch (error) {
                        canLoadSpecialists = true;

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
                    title: 'the_closest'.tr,
                  ),
                  /*      TextButton(
                    onPressed: () async {
                      pageNumSpecialists = 0;

                      if (mounted) {
                        setState(() {
                          _isLoading = true;
                          canLoadSpecialists = false;
                        });
                      }
                      try {
                        final currentLatLng =
                            await initLocationService(context);
                        if (currentLatLng == null) {
                          showErrorDialog('PERMISSION_DENIED'.tr, context);
                          return;
                        }
                        await specialistProvider.fetchAndSetSpecialists(
                          userProv.token,
                          pageNumSpecialists,
                          fieldId: fieldId,
                          specializationId: specializationId,
                          isRefresh: true,
                          startLat: currentLatLng.latitude,
                          startLng: currentLatLng.longitude,
                        );
                        canLoadSpecialists = true;
                      } on HttpException catch (error) {
                        canLoadSpecialists = true;

                        showErrorDialog('error'.tr, context);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        throw error;
                      } catch (error) {
                        canLoadSpecialists = true;

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
                          'the_closest'.tr,
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
                  ), */
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
                          pageNumSpecialists = 0;

                          if (mounted) {
                            setState(() {
                              _isLoading = true;
                              _isLoadingSpecialization = true;
                              specializationId = null;
                              canLoadSpecialists = false;
                              if (fieldId == field.id) {
                                fieldId = null;
                              } else {
                                fieldId = field.id;
                              }
                            });
                          }
                          try {
                            await specialistProvider.fetchAndSetSpecialists(
                              userProv.token,
                              pageNumSpecialists,
                              fieldId: fieldId,
                              specializationId: specializationId,
                              isRefresh: true,
                            );

                            await specializationProvider
                                .fetchAndSetSpecializations(userProv.token, 0,
                                    fieldId: fieldId, isRefresh: true);
                            canLoadSpecialists = true;
                          } on HttpException catch (_) {
                            canLoadSpecialists = true;

                            showErrorDialog('error'.tr, context);
                          } catch (error) {
                            canLoadSpecialists = true;

                            showErrorDialog('error'.tr, context);
                          }
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                              _isLoadingSpecialization = false;
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
            Container(
              decoration: BoxDecoration(
                  border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              )),
              height: AppBar().preferredSize.height,
              width: double.infinity,
              child: _isLoadingSpecialization
                  ? const LoadMoreHorizontalWidget()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _horizontalScrollControllerSpecialization,
                      child: Row(
                        children: [
                          ...specializations.map((specialization) {
                            return AppBarItem(
                              backgroundColor:
                                  specialization.id == specializationId
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).backgroundColor,
                              textColor: specialization.id != specializationId
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).backgroundColor,
                              onTap: () async {
                                pageNumSpecialists = 0;

                                if (mounted) {
                                  setState(() {
                                    _isLoading = true;
                                    canLoadSpecialists = false;
                                    if (specializationId == specialization.id) {
                                      specializationId = null;
                                    } else {
                                      specializationId = specialization.id;
                                    }
                                  });
                                }
                                try {
                                  await specialistProvider
                                      .fetchAndSetSpecialists(
                                    userProv.token,
                                    pageNumSpecialists,
                                    fieldId: fieldId,
                                    specializationId: specializationId,
                                    isRefresh: true,
                                  );
                                  canLoadSpecialists = true;
                                } on HttpException catch (error) {
                                  canLoadSpecialists = true;

                                  showErrorDialog('error'.tr, context);
                                  if (mounted) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                  throw error;
                                } catch (error) {
                                  canLoadSpecialists = true;

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
                                  ? specialization.nameAr
                                  : specialization.nameEn,
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
      drawer: AppDrawer(widget.channel, widget.streamController),
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
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_outlined,
              size: 32,
            )),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScreen(widget.channel))),
              icon: const Icon(Icons.person)),
        ],
        bottom: appBar,
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingWidget()
            : RefreshIndicator(
                onRefresh: () => _refresh(),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: specialists.isEmpty
                      ? const NoItemsWidget()
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: MediaQuery.of(context).size.width,
                            minHeight: MediaQuery.of(context).size.height -
                                appBar.preferredSize.height -
                                AppBar().preferredSize.height,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  specialists.isEmpty
                                      ? const NoItemsWidget()
                                      : Container(),
                                  ...specialists
                                      .map((specialist) => Card(
                                            margin: const EdgeInsets.all(6),
                                            child: ListTile(
                                              dense: true,
                                              onTap: userProv.userIsSignd()
                                                  ? () {
                                                      Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ConsultancyScreen(
                                                                    widget
                                                                        .channel,
                                                                    widget
                                                                        .streamController,
                                                                    secondUserEmail:
                                                                        specialist
                                                                            .email,
                                                                    secondUserPhone:
                                                                        specialist
                                                                            .phone,
                                                                    secondUserId:
                                                                        specialist
                                                                            .id,
                                                                    secondUserProfileImage:
                                                                        specialist
                                                                            .profileImageUrl,
                                                                    secondUserName:
                                                                        specialist
                                                                            .name,
                                                                    secondUserFieldNameAr:
                                                                        specialist
                                                                            .fieldNameAr,
                                                                    secondUserFieldNameEn:
                                                                        specialist
                                                                            .fieldNameEn,
                                                                    secondUserSpecializationNameAr:
                                                                        specialist
                                                                            .specializationNameAr,
                                                                    secondUserSpecializationNameEn:
                                                                        specialist
                                                                            .specializationNameEn,
                                                                    secondUserLat:
                                                                        specialist
                                                                            .lat,
                                                                    secondUserLng:
                                                                        specialist
                                                                            .lng,
                                                                    secondUserRating:
                                                                        specialist
                                                                            .rating,
                                                                  )));
                                                    }
                                                  : () => showInformationDialog(
                                                        context: context,
                                                        userEmail:
                                                            specialist.email,
                                                        userPhone:
                                                            specialist.phone,
                                                        userProfileImage:
                                                            specialist
                                                                .profileImageUrl,
                                                        userName:
                                                            specialist.name,
                                                        userFieldNameAr:
                                                            specialist
                                                                .fieldNameAr,
                                                        userFieldNameEn:
                                                            specialist
                                                                .fieldNameEn,
                                                        userSpecializationNameAr:
                                                            specialist
                                                                .specializationNameAr,
                                                        userSpecializationNameEn:
                                                            specialist
                                                                .specializationNameEn,
                                                        userLat: specialist.lat,
                                                        userLng: specialist.lng,
                                                        userRating:
                                                            specialist.rating,
                                                        userId: specialist.id,
                                                      ),
                                              title: Text(specialist.name),
                                              subtitle: Text(Get.locale ==
                                                      const Locale('ar')
                                                  ? specialist
                                                      .specializationNameAr
                                                  : specialist
                                                      .specializationNameEn),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    specialist.rating
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColorDark),
                                                  ),
                                                  Icon(
                                                      Icons
                                                          .star_outline_rounded,
                                                      color: Theme.of(context)
                                                          .primaryColorDark)
                                                ],
                                              ),
                                              leading: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    decoration: specialist
                                                            .isOnline
                                                        ? BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                          )
                                                        : null,
                                                    height: 10,
                                                    width: 10,
                                                  ),
                                                  CircleCachedImage(
                                                    image: specialist
                                                        .profileImageUrl,
                                                    radius: 35,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  (loadMoreSpecialists)
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

  String getTitle(
      FieldProvider fieldProv, SpecializationProvider specializationProvider) {
    var field = fieldId == null ? null : fieldProv.findById(fieldId!);
    var specialization = specializationId == null
        ? null
        : specializationProvider.findById(specializationId!);
    return (fieldId == null && specializationId == null) ||
            (field == null && specialization == null)
        ? 'all_specialists'.tr
        : (field != null && specialization == null)
            ? Get.locale == const Locale('ar')
                ? field.nameAr
                : field.nameEn
            : field == null
                ? Get.locale == const Locale('ar')
                    ? specialization!.nameAr
                    : specialization!.nameEn
                : Get.locale == const Locale('ar')
                    ? field.nameAr + " - " + specialization!.nameAr
                    : field.nameEn + " - " + specialization!.nameEn;
  }
}
