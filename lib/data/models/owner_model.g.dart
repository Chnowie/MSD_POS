// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOwnerModelCollection on Isar {
  IsarCollection<OwnerModel> get ownerModels => this.collection();
}

const OwnerModelSchema = CollectionSchema(
  name: r'OwnerModel',
  id: 767320537195107714,
  properties: {
    r'availableBalance': PropertySchema(
      id: 0,
      name: r'availableBalance',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    ),
    r'sharePercentage': PropertySchema(
      id: 2,
      name: r'sharePercentage',
      type: IsarType.double,
    ),
    r'totalEntitled': PropertySchema(
      id: 3,
      name: r'totalEntitled',
      type: IsarType.double,
    ),
    r'totalWithdrawn': PropertySchema(
      id: 4,
      name: r'totalWithdrawn',
      type: IsarType.double,
    )
  },
  estimateSize: _ownerModelEstimateSize,
  serialize: _ownerModelSerialize,
  deserialize: _ownerModelDeserialize,
  deserializeProp: _ownerModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'name': IndexSchema(
      id: 879695947855722453,
      name: r'name',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'name',
          type: IndexType.hash,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _ownerModelGetId,
  getLinks: _ownerModelGetLinks,
  attach: _ownerModelAttach,
  version: '3.1.0+1',
);

int _ownerModelEstimateSize(
  OwnerModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _ownerModelSerialize(
  OwnerModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.availableBalance);
  writer.writeString(offsets[1], object.name);
  writer.writeDouble(offsets[2], object.sharePercentage);
  writer.writeDouble(offsets[3], object.totalEntitled);
  writer.writeDouble(offsets[4], object.totalWithdrawn);
}

OwnerModel _ownerModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OwnerModel(
    id: id,
    name: reader.readString(offsets[1]),
    sharePercentage: reader.readDouble(offsets[2]),
    totalEntitled: reader.readDoubleOrNull(offsets[3]) ?? 0.0,
    totalWithdrawn: reader.readDoubleOrNull(offsets[4]) ?? 0.0,
  );
  return object;
}

P _ownerModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 4:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ownerModelGetId(OwnerModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ownerModelGetLinks(OwnerModel object) {
  return [];
}

void _ownerModelAttach(IsarCollection<dynamic> col, Id id, OwnerModel object) {
  object.id = id;
}

extension OwnerModelByIndex on IsarCollection<OwnerModel> {
  Future<OwnerModel?> getByName(String name) {
    return getByIndex(r'name', [name]);
  }

  OwnerModel? getByNameSync(String name) {
    return getByIndexSync(r'name', [name]);
  }

  Future<bool> deleteByName(String name) {
    return deleteByIndex(r'name', [name]);
  }

  bool deleteByNameSync(String name) {
    return deleteByIndexSync(r'name', [name]);
  }

  Future<List<OwnerModel?>> getAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndex(r'name', values);
  }

  List<OwnerModel?> getAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'name', values);
  }

  Future<int> deleteAllByName(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'name', values);
  }

  int deleteAllByNameSync(List<String> nameValues) {
    final values = nameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'name', values);
  }

  Future<Id> putByName(OwnerModel object) {
    return putByIndex(r'name', object);
  }

  Id putByNameSync(OwnerModel object, {bool saveLinks = true}) {
    return putByIndexSync(r'name', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByName(List<OwnerModel> objects) {
    return putAllByIndex(r'name', objects);
  }

  List<Id> putAllByNameSync(List<OwnerModel> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'name', objects, saveLinks: saveLinks);
  }
}

extension OwnerModelQueryWhereSort
    on QueryBuilder<OwnerModel, OwnerModel, QWhere> {
  QueryBuilder<OwnerModel, OwnerModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OwnerModelQueryWhere
    on QueryBuilder<OwnerModel, OwnerModel, QWhereClause> {
  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> nameEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'name',
        value: [name],
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterWhereClause> nameNotEqualTo(
      String name) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [name],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'name',
              lower: [],
              upper: [name],
              includeUpper: false,
            ));
      }
    });
  }
}

extension OwnerModelQueryFilter
    on QueryBuilder<OwnerModel, OwnerModel, QFilterCondition> {
  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      availableBalanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      availableBalanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      availableBalanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'availableBalance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      availableBalanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'availableBalance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      sharePercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sharePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      sharePercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sharePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      sharePercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sharePercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      sharePercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sharePercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalEntitledEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalEntitled',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalEntitledGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalEntitled',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalEntitledLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalEntitled',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalEntitledBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalEntitled',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalWithdrawnEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalWithdrawn',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalWithdrawnGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalWithdrawn',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalWithdrawnLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalWithdrawn',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterFilterCondition>
      totalWithdrawnBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalWithdrawn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension OwnerModelQueryObject
    on QueryBuilder<OwnerModel, OwnerModel, QFilterCondition> {}

extension OwnerModelQueryLinks
    on QueryBuilder<OwnerModel, OwnerModel, QFilterCondition> {}

extension OwnerModelQuerySortBy
    on QueryBuilder<OwnerModel, OwnerModel, QSortBy> {
  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      sortByAvailableBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortBySharePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharePercentage', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      sortBySharePercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharePercentage', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByTotalEntitled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEntitled', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByTotalEntitledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEntitled', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> sortByTotalWithdrawn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWithdrawn', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      sortByTotalWithdrawnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWithdrawn', Sort.desc);
    });
  }
}

extension OwnerModelQuerySortThenBy
    on QueryBuilder<OwnerModel, OwnerModel, QSortThenBy> {
  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      thenByAvailableBalanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'availableBalance', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenBySharePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharePercentage', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      thenBySharePercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sharePercentage', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByTotalEntitled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEntitled', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByTotalEntitledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalEntitled', Sort.desc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy> thenByTotalWithdrawn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWithdrawn', Sort.asc);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QAfterSortBy>
      thenByTotalWithdrawnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalWithdrawn', Sort.desc);
    });
  }
}

extension OwnerModelQueryWhereDistinct
    on QueryBuilder<OwnerModel, OwnerModel, QDistinct> {
  QueryBuilder<OwnerModel, OwnerModel, QDistinct> distinctByAvailableBalance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'availableBalance');
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QDistinct> distinctBySharePercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sharePercentage');
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QDistinct> distinctByTotalEntitled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalEntitled');
    });
  }

  QueryBuilder<OwnerModel, OwnerModel, QDistinct> distinctByTotalWithdrawn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalWithdrawn');
    });
  }
}

extension OwnerModelQueryProperty
    on QueryBuilder<OwnerModel, OwnerModel, QQueryProperty> {
  QueryBuilder<OwnerModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OwnerModel, double, QQueryOperations>
      availableBalanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'availableBalance');
    });
  }

  QueryBuilder<OwnerModel, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<OwnerModel, double, QQueryOperations> sharePercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sharePercentage');
    });
  }

  QueryBuilder<OwnerModel, double, QQueryOperations> totalEntitledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalEntitled');
    });
  }

  QueryBuilder<OwnerModel, double, QQueryOperations> totalWithdrawnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalWithdrawn');
    });
  }
}
