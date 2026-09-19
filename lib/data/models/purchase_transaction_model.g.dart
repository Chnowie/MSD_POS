// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_transaction_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPurchaseTransactionModelCollection on Isar {
  IsarCollection<PurchaseTransactionModel> get purchaseTransactionModels =>
      this.collection();
}

const PurchaseTransactionModelSchema = CollectionSchema(
  name: r'PurchaseTransactionModel',
  id: 4534009790376975967,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'dueDate': PropertySchema(
      id: 1,
      name: r'dueDate',
      type: IsarType.dateTime,
    ),
    r'grandTotal': PropertySchema(
      id: 2,
      name: r'grandTotal',
      type: IsarType.double,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'paidAmount': PropertySchema(
      id: 4,
      name: r'paidAmount',
      type: IsarType.double,
    ),
    r'paymentStatus': PropertySchema(
      id: 5,
      name: r'paymentStatus',
      type: IsarType.string,
    ),
    r'poNumber': PropertySchema(
      id: 6,
      name: r'poNumber',
      type: IsarType.string,
    ),
    r'remainingPayable': PropertySchema(
      id: 7,
      name: r'remainingPayable',
      type: IsarType.double,
    ),
    r'supplierId': PropertySchema(
      id: 8,
      name: r'supplierId',
      type: IsarType.long,
    )
  },
  estimateSize: _purchaseTransactionModelEstimateSize,
  serialize: _purchaseTransactionModelSerialize,
  deserialize: _purchaseTransactionModelDeserialize,
  deserializeProp: _purchaseTransactionModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'poNumber': IndexSchema(
      id: 4293613895205493241,
      name: r'poNumber',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'poNumber',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'supplierId': IndexSchema(
      id: -7509772217447508349,
      name: r'supplierId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'supplierId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'paymentStatus': IndexSchema(
      id: 7011973130100993011,
      name: r'paymentStatus',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'paymentStatus',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _purchaseTransactionModelGetId,
  getLinks: _purchaseTransactionModelGetLinks,
  attach: _purchaseTransactionModelAttach,
  version: '3.1.0+1',
);

int _purchaseTransactionModelEstimateSize(
  PurchaseTransactionModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.paymentStatus.length * 3;
  bytesCount += 3 + object.poNumber.length * 3;
  return bytesCount;
}

void _purchaseTransactionModelSerialize(
  PurchaseTransactionModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeDateTime(offsets[1], object.dueDate);
  writer.writeDouble(offsets[2], object.grandTotal);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeDouble(offsets[4], object.paidAmount);
  writer.writeString(offsets[5], object.paymentStatus);
  writer.writeString(offsets[6], object.poNumber);
  writer.writeDouble(offsets[7], object.remainingPayable);
  writer.writeLong(offsets[8], object.supplierId);
}

PurchaseTransactionModel _purchaseTransactionModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PurchaseTransactionModel(
    date: reader.readDateTime(offsets[0]),
    dueDate: reader.readDateTimeOrNull(offsets[1]),
    grandTotal: reader.readDouble(offsets[2]),
    id: id,
    isSynced: reader.readBoolOrNull(offsets[3]) ?? false,
    paidAmount: reader.readDouble(offsets[4]),
    paymentStatus: reader.readString(offsets[5]),
    poNumber: reader.readString(offsets[6]),
    remainingPayable: reader.readDouble(offsets[7]),
    supplierId: reader.readLong(offsets[8]),
  );
  return object;
}

P _purchaseTransactionModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _purchaseTransactionModelGetId(PurchaseTransactionModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _purchaseTransactionModelGetLinks(
    PurchaseTransactionModel object) {
  return [];
}

void _purchaseTransactionModelAttach(
    IsarCollection<dynamic> col, Id id, PurchaseTransactionModel object) {
  object.id = id;
}

extension PurchaseTransactionModelByIndex
    on IsarCollection<PurchaseTransactionModel> {
  Future<PurchaseTransactionModel?> getByPoNumber(String poNumber) {
    return getByIndex(r'poNumber', [poNumber]);
  }

  PurchaseTransactionModel? getByPoNumberSync(String poNumber) {
    return getByIndexSync(r'poNumber', [poNumber]);
  }

  Future<bool> deleteByPoNumber(String poNumber) {
    return deleteByIndex(r'poNumber', [poNumber]);
  }

  bool deleteByPoNumberSync(String poNumber) {
    return deleteByIndexSync(r'poNumber', [poNumber]);
  }

  Future<List<PurchaseTransactionModel?>> getAllByPoNumber(
      List<String> poNumberValues) {
    final values = poNumberValues.map((e) => [e]).toList();
    return getAllByIndex(r'poNumber', values);
  }

  List<PurchaseTransactionModel?> getAllByPoNumberSync(
      List<String> poNumberValues) {
    final values = poNumberValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'poNumber', values);
  }

  Future<int> deleteAllByPoNumber(List<String> poNumberValues) {
    final values = poNumberValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'poNumber', values);
  }

  int deleteAllByPoNumberSync(List<String> poNumberValues) {
    final values = poNumberValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'poNumber', values);
  }

  Future<Id> putByPoNumber(PurchaseTransactionModel object) {
    return putByIndex(r'poNumber', object);
  }

  Id putByPoNumberSync(PurchaseTransactionModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'poNumber', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByPoNumber(List<PurchaseTransactionModel> objects) {
    return putAllByIndex(r'poNumber', objects);
  }

  List<Id> putAllByPoNumberSync(List<PurchaseTransactionModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'poNumber', objects, saveLinks: saveLinks);
  }
}

