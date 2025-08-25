//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotify_app/Screens/settings_screen.dart';
import 'package:spotify_app/models/category.dart';
import 'package:spotify_app/services/category_operations.dart';
import 'package:spotify_app/models/music.dart';
import 'package:spotify_app/services/music_operations.dart';

class Home extends StatefulWidget {
  final Function _miniPlayer;
  Home(this._miniPlayer);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  Widget createCategory(Category category) {
    return Container(
        color: Colors.blueGrey.shade400,
        child: Row(
          children: [
            SizedBox(
                width: 50,
                height: 50,
                child: Image.network(category.imageURL, fit: BoxFit.cover)),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                category.name,
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ));
  }

  List<Widget> createListOfCategories() {
    List<Category> categoryList =
        CategoryOperations.getCategories(); // received data into List
    //Convert Data list into map function
    List<Widget> categories = categoryList
        .map((Category category) => createCategory(category))
        .toList();
    return categories;
  }

  Widget createMusic(Music music) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            child: InkWell(
              onTap: () {
                widget._miniPlayer(music);
              },
              child: Image.network(
                music.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            music.name,
            style: TextStyle(color: Colors.white),
          ),
          Text(
            music.desc,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget createMusicList(String label) {
    List<Music> musicList = MusicOperations.getMusic();
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createMusic(musicList[index]);
              },
              itemCount: musicList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget createGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 280,
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // prevent internal scrolling
        childAspectRatio: 5 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: createListOfCategories(),
        crossAxisCount: 2,
      ),
    );
  }

  Widget createAppBar(BuildContext context, String message) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      title: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          },
          icon: Icon(Icons.settings),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Container(
        child: Column(
          children: [
            createAppBar(context, "Good morning"),
            SizedBox(
              height: 5,
            ),
            createGrid(),
            createMusicList('Music For you'),
            createMusicList('Popular PlayList'),
          ],
        ),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blueGrey.shade300, Colors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.1, 0.3])),
        // child: Text("Hello Flutter"),
        // color : Colors.orange,
      )),
    );
  }
}
