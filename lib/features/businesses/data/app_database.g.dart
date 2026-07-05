// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BusinessProfilesTable extends BusinessProfiles
    with TableInfo<$BusinessProfilesTable, BusinessProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _phoneCountryIsoMeta =
      const VerificationMeta('phoneCountryIso');
  @override
  late final GeneratedColumn<String> phoneCountryIso = GeneratedColumn<String>(
      'phone_country_iso', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _whatsappLinkMeta =
      const VerificationMeta('whatsappLink');
  @override
  late final GeneratedColumn<String> whatsappLink = GeneratedColumn<String>(
      'whatsapp_link', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _languagesMeta =
      const VerificationMeta('languages');
  @override
  late final GeneratedColumn<String> languages = GeneratedColumn<String>(
      'languages', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _targetAudienceMeta =
      const VerificationMeta('targetAudience');
  @override
  late final GeneratedColumn<String> targetAudience = GeneratedColumn<String>(
      'target_audience', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gbpAccountNameMeta =
      const VerificationMeta('gbpAccountName');
  @override
  late final GeneratedColumn<String> gbpAccountName = GeneratedColumn<String>(
      'gbp_account_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _gbpLocationNameMeta =
      const VerificationMeta('gbpLocationName');
  @override
  late final GeneratedColumn<String> gbpLocationName = GeneratedColumn<String>(
      'gbp_location_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        category,
        description,
        address,
        latitude,
        longitude,
        phoneCountryIso,
        phoneNumber,
        whatsappLink,
        website,
        email,
        notes,
        languages,
        targetAudience,
        gbpAccountName,
        gbpLocationName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<BusinessProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('phone_country_iso')) {
      context.handle(
          _phoneCountryIsoMeta,
          phoneCountryIso.isAcceptableOrUnknown(
              data['phone_country_iso']!, _phoneCountryIsoMeta));
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    }
    if (data.containsKey('whatsapp_link')) {
      context.handle(
          _whatsappLinkMeta,
          whatsappLink.isAcceptableOrUnknown(
              data['whatsapp_link']!, _whatsappLinkMeta));
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('languages')) {
      context.handle(_languagesMeta,
          languages.isAcceptableOrUnknown(data['languages']!, _languagesMeta));
    }
    if (data.containsKey('target_audience')) {
      context.handle(
          _targetAudienceMeta,
          targetAudience.isAcceptableOrUnknown(
              data['target_audience']!, _targetAudienceMeta));
    }
    if (data.containsKey('gbp_account_name')) {
      context.handle(
          _gbpAccountNameMeta,
          gbpAccountName.isAcceptableOrUnknown(
              data['gbp_account_name']!, _gbpAccountNameMeta));
    }
    if (data.containsKey('gbp_location_name')) {
      context.handle(
          _gbpLocationNameMeta,
          gbpLocationName.isAcceptableOrUnknown(
              data['gbp_location_name']!, _gbpLocationNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      phoneCountryIso: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}phone_country_iso']),
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number']),
      whatsappLink: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}whatsapp_link']),
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      languages: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}languages'])!,
      targetAudience: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_audience']),
      gbpAccountName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}gbp_account_name']),
      gbpLocationName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}gbp_location_name']),
    );
  }

  @override
  $BusinessProfilesTable createAlias(String alias) {
    return $BusinessProfilesTable(attachedDatabase, alias);
  }
}

class BusinessProfile extends DataClass implements Insertable<BusinessProfile> {
  final int id;
  final String name;
  final String category;
  final String description;
  final String address;
  final double? latitude;
  final double? longitude;

  /// ISO country code selected in the phone field (e.g. "DO").
  final String? phoneCountryIso;

  /// Full number in E.164 (e.g. "+18095550111").
  final String? phoneNumber;
  final String? whatsappLink;
  final String? website;
  final String? email;
  final String? notes;

  /// Comma separated language codes content should be produced in (e.g. "en,es").
  final String languages;
  final String? targetAudience;

