import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_app/model/like_model.dart';

/* 관심목록에 등록한 게시물 상세 페이지 */
class LikeItemDetailPage extends StatefulWidget {
  const LikeItemDetailPage({Key? key,
    required this.item,
    required this.detail,
    required this.img,
    required this.loc,
    required this.title,
    required this.user,
    required this.like_count,
    required this.view_count,
    required this.price,
    required this.id,
    required this.register_date}) : super(key: key);
  final item;
  final detail;
  final img;
  final loc;
  final title;
  final user;
  final like_count;
  final view_count;
  final price;
  final id;
  final register_date;
  @override
  LikeItemDetailPageState createState() => LikeItemDetailPageState();
}

class LikeItemDetailPageState extends State<LikeItemDetailPage> {
  late String uid = '';
  late int like_temp = widget.like_count;
  late int view_temp = widget.view_count + 1;
  int time = 0;
  var temp = '';
  var date_now;
  var year_now;
  var mon_now;
  var day_now;
  var time_now;
  late int hour_now;
  var register_print;
  Future<void> getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString('uid') ?? '';
  }
  NumberFormat format = NumberFormat('#,###');
  @override
  Widget build(BuildContext context) {
    final like_provider = Provider.of<LikeProvider>(context);
    final usercol = FirebaseFirestore.instance.collection("items").doc(widget.id);
    usercol.update({
      "view_count": view_temp,
    });
    if (time == 0) {
      DateTime dt = DateTime.now();
      temp = dt.toString();
      date_now = temp.substring(0,10);
      year_now = int.parse(temp.substring(0,4));
      mon_now = int.parse(temp.substring(5,7));
      day_now = int.parse(temp.substring(8,10));
      time_now = temp.substring(11,19); //19까지 초시간
      hour_now = int.parse(temp.substring(11,13));
      time = 1;
    }
    if ((widget.item.registerDate).substring(0,10) != date_now) {
      //ex) 2023-06-04 substring5,7 => 월, 8,10 => 일
      var register_year = int.parse((widget.item.registerDate).substring(0,4));
      var register_mon = int.parse((widget.item.registerDate).substring(5,7));
      var register_day = int.parse((widget.item.registerDate).substring(8,10));
      if (register_year == year_now) {
        if (register_mon == mon_now) {
          register_print = (day_now - register_day).toString() + '일 전';
        }
        else {
          register_print = (mon_now - register_mon).toString() + '개월 전';
        }
      }
      else {
        register_print = (year_now - register_year).toString() + '년 전';
      }
    }
    else {
      if (hour_now - int.parse(widget.item.registerDate.substring(11,13)) > 0) {
        register_print = (hour_now - int.parse(widget.item.registerDate.substring(11,13))).toString() + '시간 전';
      }
      else {
        register_print = '방금 전';
      }
    }
    getUid();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: widget.img == 'null' ?
                        Image.asset(
                            'images/no_img.jpg', fit: BoxFit.fill
                        ) :
                        Image.network(widget.img, fit: BoxFit.fill)
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.lightBlue,
                              child: Icon(Icons.person, size: 36),
                            ),
                            SizedBox(width: 10.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.user.substring(0, widget.user.indexOf('@'))),
                                Text(widget.loc)
                              ],
                            )
                          ],
                        ),
                        SizedBox(height: 10,),
                        Divider(
                          thickness: 1.0,
                        ),
                        SizedBox(height: 10,),
                        Text(
                          widget.title,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2,),
                        Text(
                          '- '+ widget.item.type + '·' + register_print,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        SizedBox(height: 2,),
                        Text(
                          '- '+ widget.item.state,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          widget.detail,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          '관심 ${like_temp} · 조회${view_temp}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Divider(thickness: 1.0,),
                SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      format.format(widget.price) + '원',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    like_provider.isItem(widget.item) ?
                    InkWell(
                      onTap: () {
                        like_temp--;
                        final usercol = FirebaseFirestore.instance.collection("items").doc(widget.item.id);
                        usercol.update({
                          "like_count": like_temp,
                        });
                        like_provider.removeItem(uid, widget.item);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    )
                        :
                    InkWell(
                      onTap: () {
                        like_temp++;
                        final usercol = FirebaseFirestore.instance.collection("items").doc(widget.item.id);
                        usercol.update({
                          "like_count": like_temp,
                        });
                        like_provider.addItem(uid, widget.item);
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}