module.exports = {
    entry: './src/main.js',
    output: {
        filename: '../vendor/assets/javascripts/bundle.js'
    },
    module: {
        loaders: [
            {test: /\.js$/, loader: 'babel-loader'}
        ]
    },
    resolve: {
        extensions: ['', '.js']
    }
};
