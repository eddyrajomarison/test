users = db.users

user = module.exports = {

get: (request, response) ->
  id = request.params.id
  ID = mongo.ObjectId id

  if not id
    return response.json 400, {error: "Missing user id"}

  users.findOne {_id:ID} , (err,user) ->
    if (err)
      console.log "error mongodb"
    else
      console.log "ito lay user #{JSON.stringify user}"

      return response.json 200,  {user:user}


list:(request, response) ->

  users.find {},(err,users) ->
    if (err)
      console.log "error mondo"
    else
      return response.json 200, { message: users }


  #mongoose.connection.close()

update:(req, response) ->
  console.log "*******UPDATING = "+JSON.stringify(req.body.user)
  id = req.body.user.id
  ID = mongo.ObjectId id

  users.update {_id:ID} , {$set: req.body.user.info}, (err, resp)->
    if err
      console.log "error-------"+err
      return response.json 200, { error: "erreur "}

    else
      console.log 'updated  !'+resp
      return response.json 200, { mess: resp }

add:(req, response) ->
  console.log "*************req= "+JSON.stringify(req.body.user)
  newUser = {
    sex: req.body.user.sex
    name: req.body.user.name
    mail: req.body.user.mail
    age: req.body.user.age
    qual: req.body.user.qual
    lang: req.body.user.lang
    tel:req.body.user.tel
  }
  users.insert newUser, (err)->
    if err
      console.log "error-------"+err
      return response.json 200, { error: "erreur d'insertion dans la base"}

    else
      console.log 'user ajouté avec succès !'
      return response.json 200, { mess: user }

dell:(req, response) ->
  id = req.query.todell
  ID = mongo.ObjectId id
  users.remove {_id:ID},(err) ->
    if (err)
      console.log "erreur supression"
    else
      return response.json 200, { mess:req.query.todell }




  }