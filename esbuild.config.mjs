import 'dotenv/config'
import * as esbuild from 'esbuild'

let appEnvironment;
if (process.env.APP === 'mon-suivi-justice-staging') {
  appEnvironment = 'staging';
} else if (process.env.APP === 'mon-suivi-justice-prod') {
  appEnvironment = 'production';
} else if (/^mon-suivi-justice-staging-pr\d+$/.test(process.env.APP)) {
  appEnvironment = 'review';
} else {
  appEnvironment = 'development';
}

let ctx = await esbuild.context({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  loader: { '.svg': 'copy' },
  assetNames: '[name]',
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  define: {
    'SENTRY_DSN': JSON.stringify(process.env.SENTRY_DNS),
    'APP': JSON.stringify(appEnvironment)
  }
  }).catch((e) => {
    console.log(e)
    process.exit(1)

  }
)

await ctx.watch()
