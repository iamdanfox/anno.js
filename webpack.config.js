var webpack = require('webpack');

module.exports = {
  entry: './src/anno.litcoffee',
  output: {
    filename: './anno.js',
    libraryTarget: 'umd',
  },
  externals: {
    'jquery': 'jQuery',
  },
  module: {
    loaders: [
      { test: /\.litcoffee$/, loaders: ['coffee-loader?literate'] }
    ]
  }
};
