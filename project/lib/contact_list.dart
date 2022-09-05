import 'package:flutter/material.dart';
import 'package:project/dataset.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool isTimeAgoFormat = false;
  late SharedPreferences sharedPreferences;
  List<Map<String, String>> contactList = [];

  String convertTime(bool isTimeAgo, String dateTimeInString) {
    DateTime dateTime = DateTime.parse(dateTimeInString);
    if (isTimeAgo) {
      return timeago.format(dateTime);
    }
    return dateTimeInString;
  }

  void shareContact(Map<String, String> contact) {
    Share.share(
      '''
User Name: ${contact["user"]}
Phone Number: ${contact["phone"]}
Check In: ${contact["check-in"]}
''',
    );
  }

  void sortContactList(List<Map<String, String>> cList) {
    cList.sort((a, b) {
      return (b['check-in'] as String).compareTo(a['check-in'] as String);
    });
  }

  void addItem() {
    if (contactList.length != contacts.length) {
      setState(() {
        contactList.addAll(
            contacts.sublist(contactList.length, contactList.length + 5));
        sortContactList(contactList);
      });
    }
  }

  Future<void> getSharedPreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('isTimeAgoFormat') != null) {
      setState(() {
        isTimeAgoFormat = sharedPreferences.getBool('isTimeAgoFormat')!;
      });
    }
  }

  Future<void> setSharedPreference() async {
    setState(() {
      isTimeAgoFormat = !isTimeAgoFormat;
    });
    await sharedPreferences.setBool('isTimeAgoFormat', isTimeAgoFormat);
  }

  @override
  void initState() {
    super.initState();
    contactList.addAll(contacts.take(15));
    sortContactList(contactList);
    getSharedPreference();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Flutter Assessment"),
          actions: [
            Row(
              children: [
                const Text("TimeAgo: "),
                Switch(
                    activeColor: Colors.red,
                    value: isTimeAgoFormat,
                    onChanged: (value) async {
                      setSharedPreference();
                    }),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            addItem();
          },
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                if (contactList.length == index) {
                  if (contactList.length == contacts.length) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Colors.grey),
                      child: const Text(
                        "You have reached end of the list",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return const SizedBox();
                }
                return ListTile(
                  title: Text(contactList[index]["user"].toString()),
                  subtitle: Text(contactList[index]["phone"].toString()),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(convertTime(isTimeAgoFormat,
                          contactList[index]["check-in"].toString())),
                      IconButton(
                          onPressed: () {
                            shareContact(contactList[index]);
                          },
                          icon: const Icon(Icons.share))
                    ],
                  ),
                );
              },
              itemCount: contactList.length + 1),
        ),
      ),
    );
  }
}