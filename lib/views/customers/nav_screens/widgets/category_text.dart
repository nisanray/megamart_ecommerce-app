import 'package:flutter/material.dart';

class CategoryText extends StatefulWidget {
  @override
  State<CategoryText> createState() => _CategoryTextState();
}

class _CategoryTextState extends State<CategoryText> {
  final List<String> _categoryLabel = ['food', 'vegetable', 'egg', 'tea','food', 'vegetable', 'egg', 'tea','food', 'vegetable', 'egg', 'tea','food', 'vegetable', 'egg', 'tea','food', 'vegetable', 'egg', 'tea',];
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Categories",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _categoryLabel.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ActionChip(
                          label: Text(
                            _categoryLabel[index],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.deepPurpleAccent.shade700,
                          onPressed: () {
                            // Add any action here if needed
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Calculate the scroll position
                    double maxWidth = _scrollController.position.maxScrollExtent;
                    double currentPosition = _scrollController.position.pixels;
                    double newOffset = currentPosition + MediaQuery.of(context).size.width * 0.75; // Adjust the scroll distance as needed
                    if (newOffset > maxWidth) {
                      newOffset = maxWidth;
                    }
                    // Scroll to the new position
                    _scrollController.animateTo(newOffset,
                        duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                  icon: Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
