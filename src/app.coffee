express = require 'express'
  , routes = require './routes'
  , http = require 'http'
  , path = require 'path'
  , winston = require 'winston'
  , graphdb = require './services/graphdb.coffee'

# create a date  yyyy-mm-dd method
Date.prototype.yyyymmdd = ->
   yyyy = this.getFullYear().toString()
   mm = (this.getMonth()+1).toString() # getMonth() is zero-based
   dd  = this.getDate().toString()
   return "#{yyyy}-#{(if mm.length > 1 then mm else '0' + mm[0])}-#{(if dd.length > 1 then dd else '0' + dd[0])}" # padding

# Set up logging
logger = new winston.Logger
  transports: [
    new (winston.transports.Console)(),
    new (winston.transports.File) filename: "application-#{new Date().yyyymmdd()}.log"
  ]
logger.on 'error', (err) -> console.log "Unhandled error occured, #{err}"

# Connect to DB's
db = new graphdb 'http://localhost:7474', logger

# middleware method to set the database
setDb = (req, res, next) -> 
  req.db = db;
  next()

# create express app
app = express()
app.configure ->
  app.set 'port', process.env.PORT || 3618
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use require('less-middleware')(src: "#{__dirname}/public" )
  app.use express.static(path.join __dirname, 'public')
app.configure 'development', ->  
  app.use express.errorHandler( dumpExceptions: true, showStack: true)

# set up routes
app.get '/', routes.index
app.get '/relationships', setDb, routes.relationships
app.post '/relationship', setDb, routes.relationship
app.get '/clearDB', setDb, routes.clearDB
app.get '/conclusion/is_a_category', setDb, routes.isCategory

# start listening
app.listen app.get('port'), ->
  logger.info "server listening on http://localhost:#{app.get 'port'}."    