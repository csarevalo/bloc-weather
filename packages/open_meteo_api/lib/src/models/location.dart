class Location {
  final int id;
  final String city;
  final double latitude;
  final double longitude;
  final String state;
  final String country;
  final String countryCode;

  Location({
    required this.id,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.country,
    required this.countryCode,
  });

  Location.fromJson(Map<String, dynamic> json)
      : id = json['results'][0]['id'] as int,
        city = json['results'][0]['name'] as String,
        latitude = json['results'][0]['latitude'] as double,
        longitude = json['results'][0]['longitude'] as double,
        state = json['results'][0]['admin1'] as String? ?? '',
        country = json['results'][0]['country'] as String? ?? '',
        countryCode = json['results'][0]['country_code'] as String? ?? '';
}
