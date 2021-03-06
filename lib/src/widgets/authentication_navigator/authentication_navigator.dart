import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:saraka/blocs.dart';
import './signed_in_route.dart';
import './signed_out_route.dart';
import './undecided_route.dart';

class AuthenticationNavigator extends StatefulWidget {
  AuthenticationNavigator({
    Key key,
    @required this.signedInBuilder,
    @required this.signedOutBuilder,
    @required this.undecidedBuilder,
  })  : assert(signedInBuilder != null),
        assert(signedOutBuilder != null),
        assert(undecidedBuilder != null),
        super(key: key);

  final WidgetBuilder signedInBuilder;

  final WidgetBuilder signedOutBuilder;

  final WidgetBuilder undecidedBuilder;

  @override
  State<StatefulWidget> createState() => _AuthenticationNavigatorState();
}

class _AuthenticationNavigatorState extends State<AuthenticationNavigator> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  StreamSubscription _subscription;

  bool isInitialized = false;

  User _previousUser;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final authenticationBloc = Provider.of<AuthenticationBloc>(context);

      _subscription = authenticationBloc.user.listen((user) {
        if (isInitialized == false) {
          if (user == null) {
            _navigatorKey.currentState
                .pushNamedAndRemoveUntil('/signed_out', (_) => false);
          } else {
            _navigatorKey.currentState
                .pushNamedAndRemoveUntil('/signed_in', (_) => false);
          }

          isInitialized = true;
        } else if (_previousUser == null && user != null) {
          _navigatorKey.currentState
              .pushNamedAndRemoveUntil('/signed_in', (_) => false);
        } else if (_previousUser != null && user == null) {
          _navigatorKey.currentState
              .pushNamedAndRemoveUntil('/signed_out', (_) => false);
        }

        _previousUser = user;
      });
    });
  }

  @override
  void dispose() {
    _subscription ?? _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case "/":
              return UndecidedRoute(
                settings: settings,
                child: widget.undecidedBuilder(context),
              );
            case "/signed_in":
              return SignedInRoute(
                settings: settings,
                child: widget.signedInBuilder(context),
              );
            case "/signed_out":
              return SignedOutRoute(
                settings: settings,
                child: widget.signedOutBuilder(context),
              );
          }
        },
        initialRoute: "/",
      );
}
