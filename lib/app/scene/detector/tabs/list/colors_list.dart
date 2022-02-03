import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:flutter/material.dart';

class ColorsListTab extends StatelessWidget {
  const ColorsListTab(this._colorsEntityList, this.removeFromFavourites,
      this.saveFavouritesToFile,
      {Key? key})
      : super(key: key);

  final List<ColorsSheetItemEntity> _colorsEntityList;
  final Function(int) removeFromFavourites;
  final Function() saveFavouritesToFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _favColorsAppBar(),
      body: _colorsEntityList.isEmpty
          ? const Center(child: Text("Nothing here..."))
          : _favColorsListView(),
    );
  }

  AppBar _favColorsAppBar() {
    return AppBar(
      leading: TextButton(
        style: ButtonStyle(
          foregroundColor:
              MaterialStateColor.resolveWith((states) => Colors.white),
          overlayColor:
              MaterialStateColor.resolveWith((states) => Colors.white12),
        ),
        child: const Icon(Icons.save),
        onPressed: () {
          saveFavouritesToFile();
        },
      ),
      title: const Text("Favourite colors"),
      backgroundColor: Colors.black,
    );
  }

  Widget _favColorsListView() {
    return ListView.builder(
      itemCount: _colorsEntityList.length,
      itemBuilder: (context, index) {
        int position = index;
        index = _colorsEntityList.length - index - 1;

        Color colorToSave =
            _colorToSave(_colorsEntityList.elementAt(index).code);

        return _itemFavColorListView(context, colorToSave, index, position);
      },
    );
  }

  Widget _itemFavColorListView(
      BuildContext context, Color colorToSave, int index, int position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: position.isEven ? Colors.black12 : Colors.white,
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.1,
            height: MediaQuery.of(context).size.width * 0.1,
            color: colorToSave,
          ),
          Expanded(
              flex: 4,
              child:
                  Text(" code: #${_colorsEntityList.elementAt(index).code} ")),
          Expanded(
              flex: 5,
              child: Text("name: ${_colorsEntityList.elementAt(index).name}")),
          Expanded(
            flex: 1,
            child: Center(
              child: TextButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(0)),
                  foregroundColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black54),
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black12),
                ),
                child: const Icon(
                  Icons.delete_forever,
                ),
                onPressed: () {
                  removeFromFavourites(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _colorToSave(String code) {
  int r = int.parse(code.substring(0, 2), radix: 16);
  int g = int.parse(code.substring(2, 4), radix: 16);
  int b = int.parse(code.substring(4, 6), radix: 16);

  return Color.fromARGB(255, r, g, b);
}
