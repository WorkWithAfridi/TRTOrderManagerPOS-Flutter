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
//   static const String baseUrl = 'https://cp.trttechnologies.net';
//   static const String consumerKey = 'ck_bc2663992cdf540bf18572a3b8ed25527b472001';
//   static const String consumerSecret = 'cs_f8dcc9937cb605113bfc0431bbe2c219d1b18ed8';
//   static const String version = 'wc/v3';
// }
