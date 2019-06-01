module.exports = {
  target: 'node',
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      use: {
        loader: 'elm-webpack-loader',
        options: {
          cwd: './elm'
        }
      }
    }]
  },
  entry: () => './lib/atom-test-runner.js',
  externals: {
    'atom': 'atom'
  },
  output: {
    library: '',
    libraryTarget: 'commonjs'
  }
};
