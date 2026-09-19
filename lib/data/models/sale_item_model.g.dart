// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSaleItemModelCollection on Isar {
  IsarCollection<SaleItemModel> get saleItemModels => this.collection();
}

const SaleItemModelSchema = CollectionSchema(
  name: r'SaleItemModel',
  id: -7082026101599657679,
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
    r'qty': PropertySchema(
      id: 2,
      name: r'qty',
      type: IsarType.long,
    ),
    r'saleTransactionId': PropertySchema(
      id: 3,
      name: r'saleTransactionId',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 4,
      name: r'subtotal',
      type: IsarType.double,
    )
  },
  estimateSize: _saleItemModelEstimateSize,
  serialize: _saleItemModelSerialize,
  deserialize: _saleItemModelDeserialize,
  deserializeProp: _saleItemModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'saleTransactionId': IndexSchema(
      id: 1161373310257874767,
      name: r'saleTransactionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'saleTransactionId',
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
  getId: _saleItemModelGetId,
  getLinks: _saleItemModelGetLinks,
  attach: _saleItemModelAttach,
  version: '3.1.0+1',
);

int _saleItemModelEstimateSize(
  SaleItemModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _saleItemModelSerialize(
  SaleItemModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.itemId);
  writer.writeDouble(offsets[1], object.price);
  writer.writeLong(offsets[2], object.qty);
  writer.writeLong(offsets[3], object.saleTransactionId);
  writer.writeDouble(offsets[4], object.subtotal);
}

SaleItemModel _saleItemModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SaleItemModel(
    id: id,
    itemId: reader.readLong(offsets[0]),
    price: reader.readDouble(offsets[1]),
    qty: reader.readLong(offsets[2]),
    saleTransactionId: reader.readLong(offsets[3]),
    subtotal: reader.readDouble(offsets[4]),
  );
  return object;
}

P _saleItemModelDeserializeProp<P>(
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

Id _saleItemModelGetId(SaleItemModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _saleItemModelGetLinks(SaleItemModel object) {
  return [];
}

void _saleItemModelAttach(
    IsarCollection<dynamic> col, Id id, SaleItemModel object) {
  object.id = id;
}

extension SaleItemModelQueryWhereSort
    on QueryBuilder<SaleItemModel, SaleItemModel, QWhere> {
  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhere>
      anySaleTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'saleTransactionId'),
      );
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhere> anyItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'itemId'),
      );
    });
  }
}

extension SaleItemModelQueryWhere
    on QueryBuilder<SaleItemModel, SaleItemModel, QWhereClause> {
  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
      saleTransactionIdEqualTo(int saleTransactionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'saleTransactionId',
        value: [saleTransactionId],
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
      saleTransactionIdNotEqualTo(int saleTransactionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saleTransactionId',
              lower: [],
              upper: [saleTransactionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saleTransactionId',
              lower: [saleTransactionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saleTransactionId',
              lower: [saleTransactionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'saleTransactionId',
              lower: [],
              upper: [saleTransactionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
      saleTransactionIdGreaterThan(
    int saleTransactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'saleTransactionId',
        lower: [saleTransactionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
      saleTransactionIdLessThan(
    int saleTransactionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'saleTransactionId',
        lower: [],
        upper: [saleTransactionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
      saleTransactionIdBetween(
    int lowerSaleTransactionId,
    int upperSaleTransactionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'saleTransactionId',
        lower: [lowerSaleTransactionId],
        includeLower: includeLower,
        upper: [upperSaleTransactionId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> itemIdEqualTo(
      int itemId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'itemId',
        value: [itemId],
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> itemIdLessThan(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterWhereClause> itemIdBetween(
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

extension SaleItemModelQueryFilter
    on QueryBuilder<SaleItemModel, SaleItemModel, QFilterCondition> {
  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
      itemIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemId',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> qtyEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'qty',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> qtyLessThan(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition> qtyBetween(
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
      saleTransactionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saleTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
      saleTransactionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saleTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
      saleTransactionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saleTransactionId',
        value: value,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
      saleTransactionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saleTransactionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterFilterCondition>
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

extension SaleItemModelQueryObject
    on QueryBuilder<SaleItemModel, SaleItemModel, QFilterCondition> {}

extension SaleItemModelQueryLinks
    on QueryBuilder<SaleItemModel, SaleItemModel, QFilterCondition> {}

extension SaleItemModelQuerySortBy
    on QueryBuilder<SaleItemModel, SaleItemModel, QSortBy> {
  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortByQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      sortBySaleTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      sortBySaleTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }
}

extension SaleItemModelQuerySortThenBy
    on QueryBuilder<SaleItemModel, SaleItemModel, QSortThenBy> {
  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemId', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'price', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenByQtyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qty', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      thenBySaleTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleTransactionId', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      thenBySaleTransactionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saleTransactionId', Sort.desc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy> thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }
}

extension SaleItemModelQueryWhereDistinct
    on QueryBuilder<SaleItemModel, SaleItemModel, QDistinct> {
  QueryBuilder<SaleItemModel, SaleItemModel, QDistinct> distinctByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemId');
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QDistinct> distinctByPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'price');
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QDistinct> distinctByQty() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qty');
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QDistinct>
      distinctBySaleTransactionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saleTransactionId');
    });
  }

  QueryBuilder<SaleItemModel, SaleItemModel, QDistinct> distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }
}

extension SaleItemModelQueryProperty
    on QueryBuilder<SaleItemModel, SaleItemModel, QQueryProperty> {
  QueryBuilder<SaleItemModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SaleItemModel, int, QQueryOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemId');
    });
  }

  QueryBuilder<SaleItemModel, double, QQueryOperations> priceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'price');
    });
  }

  QueryBuilder<SaleItemModel, int, QQueryOperations> qtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qty');
    });
  }

  QueryBuilder<SaleItemModel, int, QQueryOperations>
      saleTransactionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saleTransactionId');
    });
  }

  QueryBuilder<SaleItemModel, double, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }
}
