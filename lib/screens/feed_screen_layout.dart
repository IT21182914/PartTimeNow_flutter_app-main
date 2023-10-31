import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parttimenow_flutter/Widgets/post_card.dart';
import 'package:parttimenow_flutter/Widgets/shimmer_post_card.dart';
import 'package:parttimenow_flutter/models/filter_model.dart';
// import 'package:parttimenow_flutter/screens/category_selection_screen.dart';
import 'package:parttimenow_flutter/screens/filter_feed_screen.dart';
import 'package:parttimenow_flutter/screens/notification_screen.dart';
import 'package:parttimenow_flutter/screens/select_location_screen.dart';
import 'package:parttimenow_flutter/utils/colors.dart';

class FeedScreenLayout extends StatefulWidget {
  const FeedScreenLayout({super.key});

  @override
  State<FeedScreenLayout> createState() => _FeedScreenLayoutState();
}

class _FeedScreenLayoutState extends State<FeedScreenLayout> {
  Map<String, dynamic> filteredData = {};
  List notilist =[1,2,3,4];

  String gender = "male";

  void navigateToFilter(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FilterFeedScreen(
          callback: getLocation,
          filterStat: filteredData,
        ),
      ),
    );
  }

  void navigateToSearch(context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SelectLocationScreen(),
      ),
    );
  }

  void showDialog({
    required context,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return SizedBox(
          child: FilterFeedScreen(
            callback: getLocation,
            filterStat: filteredData,
          ),
        );
      },
    );
  }

  void showShrim({
    required context,
    required List notilist
  }) {
    notilist.add(9);
    Navigator.of(context).push(
      MaterialPageRoute(
        // builder: (context) => const CategorySelectionScreen(),
        

        builder: (context) =>   NotificationScreen(notificationsList: notilist,),
      ),
    );
  }

  void getLocation(Map<String, dynamic> data) {
    setState(() {
      filteredData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    FilterModel filterModel = FilterModel.fromList(filteredData);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: mobileBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          SizedBox(
            width: 45,
            height: 45,
            child: Card(
              elevation: 0,
              shape: const CircleBorder(),
              color: Colors.white,
              child: IconButton(
                onPressed: () {
                  showDialog(context: context);
                },
                icon: const Icon(
                  color: navActivaeColor,
                  Icons.format_indent_increase_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          SizedBox(
            width: 45,
            height: 45,
            child: Card(
              margin: const EdgeInsets.only(right: 10),
              elevation: 0,
              shape: const CircleBorder(),
              color: Colors.white,
              child: IconButton(
                onPressed: () {
                  showShrim(context: context, notilist: notilist);
                },
                icon: const Icon(
                  color: navActivaeColor,
                  Icons.notifications,
                  size: 20,
                ),
              ),
            ),
          )
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where("gender",
                whereIn: filterModel.male != null && filterModel.female != null
                    ? null
                    : (filterModel.male != null
                        ? ["male", "both"]
                        : (filterModel.female != null
                            ? ["female", "both"]
                            : null)))
            .where("location",
                isEqualTo: filterModel.location != null
                    ? filterModel.location?.toLowerCase()
                    : filterModel.location)
            .where("category",
                isEqualTo: filterModel.category != null
                    ? filterModel.category?.toLowerCase()
                    : filterModel.category)
            .where("salary",
                isGreaterThanOrEqualTo: filterModel.startSal != null
                    ? int.parse(filterModel.startSal!)
                    : null)
            .where("salary",
                isLessThanOrEqualTo: filterModel.endSal != null
                    ? int.parse(filterModel.endSal!)
                    : null)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 2,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: const ShrimmerPostCard(),
              ),
            );
          }
          if (!snapshot.hasData ||
              snapshot.data != null && snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Data",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Error",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.active) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index) => Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                child: PostCard(
                  snap: snapshot.data?.docs[index].data(),
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: 2,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: const ShrimmerPostCard(),
            ),
          );
        },
      ),
    );
  }
}