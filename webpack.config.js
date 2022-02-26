const path = require('path');
const WebpackAssetsManifest = require('webpack-assets-manifest');
const CaseSensitivePathsPlugin = require('case-sensitive-paths-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const { NODE_ENV } = process.env;
const isProd = NODE_ENV === 'production';

module.exports = {
  mode: isProd ? 'production' : 'development',
  devtool: isProd ? false : 'source-map',
  entry: {
    application: [
      '@fortawesome/fontawesome-free/js/all.js',
      path.resolve(__dirname, 'front', 'index.scss'),
      path.resolve(__dirname, 'front', 'index.ts')
    ]
  },
  output: {
    path: path.resolve(__dirname, 'public', 'packs'),
    publicPath: isProd ? '/packs/' : '//localhost:8080/packs/',
    filename: isProd ? '[name]-[contenthash].js' : '[name].js'
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
        test: /\.(s?css)$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'sass-loader'
        ]
      },
      {
        test: /\.(svg|png|gif|eot|ttf|woff2?)$/,
        use: [
          {
            loader: 'file-loader',
            options: {
              name: isProd ? '[name]-[contenthash].[ext]' : '[name].[ext]',
            }
          }
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: isProd ? '[name]-[contenthash].css' : '[name].css',
    }),
    new WebpackAssetsManifest({
      publicPath: true,
      output: 'manifest.json',
      writeToDisk: true
    }),
    new CaseSensitivePathsPlugin()
  ],
  devServer: {
    port: 8080,
    allowedHosts: 'all',
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  }
};
