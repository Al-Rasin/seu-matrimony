import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../constants/firebase_constants.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Generic Firestore service for CRUD operations
class FirestoreService extends GetxService {
  FirebaseFirestore? _firestore;
  final Map<String, dynamic> _cache = {};

  FirebaseFirestore? get firestore => _firestore;

  @override
  void onInit() {
    super.onInit();
    if (isFirebaseInitialized) {
      _firestore = FirebaseFirestore.instance;

      // Enable offline persistence
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  void _ensureInitialized() {
    if (_firestore == null) {
      throw Exception('Firebase is not initialized. Check your configuration.');
    }
  }

  // ==================== GENERIC CRUD OPERATIONS ====================

  /// Create a document with auto-generated ID
  Future<String> create({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();
    data[FirebaseConstants.fieldCreatedAt] = FieldValue.serverTimestamp();
    data[FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();

    final docRef = await _firestore!.collection(collection).add(data);
    return docRef.id;
  }

  /// Create a document with specific ID
  Future<void> createWithId({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();
    data[FirebaseConstants.fieldCreatedAt] = FieldValue.serverTimestamp();
    data[FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();

    await _firestore!.collection(collection).doc(documentId).set(data);
  }

  /// Read a single document by ID
  Future<Map<String, dynamic>?> getById({
    required String collection,
    required String documentId,
    bool useCache = false,
  }) async {
    _ensureInitialized();
    final cacheKey = '$collection/$documentId';
    if (useCache && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey];
    }

    final doc = await _firestore!.collection(collection).doc(documentId).get();
    if (!doc.exists) return null;

    final data = {
      'id': doc.id,
      ...doc.data()!,
    };
    
    if (useCache) {
      _cache[cacheKey] = data;
    }
    
    return data;
  }

  /// Read a single document as stream
  Stream<Map<String, dynamic>?> getByIdStream({
    required String collection,
    required String documentId,
  }) {
    if (_firestore == null) return Stream.empty();
    return _firestore!
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    });
  }

  /// Update a document
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();
    data[FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();
    await _firestore!.collection(collection).doc(documentId).update(data);
  }

  /// Delete a document
  Future<void> delete({
    required String collection,
    required String documentId,
  }) async {
    _ensureInitialized();
    await _firestore!.collection(collection).doc(documentId).delete();
  }

  /// Check if document exists
  Future<bool> exists({
    required String collection,
    required String documentId,
  }) async {
    _ensureInitialized();
    final doc = await _firestore!.collection(collection).doc(documentId).get();
    return doc.exists;
  }

  // ==================== QUERY OPERATIONS ====================

  /// Get all documents in a collection
  Future<List<Map<String, dynamic>>> getAll({
    required String collection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    _ensureInitialized();
    Query query = _firestore!.collection(collection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  /// Get documents with where clause
  Future<List<Map<String, dynamic>>> getWhere({
    required String collection,
    required String field,
    required dynamic isEqualTo,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    _ensureInitialized();
    Query query = _firestore!.collection(collection).where(field, isEqualTo: isEqualTo);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  /// Get documents with complex query
  Future<List<Map<String, dynamic>>> query({
    required String collection,
    List<QueryFilter>? filters,
    int? limit,
    String? orderBy,
    bool descending = false,
    DocumentSnapshot? startAfter,
  }) async {
    _ensureInitialized();
    Query query = _firestore!.collection(collection);

    // Apply filters
    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply pagination
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  /// Get documents with complex query as stream
  Stream<List<Map<String, dynamic>>> queryStream({
    required String collection,
    List<QueryFilter>? filters,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    if (_firestore == null) return Stream.empty();
    Query query = _firestore!.collection(collection);

    // Apply filters
    if (filters != null) {
      for (final filter in filters) {
        query = _applyFilter(query, filter);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  Query _applyFilter(Query query, QueryFilter filter) {
    switch (filter.operator) {
      case QueryOperator.isEqualTo:
        return query.where(filter.field, isEqualTo: filter.value);
      case QueryOperator.isNotEqualTo:
        return query.where(filter.field, isNotEqualTo: filter.value);
      case QueryOperator.isLessThan:
        return query.where(filter.field, isLessThan: filter.value);
      case QueryOperator.isLessThanOrEqualTo:
        return query.where(filter.field, isLessThanOrEqualTo: filter.value);
      case QueryOperator.isGreaterThan:
        return query.where(filter.field, isGreaterThan: filter.value);
      case QueryOperator.isGreaterThanOrEqualTo:
        return query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
      case QueryOperator.arrayContains:
        return query.where(filter.field, arrayContains: filter.value);
      case QueryOperator.arrayContainsAny:
        return query.where(filter.field, arrayContainsAny: filter.value);
      case QueryOperator.whereIn:
        return query.where(filter.field, whereIn: filter.value);
      case QueryOperator.whereNotIn:
        return query.where(filter.field, whereNotIn: filter.value);
      case QueryOperator.isNull:
        return query.where(filter.field, isNull: filter.value);
    }
  }

  // ==================== SUBCOLLECTION OPERATIONS ====================

  /// Create a document in a subcollection
  Future<String> createInSubcollection({
    required String parentCollection,
    required String parentDocumentId,
    required String subcollection,
    required Map<String, dynamic> data,
  }) async {
    _ensureInitialized();
    data[FirebaseConstants.fieldCreatedAt] = FieldValue.serverTimestamp();

    final docRef = await _firestore!
        .collection(parentCollection)
        .doc(parentDocumentId)
        .collection(subcollection)
        .add(data);

    return docRef.id;
  }

  /// Get documents from subcollection
  Future<List<Map<String, dynamic>>> getFromSubcollection({
    required String parentCollection,
    required String parentDocumentId,
    required String subcollection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    _ensureInitialized();
    Query query = _firestore!
        .collection(parentCollection)
        .doc(parentDocumentId)
        .collection(subcollection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      };
    }).toList();
  }

  /// Stream documents from subcollection
  Stream<List<Map<String, dynamic>>> streamSubcollection({
    required String parentCollection,
    required String parentDocumentId,
    required String subcollection,
    int? limit,
    String? orderBy,
    bool descending = false,
  }) {
    if (_firestore == null) return Stream.empty();
    Query query = _firestore!
        .collection(parentCollection)
        .doc(parentDocumentId)
        .collection(subcollection);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  // ==================== BATCH OPERATIONS ====================

  /// Batch write multiple documents
  Future<void> batchWrite(List<BatchOperation> operations) async {
    _ensureInitialized();
    final batch = _firestore!.batch();

    for (final operation in operations) {
      final docRef = _firestore!.collection(operation.collection).doc(operation.documentId);

      switch (operation.type) {
        case BatchOperationType.create:
        case BatchOperationType.set:
          operation.data![FirebaseConstants.fieldCreatedAt] = FieldValue.serverTimestamp();
          operation.data![FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();
          batch.set(docRef, operation.data!);
        case BatchOperationType.update:
          operation.data![FirebaseConstants.fieldUpdatedAt] = FieldValue.serverTimestamp();
          batch.update(docRef, operation.data!);
        case BatchOperationType.delete:
          batch.delete(docRef);
      }
    }

    await batch.commit();
  }

  // ==================== TRANSACTION OPERATIONS ====================

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    _ensureInitialized();
    return await _firestore!.runTransaction(transactionHandler);
  }

  // ==================== UTILITY METHODS ====================

  /// Get document reference
  DocumentReference getDocRef(String collection, String documentId) {
    _ensureInitialized();
    return _firestore!.collection(collection).doc(documentId);
  }

  /// Get collection reference
  CollectionReference getCollectionRef(String collection) {
    _ensureInitialized();
    return _firestore!.collection(collection);
  }

  /// Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Increment a field value
  FieldValue increment(int value) => FieldValue.increment(value);

  /// Add to array
  FieldValue arrayUnion(List<dynamic> elements) => FieldValue.arrayUnion(elements);

  /// Remove from array
  FieldValue arrayRemove(List<dynamic> elements) => FieldValue.arrayRemove(elements);

  /// Clear Firestore cache
  void clearCache() {
    _cache.clear();
  }
}

// ==================== HELPER CLASSES ====================

/// Query filter for complex queries
class QueryFilter {
  final String field;
  final QueryOperator operator;
  final dynamic value;

  QueryFilter({
    required this.field,
    required this.operator,
    required this.value,
  });
}

/// Query operators
enum QueryOperator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

/// Batch operation for batch writes
class BatchOperation {
  final String collection;
  final String? documentId;
  final BatchOperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.collection,
    this.documentId,
    required this.type,
    this.data,
  });
}

/// Batch operation types
enum BatchOperationType {
  create,
  set,
  update,
  delete,
}