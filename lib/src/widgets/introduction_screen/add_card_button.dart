import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:saraka/blocs.dart';
import 'package:saraka/constants.dart';
import 'package:saraka/widgets.dart';

class AddCardButton extends StatelessWidget {
  AddCardButton({Key key, @required this.onPressed})
      : assert(onPressed != null),
        super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer<FirstCardListBloc>(
      builder: (context, firstCardListBloc) => StreamBuilder<List<Card>>(
            stream: firstCardListBloc.firstCards,
            initialData: firstCardListBloc.firstCards.value,
            builder: (context, snapshot) => ProcessableFancyButton(
                  color: SarakaColors.lightRed,
                  onPressed: onPressed,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.getIconData("plus"),
                        color: SarakaColors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        snapshot.requireData.isEmpty
                            ? "Add First Card"
                            : "Add More",
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}
