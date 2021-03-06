import 'package:flutter/material.dart' show Material;
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:saraka/blocs.dart';
import 'package:saraka/constants.dart';
import './maturity_description.dart';
import './maturity_line_chart.dart';
import './menu_icon_button.dart';
import './next_review_date_description.dart';
import './synthesize_icon_button.dart';

class CardListViewItem extends StatelessWidget {
  CardListViewItem({
    Key key,
    @required this.card,
    this.showDetail = true,
  })  : assert(card != null),
        super(key: key);

  final Card card;

  final bool showDetail;

  Widget build(BuildContext context) =>
      Consumer2<CardDetailBlocFactory, SynthesizerBlocFactory>(
        builder: (context, cardDetailBlocFactory, synthesizerBlocFactory) =>
            MultiProvider(
              providers: [
                Provider<CardDetailBloc>(
                  value: cardDetailBlocFactory.create(card),
                ),
                Provider<SynthesizerBloc>(
                  value: synthesizerBlocFactory.create(),
                ),
              ],
              child: Material(
                shape:
                    SuperellipseShape(borderRadius: BorderRadius.circular(24)),
                elevation: 6,
                shadowColor: SarakaColors.darkGray.withOpacity(0.25),
                color: Color(0xffffffff),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: EdgeInsets.only(right: 64, bottom: 24),
                        child: MaturityLineChart(),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 16,
                                  left: 16,
                                  right: 8,
                                ),
                                child: Text(
                                  card.text,
                                  overflow: TextOverflow.ellipsis,
                                  style: SarakaTextStyles.heading,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 4, right: 4),
                              child: MenuIconButton(),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 8,
                            left: 8,
                            right: 24,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SynthesizeIconButton(text: card.text),
                            ]..addAll(showDetail
                                ? [
                                    Expanded(child: Container()),
                                    SizedBox(width: 32),
                                    SizedBox(
                                      width: 96,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: NextReviewDateDescription(
                                          nextReviewScheduledAt:
                                              card.nextReviewScheduledAt,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 32),
                                    SizedBox(
                                      width: 64,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: MaturityDescription(
                                            maturity: card.maturity),
                                      ),
                                    ),
                                  ]
                                : []),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );
}
