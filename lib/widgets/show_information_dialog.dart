import 'package:ask_me/functions/open_map.dart';
import 'package:ask_me/models/http_exception.dart';
import 'package:ask_me/providers/specialist_provider.dart';
import 'package:ask_me/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../functions/launch_email.dart';
import '../functions/launch_phone.dart';
import '../providers/user_provider.dart';
import 'circle_cached_image.dart';
import 'load_more_horizontal_widget.dart';

Future<void> showInformationDialog({
  required BuildContext context,
  required int userId,
  required String userEmail,
  required String userPhone,
  required String? userProfileImage,
  required String userName,
  double? userRating,
  double? userLat,
  double? userLng,
  String? userFieldNameAr,
  String? userFieldNameEn,
  String? userSpecializationNameAr,
  String? userSpecializationNameEn,
}) async {
  var isLoading = false;
  Placemark? first;
  if (userLat != null && userLng != null) {
    try {
      final addresses = await placemarkFromCoordinates(
        userLat,
        userLng,
      );
      first = addresses.first;
    } catch (error) {
      debugPrint(error.toString());
    }
  }
  showDialog(
      context: context,
      useSafeArea: true,
      builder: (cox) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Center(child: Text(userName)),
            scrollable: true,
            content: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleCachedImage(
                    image: userProfileImage,
                    radius: 35,
                  ),
                  userRating != null
                      ? ListTile(
                          subtitle: Center(
                              child: Text(
                            userRating.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          )),
                          title: RatingBar.builder(
                            initialRating: 1,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Theme.of(context).primaryColorDark,
                            ),
                            onRatingUpdate: (rating) async {
                              setState(() {
                                isLoading = true;
                              });
                              final newRate = await rateSpecialist(
                                userId,
                                rating.toInt(),
                                context,
                              );
                              if (newRate != null) userRating = newRate;
                              setState(() {
                                isLoading = false;
                                userRating;
                              });
                            },
                          ),
                        )
                      : Container(),
                  userFieldNameAr != null &&
                          userSpecializationNameAr != null &&
                          userFieldNameEn != null &&
                          userSpecializationNameEn != null
                      ? Text(Get.locale == const Locale('ar')
                          ? userFieldNameAr + " - " + userSpecializationNameAr
                          : userFieldNameEn + " - " + userSpecializationNameEn)
                      : Container(),
                  userLat != null && userLng != null
                      ? ListTile(
                          title: Text(first == null
                              ? 'open_in_map'.tr
                              : '${first.country}, ${first.locality}, ${first.name}\n${'open_in_map'.tr}'),
                          onTap: () => openMap(userLat, userLng),
                        )
                      : Container(),
                  const Divider(
                    thickness: 2,
                  ),
                  Text('conatact_info'.tr),
                  ListTile(
                    title: Text(
                      userEmail,
                      textDirection: TextDirection.ltr,
                    ),
                    leading: const Icon(Icons.email),
                    onTap: () => launchEmail(userEmail),
                  ),
                  ListTile(
                    title: Text(
                      userPhone,
                      textDirection: TextDirection.ltr,
                    ),
                    leading: const Icon(Icons.phone),
                    onTap: () => launchPhoneURL(userPhone),
                  ),
                ],
              ),
            ),
            actions: [
              isLoading
                  ? const LoadMoreHorizontalWidget()
                  : TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15.0)),
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
                        ),
                        child: Text(
                          'okay'.tr,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ),
                    ),
            ],
          );
        });
      });
}

Future<double?> rateSpecialist(
    int specialistId, int stars, BuildContext context) async {
  try {
    var specialistProvider =
        Provider.of<SpecialistProvider>(context, listen: false);
    final userProv = Provider.of<UserProvider>(context, listen: false);

    final result = await specialistProvider.rateSpecialist(
      specialistId,
      stars,
      userProv.token,
    );
    await specialistProvider.fetchAndSetSpecialists(userProv.token, 0,
        isRefresh: true);
    return result;
  } on HttpException catch (_) {
    showErrorDialog('add_failed'.tr, context);
  } catch (_) {
    showErrorDialog('add_failed'.tr, context);
  }
  return null;
}