extension PurchaseTransactionModelQueryWhereSort on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QWhere> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterWhere>
      anySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'supplierId'),
      );
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterWhere>
      anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension PurchaseTransactionModelQueryWhere on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QWhereClause> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> poNumberEqualTo(String poNumber) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'poNumber',
        value: [poNumber],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> poNumberNotEqualTo(String poNumber) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poNumber',
              lower: [],
              upper: [poNumber],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poNumber',
              lower: [poNumber],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poNumber',
              lower: [poNumber],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'poNumber',
              lower: [],
              upper: [poNumber],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> supplierIdEqualTo(int supplierId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supplierId',
        value: [supplierId],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> supplierIdNotEqualTo(int supplierId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supplierId',
              lower: [],
              upper: [supplierId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supplierId',
              lower: [supplierId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supplierId',
              lower: [supplierId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supplierId',
              lower: [],
              upper: [supplierId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> supplierIdGreaterThan(
    int supplierId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supplierId',
        lower: [supplierId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> supplierIdLessThan(
    int supplierId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supplierId',
        lower: [],
        upper: [supplierId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> supplierIdBetween(
    int lowerSupplierId,
    int upperSupplierId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supplierId',
        lower: [lowerSupplierId],
        includeLower: includeLower,
        upper: [upperSupplierId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> dateEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> paymentStatusEqualTo(String paymentStatus) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'paymentStatus',
        value: [paymentStatus],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> paymentStatusNotEqualTo(String paymentStatus) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentStatus',
              lower: [],
              upper: [paymentStatus],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentStatus',
              lower: [paymentStatus],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentStatus',
              lower: [paymentStatus],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'paymentStatus',
              lower: [],
              upper: [paymentStatus],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterWhereClause> isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PurchaseTransactionModelQueryFilter on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QFilterCondition> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dueDate',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dueDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> dueDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dueDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> grandTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'grandTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> grandTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'grandTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> grandTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'grandTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> grandTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'grandTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paidAmountEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paidAmountGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paidAmountLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paidAmount',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paidAmountBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paidAmount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'paymentStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
          QAfterFilterCondition>
      paymentStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'paymentStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
          QAfterFilterCondition>
      paymentStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'paymentStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'paymentStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> paymentStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'paymentStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'poNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
          QAfterFilterCondition>
      poNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'poNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
          QAfterFilterCondition>
      poNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'poNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'poNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> poNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'poNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> remainingPayableEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remainingPayable',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> remainingPayableGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remainingPayable',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> remainingPayableLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remainingPayable',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> remainingPayableBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remainingPayable',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> supplierIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supplierId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> supplierIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supplierId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> supplierIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supplierId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel,
      QAfterFilterCondition> supplierIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supplierId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PurchaseTransactionModelQueryObject on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QFilterCondition> {}

extension PurchaseTransactionModelQueryLinks on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QFilterCondition> {}

extension PurchaseTransactionModelQuerySortBy on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QSortBy> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByGrandTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grandTotal', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByGrandTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grandTotal', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPoNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poNumber', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByPoNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poNumber', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByRemainingPayable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingPayable', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortByRemainingPayableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingPayable', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      sortBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }
}

extension PurchaseTransactionModelQuerySortThenBy on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QSortThenBy> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByDueDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dueDate', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByGrandTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grandTotal', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByGrandTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'grandTotal', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPaidAmountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paidAmount', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPaymentStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPaymentStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'paymentStatus', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPoNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poNumber', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByPoNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'poNumber', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByRemainingPayable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingPayable', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenByRemainingPayableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remainingPayable', Sort.desc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QAfterSortBy>
      thenBySupplierIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supplierId', Sort.desc);
    });
  }
}

extension PurchaseTransactionModelQueryWhereDistinct on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QDistinct> {
  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByDueDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dueDate');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByGrandTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'grandTotal');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByPaidAmount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paidAmount');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByPaymentStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'paymentStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByPoNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'poNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctByRemainingPayable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remainingPayable');
    });
  }

  QueryBuilder<PurchaseTransactionModel, PurchaseTransactionModel, QDistinct>
      distinctBySupplierId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supplierId');
    });
  }
}

extension PurchaseTransactionModelQueryProperty on QueryBuilder<
    PurchaseTransactionModel, PurchaseTransactionModel, QQueryProperty> {
  QueryBuilder<PurchaseTransactionModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PurchaseTransactionModel, DateTime, QQueryOperations>
      dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<PurchaseTransactionModel, DateTime?, QQueryOperations>
      dueDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dueDate');
    });
  }

  QueryBuilder<PurchaseTransactionModel, double, QQueryOperations>
      grandTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'grandTotal');
    });
  }

  QueryBuilder<PurchaseTransactionModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<PurchaseTransactionModel, double, QQueryOperations>
      paidAmountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paidAmount');
    });
  }

  QueryBuilder<PurchaseTransactionModel, String, QQueryOperations>
      paymentStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'paymentStatus');
    });
  }

  QueryBuilder<PurchaseTransactionModel, String, QQueryOperations>
      poNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'poNumber');
    });
  }

  QueryBuilder<PurchaseTransactionModel, double, QQueryOperations>
      remainingPayableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remainingPayable');
    });
  }

  QueryBuilder<PurchaseTransactionModel, int, QQueryOperations>
      supplierIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supplierId');
    });
  }
}