  /// Linked Google Business Profile resources ("accounts/123", "locations/456").
  final String? gbpAccountName;
  final String? gbpLocationName;
  const BusinessProfile(
      {required this.id,
      required this.name,
      required this.category,
      required this.description,
      required this.address,
      this.latitude,
      this.longitude,
      this.phoneCountryIso,
      this.phoneNumber,
      this.whatsappLink,
      this.website,
      this.email,
      this.notes,
      required this.languages,
      this.targetAudience,
      this.gbpAccountName,
      this.gbpLocationName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['address'] = Variable<String>(address);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || phoneCountryIso != null) {
      map['phone_country_iso'] = Variable<String>(phoneCountryIso);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    if (!nullToAbsent || whatsappLink != null) {
      map['whatsapp_link'] = Variable<String>(whatsappLink);
    }
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['languages'] = Variable<String>(languages);
    if (!nullToAbsent || targetAudience != null) {
      map['target_audience'] = Variable<String>(targetAudience);
    }
    if (!nullToAbsent || gbpAccountName != null) {
      map['gbp_account_name'] = Variable<String>(gbpAccountName);
    }
    if (!nullToAbsent || gbpLocationName != null) {
      map['gbp_location_name'] = Variable<String>(gbpLocationName);
    }
    return map;
  }

  BusinessProfilesCompanion toCompanion(bool nullToAbsent) {
    return BusinessProfilesCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      description: Value(description),
      address: Value(address),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      phoneCountryIso: phoneCountryIso == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneCountryIso),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
      whatsappLink: whatsappLink == null && nullToAbsent
          ? const Value.absent()
          : Value(whatsappLink),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      languages: Value(languages),
      targetAudience: targetAudience == null && nullToAbsent
          ? const Value.absent()
          : Value(targetAudience),
      gbpAccountName: gbpAccountName == null && nullToAbsent
          ? const Value.absent()
          : Value(gbpAccountName),
      gbpLocationName: gbpLocationName == null && nullToAbsent
          ? const Value.absent()
          : Value(gbpLocationName),
    );
  }

  factory BusinessProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      phoneCountryIso: serializer.fromJson<String?>(json['phoneCountryIso']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
      whatsappLink: serializer.fromJson<String?>(json['whatsappLink']),
      website: serializer.fromJson<String?>(json['website']),
      email: serializer.fromJson<String?>(json['email']),
      notes: serializer.fromJson<String?>(json['notes']),
      languages: serializer.fromJson<String>(json['languages']),
      targetAudience: serializer.fromJson<String?>(json['targetAudience']),
      gbpAccountName: serializer.fromJson<String?>(json['gbpAccountName']),
      gbpLocationName: serializer.fromJson<String?>(json['gbpLocationName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'phoneCountryIso': serializer.toJson<String?>(phoneCountryIso),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
      'whatsappLink': serializer.toJson<String?>(whatsappLink),
      'website': serializer.toJson<String?>(website),
      'email': serializer.toJson<String?>(email),
      'notes': serializer.toJson<String?>(notes),
      'languages': serializer.toJson<String>(languages),
      'targetAudience': serializer.toJson<String?>(targetAudience),
      'gbpAccountName': serializer.toJson<String?>(gbpAccountName),
      'gbpLocationName': serializer.toJson<String?>(gbpLocationName),
    };
  }

  BusinessProfile copyWith(
          {int? id,
          String? name,
          String? category,
          String? description,
          String? address,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          Value<String?> phoneCountryIso = const Value.absent(),
          Value<String?> phoneNumber = const Value.absent(),
          Value<String?> whatsappLink = const Value.absent(),
          Value<String?> website = const Value.absent(),
          Value<String?> email = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? languages,
          Value<String?> targetAudience = const Value.absent(),
          Value<String?> gbpAccountName = const Value.absent(),
          Value<String?> gbpLocationName = const Value.absent()}) =>
      BusinessProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        category: category ?? this.category,
        description: description ?? this.description,
        address: address ?? this.address,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        phoneCountryIso: phoneCountryIso.present
            ? phoneCountryIso.value
            : this.phoneCountryIso,
        phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
        whatsappLink:
            whatsappLink.present ? whatsappLink.value : this.whatsappLink,
        website: website.present ? website.value : this.website,
        email: email.present ? email.value : this.email,
        notes: notes.present ? notes.value : this.notes,
        languages: languages ?? this.languages,
        targetAudience:
            targetAudience.present ? targetAudience.value : this.targetAudience,
        gbpAccountName:
            gbpAccountName.present ? gbpAccountName.value : this.gbpAccountName,
        gbpLocationName: gbpLocationName.present
            ? gbpLocationName.value
            : this.gbpLocationName,
      );
  BusinessProfile copyWithCompanion(BusinessProfilesCompanion data) {
    return BusinessProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      phoneCountryIso: data.phoneCountryIso.present
          ? data.phoneCountryIso.value
          : this.phoneCountryIso,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      whatsappLink: data.whatsappLink.present
          ? data.whatsappLink.value
          : this.whatsappLink,
      website: data.website.present ? data.website.value : this.website,
      email: data.email.present ? data.email.value : this.email,
      notes: data.notes.present ? data.notes.value : this.notes,
      languages: data.languages.present ? data.languages.value : this.languages,
      targetAudience: data.targetAudience.present
          ? data.targetAudience.value
          : this.targetAudience,
      gbpAccountName: data.gbpAccountName.present
          ? data.gbpAccountName.value
          : this.gbpAccountName,
      gbpLocationName: data.gbpLocationName.present
          ? data.gbpLocationName.value
          : this.gbpLocationName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phoneCountryIso: $phoneCountryIso, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('whatsappLink: $whatsappLink, ')
          ..write('website: $website, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('languages: $languages, ')
          ..write('targetAudience: $targetAudience, ')
          ..write('gbpAccountName: $gbpAccountName, ')
          ..write('gbpLocationName: $gbpLocationName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      category,
      description,
      address,
      latitude,
      longitude,
      phoneCountryIso,
      phoneNumber,
      whatsappLink,
      website,
      email,
      notes,
      languages,
      targetAudience,
      gbpAccountName,
      gbpLocationName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.description == this.description &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.phoneCountryIso == this.phoneCountryIso &&
          other.phoneNumber == this.phoneNumber &&
          other.whatsappLink == this.whatsappLink &&
          other.website == this.website &&
          other.email == this.email &&
          other.notes == this.notes &&
          other.languages == this.languages &&
          other.targetAudience == this.targetAudience &&
          other.gbpAccountName == this.gbpAccountName &&
          other.gbpLocationName == this.gbpLocationName);
}

class BusinessProfilesCompanion extends UpdateCompanion<BusinessProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> description;
  final Value<String> address;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<String?> phoneCountryIso;
  final Value<String?> phoneNumber;
  final Value<String?> whatsappLink;
  final Value<String?> website;
  final Value<String?> email;
  final Value<String?> notes;
  final Value<String> languages;
  final Value<String?> targetAudience;
  final Value<String?> gbpAccountName;
  final Value<String?> gbpLocationName;
  const BusinessProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phoneCountryIso = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.whatsappLink = const Value.absent(),
    this.website = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.languages = const Value.absent(),
    this.targetAudience = const Value.absent(),
    this.gbpAccountName = const Value.absent(),
    this.gbpLocationName = const Value.absent(),
  });
  BusinessProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.phoneCountryIso = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.whatsappLink = const Value.absent(),
    this.website = const Value.absent(),
    this.email = const Value.absent(),
    this.notes = const Value.absent(),
    this.languages = const Value.absent(),
    this.targetAudience = const Value.absent(),
    this.gbpAccountName = const Value.absent(),
    this.gbpLocationName = const Value.absent(),
  }) : name = Value(name);
  static Insertable<BusinessProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? phoneCountryIso,
    Expression<String>? phoneNumber,
    Expression<String>? whatsappLink,
    Expression<String>? website,
    Expression<String>? email,
    Expression<String>? notes,
    Expression<String>? languages,
    Expression<String>? targetAudience,
    Expression<String>? gbpAccountName,
    Expression<String>? gbpLocationName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (phoneCountryIso != null) 'phone_country_iso': phoneCountryIso,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (whatsappLink != null) 'whatsapp_link': whatsappLink,
      if (website != null) 'website': website,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      if (languages != null) 'languages': languages,
      if (targetAudience != null) 'target_audience': targetAudience,
      if (gbpAccountName != null) 'gbp_account_name': gbpAccountName,
      if (gbpLocationName != null) 'gbp_location_name': gbpLocationName,
    });
  }

  BusinessProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? category,
      Value<String>? description,
      Value<String>? address,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<String?>? phoneCountryIso,
      Value<String?>? phoneNumber,
      Value<String?>? whatsappLink,
      Value<String?>? website,
      Value<String?>? email,
      Value<String?>? notes,
      Value<String>? languages,
      Value<String?>? targetAudience,
      Value<String?>? gbpAccountName,
      Value<String?>? gbpLocationName}) {
    return BusinessProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneCountryIso: phoneCountryIso ?? this.phoneCountryIso,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappLink: whatsappLink ?? this.whatsappLink,
      website: website ?? this.website,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      languages: languages ?? this.languages,
      targetAudience: targetAudience ?? this.targetAudience,
      gbpAccountName: gbpAccountName ?? this.gbpAccountName,
      gbpLocationName: gbpLocationName ?? this.gbpLocationName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (phoneCountryIso.present) {
      map['phone_country_iso'] = Variable<String>(phoneCountryIso.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (whatsappLink.present) {
      map['whatsapp_link'] = Variable<String>(whatsappLink.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (languages.present) {
      map['languages'] = Variable<String>(languages.value);
    }
    if (targetAudience.present) {
      map['target_audience'] = Variable<String>(targetAudience.value);
    }
    if (gbpAccountName.present) {
      map['gbp_account_name'] = Variable<String>(gbpAccountName.value);
    }
    if (gbpLocationName.present) {
      map['gbp_location_name'] = Variable<String>(gbpLocationName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('phoneCountryIso: $phoneCountryIso, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('whatsappLink: $whatsappLink, ')
          ..write('website: $website, ')
          ..write('email: $email, ')
          ..write('notes: $notes, ')
          ..write('languages: $languages, ')
          ..write('targetAudience: $targetAudience, ')
          ..write('gbpAccountName: $gbpAccountName, ')
          ..write('gbpLocationName: $gbpLocationName')
          ..write(')'))
        .toString();
  }
}

class $StagingItemsTable extends StagingItems
    with TableInfo<$StagingItemsTable, StagingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StagingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
      'business_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES business_profiles (id)'));
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('product'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _priceAmountMeta =
      const VerificationMeta('priceAmount');
  @override
  late final GeneratedColumn<String> priceAmount = GeneratedColumn<String>(
      'price_amount', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _priceIsAiEstimateMeta =
      const VerificationMeta('priceIsAiEstimate');
  @override
  late final GeneratedColumn<bool> priceIsAiEstimate = GeneratedColumn<bool>(
      'price_is_ai_estimate', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("price_is_ai_estimate" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _landingUrlMeta =
      const VerificationMeta('landingUrl');
  @override
  late final GeneratedColumn<String> landingUrl = GeneratedColumn<String>(
      'landing_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        kind,
        title,
        category,
        description,
        language,
        priceAmount,
        currencyCode,
        priceIsAiEstimate,
        landingUrl,
        imagePath,
        source,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staging_items';
  @override
  VerificationContext validateIntegrity(Insertable<StagingItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('price_amount')) {
      context.handle(
          _priceAmountMeta,
          priceAmount.isAcceptableOrUnknown(
              data['price_amount']!, _priceAmountMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('price_is_ai_estimate')) {
      context.handle(
          _priceIsAiEstimateMeta,
          priceIsAiEstimate.isAcceptableOrUnknown(
              data['price_is_ai_estimate']!, _priceIsAiEstimateMeta));
    }
    if (data.containsKey('landing_url')) {
      context.handle(
          _landingUrlMeta,
          landingUrl.isAcceptableOrUnknown(
              data['landing_url']!, _landingUrlMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StagingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StagingItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}business_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      priceAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}price_amount'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      priceIsAiEstimate: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}price_is_ai_estimate'])!,
      landingUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}landing_url']),
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StagingItemsTable createAlias(String alias) {
    return $StagingItemsTable(attachedDatabase, alias);
  }
}

class StagingItem extends DataClass implements Insertable<StagingItem> {
  final int id;
  final int businessId;

  /// product | service | offer | other
  final String kind;
  final String title;
  final String category;
  final String description;

  /// Language of this entry ("en", "es", …).
  final String language;
  final String priceAmount;
  final String currencyCode;

  /// True while the price is an unverified AI estimation (amber highlight).
  final bool priceIsAiEstimate;

  /// Optional "product landing page" URL (official brand page, Wikipedia, …).
  final String? landingUrl;
  final String? imagePath;

  /// ai:gemini | ai:qwen | manual
  final String source;

  /// draft | published
  final String status;
  final DateTime createdAt;
  const StagingItem(
      {required this.id,
      required this.businessId,
      required this.kind,
      required this.title,
      required this.category,
      required this.description,
      required this.language,
      required this.priceAmount,
      required this.currencyCode,
      required this.priceIsAiEstimate,
      this.landingUrl,
      this.imagePath,
      required this.source,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['category'] = Variable<String>(category);
    map['description'] = Variable<String>(description);
    map['language'] = Variable<String>(language);
    map['price_amount'] = Variable<String>(priceAmount);
    map['currency_code'] = Variable<String>(currencyCode);
    map['price_is_ai_estimate'] = Variable<bool>(priceIsAiEstimate);
    if (!nullToAbsent || landingUrl != null) {
      map['landing_url'] = Variable<String>(landingUrl);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StagingItemsCompanion toCompanion(bool nullToAbsent) {
    return StagingItemsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      kind: Value(kind),
      title: Value(title),
      category: Value(category),
      description: Value(description),
      language: Value(language),
      priceAmount: Value(priceAmount),
      currencyCode: Value(currencyCode),
      priceIsAiEstimate: Value(priceIsAiEstimate),
      landingUrl: landingUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(landingUrl),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      source: Value(source),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory StagingItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StagingItem(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      description: serializer.fromJson<String>(json['description']),
      language: serializer.fromJson<String>(json['language']),
      priceAmount: serializer.fromJson<String>(json['priceAmount']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      priceIsAiEstimate: serializer.fromJson<bool>(json['priceIsAiEstimate']),
      landingUrl: serializer.fromJson<String?>(json['landingUrl']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'category': serializer.toJson<String>(category),
      'description': serializer.toJson<String>(description),
      'language': serializer.toJson<String>(language),
      'priceAmount': serializer.toJson<String>(priceAmount),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'priceIsAiEstimate': serializer.toJson<bool>(priceIsAiEstimate),
      'landingUrl': serializer.toJson<String?>(landingUrl),
      'imagePath': serializer.toJson<String?>(imagePath),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StagingItem copyWith(
          {int? id,
          int? businessId,
          String? kind,
          String? title,
          String? category,
          String? description,
          String? language,
          String? priceAmount,
          String? currencyCode,
          bool? priceIsAiEstimate,
          Value<String?> landingUrl = const Value.absent(),
          Value<String?> imagePath = const Value.absent(),
          String? source,
          String? status,
          DateTime? createdAt}) =>
      StagingItem(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        category: category ?? this.category,
        description: description ?? this.description,
        language: language ?? this.language,
        priceAmount: priceAmount ?? this.priceAmount,
        currencyCode: currencyCode ?? this.currencyCode,
        priceIsAiEstimate: priceIsAiEstimate ?? this.priceIsAiEstimate,
        landingUrl: landingUrl.present ? landingUrl.value : this.landingUrl,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        source: source ?? this.source,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  StagingItem copyWithCompanion(StagingItemsCompanion data) {
    return StagingItem(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      description:
          data.description.present ? data.description.value : this.description,
      language: data.language.present ? data.language.value : this.language,
      priceAmount:
          data.priceAmount.present ? data.priceAmount.value : this.priceAmount,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      priceIsAiEstimate: data.priceIsAiEstimate.present
          ? data.priceIsAiEstimate.value
          : this.priceIsAiEstimate,
      landingUrl:
          data.landingUrl.present ? data.landingUrl.value : this.landingUrl,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StagingItem(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('priceIsAiEstimate: $priceIsAiEstimate, ')
          ..write('landingUrl: $landingUrl, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      businessId,
      kind,
      title,
      category,
      description,
      language,
      priceAmount,
      currencyCode,
      priceIsAiEstimate,
      landingUrl,
      imagePath,
      source,
      status,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StagingItem &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.category == this.category &&
          other.description == this.description &&
          other.language == this.language &&
          other.priceAmount == this.priceAmount &&
          other.currencyCode == this.currencyCode &&
          other.priceIsAiEstimate == this.priceIsAiEstimate &&
          other.landingUrl == this.landingUrl &&
          other.imagePath == this.imagePath &&
          other.source == this.source &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class StagingItemsCompanion extends UpdateCompanion<StagingItem> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> category;
  final Value<String> description;
  final Value<String> language;
  final Value<String> priceAmount;
  final Value<String> currencyCode;
  final Value<bool> priceIsAiEstimate;
  final Value<String?> landingUrl;
  final Value<String?> imagePath;
  final Value<String> source;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const StagingItemsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.priceAmount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.priceIsAiEstimate = const Value.absent(),
    this.landingUrl = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StagingItemsCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    this.kind = const Value.absent(),
    required String title,
    this.category = const Value.absent(),
    this.description = const Value.absent(),
    this.language = const Value.absent(),
    this.priceAmount = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.priceIsAiEstimate = const Value.absent(),
    this.landingUrl = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : businessId = Value(businessId),
        title = Value(title);
  static Insertable<StagingItem> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? description,
    Expression<String>? language,
    Expression<String>? priceAmount,
    Expression<String>? currencyCode,
    Expression<bool>? priceIsAiEstimate,
    Expression<String>? landingUrl,
    Expression<String>? imagePath,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (language != null) 'language': language,
      if (priceAmount != null) 'price_amount': priceAmount,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (priceIsAiEstimate != null) 'price_is_ai_estimate': priceIsAiEstimate,
      if (landingUrl != null) 'landing_url': landingUrl,
      if (imagePath != null) 'image_path': imagePath,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StagingItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? businessId,
      Value<String>? kind,
      Value<String>? title,
      Value<String>? category,
      Value<String>? description,
      Value<String>? language,
      Value<String>? priceAmount,
      Value<String>? currencyCode,
      Value<bool>? priceIsAiEstimate,
      Value<String?>? landingUrl,
      Value<String?>? imagePath,
      Value<String>? source,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return StagingItemsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      language: language ?? this.language,
      priceAmount: priceAmount ?? this.priceAmount,
      currencyCode: currencyCode ?? this.currencyCode,
      priceIsAiEstimate: priceIsAiEstimate ?? this.priceIsAiEstimate,
      landingUrl: landingUrl ?? this.landingUrl,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (priceAmount.present) {
      map['price_amount'] = Variable<String>(priceAmount.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (priceIsAiEstimate.present) {
      map['price_is_ai_estimate'] = Variable<bool>(priceIsAiEstimate.value);
    }
    if (landingUrl.present) {
      map['landing_url'] = Variable<String>(landingUrl.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StagingItemsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('description: $description, ')
          ..write('language: $language, ')
          ..write('priceAmount: $priceAmount, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('priceIsAiEstimate: $priceIsAiEstimate, ')
          ..write('landingUrl: $landingUrl, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BusinessPostsTable extends BusinessPosts
    with TableInfo<$BusinessPostsTable, BusinessPost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessPostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _businessIdMeta =
      const VerificationMeta('businessId');
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
      'business_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES business_profiles (id)'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('en'));
  static const VerificationMeta _topicTypeMeta =
      const VerificationMeta('topicType');
  @override
  late final GeneratedColumn<String> topicType = GeneratedColumn<String>(
      'topic_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('STANDARD'));
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessId,
        title,
        body,
        language,
        topicType,
        imagePath,
        source,
        status,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'business_posts';
  @override
  VerificationContext validateIntegrity(Insertable<BusinessPost> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
          _businessIdMeta,
          businessId.isAcceptableOrUnknown(
              data['business_id']!, _businessIdMeta));
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    }
    if (data.containsKey('topic_type')) {
      context.handle(_topicTypeMeta,
          topicType.isAcceptableOrUnknown(data['topic_type']!, _topicTypeMeta));
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BusinessPost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BusinessPost(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      businessId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}business_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      topicType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic_type'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BusinessPostsTable createAlias(String alias) {
    return $BusinessPostsTable(attachedDatabase, alias);
  }
}

class BusinessPost extends DataClass implements Insertable<BusinessPost> {
  final int id;
  final int businessId;
  final String title;
  final String body;
  final String language;

  /// STANDARD | OFFER | EVENT — maps to GBP localPost topic types.
  final String topicType;
  final String? imagePath;

  /// ai:gemini | ai:qwen | manual
  final String source;

  /// draft | published
  final String status;
  final DateTime createdAt;
  const BusinessPost(
      {required this.id,
      required this.businessId,
      required this.title,
      required this.body,
      required this.language,
      required this.topicType,
      this.imagePath,
      required this.source,
      required this.status,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['language'] = Variable<String>(language);
    map['topic_type'] = Variable<String>(topicType);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['source'] = Variable<String>(source);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BusinessPostsCompanion toCompanion(bool nullToAbsent) {
    return BusinessPostsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      title: Value(title),
      body: Value(body),
      language: Value(language),
      topicType: Value(topicType),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      source: Value(source),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory BusinessPost.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BusinessPost(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      language: serializer.fromJson<String>(json['language']),
      topicType: serializer.fromJson<String>(json['topicType']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      source: serializer.fromJson<String>(json['source']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'language': serializer.toJson<String>(language),
      'topicType': serializer.toJson<String>(topicType),
      'imagePath': serializer.toJson<String?>(imagePath),
      'source': serializer.toJson<String>(source),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BusinessPost copyWith(
          {int? id,
          int? businessId,
          String? title,
          String? body,
          String? language,
          String? topicType,
          Value<String?> imagePath = const Value.absent(),
          String? source,
          String? status,
          DateTime? createdAt}) =>
      BusinessPost(
        id: id ?? this.id,
        businessId: businessId ?? this.businessId,
        title: title ?? this.title,
        body: body ?? this.body,
        language: language ?? this.language,
        topicType: topicType ?? this.topicType,
        imagePath: imagePath.present ? imagePath.value : this.imagePath,
        source: source ?? this.source,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
      );
  BusinessPost copyWithCompanion(BusinessPostsCompanion data) {
    return BusinessPost(
      id: data.id.present ? data.id.value : this.id,
      businessId:
          data.businessId.present ? data.businessId.value : this.businessId,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      language: data.language.present ? data.language.value : this.language,
      topicType: data.topicType.present ? data.topicType.value : this.topicType,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      source: data.source.present ? data.source.value : this.source,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BusinessPost(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('language: $language, ')
          ..write('topicType: $topicType, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessId, title, body, language,
      topicType, imagePath, source, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BusinessPost &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.title == this.title &&
          other.body == this.body &&
          other.language == this.language &&
          other.topicType == this.topicType &&
          other.imagePath == this.imagePath &&
          other.source == this.source &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class BusinessPostsCompanion extends UpdateCompanion<BusinessPost> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<String> title;
  final Value<String> body;
  final Value<String> language;
  final Value<String> topicType;
  final Value<String?> imagePath;
  final Value<String> source;
  final Value<String> status;
  final Value<DateTime> createdAt;
  const BusinessPostsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.language = const Value.absent(),
    this.topicType = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BusinessPostsCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required String title,
    required String body,
    this.language = const Value.absent(),
    this.topicType = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.source = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : businessId = Value(businessId),
        title = Value(title),
        body = Value(body);
  static Insertable<BusinessPost> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? language,
    Expression<String>? topicType,
    Expression<String>? imagePath,
    Expression<String>? source,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (language != null) 'language': language,
      if (topicType != null) 'topic_type': topicType,
      if (imagePath != null) 'image_path': imagePath,
      if (source != null) 'source': source,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BusinessPostsCompanion copyWith(
      {Value<int>? id,
      Value<int>? businessId,
      Value<String>? title,
      Value<String>? body,
      Value<String>? language,
      Value<String>? topicType,
      Value<String?>? imagePath,
      Value<String>? source,
      Value<String>? status,
      Value<DateTime>? createdAt}) {
    return BusinessPostsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      body: body ?? this.body,
      language: language ?? this.language,
      topicType: topicType ?? this.topicType,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (topicType.present) {
      map['topic_type'] = Variable<String>(topicType.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessPostsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('language: $language, ')
          ..write('topicType: $topicType, ')
          ..write('imagePath: $imagePath, ')
          ..write('source: $source, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessProfilesTable businessProfiles =
      $BusinessProfilesTable(this);
  late final $StagingItemsTable stagingItems = $StagingItemsTable(this);
  late final $BusinessPostsTable businessPosts = $BusinessPostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [businessProfiles, stagingItems, businessPosts];
}

typedef $$BusinessProfilesTableCreateCompanionBuilder
    = BusinessProfilesCompanion Function({
  Value<int> id,
  required String name,
  Value<String> category,
  Value<String> description,
  Value<String> address,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> phoneCountryIso,
  Value<String?> phoneNumber,
  Value<String?> whatsappLink,
  Value<String?> website,
  Value<String?> email,
  Value<String?> notes,
  Value<String> languages,
  Value<String?> targetAudience,
  Value<String?> gbpAccountName,
  Value<String?> gbpLocationName,
});
typedef $$BusinessProfilesTableUpdateCompanionBuilder
    = BusinessProfilesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> category,
  Value<String> description,
  Value<String> address,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<String?> phoneCountryIso,
  Value<String?> phoneNumber,
  Value<String?> whatsappLink,
  Value<String?> website,
  Value<String?> email,
  Value<String?> notes,
  Value<String> languages,
  Value<String?> targetAudience,
  Value<String?> gbpAccountName,
  Value<String?> gbpLocationName,
});

final class $$BusinessProfilesTableReferences extends BaseReferences<
    _$AppDatabase, $BusinessProfilesTable, BusinessProfile> {
  $$BusinessProfilesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StagingItemsTable, List<StagingItem>>
      _stagingItemsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.stagingItems,
              aliasName: 'business_profiles__id__staging_items__business_id');

  $$StagingItemsTableProcessedTableManager get stagingItemsRefs {
    final manager = $$StagingItemsTableTableManager($_db, $_db.stagingItems)
        .filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stagingItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BusinessPostsTable, List<BusinessPost>>
      _businessPostsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.businessPosts,
              aliasName: 'business_profiles__id__business_posts__business_id');

  $$BusinessPostsTableProcessedTableManager get businessPostsRefs {
    final manager = $$BusinessPostsTableTableManager($_db, $_db.businessPosts)
        .filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_businessPostsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BusinessProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneCountryIso => $composableBuilder(
      column: $table.phoneCountryIso,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get whatsappLink => $composableBuilder(
      column: $table.whatsappLink, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gbpAccountName => $composableBuilder(
      column: $table.gbpAccountName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gbpLocationName => $composableBuilder(
      column: $table.gbpLocationName,
      builder: (column) => ColumnFilters(column));

  Expression<bool> stagingItemsRefs(
      Expression<bool> Function($$StagingItemsTableFilterComposer f) f) {
    final $$StagingItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stagingItems,
        getReferencedColumn: (t) => t.businessId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StagingItemsTableFilterComposer(
              $db: $db,
              $table: $db.stagingItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> businessPostsRefs(
      Expression<bool> Function($$BusinessPostsTableFilterComposer f) f) {
    final $$BusinessPostsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.businessPosts,
        getReferencedColumn: (t) => t.businessId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessPostsTableFilterComposer(
              $db: $db,
              $table: $db.businessPosts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BusinessProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneCountryIso => $composableBuilder(
      column: $table.phoneCountryIso,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get whatsappLink => $composableBuilder(
      column: $table.whatsappLink,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get languages => $composableBuilder(
      column: $table.languages, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gbpAccountName => $composableBuilder(
      column: $table.gbpAccountName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gbpLocationName => $composableBuilder(
      column: $table.gbpLocationName,
      builder: (column) => ColumnOrderings(column));
}

class $$BusinessProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessProfilesTable> {
  $$BusinessProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get phoneCountryIso => $composableBuilder(
      column: $table.phoneCountryIso, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get whatsappLink => $composableBuilder(
      column: $table.whatsappLink, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get languages =>
      $composableBuilder(column: $table.languages, builder: (column) => column);

  GeneratedColumn<String> get targetAudience => $composableBuilder(
      column: $table.targetAudience, builder: (column) => column);

  GeneratedColumn<String> get gbpAccountName => $composableBuilder(
      column: $table.gbpAccountName, builder: (column) => column);

  GeneratedColumn<String> get gbpLocationName => $composableBuilder(
      column: $table.gbpLocationName, builder: (column) => column);

  Expression<T> stagingItemsRefs<T extends Object>(
      Expression<T> Function($$StagingItemsTableAnnotationComposer a) f) {
    final $$StagingItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.stagingItems,
        getReferencedColumn: (t) => t.businessId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$StagingItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.stagingItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> businessPostsRefs<T extends Object>(
      Expression<T> Function($$BusinessPostsTableAnnotationComposer a) f) {
    final $$BusinessPostsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.businessPosts,
        getReferencedColumn: (t) => t.businessId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessPostsTableAnnotationComposer(
              $db: $db,
              $table: $db.businessPosts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BusinessProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BusinessProfilesTable,
    BusinessProfile,
    $$BusinessProfilesTableFilterComposer,
    $$BusinessProfilesTableOrderingComposer,
    $$BusinessProfilesTableAnnotationComposer,
    $$BusinessProfilesTableCreateCompanionBuilder,
    $$BusinessProfilesTableUpdateCompanionBuilder,
    (BusinessProfile, $$BusinessProfilesTableReferences),
    BusinessProfile,
    PrefetchHooks Function({bool stagingItemsRefs, bool businessPostsRefs})> {
  $$BusinessProfilesTableTableManager(
      _$AppDatabase db, $BusinessProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> phoneCountryIso = const Value.absent(),
            Value<String?> phoneNumber = const Value.absent(),
            Value<String?> whatsappLink = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> languages = const Value.absent(),
            Value<String?> targetAudience = const Value.absent(),
            Value<String?> gbpAccountName = const Value.absent(),
            Value<String?> gbpLocationName = const Value.absent(),
          }) =>
              BusinessProfilesCompanion(
            id: id,
            name: name,
            category: category,
            description: description,
            address: address,
            latitude: latitude,
            longitude: longitude,
            phoneCountryIso: phoneCountryIso,
            phoneNumber: phoneNumber,
            whatsappLink: whatsappLink,
            website: website,
            email: email,
            notes: notes,
            languages: languages,
            targetAudience: targetAudience,
            gbpAccountName: gbpAccountName,
            gbpLocationName: gbpLocationName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> address = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<String?> phoneCountryIso = const Value.absent(),
            Value<String?> phoneNumber = const Value.absent(),
            Value<String?> whatsappLink = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> languages = const Value.absent(),
            Value<String?> targetAudience = const Value.absent(),
            Value<String?> gbpAccountName = const Value.absent(),
            Value<String?> gbpLocationName = const Value.absent(),
          }) =>
              BusinessProfilesCompanion.insert(
            id: id,
            name: name,
            category: category,
            description: description,
            address: address,
            latitude: latitude,
            longitude: longitude,
            phoneCountryIso: phoneCountryIso,
            phoneNumber: phoneNumber,
            whatsappLink: whatsappLink,
            website: website,
            email: email,
            notes: notes,
            languages: languages,
            targetAudience: targetAudience,
            gbpAccountName: gbpAccountName,
            gbpLocationName: gbpLocationName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BusinessProfilesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {stagingItemsRefs = false, businessPostsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (stagingItemsRefs) db.stagingItems,
                if (businessPostsRefs) db.businessPosts
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stagingItemsRefs)
                    await $_getPrefetchedData<BusinessProfile,
                            $BusinessProfilesTable, StagingItem>(
                        currentTable: table,
                        referencedTable: $$BusinessProfilesTableReferences
                            ._stagingItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BusinessProfilesTableReferences(db, table, p0)
                                .stagingItemsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.businessId == item.id),
                        typedResults: items),
                  if (businessPostsRefs)
                    await $_getPrefetchedData<BusinessProfile,
                            $BusinessProfilesTable, BusinessPost>(
                        currentTable: table,
                        referencedTable: $$BusinessProfilesTableReferences
                            ._businessPostsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BusinessProfilesTableReferences(db, table, p0)
                                .businessPostsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.businessId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BusinessProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BusinessProfilesTable,
    BusinessProfile,
    $$BusinessProfilesTableFilterComposer,
    $$BusinessProfilesTableOrderingComposer,
    $$BusinessProfilesTableAnnotationComposer,
    $$BusinessProfilesTableCreateCompanionBuilder,
    $$BusinessProfilesTableUpdateCompanionBuilder,
    (BusinessProfile, $$BusinessProfilesTableReferences),
    BusinessProfile,
    PrefetchHooks Function({bool stagingItemsRefs, bool businessPostsRefs})>;
typedef $$StagingItemsTableCreateCompanionBuilder = StagingItemsCompanion
    Function({
  Value<int> id,
  required int businessId,
  Value<String> kind,
  required String title,
  Value<String> category,
  Value<String> description,
  Value<String> language,
  Value<String> priceAmount,
  Value<String> currencyCode,
  Value<bool> priceIsAiEstimate,
  Value<String?> landingUrl,
  Value<String?> imagePath,
  Value<String> source,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$StagingItemsTableUpdateCompanionBuilder = StagingItemsCompanion
    Function({
  Value<int> id,
  Value<int> businessId,
  Value<String> kind,
  Value<String> title,
  Value<String> category,
  Value<String> description,
  Value<String> language,
  Value<String> priceAmount,
  Value<String> currencyCode,
  Value<bool> priceIsAiEstimate,
  Value<String?> landingUrl,
  Value<String?> imagePath,
  Value<String> source,
  Value<String> status,
  Value<DateTime> createdAt,
});

final class $$StagingItemsTableReferences
    extends BaseReferences<_$AppDatabase, $StagingItemsTable, StagingItem> {
  $$StagingItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessProfilesTable _businessIdTable(_$AppDatabase db) =>
      db.businessProfiles
          .createAlias('staging_items__business_id__business_profiles__id');

  $$BusinessProfilesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager =
        $$BusinessProfilesTableTableManager($_db, $_db.businessProfiles)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$StagingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $StagingItemsTable> {
  $$StagingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get priceIsAiEstimate => $composableBuilder(
      column: $table.priceIsAiEstimate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get landingUrl => $composableBuilder(
      column: $table.landingUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BusinessProfilesTableFilterComposer get businessId {
    final $$BusinessProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableFilterComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StagingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $StagingItemsTable> {
  $$StagingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get priceIsAiEstimate => $composableBuilder(
      column: $table.priceIsAiEstimate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get landingUrl => $composableBuilder(
      column: $table.landingUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BusinessProfilesTableOrderingComposer get businessId {
    final $$BusinessProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StagingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StagingItemsTable> {
  $$StagingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get priceAmount => $composableBuilder(
      column: $table.priceAmount, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<bool> get priceIsAiEstimate => $composableBuilder(
      column: $table.priceIsAiEstimate, builder: (column) => column);

  GeneratedColumn<String> get landingUrl => $composableBuilder(
      column: $table.landingUrl, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessProfilesTableAnnotationComposer get businessId {
    final $$BusinessProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$StagingItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StagingItemsTable,
    StagingItem,
    $$StagingItemsTableFilterComposer,
    $$StagingItemsTableOrderingComposer,
    $$StagingItemsTableAnnotationComposer,
    $$StagingItemsTableCreateCompanionBuilder,
    $$StagingItemsTableUpdateCompanionBuilder,
    (StagingItem, $$StagingItemsTableReferences),
    StagingItem,
    PrefetchHooks Function({bool businessId})> {
  $$StagingItemsTableTableManager(_$AppDatabase db, $StagingItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StagingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StagingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StagingItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> businessId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> priceAmount = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<bool> priceIsAiEstimate = const Value.absent(),
            Value<String?> landingUrl = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              StagingItemsCompanion(
            id: id,
            businessId: businessId,
            kind: kind,
            title: title,
            category: category,
            description: description,
            language: language,
            priceAmount: priceAmount,
            currencyCode: currencyCode,
            priceIsAiEstimate: priceIsAiEstimate,
            landingUrl: landingUrl,
            imagePath: imagePath,
            source: source,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int businessId,
            Value<String> kind = const Value.absent(),
            required String title,
            Value<String> category = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> priceAmount = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<bool> priceIsAiEstimate = const Value.absent(),
            Value<String?> landingUrl = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              StagingItemsCompanion.insert(
            id: id,
            businessId: businessId,
            kind: kind,
            title: title,
            category: category,
            description: description,
            language: language,
            priceAmount: priceAmount,
            currencyCode: currencyCode,
            priceIsAiEstimate: priceIsAiEstimate,
            landingUrl: landingUrl,
            imagePath: imagePath,
            source: source,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$StagingItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (businessId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.businessId,
                    referencedTable:
                        $$StagingItemsTableReferences._businessIdTable(db),
                    referencedColumn:
                        $$StagingItemsTableReferences._businessIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$StagingItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StagingItemsTable,
    StagingItem,
    $$StagingItemsTableFilterComposer,
    $$StagingItemsTableOrderingComposer,
    $$StagingItemsTableAnnotationComposer,
    $$StagingItemsTableCreateCompanionBuilder,
    $$StagingItemsTableUpdateCompanionBuilder,
    (StagingItem, $$StagingItemsTableReferences),
    StagingItem,
    PrefetchHooks Function({bool businessId})>;
typedef $$BusinessPostsTableCreateCompanionBuilder = BusinessPostsCompanion
    Function({
  Value<int> id,
  required int businessId,
  required String title,
  required String body,
  Value<String> language,
  Value<String> topicType,
  Value<String?> imagePath,
  Value<String> source,
  Value<String> status,
  Value<DateTime> createdAt,
});
typedef $$BusinessPostsTableUpdateCompanionBuilder = BusinessPostsCompanion
    Function({
  Value<int> id,
  Value<int> businessId,
  Value<String> title,
  Value<String> body,
  Value<String> language,
  Value<String> topicType,
  Value<String?> imagePath,
  Value<String> source,
  Value<String> status,
  Value<DateTime> createdAt,
});

final class $$BusinessPostsTableReferences
    extends BaseReferences<_$AppDatabase, $BusinessPostsTable, BusinessPost> {
  $$BusinessPostsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $BusinessProfilesTable _businessIdTable(_$AppDatabase db) =>
      db.businessProfiles
          .createAlias('business_posts__business_id__business_profiles__id');

  $$BusinessProfilesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager =
        $$BusinessProfilesTableTableManager($_db, $_db.businessProfiles)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BusinessPostsTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessPostsTable> {
  $$BusinessPostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topicType => $composableBuilder(
      column: $table.topicType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$BusinessProfilesTableFilterComposer get businessId {
    final $$BusinessProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableFilterComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BusinessPostsTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessPostsTable> {
  $$BusinessPostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get language => $composableBuilder(
      column: $table.language, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topicType => $composableBuilder(
      column: $table.topicType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$BusinessProfilesTableOrderingComposer get businessId {
    final $$BusinessProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BusinessPostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessPostsTable> {
  $$BusinessPostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get topicType =>
      $composableBuilder(column: $table.topicType, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessProfilesTableAnnotationComposer get businessId {
    final $$BusinessProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.businessId,
        referencedTable: $db.businessProfiles,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BusinessProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.businessProfiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BusinessPostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BusinessPostsTable,
    BusinessPost,
    $$BusinessPostsTableFilterComposer,
    $$BusinessPostsTableOrderingComposer,
    $$BusinessPostsTableAnnotationComposer,
    $$BusinessPostsTableCreateCompanionBuilder,
    $$BusinessPostsTableUpdateCompanionBuilder,
    (BusinessPost, $$BusinessPostsTableReferences),
    BusinessPost,
    PrefetchHooks Function({bool businessId})> {
  $$BusinessPostsTableTableManager(_$AppDatabase db, $BusinessPostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessPostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessPostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessPostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> businessId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<String> language = const Value.absent(),
            Value<String> topicType = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BusinessPostsCompanion(
            id: id,
            businessId: businessId,
            title: title,
            body: body,
            language: language,
            topicType: topicType,
            imagePath: imagePath,
            source: source,
            status: status,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int businessId,
            required String title,
            required String body,
            Value<String> language = const Value.absent(),
            Value<String> topicType = const Value.absent(),
            Value<String?> imagePath = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BusinessPostsCompanion.insert(
            id: id,
            businessId: businessId,
            title: title,
            body: body,
            language: language,
            topicType: topicType,
            imagePath: imagePath,
            source: source,
            status: status,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$BusinessPostsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (businessId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.businessId,
                    referencedTable:
                        $$BusinessPostsTableReferences._businessIdTable(db),
                    referencedColumn:
                        $$BusinessPostsTableReferences._businessIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BusinessPostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BusinessPostsTable,
    BusinessPost,
    $$BusinessPostsTableFilterComposer,
    $$BusinessPostsTableOrderingComposer,
    $$BusinessPostsTableAnnotationComposer,
    $$BusinessPostsTableCreateCompanionBuilder,
    $$BusinessPostsTableUpdateCompanionBuilder,
    (BusinessPost, $$BusinessPostsTableReferences),
    BusinessPost,
    PrefetchHooks Function({bool businessId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessProfilesTableTableManager get businessProfiles =>
      $$BusinessProfilesTableTableManager(_db, _db.businessProfiles);
  $$StagingItemsTableTableManager get stagingItems =>
      $$StagingItemsTableTableManager(_db, _db.stagingItems);
  $$BusinessPostsTableTableManager get businessPosts =>
      $$BusinessPostsTableTableManager(_db, _db.businessPosts);
}
