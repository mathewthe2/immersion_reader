import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:immersion_reader/widgets/discover/discover_box.dart';

class RecommendedWidget extends StatelessWidget {
  const RecommendedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 10, 10),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Row(children: const [
                FaIcon(
                  FontAwesomeIcons.headphones,
                  color: CupertinoColors.black,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text('Audio Books',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18))
              ]))),
      SizedBox(
          height: 400,
          child: GridView.builder(
              // shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: MediaQuery.of(context).size.width /
                    (MediaQuery.of(context).size.height / 1.8),
              ),
              itemCount: 1,
              itemBuilder: (BuildContext context, int index) {
                return const DiscoverBox(title: "あひるさん と 時計");
              }))
      // const DiscoverBox(title: "あひるさん と 時計")
    ]);
  }
}
