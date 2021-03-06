import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saraka/blocs.dart';
import 'package:saraka/constants.dart';
import 'package:saraka/widgets.dart';
import './add_button.dart';
import './synthesize_button.dart';
import './word_input.dart';

Future<void> showNewCardDialog({@required context}) {
  assert(context != null);

  return showFancyPopupDialog(
    context: context,
    pageBuilder: (context, _, __) => MultiProvider(
          providers: [
            StatefulProvider<CardListBloc>(
              valueBuilder: (_) =>
                  Provider.of<CardListBlocFactory>(context).create(),
            ),
            StatefulProvider<CardAdderBloc>(
              valueBuilder: (_) =>
                  Provider.of<CardAdderBlocFactory>(context).create()
                    ..initialize()
                    ..onComplete.listen((_) {
                      Navigator.of(context).pop();
                    })
                    ..onError.listen((error) {
                      Navigator.of(context).pop();
                    }),
            ),
            StatefulProvider<SynthesizerBloc>(
              valueBuilder: (_) =>
                  Provider.of<SynthesizerBlocFactory>(context).create(),
            ),
          ],
          child: _NewCardDialog(),
        ),
  );
}

class _NewCardDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () => _onWillPop(context),
        child: Material(
          shape: SuperellipseShape(
            borderRadius: BorderRadius.circular(24),
          ),
          clipBehavior: Clip.antiAlias,
          color: SarakaColors.white,
          elevation: 6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WordInput(),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8),
                      child: SynthesizeButton(),
                    ),
                    Expanded(child: Container()),
                    Padding(
                      padding: EdgeInsets.only(bottom: 16, right: 16),
                      child: AddButton(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Future<bool> _onWillPop(BuildContext context) async {
    final cardAdderBloc = Provider.of<CardAdderBloc>(context);

    return cardAdderBloc.state.value == CardAddingState.initial;
  }
}
