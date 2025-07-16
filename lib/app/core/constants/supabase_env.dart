enum Env { dev, prod }

class EnvConfig {
  static final Map<Env, EnviromentConfigModel> config = {
    Env.dev: EnviromentConfigModel(
      sentryDSN:
          'https://1fac1f51bf8310a24f87c4b9f4d6ac8f@o4507016424456192.ingest.us.sentry.io/4508968564817920',
      isdev: true,
      supabaseUrl: 'https://oboeejxzmorurvvwocsd.supabase.co',
      supabaseAnon:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9ib2Vlanh6bW9ydXJ2dndvY3NkIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODUwNzU1NTksImV4cCI6MjAwMDY1MTU1OX0.Q6IEwfg-ISOLOp9zptZ8wN2L0Oa1nG_wabUKpjMxi3M',
    ),
    Env.prod: EnviromentConfigModel(
      sentryDSN:
          'https://1fac1f51bf8310a24f87c4b9f4d6ac8f@o4507016424456192.ingest.us.sentry.io/4508968564817920',
      isdev: false,
      supabaseUrl: 'https://adkbfrddlbetixyojduz.supabase.co',
      supabaseAnon:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFka2JmcmRkbGJldGl4eW9qZHV6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxODA2MzUsImV4cCI6MjA1MTc1NjYzNX0.pbI5s7ayhw8JHYiV_bGRU8kTHSiM5rOSgmnbN3WNq_8',
    ),
  };

  static EnviromentConfigModel getCurrentENV(Env env) => config[env]!;
}

class EnviromentConfigModel {
  final String supabaseUrl;
  final String supabaseAnon;
  final String sentryDSN;
  final bool isdev;

  const EnviromentConfigModel({
    required this.supabaseUrl,
    required this.isdev,
    required this.sentryDSN,
    required this.supabaseAnon,
  });
}
