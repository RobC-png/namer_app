// libs
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

//Pages
import 'myHomePage.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await Hive.initFlutter();
  await Hive.openBox("My_Box");

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 247, 4, 4)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

  var current = WordPair.random();
  var history = <WordPair>[];
  var favorites = <WordPair>[];
  final _MyBox = Hive.box("My_box");

  MyAppState() {
    LoadWPFromDB(); // <-- Load favorites from DB on startup
  }

  void getNext() {
    history.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite(WordPair pair) {
    if (favorites.contains(pair)){
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  void removeWordPair(WordPair pair){
      favorites.remove(pair);
      history.remove(pair);
      notifyListeners();
  }

  void SaveWPToDB(){

    var SaveableFavs = <List<String>>[];

    for (WordPair pair in favorites){
      SaveableFavs.add([pair.first, pair.second]);
    }

    _MyBox.put('favs', SaveableFavs);
  }

  void LoadWPFromDB(){
    // Get the saved list from Hive
    var favoritesTemp = _MyBox.get('favs', defaultValue: <List<String>>[]);

    // Convert List<List<String>> to List<WordPair>
    favorites = (favoritesTemp as List)
      .map<WordPair>((item) => WordPair(item[0], item[1]))
      .toList();

    for (WordPair pair in favorites){
      if (!history.contains(pair)){
        history.add(pair);
      }
    }

    notifyListeners();
  }
}