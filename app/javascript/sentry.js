import * as Sentry from "@sentry/browser";

Sentry.init({
  dsn: SENTRY_DSN,
  environment: APP,
  release: 'msj@1.0.0',

  // Alternatively, use `process.env.npm_package_version` for a dynamic release version
  // if your build tool supports it.
  integrations: [new Sentry.BrowserTracing(), new Sentry.Replay()],

  // Set tracesSampleRate to 1.0 to capture 100%
  // of transactions for performance monitoring.
  // We recommend adjusting this value in production
  tracesSampleRate: 1.0,

  // Capture Replay for 10% of all sessions,
  // plus for 100% of sessions with an error
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
});