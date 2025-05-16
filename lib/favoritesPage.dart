// libs
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//files
import 'main.dart';

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