const path = require('path');
const WebpackAssetsManifest = require('webpack-assets-manifest');
const CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');

const { NODE_ENV } = process.env;
const isProd = NODE_ENV === 'production';

module.exports = {
  mode: isProd ? 'production' : 'development',
  devtool: isProd ? false : 'source-map',
  entry: {
    application: path.resolve(__dirname, 'front', 'index.js')
  },
  output: {
    path: path.resolve(__dirname, 'public', 'packs'),
    publicPath: isProd ? '/packs/' : '//localhost:8080/packs/',
    filename: isProd ? '[name]-[hash].js' : '[name].js'
  },
  resolve: {
    extensions: ['.tsx', '.ts', '.jsx', '.js']
  },
  module: {
    rules: [
      {
        test: /\.(tsx?|js)$/,
        use: 'babel-loader',
        include: path.resolve(__dirname, 'front')
      },
      {
        test: /\.(svg|png|gif)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: '[name]-[hash].[ext]'
            }
          }
        ],
        include: path.join(__dirname, 'front')
      }
    ]
  },
  plugins: [
    new WebpackAssetsManifest({
      publicPath: true,
      output: 'manifest.json',
      writeToDisk: true
    }),
    new CaseSensitivePathsPlugin()
  ],
  devServer: {
    contentBase: path.resolve(__dirname, 'public'),
    publicPath: '/packs/',
    port: 8080,
    disableHostCheck: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};
