window.GraphCtrl = ['$scope', '$http', ($scope, $http) ->
    @sys = arbor.ParticleSystem 1000, 800, 0.5  # create the system with sensible repulsion/stiffness/friction
    @sys.renderer = new window.GraphRenderer "#graphCanvas" # our newly created renderer will have its .init() method called shortly by sys...
    $scope.inputText = 'a dog is an animal'
    # call the rest api endpoint to get the data
    $http.get('/graphData/arbor').success (data) =>
      # get the nodes from the server
      $scope.data = data
      @sys.graft data

    $scope.addRel = =>
      Obj = $scope.object
      Rel = $scope.relationship
      Sub = $scope.subject

      # add the relationship to the graph and to the db
      $http.post('/relationship', { Obj, Rel, Sub }).success (success) =>
        @sys.addEdge Obj, Sub, { name: Rel }

    $scope.parseText = ->
      text = $scope.inputText
      # This will do a match for the following:
      #  a dog is a animal
      #  the man is an gigolow
      match = text.match /(?:a|the)\s+(\w+)\s+is\s(?:a|an)\s+(\w+)/i
      object = match?[1]
      subject = match?[2]
      if object && subject
        $scope.object = object.toLowerCase()
        $scope.relationship = 'is_a'
        $scope.subject = subject.toLowerCase()
]
