import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 3, 229, 173)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

  var current = WordPair.random();
  var history = <WordPair>[];

  void getNext() {
    history.add(current);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

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
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex){
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
      throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: true  ,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatefulWidget {
  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  // Declare the ScrollController
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Dispose when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
  
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the contents vertically
        crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
        children: [
          // Scrollable history list
          Expanded(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Fade out at the top
                  Colors.black,       // Fully visible below
                ],
                stops: [0.1, 1],     // Fade spans top 50%
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: FavsScrollWidget(scrollController: _scrollController, appState: appState),
            ),
          ),

          // BigCard remains centered
          Center(
            child: BigCard(pair: pair),
          ),
          const SizedBox(height: 10),

          // Buttons remain centered below BigCard
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair);
                },
                icon: Icon(icon),
                label: const Text('Like'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  var appState = context.read<MyAppState>(); // Use read instead of watch

                  appState.getNext();

                  // Scroll to bottom after next word is added
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                    });
                  },
                  child: const Text('Next'),
                ),
            ],
          ),

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35, // 50% of screen height
          )
        ],
      ),
    );
  }
}

class FavsScrollWidget extends StatefulWidget {
  const FavsScrollWidget({
    super.key,
    required ScrollController scrollController,
    required this.appState,
  }) : _scrollController = scrollController;

  final ScrollController _scrollController;
  final MyAppState appState;

  @override
  State<FavsScrollWidget> createState() => _FavsScrollWidgetState();
}

class _FavsScrollWidgetState extends State<FavsScrollWidget> {

  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    return SingleChildScrollView(
      controller: widget._scrollController,
      child: Column(
        children: widget.appState.history
            .map((pair) => GestureDetector(
                  onTap: () {
                    widget.appState.toggleFavorite(pair); // Toggle favorite on tap
                  },
                  child: Container(
                    padding: EdgeInsets.all(8), // Optional padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.appState.favorites.contains(pair)
                            ? Icons.favorite
                            : Icons.favorite_border,
                            color: Theme.of(context).colorScheme.primary
                        ),

                        SizedBox(width: 10),

                        Text(
                          pair.asPascalCase,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: widget.appState.favorites.contains(pair)
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        SizedBox(width: 10),

                        GestureDetector(
                          onTap: () => appState.removeWordPair(pair),
                          child: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}



class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);

    var styleFavrOne = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    );
    var styleFavrTwo = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w500,
      fontSize: 18,
    );

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    void favClicked(WordPair wordPair) {
      appState.toggleFavorite(wordPair);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have ${appState.favorites.length} favorites:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250, // Each item will be at most 200 pixels wide
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3, // Width / Height ratio
            ),
            itemCount: appState.favorites.length,
            itemBuilder: (context, index) {
              final pair = appState.favorites[index];
              return GestureDetector(
                onTap: () => favClicked(pair),
                child: Card(
                  elevation: 4,
                  color: theme.colorScheme.primary,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: theme.colorScheme.onPrimary
                        ),
                        SizedBox(width: 8),
                        Text(
                          appState.capitalize(pair.first),
                          style: styleFavrOne,
                        ),
                        Text(
                          appState.capitalize(pair.second),
                          style: styleFavrTwo,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class BigCard extends StatefulWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> {
  @override
  Widget build(BuildContext context) {

    var appState = context.watch<MyAppState>();

    var theme = Theme.of(context);

    var styleNormOne = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w400,
    );
    var styleFavrOne = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w700,
    );
    var styleNormTwo = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w200,
    );
    var styleFavrTwo = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w400,
    );

    void removeCurrent(WordPair pair){
      appState.getNext();
      appState.history.remove(pair);
      appState.favorites.remove(pair);
    }

    return Card(
      elevation: 5,
      shadowColor: theme.colorScheme.primary,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [

            GestureDetector(
              onTap: () => appState.toggleFavorite(widget.pair),
              child: Icon(appState.favorites.contains(appState.current) 
                ? Icons.favorite
                : Icons.favorite_border,
                color: theme.colorScheme.onPrimary,
                size: 40
              ),
            ),

            SizedBox(width: 10),

            Text(appState.capitalize(widget.pair.first),
              style: appState.favorites.contains(appState.current) ? styleFavrOne : styleNormOne,
              semanticsLabel: widget.pair.asPascalCase,
            ),

            Text(appState.capitalize(widget.pair.second),
              style: appState.favorites.contains(appState.current) ? styleFavrTwo : styleNormTwo,
              semanticsLabel: widget.pair.asPascalCase,
            ),

            SizedBox(width: 10),

            GestureDetector(
              onTap: () => removeCurrent(widget.pair),
              child: Icon(
                Icons.loop,
                color: theme.colorScheme.onPrimaryContainer,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}