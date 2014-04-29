{log} = require '../services/log'
express = require 'express'

calculation = express.Router()

# [get /calculation/categories]
# gets a grouped collection
calculation.get '/categories', (req, res, next) ->
  query = 'START n=node(*)
    MATCH n-[:is_a]->m
    RETURN m.name as name, count(m) as num'
  req.db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

# [get /calculation/relations]
# gets a grouped collection
calculation.get '/relations', (req, res, next) ->
  query = 'START n=node(*)
     MATCH p=n-->o<--m
     RETURN n.name, m.name, count(p) as countp
     ORDER BY countp DESC'
  req.db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

# [get /calculation/popular_relationships]
# gets relationships ordered by use
calculation.get '/popular_relationships', (req, res, next) ->
  query = 'START n=node(*) MATCH (n)-[r]->() RETURN type(r) as name, count(*) as num_uses'
  req.db.cypher query, {}, (err, results) ->
    if err then return next err
    res.send results

module.exports = calculation
