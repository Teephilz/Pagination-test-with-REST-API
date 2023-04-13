import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final baseUrl= "https://jsonplaceholder.typicode.com/posts";
  int page =0;
  final int _limit= 20;


  bool _isFirstLoadRunning= false;
  bool isLoadMoreRunning =false;
  bool hasNextPage=true;

  List posts=[];

  void _firstLoad() async{
    setState(() {
      _isFirstLoadRunning = true;
    });
    try{
      final res =
          await http.get(Uri.parse("$baseUrl?_page=$page&_limit=$_limit"));
      setState(() {
        posts= json.decode(res.body);
      });
    } catch(err){
      if(kDebugMode){
        print("Somethimg went wrong");
      }
    }
    setState(() {
      _isFirstLoadRunning= false;
    });
  }


  void loadMore() async{
    if(hasNextPage== true &&
    _isFirstLoadRunning == false &&
    isLoadMoreRunning == false &&
    _controller.position.extentAfter < 300){

      setState(() {
        isLoadMoreRunning = true;
      });
      page += 1;

       try{
         final res= await http.get(Uri.parse("$baseUrl?_page=$page&_limit=$_limit"));
         final List fetchedPost = json.decode(res.body);
         if(fetchedPost.isNotEmpty){
           setState(() {
             posts.addAll(fetchedPost);
           });
         }
         else{
           setState(() {
             hasNextPage= false;
           });
         }

       }catch(err){
         if(kDebugMode){
           print("Something went wrong");
         }
       }
      setState(() {
        isLoadMoreRunning = false;
      });
    }
  }

  late ScrollController _controller;
  @override
  void initState() {
    _firstLoad();
    _controller= ScrollController()..addListener(loadMore);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your News", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isFirstLoadRunning? Center(
        child:  CircularProgressIndicator(),
      ):
          Column(
            children: [
              Expanded(child:
              ListView.builder(
                controller: _controller,
                itemCount: posts.length,
                  itemBuilder: (_, index)=>
                  Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10
                    ),
                   child:
                    ListTile(
                      title: Text(posts[index]["title"]),
                      subtitle: Text(posts[index]["body"]),
                    ),
                  )
              )),
              if(isLoadMoreRunning ==true)
                 Padding(
                    padding: EdgeInsets.only(top: 10,bottom: 40),
                 child: Center(
                   child: CircularProgressIndicator(),
                 ),),
              if(hasNextPage ==false)
                Container(
                  padding: EdgeInsets.only(top: 30, bottom: 40),
                  color: Colors.amber,
                  child: Center(
                    child: Text("You have fetched all the contents"),
                  ),
                )

            ],
          )
    );
  }
}
