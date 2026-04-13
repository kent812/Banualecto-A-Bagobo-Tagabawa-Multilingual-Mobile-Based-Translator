import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/word_model.dart';

class FirestoreService extends ChangeNotifier {
  static final FirestoreService _instance = FirestoreService._internal();
  static FirestoreService get instance => _instance;
  factory FirestoreService() => _instance;
  FirestoreService._internal() : super();

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase not initialized. Call init() first.');
    }
    return _firestore!;
  }

  FirebaseAuth get auth {
    if (_auth == null) {
      throw Exception('Firebase not initialized. Call init() first.');
    }
    return _auth!;
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _auth = FirebaseAuth.instance;
  }

  Future<List<DictionaryWord>> fetchDictionaryWords() async {
    final snapshot = await firestore.collection('dictionary').get();
    return snapshot.docs.map((doc) => DictionaryWord.fromMap(doc.data())).toList();
  }

  Future<void> syncWord(DictionaryWord word) async {
    await firestore.collection('dictionary').doc(word.id).set(word.toMap());
  }

  Future<void> deleteWord(String wordId) async {
    await firestore.collection('dictionary').doc(wordId).delete();
  }

  Stream<List<DictionaryWord>> watchDictionaryWords() {
    return firestore.collection('dictionary').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => DictionaryWord.fromMap(doc.data())).toList(),
    );
  }

  Future<void> addHistory(String wordId, Map<String, dynamic> historyData) async {
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      await firestore.collection('users').doc(userId).collection('history').add(historyData);
    }
  }

  Future<void> addBookmark(String wordId, Map<String, dynamic> bookmarkData) async {
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      await firestore.collection('users').doc(userId).collection('bookmarks').doc(wordId).set(bookmarkData);
    }
  }

  Future<void> removeBookmark(String wordId) async {
    final userId = auth.currentUser?.uid;
    if (userId != null) {
      await firestore.collection('users').doc(userId).collection('bookmarks').doc(wordId).delete();
    }
  }

  Future<List<Map<String, dynamic>>> getUserHistory() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return [];
    
    final snapshot = await firestore.collection('users').doc(userId).collection('history').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getUserBookmarks() async {
    final userId = auth.currentUser?.uid;
    if (userId == null) return [];
    
    final snapshot = await firestore.collection('users').doc(userId).collection('bookmarks').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> signInAnonymously() async {
    await auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await auth.signOut();
  }

  bool get isSignedIn => auth.currentUser != null;
  String? get currentUserId => auth.currentUser?.uid;
}
