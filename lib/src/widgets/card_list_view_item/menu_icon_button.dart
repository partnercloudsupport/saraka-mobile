import 'package:flutter/material.dart' show PopupMenuItem, showMenu;
import 'package:flutter/material.dart' show IconButton;
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:saraka/blocs.dart';
import 'package:saraka/constants.dart';
import 'package:saraka/widgets.dart';

class MenuIconButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Feather.getIconData('more-vertical'),
        color: SarakaColors.darkGray,
      ),
      onPressed: () => onPressed(context),
    );
  }

  void onPressed(BuildContext context) async {
    final RenderBox self = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    final selectedItem = await showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          self.localToGlobal(Offset.zero, ancestor: overlay),
          self.localToGlobal(self.size.bottomRight(Offset.zero),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      ),
      items: [
        const PopupMenuItem(
          value: "",
          child: Text(
            "Delete",
            style: TextStyle(
              color: SarakaColors.lightRed,
              fontFamily: SarakaFonts.rubik,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    if (selectedItem != null) {
      final card = Provider.of<CardDetailBloc>(context).card;

      showCardDeleteConfirmDialog(
        context: context,
        card: card,
      );
    }
  }
}
