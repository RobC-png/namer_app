// libs
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

//files
import 'main.dart';

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
                stops: [0, 0.5],     // Fade spans top 50%
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
                        _scrollController.position.minScrollExtent,
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
            //set Height based of Platform
            height: MediaQuery.of(context).size.height *
            (Platform.isAndroid ? 0.05 : 
            (Platform.isWindows) ? 0.35 : 0.5),
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
      reverse: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
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
              )).toList(),
      ),
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