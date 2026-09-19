// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPurchaseItemModelCollection on Isar {
  IsarCollection<PurchaseItemModel> get purchaseItemModels => this.collection();
}

const PurchaseItemModelSchema = CollectionSchema(
  name: r'PurchaseItemModel',
  id: 8037531023585824605,
  properties: {
    r'itemId': PropertySchema(
      id: 0,
      name: r'itemId',
      type: IsarType.long,
    ),
    r'price': PropertySchema(
      id: 1,
      name: r'price',
      type: IsarType.double,
    ),
    r'purchaseTransactionId': PropertySchema(
      id: 2,
      name: r'purchaseTransactionId',
      type: IsarType.long,
    ),
    r'qty': PropertySchema(
      id: 3,
      name: r'qty',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 4,
      name: r'subtotal',
      type: IsarType.double,
    )
  },
  estimateSize: _purchaseItemModelEstimateSize,
  serialize: _purchaseItemModelSerialize,
  deserialize: _purchaseItemModelDeserialize,
  deserializeProp: _purchaseItemModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'purchaseTransactionId': IndexSchema(
      id: 1028568190164271347,
      name: r'purchaseTransactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'purchaseTransactionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _purchaseItemModelGetId,
  getLinks: _purchaseItemModelGetLinks,
  attach: _purchaseItemModelAttach,
  version: '3.1.0+1',
);

int _purchaseItemModelEstimateSize(
  PurchaseItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _purchaseItemModelSerialize(
  PurchaseItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.itemId);
  writer.writeDouble(offsets[1], object.price);
  writer.writeLong(offsets[2], object.purchaseTransactionId);
  writer.writeLong(offsets[3], object.qty);
  writer.writeDouble(offsets[4], object.subtotal);
}

PurchaseItemModel _purchaseItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PurchaseItemModel(
    id: id,
    itemId: reader.readLong(offsets[0]),
    price: reader.readDouble(offsets[1]),
    purchaseTransactionId: reader.readLong(offsets[2]),
    qty: reader.readLong(offsets[3]),
    subtotal: reader.readDouble(offsets[4]),
  );
  return object;
}

P _purchaseItemModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _purchaseItemModelGetId(PurchaseItemModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _purchaseItemModelGetLinks(
    PurchaseItemModel object) {
  return [];
}

void _purchaseItemModelAttach(
    IsarCollection<dynamic> col, Id id, PurchaseItemModel object) {
  object.id = id;
}

extension PurchaseItemModelQueryWhereSort
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QWhere> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhere>
      anyPurchaseTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'purchaseTransactionId'),
      );
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhere> anyItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'itemId'),
      );
    });
  }
}

extension PurchaseItemModelQueryWhere
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QWhereClause> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      purchaseTransactionIdEqualTo(int purchaseTransactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'purchaseTransactionId',
        value: [purchaseTransactionId],
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      purchaseTransactionIdNotEqualTo(int purchaseTransactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseTransactionId',
              lower: [],
              upper: [purchaseTransactionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseTransactionId',
              lower: [purchaseTransactionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseTransactionId',
              lower: [purchaseTransactionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'purchaseTransactionId',
              lower: [],
              upper: [purchaseTransactionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      purchaseTransactionIdGreaterThan(
    int purchaseTransactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseTransactionId',
        lower: [purchaseTransactionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      purchaseTransactionIdLessThan(
    int purchaseTransactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseTransactionId',
        lower: [],
        upper: [purchaseTransactionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      purchaseTransactionIdBetween(
    int lowerPurchaseTransactionId,
    int upperPurchaseTransactionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'purchaseTransactionId',
        lower: [lowerPurchaseTransactionId],
        includeLower: includeLower,
        upper: [upperPurchaseTransactionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
      itemIdEqualTo(int itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterWhereClause>
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
}

extension PurchaseItemModelQueryFilter
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QFilterCondition> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      itemIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      itemIdGreaterThan(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      itemIdLessThan(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      itemIdBetween(
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

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      priceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      priceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      priceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'price',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      priceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'price',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      purchaseTransactionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      purchaseTransactionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      purchaseTransactionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      purchaseTransactionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      qtyEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qty',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      qtyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'qty',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      qtyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'qty',
        value: value,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      qtyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'qty',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      subtotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      subtotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      subtotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterFilterCondition>
      subtotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension PurchaseItemModelQueryObject
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QFilterCondition> {}

extension PurchaseItemModelQueryLinks
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QFilterCondition> {}

extension PurchaseItemModelQuerySortBy
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QSortBy> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByPurchaseTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByPurchaseTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy> sortByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortByQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }
}

extension PurchaseItemModelQuerySortThenBy
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QSortThenBy> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByPurchaseTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseTransactionId', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByPurchaseTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseTransactionId', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy> thenByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenByQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.desc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }
}

extension PurchaseItemModelQueryWhereDistinct
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct> {
  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct>
      distinctByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId');
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct>
      distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct>
      distinctByPurchaseTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseTransactionId');
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct>
      distinctByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qty');
    });
  }

  QueryBuilder<PurchaseItemModel, PurchaseItemModel, QDistinct>
      distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }
}

extension PurchaseItemModelQueryProperty
    on QueryBuilder<PurchaseItemModel, PurchaseItemModel, QQueryProperty> {
  QueryBuilder<PurchaseItemModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PurchaseItemModel, int, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<PurchaseItemModel, double, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<PurchaseItemModel, int, QQueryOperations>
      purchaseTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseTransactionId');
    });
  }

  QueryBuilder<PurchaseItemModel, int, QQueryOperations> qtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qty');
    });
  }

  QueryBuilder<PurchaseItemModel, double, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }
}
