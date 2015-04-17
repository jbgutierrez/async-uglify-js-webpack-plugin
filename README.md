# Async uglify-js plugin for webpack

A webpack plugin to asynchronously uglify webpack bundles

## Install

```
$ npm install --save async-uglify-js-webpack-plugin
```

## Usage

``` javascript
var AsyncUglifyJs = require("async-uglify-js-webpack-plugin");
module.exports = {
  plugins: [
    new AsyncUglifyJs({
      delay: 5000,
      minifyOptions: {},
      logger: false,
      done: function(path, originalContents) { }
    });
  ]
}
```

Use `minifyOptions` to further customize uglifying.

See [`UglifyJS.minify`](https://www.npmjs.com/package/uglify-js#the-simple-way) docs.

## License

MIT © [Javier Blanco](http://jbgutierrez.info)
