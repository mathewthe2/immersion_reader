import 'package:flutter/cupertino.dart';
import 'package:immersion_reader/data/reader/book.dart';
import 'package:immersion_reader/utils/reader/ttu_source.dart';
import 'package:immersion_reader/widgets/my_books/book_widget.dart';

class MyBooksWidget extends StatefulWidget {
  const MyBooksWidget({super.key});

  @override
  State<MyBooksWidget> createState() => _MyBooksWidgetState();
}

class _MyBooksWidgetState extends State<MyBooksWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Book>>(
        future: TtuSource.getBooksHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
                height: 400,
                child: GridView.builder(
                    // shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.8),
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BookWidget(book: snapshot.data![index]);
                    }));
            //return BookWidget(book: snapshot.data![0]);
          } else {
            return Container();
          }
        });
  }
}
