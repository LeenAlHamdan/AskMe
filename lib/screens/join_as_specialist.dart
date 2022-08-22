import 'package:ask_me/models/field.dart';
import 'package:ask_me/models/specialization.dart';
import 'package:ask_me/providers/specialist_provider.dart';
import 'package:ask_me/providers/specialization_provider.dart';
import 'package:ask_me/screens/profile_screen.dart';
import 'package:ask_me/widgets/error_dialog.dart';
import 'package:ask_me/widgets/load_more_widget.dart';
import 'package:ask_me/widgets/loading_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';
import 'package:provider/provider.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:web_socket_channel/io.dart';

import '../functions/init_location_service.dart';
import '../models/http_exception.dart';
import '../providers/field_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/not_signed_dialog.dart';
import '../widgets/paginationed_drop_dwon.dart';
import '../widgets/screen_bottom_navigation_bar.dart';
import 'favorite_screen.dart';

class JoinAsSpecialistScreen extends StatefulWidget {
  final IOWebSocketChannel? channel;

  const JoinAsSpecialistScreen(this.channel, {Key? key}) : super(key: key);

  @override
  _JoinAsSpecialistScreenState createState() => _JoinAsSpecialistScreenState();
}

class _JoinAsSpecialistScreenState extends State<JoinAsSpecialistScreen> {
  List<Field> _filedsList = [];
  List<Specialization> _spercializationsList = [];

  Specialization? _selectedSpecializationValue;
  Field? _selectedFiledValue;
  late final MapController _mapController;
  bool _isLoading = false;
  bool _isLoadingMap = true;
  LatLng? currentLatLng;

  int interActiveFlags = InteractiveFlag.all;

  List<LatLng> tappedPoints = [];
  var prevSearchKey = '';

  Future<void> _registerAsASpecialist(UserProvider userProv) async {
    if (_selectedFiledValue == null ||
        _selectedSpecializationValue == null ||
        tappedPoints.isEmpty) {
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
      await Provider.of<SpecialistProvider>(context, listen: false)
          .registerAsSpecialist(
        lat: tappedPoints.first.latitude.toString(),
        lng: tappedPoints.first.longitude.toString(),
        specializationId: _selectedSpecializationValue!.id,
        token: userProv.token,
      );

      await userProv.fetchProfile();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('register_as_specialist_successfully'.tr),
          duration: const Duration(seconds: 2)));

