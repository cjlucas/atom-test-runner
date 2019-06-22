const CopyPlugin = require('copy-webpack-plugin');

module.exports = {
  target: 'node',
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            cwd: './elm'
          }
        }
      },
      {
        test: /\.node$/,
        use: 'node-loader'
      }
    ]
  },
  entry: () => './lib/atom-test-runner.js',
  externals: [
    'atom',
    './build/Release/tree_sitter_runtime_binding',
    './build/Release/tree_sitter_elm_binding',
    './build/Debug/tree_sitter_runtime_binding',
    './build/Debug/tree_sitter_elm_binding'
  ],
  resolve: {
    extensions: ['.js', '.node']
  },
  output: {
    library: '',
    libraryTarget: 'commonjs'
  },
  plugins: [
    new CopyPlugin([
      {
        from: 'node_modules/tree-sitter/build/Release/tree_sitter_runtime_binding.node',
        to: 'build/Release'
      },
      {
        from: 'node_modules/tree-sitter-elm/build/Release/tree_sitter_elm_binding.node',
        to: 'build/Release'
      },
    ])
  ]
};
