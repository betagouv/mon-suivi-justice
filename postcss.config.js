module.exports = {
  syntax: "postcss-scss",
  plugins: [
    require('postcss-mixins'),
    require('postcss-color-mod-function'),
    require('postcss-import'),
    require('postcss-nesting'),
    require('autoprefixer'),
  ],
}
