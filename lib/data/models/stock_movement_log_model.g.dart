// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_movement_log_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetStockMovementLogModelCollection on Isar {
  IsarCollection<StockMovementLogModel> get stockMovementLogModels =>
      this.collection();
}

const StockMovementLogModelSchema = CollectionSchema(
  name: r'StockMovementLogModel',
  id: 6572909359493359174,
  properties: {
    r'changeQty': PropertySchema(
      id: 0,
      name: r'changeQty',
      type: IsarType.long,
    ),
    r'isSynced': PropertySchema(
      id: 1,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'itemId': PropertySchema(
      id: 2,
      name: r'itemId',
      type: IsarType.long,
    ),
    r'movementType': PropertySchema(
      id: 3,
      name: r'movementType',
      type: IsarType.string,
    ),
    r'referenceNumber': PropertySchema(
      id: 4,
      name: r'referenceNumber',
      type: IsarType.string,
    ),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _stockMovementLogModelEstimateSize,
  serialize: _stockMovementLogModelSerialize,
  deserialize: _stockMovementLogModelDeserialize,
  deserializeProp: _stockMovementLogModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'itemId': IndexSchema(
      id: -5342806140158601489,
      name: r'itemId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'itemId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'timestamp': IndexSchema(
      id: 1852253767416892198,
      name: r'timestamp',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'timestamp',
          type: IndexType.value,
          caseSensitive: false,
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
  getId: _stockMovementLogModelGetId,
  getLinks: _stockMovementLogModelGetLinks,
  attach: _stockMovementLogModelAttach,
  version: '3.1.0+1',
);

int _stockMovementLogModelEstimateSize(
  StockMovementLogModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.movementType.length * 3;
  bytesCount += 3 + object.referenceNumber.length * 3;
  return bytesCount;
}

void _stockMovementLogModelSerialize(
  StockMovementLogModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.changeQty);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeLong(offsets[2], object.itemId);
  writer.writeString(offsets[3], object.movementType);
  writer.writeString(offsets[4], object.referenceNumber);
  writer.writeDateTime(offsets[5], object.timestamp);
}

StockMovementLogModel _stockMovementLogModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = StockMovementLogModel(
    changeQty: reader.readLong(offsets[0]),
    id: id,
    isSynced: reader.readBoolOrNull(offsets[1]) ?? false,
    itemId: reader.readLong(offsets[2]),
    movementType: reader.readString(offsets[3]),
    referenceNumber: reader.readString(offsets[4]),
    timestamp: reader.readDateTime(offsets[5]),
  );
  return object;
}

P _stockMovementLogModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _stockMovementLogModelGetId(StockMovementLogModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _stockMovementLogModelGetLinks(
    StockMovementLogModel object) {
  return [];
}

void _stockMovementLogModelAttach(
    IsarCollection<dynamic> col, Id id, StockMovementLogModel object) {
  object.id = id;
}

extension StockMovementLogModelQueryWhereSort
    on QueryBuilder<StockMovementLogModel, StockMovementLogModel, QWhere> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhere>
      anyItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'itemId'),
      );
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhere>
      anyTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'timestamp'),
      );
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension StockMovementLogModelQueryWhere on QueryBuilder<StockMovementLogModel,
    StockMovementLogModel, QWhereClause> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      itemIdEqualTo(int itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      itemIdNotEqualTo(int itemId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [itemId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'itemId',
              lower: [],
              upper: [itemId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      itemIdGreaterThan(
    int itemId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [itemId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      itemIdLessThan(
    int itemId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [],
        upper: [itemId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      itemIdBetween(
    int lowerItemId,
    int upperItemId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'itemId',
        lower: [lowerItemId],
        includeLower: includeLower,
        upper: [upperItemId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      timestampEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'timestamp',
        value: [timestamp],
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      timestampNotEqualTo(DateTime timestamp) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [timestamp],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'timestamp',
              lower: [],
              upper: [timestamp],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      timestampGreaterThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [timestamp],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      timestampLessThan(
    DateTime timestamp, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [],
        upper: [timestamp],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      timestampBetween(
    DateTime lowerTimestamp,
    DateTime upperTimestamp, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'timestamp',
        lower: [lowerTimestamp],
        includeLower: includeLower,
        upper: [upperTimestamp],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
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

extension StockMovementLogModelQueryFilter on QueryBuilder<
    StockMovementLogModel, StockMovementLogModel, QFilterCondition> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> changeQtyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'changeQty',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> changeQtyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'changeQty',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> changeQtyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'changeQty',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> changeQtyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'changeQty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
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

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
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

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
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

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> itemIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> itemIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> itemIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> itemIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movementType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
          QAfterFilterCondition>
      movementTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'movementType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
          QAfterFilterCondition>
      movementTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'movementType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> movementTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'movementType',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referenceNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
          QAfterFilterCondition>
      referenceNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referenceNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
          QAfterFilterCondition>
      referenceNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referenceNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referenceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> referenceNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referenceNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel,
      QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension StockMovementLogModelQueryObject on QueryBuilder<
    StockMovementLogModel, StockMovementLogModel, QFilterCondition> {}

extension StockMovementLogModelQueryLinks on QueryBuilder<StockMovementLogModel,
    StockMovementLogModel, QFilterCondition> {}

extension StockMovementLogModelQuerySortBy
    on QueryBuilder<StockMovementLogModel, StockMovementLogModel, QSortBy> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByChangeQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeQty', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByChangeQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeQty', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension StockMovementLogModelQuerySortThenBy
    on QueryBuilder<StockMovementLogModel, StockMovementLogModel, QSortThenBy> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByChangeQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeQty', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByChangeQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'changeQty', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByMovementType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByMovementTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movementType', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByReferenceNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByReferenceNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referenceNumber', Sort.desc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QAfterSortBy>
      thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }
}

extension StockMovementLogModelQueryWhereDistinct
    on QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct> {
  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByChangeQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'changeQty');
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId');
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByMovementType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movementType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByReferenceNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referenceNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<StockMovementLogModel, StockMovementLogModel, QDistinct>
      distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }
}

extension StockMovementLogModelQueryProperty on QueryBuilder<
    StockMovementLogModel, StockMovementLogModel, QQueryProperty> {
  QueryBuilder<StockMovementLogModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<StockMovementLogModel, int, QQueryOperations>
      changeQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'changeQty');
    });
  }

  QueryBuilder<StockMovementLogModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<StockMovementLogModel, int, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<StockMovementLogModel, String, QQueryOperations>
      movementTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movementType');
    });
  }

  QueryBuilder<StockMovementLogModel, String, QQueryOperations>
      referenceNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referenceNumber');
    });
  }

  QueryBuilder<StockMovementLogModel, DateTime, QQueryOperations>
      timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }
}
