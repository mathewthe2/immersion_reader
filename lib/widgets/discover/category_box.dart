import 'package:flutter/cupertino.dart';

class CategoryBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final Function onPressed;
  const CategoryBox(
      {super.key,
      required this.text,
      required this.isSelected,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => onPressed(),
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isSelected
                  ? const Color(0xFF9B99E9)
                  : const Color(0xFFDCD8FF),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                          color: const Color(0xff4A80F0).withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 12),
                    ]
                  : [],
            ),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Text(
                  text,
                  style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
