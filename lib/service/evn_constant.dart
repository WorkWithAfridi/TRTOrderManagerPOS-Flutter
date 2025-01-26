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

// class EvnConstant {
//   static const String baseUrl = 'https://thebiryanibox.ca/';
//   static const String consumerKey = 'ck_e5cf8a7f769fe6561ddf099fcb2298795d36227e';
//   static const String consumerSecret = 'cs_68511645df3e7b43c66fd5fdbc0c33e82850447e';
//   static const String version = 'wc/v3';
// }
