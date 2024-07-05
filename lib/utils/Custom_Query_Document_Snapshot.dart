// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class CustomQueryDocumentSnapshot extends DocumentSnapshot<Object?> implements QueryDocumentSnapshot<Object?> {
//   final DocumentSnapshot<Object?> snapshot;
//
//   CustomQueryDocumentSnapshot(this.snapshot)
//       : super(snapshot.reference, snapshot.data(), snapshot.metadata);
//
//   @override
//   Object? operator [](Object? field) => snapshot[field];
//
//   @override
//   Map<String, dynamic>? data() => snapshot.data() as Map<String, dynamic>?;
//
//   @override
//   SnapshotMetadata get metadata => snapshot.metadata;
//
//   @override
//   String get id => snapshot.id;
//
//   @override
//   bool get exists => snapshot.exists;
//
//   @override
//   DocumentReference<Object?> get reference => snapshot.reference;
//
//   @override
//   Object? get(Object field) => snapshot.get(field);
// }
