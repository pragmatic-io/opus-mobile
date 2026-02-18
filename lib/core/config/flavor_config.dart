enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;

  static FlavorConfig? _instance;

  FlavorConfig._({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
  });

  static void initialize({
    required Flavor flavor,
    required String appName,
    required String apiBaseUrl,
    required bool enableLogging,
  }) {
    _instance = FlavorConfig._(
      flavor: flavor,
      appName: appName,
      apiBaseUrl: apiBaseUrl,
      enableLogging: enableLogging,
    );
  }

  static FlavorConfig get instance {
    assert(_instance != null, 'FlavorConfig must be initialized before use.');
    return _instance!;
  }

  bool get isDev => flavor == Flavor.dev;
  bool get isStaging => flavor == Flavor.staging;
  bool get isProd => flavor == Flavor.prod;
}
