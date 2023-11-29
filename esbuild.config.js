const esbuild = require('esbuild');

esbuild.build({
    entryPoints: ['app/javascript/*.js'],
    bundle: true,
    sourcemap: true,
    plugins: [
        sentryEsbuildPlugin({
          org: "betagouv",
          project: "mon-suivi-justice",
          authToken: process.env.SENTRY_AUTH_TOKEN,
        }),
      ],
    loader: {
        '.svg': 'copy'
    },
    assetNames: '[name]',
    absWorkingDir: path.join(process.cwd(), "app/javascript"),
    outdir: 'app/assets/builds',
    publicPath: '/assets',
    define: {
        'SENTRY_DSN': JSON.stringify(process.env.SENTRY_DNS),
        'APP': JSON.stringify(appEnvironment)
      }
}).catch(() => process.exit(1));
