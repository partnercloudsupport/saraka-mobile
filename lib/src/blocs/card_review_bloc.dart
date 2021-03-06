import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:saraka/entities.dart';
import './commons/authenticatable.dart';

export 'package:saraka/entities.dart' show ReviewCertainty;

class CardReviewBlocFactory {
  CardReviewBlocFactory({
    @required Authenticatable authenticatable,
    @required CardReviewable cardReviewable,
    @required CardReviewLoggable cardReviewLoggable,
    @required InQueueCardSubscribable inQueueCardSubscribable,
  })  : assert(authenticatable != null),
        assert(cardReviewable != null),
        assert(inQueueCardSubscribable != null),
        _authenticatable = authenticatable,
        _cardReviewable = cardReviewable,
        _cardReviewLoggable = cardReviewLoggable,
        _inQueueCardSubscribable = inQueueCardSubscribable;

  final Authenticatable _authenticatable;

  final CardReviewable _cardReviewable;

  final CardReviewLoggable _cardReviewLoggable;

  final InQueueCardSubscribable _inQueueCardSubscribable;

  CardReviewBloc create() => _CardReviewBloc(
        authenticatable: _authenticatable,
        cardReviewable: _cardReviewable,
        cardReviewLoggable: _cardReviewLoggable,
        inQueueCardSubscribable: _inQueueCardSubscribable,
      );
}

abstract class CardReviewBloc {
  Observable<List<Card>> get cardsInQueue;

  Observable<double> get finishedRatio;

  Observable<bool> get canUndo;

  void initialize();

  void reviewedWell(Card card);

  void reviewedVaguely(Card card);

  void undo();

  void dispose();
}

class _CardReviewBloc implements CardReviewBloc {
  _CardReviewBloc({
    @required Authenticatable authenticatable,
    @required CardReviewable cardReviewable,
    @required CardReviewLoggable cardReviewLoggable,
    @required InQueueCardSubscribable inQueueCardSubscribable,
  })  : assert(authenticatable != null),
        assert(cardReviewable != null),
        assert(inQueueCardSubscribable != null),
        _authenticatable = authenticatable,
        _cardReviewable = cardReviewable,
        _cardReviewLoggable = cardReviewLoggable,
        _inQueueCardSubscribable = inQueueCardSubscribable;

  final Authenticatable _authenticatable;

  final CardReviewable _cardReviewable;

  final CardReviewLoggable _cardReviewLoggable;

  final InQueueCardSubscribable _inQueueCardSubscribable;

  final BehaviorSubject<List<Card>> _allInQueueCards =
      BehaviorSubject.seeded([]);

  final BehaviorSubject<List<Card>> _reviewedCards = BehaviorSubject.seeded([]);

  @override
  Observable<List<Card>> get cardsInQueue => Observable.combineLatest2(
        _allInQueueCards,
        _reviewedCards,
        (allCards, reviewedCards) =>
            allCards.where((card) => !reviewedCards.contains(card)).toList(),
      );

  @override
  Observable<double> get finishedRatio => Observable.combineLatest2(
        _allInQueueCards,
        _reviewedCards,
        (allCards, reviewedCards) {
          final numberOfAllCards = allCards.length;

          return numberOfAllCards == 0
              ? 0
              : reviewedCards.length / numberOfAllCards;
        },
      );

  @override
  Observable<bool> get canUndo =>
      _reviewedCards.map((reviewedCards) => reviewedCards.length > 0);

  @override
  void initialize() async {
    final cards = await _inQueueCardSubscribable
        .subscribeInQueueCards(user: _authenticatable.user.value)
        .first;

    _cardReviewLoggable.logReviewStart(cardLength: cards.length);

    _allInQueueCards.add(cards);

    finishedRatio.listen((ratio) {
      if (ratio == 1) {
        _cardReviewLoggable.logReviewEnd(
          cardLength: cards.length,
          reviewedCardLength: _reviewedCards.value.length,
        );
      }
    });
  }

  @override
  Future<void> reviewedWell(Card card) async {
    _reviewedCards.add(List.from(_reviewedCards.value)..add(card));

    _cardReviewable.review(
      card: card,
      certainty: ReviewCertainty.good,
      user: _authenticatable.user.value,
    );

    _cardReviewLoggable.logCardReview(
      certainty: ReviewCertainty.good,
    );
  }

  @override
  Future<void> reviewedVaguely(Card card) async {
    _reviewedCards.add(List.from(_reviewedCards.value)..add(card));

    _cardReviewable.review(
      card: card,
      certainty: ReviewCertainty.vague,
      user: _authenticatable.user.value,
    );

    _cardReviewLoggable.logCardReview(
      certainty: ReviewCertainty.vague,
    );
  }

  @override
  void undo() async {
    assert(_reviewedCards.value.length >= 1);

    final lastCard = _reviewedCards.value.last;

    _reviewedCards.add(List.from(_reviewedCards.value)..remove(lastCard));

    _cardReviewable.undoReview(
      card: lastCard,
      user: _authenticatable.user.value,
    );

    _cardReviewLoggable.logCardReviewUndo();
  }

  @override
  Future<void> dispose() async {
    _cardReviewLoggable.logReviewEnd(
      cardLength: _allInQueueCards.value.length,
      reviewedCardLength: _reviewedCards.value.length,
    );
  }
}

mixin CardReviewable {
  Future<void> review({
    @required Card card,
    @required ReviewCertainty certainty,
    @required User user,
  });

  Future<void> undoReview({
    @required Card card,
    @required User user,
  });
}

mixin InQueueCardSubscribable {
  Observable<List<Card>> subscribeInQueueCards({@required User user});
}

mixin CardReviewLoggable {
  Future<void> logReviewStart({@required int cardLength});

  Future<void> logReviewEnd({
    @required int cardLength,
    @required int reviewedCardLength,
  });

  Future<void> logCardReview({@required ReviewCertainty certainty});

  Future<void> logCardReviewUndo();
}

class ReviewDuplicationException implements Exception {
  ReviewDuplicationException(this.card);

  final Card card;

  String toString() =>
      'ReviewDuplicationException: `${card.id}` has been just reviewed.';
}

class ReviewOverundoException implements Exception {
  ReviewOverundoException(this.card);

  final Card card;

  String toString() =>
      'ReviewOverundoException: `${card.id}` doesn\'t have review to undo.';
}