      Navigator.of(context).pop();
    } on HttpException catch (_) {
      showErrorDialog('add_failed'.tr, context);
    } catch (er) {
      showErrorDialog('add_failed'.tr, context);
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
    _mapController = MapController();
    initLocationService(context).then((value) {
      value ??= LatLng(36.21508, 37.128727);
      currentLatLng = value;
      if (mounted) {
        setState(() {
          currentLatLng;
          _isLoadingMap = false;
        });
      }
      tappedPoints.add(currentLatLng!);
    });
  }

  void _handleTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      if (tappedPoints.isEmpty) {
        tappedPoints.add(latlng);
      } else {
        tappedPoints = [];
        tappedPoints.add(latlng);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);
    final fieldsProvider = Provider.of<FieldProvider>(context);
    final specializationProvider = Provider.of<SpecializationProvider>(context);
    if (_filedsList.isEmpty) {
      _filedsList = fieldsProvider.fields;
    }
    if (_spercializationsList.isEmpty) {
      _spercializationsList = specializationProvider.specializations;
    }

    if (currentLatLng == null) {
      if (mounted) {
        setState(() {
          _isLoadingMap = true;
        });
      }
    }

    final markers = tappedPoints.map((latlng) {
      return Marker(
        width: 20,
        height: 20,
        point: latlng,
        builder: (ctx) => const Icon(Icons.pin_drop),
      );
    }).toList();
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
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProfileScreen(widget.channel))),
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: userProv.userIsSignd()
                  ? () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => FavoriteScreen(widget.channel)))
                  : () => notSignedDialog(context),
              icon: const Icon(Icons.favorite)),
        ],
      ),
      bottomNavigationBar: ScreenBottomNavigationBar(
        text: 'regist',
        enabled: !_isLoading,
        onTap: _isLoading ? () {} : () => _registerAsASpecialist(userProv),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
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
                      'join_as_specialist_subtitle'.tr,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  PaginationedDropDwon<int>(
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
                      style: Theme.of(context).textTheme.headline6!.copyWith(
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

                        _selectedSpecializationValue = null;

                        specializationProvider.fetchAndSetSpecializations(
                          userProv.token,
                          0,
                          fieldId: _selectedFiledValue != null
                              ? _selectedFiledValue!.id
                              : null,
                          isRefresh: true,
                        );
                      }
                      if (mounted) {
                        setState(() {
                          _selectedSpecializationValue;
                          _selectedFiledValue;
                        });
                      }
                    },
                  ),
                  PaginationedDropDwon<int>(
                    initList: const [] /*  specializations.map((item) {
                return SearchableDropdownMenuItem(
                    value: item.id,
                    label: Get.locale == const Locale('ar')
                        ? item.nameAr
                        : item.nameEn,
                    child: Text(
                        Get.locale == const Locale('ar')
                            ? item.nameAr
                            : item.nameEn,
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontSize: 14, fontWeight: FontWeight.normal)));
              }).toList() */
                    ,
                    selectedItem: _selectedSpecializationValue == null
                        ? null
                        : SearchableDropdownMenuItem(
                            value: _selectedSpecializationValue!.id,
                            label: Get.locale == const Locale('ar')
                                ? _selectedSpecializationValue!.nameAr
                                : _selectedSpecializationValue!.nameEn,
                            child: Text(
                                Get.locale == const Locale('ar')
                                    ? _selectedSpecializationValue!.nameAr
                                    : _selectedSpecializationValue!.nameEn,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6!
                                    .copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal))),
                    searchHintText: 'search'.tr,
                    hintText: Text(
                      'choose_specialization'.tr,
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                          fontSize: 14, fontWeight: FontWeight.normal),
                    ),
                    noRecordText: 'no_items_to_show'.tr,
                    margin: const EdgeInsets.all(15),
                    paginatedRequest: (int page, String? searchKey) async {
                      _spercializationsList = searchKey == null
                          ? await specializationProvider
                              .fetchAndSetSpecializations(
                              userProv.token,
                              page,
                              fieldId: _selectedFiledValue != null
                                  ? _selectedFiledValue!.id
                                  : null,
                            )
                          : await specializationProvider.search(
                              userProv.token,
                              searchKey,
                              page,
                              isRefresh: prevSearchKey != searchKey,
                            );
                      if (searchKey != null) {
                        prevSearchKey = searchKey;
                      }

                      return _spercializationsList
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
                    requestItemCount: specializationProvider.limit + 1,
                    onChanged: (int? value) {
                      prevSearchKey = '';
                      debugPrint('$value');
                      if (value == null) {
                        _selectedSpecializationValue = null;
                      } else {
                        _selectedSpecializationValue = _spercializationsList
                            .firstWhere((element) => element.id == value);
                        if (mounted) {
                          setState(() {
                            _selectedSpecializationValue;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'choose_location'.tr,
                      style: Theme.of(context).textTheme.headline1,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _isLoadingMap
                      ? const LoadMoreWidget()
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: FlutterMap(
                            options: MapOptions(
                                center: LatLng(currentLatLng!.latitude,
                                    currentLatLng!.longitude),
                                controller: _mapController,
                                keepAlive: true,
                                zoom: 18,
                                interactiveFlags: interActiveFlags,
                                onTap: _handleTap),
                            layers: [
                              TileLayerOptions(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                                userAgentPackageName:
                                    'dev.fleaflet.flutter_map.example',
                              ),
                              MarkerLayerOptions(markers: markers)
                            ],
                          ),
                        ),
                ],
              ),
            ),
    );
  }
}
