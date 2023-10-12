module.exports = {
  syntax: "postcss-scss",
  plugins: {
    "postcss-mixins": {},
    "postcss-color-mod-function": {},
    "postcss-import": {},
    "postcss-nesting": {},
    autoprefixer: {},
    "postcss-replace": {
      pattern: /(?:\.\.\/){0,2}icons\/\w+\//,
      data: { replaceAll: '' }
    },
  },
}
