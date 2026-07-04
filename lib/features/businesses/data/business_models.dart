class BusinessProfileModel {
  const BusinessProfileModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.direction,
    required this.contactPhone,
    required this.website,
    required this.notes,
  });

  final int id;
  final String name;
  final String category;
  final String location;
  final String direction;
  final String? contactPhone;
  final String? website;
  final String? notes;
}

class StagingProductModel {
  const StagingProductModel({
    required this.id,
    required this.businessId,
    required this.title,
    required this.category,
    required this.description,
    required this.priceUsd,
    required this.priceDop,
    required this.source,
    required this.isPublished,
  });

  final int id;
  final int businessId;
  final String title;
  final String category;
  final String description;
  final String priceUsd;
  final String priceDop;
  final String source;
  final bool isPublished;
}
