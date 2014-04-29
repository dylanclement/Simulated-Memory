express = require 'express'
async = require 'async'
{log} = require '../services/log'
fs = require 'fs'

data = express.Router()

# [post /data/cypher]
# Post a cypher query
data.post '/cypher', (req, res, next) ->
  query = req.body.query
  req.db.cypher query, {}, (err, results) ->
    if err then next err
    data = JSON.stringify results
    log.info {data, query}, 'Results from query'
    res.json "#{data}"

# [get /data/arbor]
# Gets data in a format that arbor.js can use to display in a graph
data.get '/arbor', (req, res, next) ->
  db = req.db
  query = 'START n=node(*)
    MATCH n-[p]->m
    RETURN n.name as obj, TYPE(p) as rel, m.name as sub'
  db.cypher query, {}, (err, results) ->
    if err then return next err
    data = nodes: {}, edges: {}

    for result in results
      # Create the nodes
      data.nodes[result.obj] ?= {}
      data.nodes[result.sub] ?= {}

      # create the edges
      data.edges[result.obj] ?= {}
      data.edges[result.obj][result.sub] =
        # set the name and weight for the edges
        weight: 0.5
        name: result.rel.replace '_', ' '

    res.json data


# [get /data/save]
# Save relationships to a file
data.get '/save', (req, res, next) ->
  req.db.getAllRelationships (err, results) ->
    if err then return next err
    resJSON = JSON.stringify(results)
    fs.writeFile "data/relations.json", resJSON, (err) ->
      if err then return next err
      res.send resJSON

fileLoad = (fileName, req, res, next) ->
  fs.readFile fileName, 'utf8', (err, resJSON) ->
    if err then return next err
    results = JSON.parse resJSON
    res.send results
    # build an array of methods to run and run them in series since we can't lock and don't want to add duplicate items
    cbs = []
    for ors in results
      do (ors) ->
        cbs.push (callback) ->
          req.db.create ors.obj, ors.rel, ors.sub, callback
    async.series cbs

# [get /data/load]
# Load relationships from a file
data.get '/load', (req, res, next) ->
  fileLoad 'data/relations.json', req, res, next

# [get /data/load-demo]
data.get '/load-demo', (req, res, next) ->
  fileLoad 'data/demo-relations.json', req, res, next

module.exports = data
