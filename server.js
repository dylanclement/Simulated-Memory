require('coffee-script')
var app = module.exports = require('./src/app.coffee')
if (require.main === module) app.run()
