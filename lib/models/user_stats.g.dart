// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserStatsCollection on Isar {
  IsarCollection<UserStats> get userStats => this.collection();
}

const UserStatsSchema = CollectionSchema(
  name: r'UserStats',
  id: 3718987168289318233,
  properties: {
    r'currentStreak': PropertySchema(
      id: 0,
      name: r'currentStreak',
      type: IsarType.long,
    ),
    r'earthRank': PropertySchema(
      id: 1,
      name: r'earthRank',
      type: IsarType.string,
    ),
    r'highestStreak': PropertySchema(
      id: 2,
      name: r'highestStreak',
      type: IsarType.long,
    ),
    r'lastActivityDate': PropertySchema(
      id: 3,
      name: r'lastActivityDate',
      type: IsarType.dateTime,
    ),
    r'lessonProgress': PropertySchema(
      id: 4,
      name: r'lessonProgress',
      type: IsarType.objectList,

      target: r'LessonProgress',
    ),
    r'onboardingComplete': PropertySchema(
      id: 5,
      name: r'onboardingComplete',
      type: IsarType.bool,
    ),
    r'totalXp': PropertySchema(id: 6, name: r'totalXp', type: IsarType.long),
  },

  estimateSize: _userStatsEstimateSize,
  serialize: _userStatsSerialize,
  deserialize: _userStatsDeserialize,
  deserializeProp: _userStatsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'LessonProgress': LessonProgressSchema},

  getId: _userStatsGetId,
  getLinks: _userStatsGetLinks,
  attach: _userStatsAttach,
  version: '3.3.2',
);

int _userStatsEstimateSize(
  UserStats object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.earthRank.length * 3;
  bytesCount += 3 + object.lessonProgress.length * 3;
  {
    final offsets = allOffsets[LessonProgress]!;
    for (var i = 0; i < object.lessonProgress.length; i++) {
      final value = object.lessonProgress[i];
      bytesCount += LessonProgressSchema.estimateSize(
        value,
        offsets,
        allOffsets,
      );
    }
  }
  return bytesCount;
}

void _userStatsSerialize(
  UserStats object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.currentStreak);
  writer.writeString(offsets[1], object.earthRank);
  writer.writeLong(offsets[2], object.highestStreak);
  writer.writeDateTime(offsets[3], object.lastActivityDate);
  writer.writeObjectList<LessonProgress>(
    offsets[4],
    allOffsets,
    LessonProgressSchema.serialize,
    object.lessonProgress,
  );
  writer.writeBool(offsets[5], object.onboardingComplete);
  writer.writeLong(offsets[6], object.totalXp);
}

UserStats _userStatsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserStats();
  object.currentStreak = reader.readLong(offsets[0]);
  object.earthRank = reader.readString(offsets[1]);
  object.highestStreak = reader.readLong(offsets[2]);
  object.id = id;
  object.lastActivityDate = reader.readDateTimeOrNull(offsets[3]);
  object.lessonProgress =
      reader.readObjectList<LessonProgress>(
        offsets[4],
        LessonProgressSchema.deserialize,
        allOffsets,
        LessonProgress(),
      ) ??
      [];
  object.onboardingComplete = reader.readBool(offsets[5]);
  object.totalXp = reader.readLong(offsets[6]);
  return object;
}

P _userStatsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readObjectList<LessonProgress>(
                offset,
                LessonProgressSchema.deserialize,
                allOffsets,
                LessonProgress(),
              ) ??
              [])
          as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userStatsGetId(UserStats object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userStatsGetLinks(UserStats object) {
  return [];
}

void _userStatsAttach(IsarCollection<dynamic> col, Id id, UserStats object) {
  object.id = id;
}

extension UserStatsQueryWhereSort
    on QueryBuilder<UserStats, UserStats, QWhere> {
  QueryBuilder<UserStats, UserStats, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserStatsQueryWhere
    on QueryBuilder<UserStats, UserStats, QWhereClause> {
  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserStatsQueryFilter
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {
  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentStreak', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  currentStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentStreak',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  earthRankGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'earthRank',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'earthRank',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'earthRank',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> earthRankIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'earthRank', value: ''),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  earthRankIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'earthRank', value: ''),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  highestStreakEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'highestStreak', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  highestStreakGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'highestStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  highestStreakLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'highestStreak',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  highestStreakBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'highestStreak',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastActivityDate'),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastActivityDate'),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastActivityDate', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastActivityDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastActivityDate',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lastActivityDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastActivityDate',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lessonProgress', length, true, length, true);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lessonProgress', 0, true, 0, true);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lessonProgress', 0, false, 999999, true);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lessonProgress', 0, true, length, include);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lessonProgress', length, include, 999999, true);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lessonProgress',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  onboardingCompleteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onboardingComplete', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalXpEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalXp', value: value),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalXpGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalXp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalXpLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalXp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterFilterCondition> totalXpBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalXp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension UserStatsQueryObject
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {
  QueryBuilder<UserStats, UserStats, QAfterFilterCondition>
  lessonProgressElement(FilterQuery<LessonProgress> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'lessonProgress');
    });
  }
}

