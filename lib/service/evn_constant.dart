class EvnConstant {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  static const String consumerKey = String.fromEnvironment(
    'CONSUMER_KEY',
    defaultValue: '',
  );

  static const String consumerSecret = String.fromEnvironment(
    'CONSUMER_SECRET',
    defaultValue: '',
  );

  static const String version = String.fromEnvironment(
    'VERSION',
    defaultValue: '',
  );
}
