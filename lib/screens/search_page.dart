import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shopping_app/screens/like_page.dart';
import 'package:shopping_app/screens/home_page.dart';
import 'package:shopping_app/screens/profile_page.dart';
import '../model/provider_model.dart';
import '../model/query_model.dart';
import 'item_detail_page.dart';

/* 게시물 검색 페이지 */
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.email}) : super(key: key);
  final email;
  @override
  _SearchPage createState() {
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage>{
  int _currentIndex = 1;
  int time = 0;
  var temp = '';
  var date_now;
  var year_now;
  var mon_now;
  var day_now;
  var time_now;
  late int hour_now;
  var register_print;
  NumberFormat format = NumberFormat('#,###');
  DateTime? currentBackPressTime;
  Future<bool> onWillPop(){
    DateTime now = DateTime.now();
    final msg = "'뒤로가기'버튼을 한 번 더 누르면 종료됩니다.";
    Fluttertoast.showToast(msg: msg);
    if(currentBackPressTime == null || now.difference(currentBackPressTime!)
        > Duration(seconds: 2)) {
      currentBackPressTime = now;
      return Future.value(false);
    }
    return Future.value(true);
  }
  @override
  Widget build(BuildContext context) {
    final item_provider = Provider.of<ItemProvider>(context);
    final que_provider = Provider.of<QueryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            TextField(
              onChanged: (text) {
                que_provider.updateText(text);
              },
              autofocus: true,
              decoration: InputDecoration(
                hintText: '검색',
                border: InputBorder.none,
              ),
              cursorColor: Colors.grey,
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              item_provider.find_Item(que_provider.text);
            },
            icon: Icon(Icons.search_rounded))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        iconSize: 24,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontSize: 14),
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined), label: '홈'),
          BottomNavigationBarItem(icon: Icon(_currentIndex == 1 ? Icons.saved_search : Icons.search_outlined), label: '검색'),
          BottomNavigationBarItem(icon: Icon(_currentIndex == 2 ? Icons.favorite : Icons.favorite_border), label: '관심목록'),
          BottomNavigationBarItem(icon: Icon(_currentIndex == 3 ? Icons.person : Icons.person_outlined), label: '내 정보'),
        ],
        onTap: (int index){
          setState(() {
            _currentIndex = index;
            if(index == 0){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => HomePage(
                email: widget.email,
              )), (route) => false);
            }
            if(index == 2){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LikePage(
                email: widget.email,
              )), (route) => false);
            }
            if(index == 3){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ProfilePage(
                email: widget.email,
              )), (route) => false);
            }
          });
        },
      ),
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(15),
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) => const Divider(),
                shrinkWrap: true,
                itemCount: item_provider.find_result.length,
                itemBuilder: (context, index) {
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
                  if ((item_provider.find_result[index].registerDate).substring(0,10) != date_now) {
                    //ex) 2023-06-04 substring5,7 => 월, 8,10 => 일
                    var register_year = int.parse((item_provider.find_result[index].registerDate).substring(0,4));
                    var register_mon = int.parse((item_provider.find_result[index].registerDate).substring(5,7));
                    var register_day = int.parse((item_provider.find_result[index].registerDate).substring(8,10));
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
                    register_print = (hour_now - int.parse(item_provider.find_result[index].registerDate.substring(11,13))).toString() + '시간 전';
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ItemDetailPage(
                              item: item_provider.find_result[index],
                              email: widget.email,)
                          )
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(height: 5.0,),
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                height: MediaQuery.of(context).size.width * 0.30,
                                child: Image.network(
                                  item_provider.find_result[index].img,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.45,
                              height: MediaQuery.of(context).size.width * 0.30,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5.0,),
                                  Text(
                                    item_provider.find_result[index].title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text(
                                    item_provider.find_result[index].loc + ' ' + register_print,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 3.0,),
                                  Text(
                                    format.format(item_provider.find_result[index].price) + '원',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: Column(
                                  children: [
                                    Container(height: MediaQuery.of(context).size.width * 0.3 - 24,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Icon(
                                          Icons.favorite_border,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                        Text(
                                            '${item_provider.find_result[index].like_count}',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 16,
                                            )
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                        SizedBox(height: 5.0,),
                      ],
                    ),
                  );
                }
              )
            )
          ],
        ),
      )
    );
  }
}