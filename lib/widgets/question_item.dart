import 'package:intl/intl.dart' as intl;

import '../models/question.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionItem extends StatelessWidget {
  final Question question;
  final Function? onLongPr;
  final Function? onPr;
  const QuestionItem(this.question, {Key? key, this.onLongPr, this.onPr})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(
            question.subject,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          subtitle: Text(
            question.question,
          ),
          trailing: Text(
            Get.locale == const Locale('ar')
                ? question.fieldNameAr
                : question.fieldNameEn,
            style: TextStyle(
              color: Theme.of(context).primaryColorDark,
            ),
          ),
          onLongPress: onLongPr != null ? () => onLongPr!() : null,
          onTap: onPr != null ? () => onPr!() : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Icon(
              Icons.person,
              size: 20,
            ),
            const SizedBox(
              width: 4,
            ),
            Flexible(
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyText2,
                  text: question.userName,
                ),
              ),
            ),
            /* Text(
              'question.userName question.userNamequestion.userNamequestion.userNamequestion.userNamequestion.userNamequestion.userNamequestion.userNamequestion.userName',
              overflow: TextOverflow.ellipsis,
            ), */
            const SizedBox(
              width: 4,
            ),
            Text((intl.DateFormat('yyyy/MM/dd'))
                .format(DateTime.parse(question.createdAt))),
          ],
        )
      ],
    );
  }
}
