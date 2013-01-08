# [get]
# Gets the index page
exports.index = (req, res) ->
  res.render 'index', title: 'In4mahcy'# CoffeeScript

# [push]
# Save a relationship
exports.relationship = (req, res) ->
  body = req.body
  db = req.db
  db.createObject name: body.Obj, (err, obj) ->
    if err
      console.log err
      return
    db.createObject name: body.Sub, (err, sub) ->
      if err
        console.log err
        return
      db.createRelation obj, sub, body.Rel, (err, rel) ->
        if err
          console.log err
          return
        res.send 'saved object #{obj} -> #{rel} #{sub}'

# [get]
# Clears the database
exports.clearDB = (req, res) ->
  body = req.body
  db = req.db
  db.clear()