extension UserStatsQueryLinks
    on QueryBuilder<UserStats, UserStats, QFilterCondition> {}

extension UserStatsQuerySortBy on QueryBuilder<UserStats, UserStats, QSortBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByEarthRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earthRank', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByEarthRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earthRank', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByHighestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  sortByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  sortByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> sortByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }
}

extension UserStatsQuerySortThenBy
    on QueryBuilder<UserStats, UserStats, QSortThenBy> {
  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByCurrentStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByEarthRank() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earthRank', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByEarthRankDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'earthRank', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByHighestStreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'highestStreak', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  thenByLastActivityDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastActivityDate', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy>
  thenByOnboardingCompleteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingComplete', Sort.desc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.asc);
    });
  }

  QueryBuilder<UserStats, UserStats, QAfterSortBy> thenByTotalXpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalXp', Sort.desc);
    });
  }
}

extension UserStatsQueryWhereDistinct
    on QueryBuilder<UserStats, UserStats, QDistinct> {
  QueryBuilder<UserStats, UserStats, QDistinct> distinctByCurrentStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentStreak');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByEarthRank({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'earthRank', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByHighestStreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'highestStreak');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByLastActivityDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastActivityDate');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByOnboardingComplete() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingComplete');
    });
  }

  QueryBuilder<UserStats, UserStats, QDistinct> distinctByTotalXp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalXp');
    });
  }
}

extension UserStatsQueryProperty
    on QueryBuilder<UserStats, UserStats, QQueryProperty> {
  QueryBuilder<UserStats, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> currentStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentStreak');
    });
  }

  QueryBuilder<UserStats, String, QQueryOperations> earthRankProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'earthRank');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> highestStreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'highestStreak');
    });
  }

  QueryBuilder<UserStats, DateTime?, QQueryOperations>
  lastActivityDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastActivityDate');
    });
  }

  QueryBuilder<UserStats, List<LessonProgress>, QQueryOperations>
  lessonProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lessonProgress');
    });
  }

  QueryBuilder<UserStats, bool, QQueryOperations> onboardingCompleteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingComplete');
    });
  }

  QueryBuilder<UserStats, int, QQueryOperations> totalXpProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalXp');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const LessonProgressSchema = Schema(
  name: r'LessonProgress',
  id: -711414530132804753,
  properties: {
    r'completedSections': PropertySchema(
      id: 0,
      name: r'completedSections',
      type: IsarType.long,
    ),
    r'fraction': PropertySchema(
      id: 1,
      name: r'fraction',
      type: IsarType.double,
    ),
    r'lessonId': PropertySchema(
      id: 2,
      name: r'lessonId',
      type: IsarType.string,
    ),
    r'totalSections': PropertySchema(
      id: 3,
      name: r'totalSections',
      type: IsarType.long,
    ),
  },

  estimateSize: _lessonProgressEstimateSize,
  serialize: _lessonProgressSerialize,
  deserialize: _lessonProgressDeserialize,
  deserializeProp: _lessonProgressDeserializeProp,
);

int _lessonProgressEstimateSize(
  LessonProgress object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.lessonId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _lessonProgressSerialize(
  LessonProgress object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completedSections);
  writer.writeDouble(offsets[1], object.fraction);
  writer.writeString(offsets[2], object.lessonId);
  writer.writeLong(offsets[3], object.totalSections);
}

LessonProgress _lessonProgressDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LessonProgress();
  object.completedSections = reader.readLong(offsets[0]);
  object.lessonId = reader.readStringOrNull(offsets[2]);
  object.totalSections = reader.readLong(offsets[3]);
  return object;
}

P _lessonProgressDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension LessonProgressQueryFilter
    on QueryBuilder<LessonProgress, LessonProgress, QFilterCondition> {
  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  completedSectionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'completedSections', value: value),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  completedSectionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'completedSections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  completedSectionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'completedSections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  completedSectionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'completedSections',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  fractionEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fraction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  fractionGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fraction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  fractionLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fraction',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  fractionBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fraction',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lessonId'),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lessonId'),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lessonId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lessonId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lessonId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lessonId', value: ''),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  lessonIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'lessonId', value: ''),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  totalSectionsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalSections', value: value),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  totalSectionsGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalSections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  totalSectionsLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalSections',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LessonProgress, LessonProgress, QAfterFilterCondition>
  totalSectionsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalSections',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LessonProgressQueryObject
    on QueryBuilder<LessonProgress, LessonProgress, QFilterCondition> {}
