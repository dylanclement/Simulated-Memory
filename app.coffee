express = require 'express'
http = require 'http'
path = require 'path'
bodyParser = require 'body-parser'
favicon = require 'static-favicon'
logger = require 'morgan'
methodOverride = require 'method-override'
passport = require 'passport'
BasicStrategy = require('passport-http').BasicStrategy
routes = require './server/src/routes'
GraphDb = require './server/src/services/graphdb'
{log} = require './server/src/services/log'
# Connect to DB's
db = new GraphDb process.env.NEO4J_URL || 'http://localhost:7474'

# middleware method to set the database
setDb = (req, res, next) ->
  req.db = db
  next()

env = process.env.NODE_ENV || 'development'
# create express app
app = express()
app.set 'port', process.env.PORT || 3618
app.set 'views', './server/views'
app.set 'view engine', 'jade'
app.use favicon './public/images/favicon.ico'
app.use logger 'dev'
app.use bodyParser()
app.use methodOverride()
passport.use new BasicStrategy (username, password, done) ->
  if username == 'admin' and password == 'aapkop' then return done null, {username}
  return done null, false
passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (user, done) -> done null, user

app.use passport.initialize()
# app.use require('connect-livereload')()
app.use express.static './public'
app.use express.static './build/assets'
app.use require('connect-assets')()

# set up routes
# read http://info.apigee.com/Portals/62317/docs/web%20api.pdf before adding routes
app.get '/', routes.index
app.all '/calculations*',  passport.authenticate 'basic'
app.get '/calculations', routes.calculations
app.get '/objects', setDb, routes.objects
app.get '/relationships', setDb, routes.relationships
app.post '/relationship', setDb, routes.relationship
app.del '/relationship/:obj', setDb, routes.deleteNode
app.del '/relationship/:obj/:rel/:sub', setDb, routes.deleteRelationship

app.get '/clearDB', setDb, routes.clearDB
app.get '/relationships/save', setDb, routes.saveToFile
app.get '/relationships/load', setDb, routes.loadFromFile
app.get '/relationships/load-demo', setDb, routes.loadDemoFromFile

app.post '/graph/cypher', setDb, routes.execCypher
app.get '/graph/edit', setDb, routes.editGraph
app.get '/graphData/arbor', setDb, routes.getGraphDataArbor
app.get '/conclusion/is_a_category', setDb, routes.categories
app.get '/conclusion/relations', setDb, routes.relations
app.get '/conclusion/popular_relationships', setDb, routes.getRelationshipsOrderedByUse
# start listening
app.listen app.get('port'), ->  log.info "server listening on http://localhost:#{app.get 'port'}."
