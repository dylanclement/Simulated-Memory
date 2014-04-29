express = require 'express'
http = require 'http'
path = require 'path'
bodyParser = require 'body-parser'
favicon = require 'static-favicon'
logger = require 'morgan'
methodOverride = require 'method-override'
passport = require 'passport'
BasicStrategy = require('passport-http').BasicStrategy
viewRoutes = require './server/src/routes/view'
relationshipRoutes = require './server/src/routes/relationship'
dataRoutes = require './server/src/routes/data'
calculationRoutes = require './server/src/routes/calculation'
GraphDb = require './server/src/services/graphdb'
{log} = require './server/src/services/log'
# Connect to DB's
db = new GraphDb process.env.NEO4J_URL || 'http://localhost:7474'

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
# Passport methods
passport.use new BasicStrategy (username, password, done) ->
  if username == 'admin' and password == 'aapkop' then return done null, {username}
  return done null, false
passport.serializeUser (user, done) -> done null, user
passport.deserializeUser (user, done) -> done null, user
app.use passport.initialize()

app.use express.static './public'
app.use express.static './build/assets'
app.use require('connect-assets')()

# middleware method to set the database
app.use (req, res, next) ->
  req.db = db
  next()

# set up routes
# read http://info.apigee.com/Portals/62317/docs/web%20api.pdf before adding routes
# View Routes
app.get '/', (req, res) -> res.redirect '/view/home'
app.use '/view', viewRoutes
app.use '/relationship', relationshipRoutes
app.use '/data', dataRoutes
app.use '/calculation', calculationRoutes

# start listening
app.listen app.get('port'), ->  log.info "server listening on http://localhost:#{app.get 'port'}."
