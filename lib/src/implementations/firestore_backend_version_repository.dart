import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:saraka/blocs.dart';

class FirestoreBackendVersionRepository implements BackendVersionGetable {
  FirestoreBackendVersionRepository({
    @required Firestore firestore,
  })  : assert(firestore != null),
        _firestore = firestore;

  final Firestore _firestore;

  @override
  Future<int> getBackendVersion() async {
    final snapshot = await _firestore
        .collection('constants')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .getDocuments();

    if (snapshot.documents.length != 1) {
      throw Error();
    }

    final int backendVersion = snapshot.documents[0].data['backendVersion'];

    return backendVersion;
  }
}
