// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_profit_close_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMonthlyProfitCloseModelCollection on Isar {
  IsarCollection<MonthlyProfitCloseModel> get monthlyProfitCloseModels =>
      this.collection();
}

const MonthlyProfitCloseModelSchema = CollectionSchema(
  name: r'MonthlyProfitCloseModel',
  id: 4445108677046251696,
  properties: {
    r'closedAt': PropertySchema(
      id: 0,
      name: r'closedAt',
      type: IsarType.dateTime,
    ),
    r'isSynced': PropertySchema(
      id: 1,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'month': PropertySchema(
      id: 2,
      name: r'month',
      type: IsarType.long,
    ),
    r'monthKey': PropertySchema(
      id: 3,
      name: r'monthKey',
      type: IsarType.string,
    ),
    r'netProfit': PropertySchema(
      id: 4,
      name: r'netProfit',
      type: IsarType.double,
    ),
    r'year': PropertySchema(
      id: 5,
      name: r'year',
      type: IsarType.long,
    )
  },
  estimateSize: _monthlyProfitCloseModelEstimateSize,
  serialize: _monthlyProfitCloseModelSerialize,
  deserialize: _monthlyProfitCloseModelDeserialize,
  deserializeProp: _monthlyProfitCloseModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'monthKey': IndexSchema(
      id: -6349924167704926890,
      name: r'monthKey',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'monthKey',
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
  getId: _monthlyProfitCloseModelGetId,
  getLinks: _monthlyProfitCloseModelGetLinks,
  attach: _monthlyProfitCloseModelAttach,
  version: '3.1.0+1',
);

int _monthlyProfitCloseModelEstimateSize(
  MonthlyProfitCloseModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.monthKey.length * 3;
  return bytesCount;
}

void _monthlyProfitCloseModelSerialize(
  MonthlyProfitCloseModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.closedAt);
  writer.writeBool(offsets[1], object.isSynced);
  writer.writeLong(offsets[2], object.month);
  writer.writeString(offsets[3], object.monthKey);
  writer.writeDouble(offsets[4], object.netProfit);
  writer.writeLong(offsets[5], object.year);
}

MonthlyProfitCloseModel _monthlyProfitCloseModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MonthlyProfitCloseModel(
    closedAt: reader.readDateTime(offsets[0]),
    id: id,
    isSynced: reader.readBoolOrNull(offsets[1]) ?? false,
    month: reader.readLong(offsets[2]),
    monthKey: reader.readString(offsets[3]),
    netProfit: reader.readDouble(offsets[4]),
    year: reader.readLong(offsets[5]),
  );
  return object;
}

P _monthlyProfitCloseModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _monthlyProfitCloseModelGetId(MonthlyProfitCloseModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _monthlyProfitCloseModelGetLinks(
    MonthlyProfitCloseModel object) {
  return [];
}

void _monthlyProfitCloseModelAttach(
    IsarCollection<dynamic> col, Id id, MonthlyProfitCloseModel object) {
  object.id = id;
}

extension MonthlyProfitCloseModelByIndex
    on IsarCollection<MonthlyProfitCloseModel> {
  Future<MonthlyProfitCloseModel?> getByMonthKey(String monthKey) {
    return getByIndex(r'monthKey', [monthKey]);
  }

  MonthlyProfitCloseModel? getByMonthKeySync(String monthKey) {
    return getByIndexSync(r'monthKey', [monthKey]);
  }

  Future<bool> deleteByMonthKey(String monthKey) {
    return deleteByIndex(r'monthKey', [monthKey]);
  }

  bool deleteByMonthKeySync(String monthKey) {
    return deleteByIndexSync(r'monthKey', [monthKey]);
  }

  Future<List<MonthlyProfitCloseModel?>> getAllByMonthKey(
      List<String> monthKeyValues) {
    final values = monthKeyValues.map((e) => [e]).toList();
    return getAllByIndex(r'monthKey', values);
  }

  List<MonthlyProfitCloseModel?> getAllByMonthKeySync(
      List<String> monthKeyValues) {
    final values = monthKeyValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'monthKey', values);
  }

  Future<int> deleteAllByMonthKey(List<String> monthKeyValues) {
    final values = monthKeyValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'monthKey', values);
  }

  int deleteAllByMonthKeySync(List<String> monthKeyValues) {
    final values = monthKeyValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'monthKey', values);
  }

  Future<Id> putByMonthKey(MonthlyProfitCloseModel object) {
    return putByIndex(r'monthKey', object);
  }

  Id putByMonthKeySync(MonthlyProfitCloseModel object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'monthKey', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMonthKey(List<MonthlyProfitCloseModel> objects) {
    return putAllByIndex(r'monthKey', objects);
  }

  List<Id> putAllByMonthKeySync(List<MonthlyProfitCloseModel> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'monthKey', objects, saveLinks: saveLinks);
  }
}

extension MonthlyProfitCloseModelQueryWhereSort
    on QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QWhere> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension MonthlyProfitCloseModelQueryWhere on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QWhereClause> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> monthKeyEqualTo(String monthKey) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'monthKey',
        value: [monthKey],
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> monthKeyNotEqualTo(String monthKey) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthKey',
              lower: [],
              upper: [monthKey],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthKey',
              lower: [monthKey],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthKey',
              lower: [monthKey],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'monthKey',
              lower: [],
              upper: [monthKey],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterWhereClause> isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

extension MonthlyProfitCloseModelQueryFilter on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QFilterCondition> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> closedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> closedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> closedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'closedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> closedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'closedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
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

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'month',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'month',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monthKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
          QAfterFilterCondition>
      monthKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'monthKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
          QAfterFilterCondition>
      monthKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'monthKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monthKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> monthKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'monthKey',
        value: '',
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> netProfitEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'netProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> netProfitGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'netProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> netProfitLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'netProfit',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> netProfitBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'netProfit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> yearEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> yearGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> yearLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'year',
        value: value,
      ));
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel,
      QAfterFilterCondition> yearBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'year',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MonthlyProfitCloseModelQueryObject on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QFilterCondition> {}

extension MonthlyProfitCloseModelQueryLinks on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QFilterCondition> {}

extension MonthlyProfitCloseModelQuerySortBy
    on QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QSortBy> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByMonthKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthKey', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByMonthKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthKey', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByNetProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netProfit', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByNetProfitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netProfit', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      sortByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension MonthlyProfitCloseModelQuerySortThenBy on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QSortThenBy> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByClosedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'closedAt', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'month', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByMonthKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthKey', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByMonthKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monthKey', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByNetProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netProfit', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByNetProfitDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'netProfit', Sort.desc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.asc);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QAfterSortBy>
      thenByYearDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'year', Sort.desc);
    });
  }
}

extension MonthlyProfitCloseModelQueryWhereDistinct on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct> {
  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByClosedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'closedAt');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'month');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByMonthKey({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monthKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByNetProfit() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'netProfit');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, MonthlyProfitCloseModel, QDistinct>
      distinctByYear() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'year');
    });
  }
}

extension MonthlyProfitCloseModelQueryProperty on QueryBuilder<
    MonthlyProfitCloseModel, MonthlyProfitCloseModel, QQueryProperty> {
  QueryBuilder<MonthlyProfitCloseModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, DateTime, QQueryOperations>
      closedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'closedAt');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, bool, QQueryOperations>
      isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, int, QQueryOperations> monthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'month');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, String, QQueryOperations>
      monthKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monthKey');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, double, QQueryOperations>
      netProfitProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'netProfit');
    });
  }

  QueryBuilder<MonthlyProfitCloseModel, int, QQueryOperations> yearProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'year');
    });
  }
}
