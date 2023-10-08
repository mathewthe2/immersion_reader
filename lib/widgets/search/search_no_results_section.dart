import 'package:flutter/cupertino.dart';

class SearchNoResultsSection extends StatelessWidget {
  const SearchNoResultsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: Center(child: Text("No results found")));
  }
}
