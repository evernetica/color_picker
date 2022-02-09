import 'package:color_picker/app/scene/detector/tabs/list/color_info_card.dart';
import 'package:color_picker/app/scene/detector/tabs/list/cubit/colors_list_cubit.dart';
import 'package:color_picker/app/scene/detector/tabs/list/cubit/colors_list_state.dart';
import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:color_picker/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocProvider(
      create: (context) => ColorsListCubit(),
      child: BlocBuilder<ColorsListCubit, ColorsListState>(
        builder: (context, state) {
          return _colorsEntityList.isNotEmpty
              ? _favColorsListView(state)
              : Center(child: Text(l10n?.emptyListPlaceholder ?? ""));
        },
      ),
    );
  }

  Widget _favColorsListView(ColorsListState state) {
    return ListView.builder(
      itemCount: _colorsEntityList.length,
      itemBuilder: (context, index) {
        int position = index;
        index = _colorsEntityList.length - index - 1;

        Color colorToSave =
            _colorToSave(_colorsEntityList.elementAt(index).code);

        return _itemFavColorsListView(
            context, colorToSave, index, position, state);
      },
    );
  }

  Widget _itemFavColorsListView(BuildContext context, Color colorToSave,
      int index, int position, ColorsListState state) {
    TextStyle textStyle = const TextStyle(
      inherit: false,
      color: Colors.black,
    );

    return Container(
      color: position.isEven ? Colors.black12 : Colors.white,
      child: Column(
        children: [
          _colorInfoRow(context, index, colorToSave, textStyle,
              index == state.colorInfoIndex),
          if (index == state.colorInfoIndex)
            ColorInfoCard(
              colorToSave: colorToSave,
            ),
        ],
      ),
    );
  }

  Widget _colorInfoRow(BuildContext context, int index, Color colorToSave,
      TextStyle textStyle, bool isCardOpened) {
    return TextButton(
      onPressed: () {
        BlocProvider.of<ColorsListCubit>(context)
            .setColorInfoIndex(index: index);
      },
      style: ButtonStyle(
        padding: MaterialStateProperty.resolveWith((states) => EdgeInsets.zero),
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.black26),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _colorIcon(context, colorToSave),
            Expanded(
              flex: 4,
              child: _colorCodeText(_colorsEntityList, index, textStyle),
            ),
            Expanded(
              flex: 5,
              child: _colorNameText(_colorsEntityList, index, textStyle),
            ),
            Expanded(
              flex: 1,
              child: _expandCardIcon(isCardOpened),
            ),
            Expanded(
              flex: 1,
              child: _deleteColorButton(context, removeFromFavourites, index),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _colorIcon(BuildContext context, Color color) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.1,
    height: MediaQuery.of(context).size.width * 0.1,
    color: color,
  );
}

Widget _colorCodeText(List<ColorsSheetItemEntity> colorsEntityList, int index,
    TextStyle textStyle) {
  return Text(
    " ${l10n?.savedColorCodeText} #${colorsEntityList.elementAt(index).code} ",
    style: textStyle,
  );
}

Widget _colorNameText(List<ColorsSheetItemEntity> colorsEntityList, int index,
    TextStyle textStyle) {
  return Text(
    "${l10n?.savedColorNameText} ${colorsEntityList.elementAt(index).name}",
    style: textStyle,
  );
}

Widget _expandCardIcon(bool isCardOpened) {
  return FittedBox(
    child: Icon(
      isCardOpened
          ? Icons.arrow_drop_up_rounded
          : Icons.arrow_drop_down_rounded,
      color: Colors.black54,
    ),
  );
}

Widget _deleteColorButton(
    BuildContext context, Function(int index) callback, int index) {
  return Center(
    child: TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0)),
        foregroundColor:
            MaterialStateColor.resolveWith((states) => Colors.black54),
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.black12),
      ),
      child: const Icon(
        Icons.delete_forever,
      ),
      onPressed: () {
        callback(index);
        BlocProvider.of<ColorsListCubit>(context).setColorInfoIndex();
      },
    ),
  );
}

Color _colorToSave(String code) {
  int r = int.parse(code.substring(0, 2), radix: 16);
  int g = int.parse(code.substring(2, 4), radix: 16);
  int b = int.parse(code.substring(4, 6), radix: 16);

  return Color.fromARGB(255, r, g, b);
}
