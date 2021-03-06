import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CardMaturityDonutChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  CardMaturityDonutChart({@required this.seriesList, @required this.animate})
      : assert(seriesList != null),
        assert(animate != null);

  @override
  Widget build(BuildContext context) {
    return new charts.PieChart(seriesList,
        animate: animate,
        layoutConfig: charts.LayoutConfig(
          topMarginSpec: charts.MarginSpec.fixedPixel(0),
          bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
          leftMarginSpec: charts.MarginSpec.fixedPixel(0),
          rightMarginSpec: charts.MarginSpec.fixedPixel(0),
        ),
        defaultRenderer: new charts.ArcRendererConfig(arcWidth: 4));
  }
}

class MatureCount {
  final String title;
  final int maturity;
  final charts.Color color;

  MatureCount(this.title, this.maturity, Color color)
      : this.color = new charts.Color(
          r: color.red,
          g: color.green,
          b: color.blue,
          a: color.alpha,
        );
}
