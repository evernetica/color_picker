import 'package:color_picker/domain/entities/colors_sheet_item_entity.dart';
import 'package:flutter/material.dart';

class ColorsListTab extends StatelessWidget {
  const ColorsListTab(this._colorsEntityList, {Key? key}) : super(key: key);

  final List<ColorsSheetItemEntity> _colorsEntityList;

  @override
  Widget build(BuildContext context) {
    return _colorsEntityList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _colorsEntityList.length,
            itemBuilder: (context, index) => Row(
              children: [
                Text(
                    "code: ${_colorsEntityList.elementAt(index).code} name: ${_colorsEntityList.elementAt(index).name} "),
              ],
            ),
          );
  }
}
