# [get]
# Gets the index page
exports.index = (req, res) ->
  res.render 'index', title: 'In4mahcy'# CoffeeScript

# [push]
# Save a relationship
exports.relationship = (req, res) ->
  body = req.body
  db = req.db
  db.createObject { name: body.Obj, access_count: 0 }, (err, obj) ->
    if err
      console.log err
      return
    db.createObject { name: body.Sub, access_count: 0 }, (err, sub) ->
      if err
        console.log err
        return
      db.createRelation obj, sub, body.Rel, (err, rel) ->
        if err
          console.log err
          return
        res.send 'saved object #{obj} -> #{rel} #{sub}'

# [push]
# Save a relationship
exports.relationships = (req, res) ->
  body = req.body
  db = req.db
  db.getAllObjects (err, results) ->
    res.send results

# [get]
# Clears the database
exports.clearDB = (req, res) ->
  body = req.body
  db = req.db
  db.clear()
  res.send 'Cleared database.'
