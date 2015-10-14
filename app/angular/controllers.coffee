"use strict"

###
  Controllers
###

AppCtrl = ($scope, ezfb, $window, $location) ->

  updateLoginStatus = (more) ->
    ezfb.getLoginStatus (res) ->
      $scope.loginStatus = res
      (more or angular.noop)()
      return
    return

  ###*
  # Update api('/me') result
  ###

  updateApiMe = ->
    ezfb.api '/me', (res) ->
      $scope.apiMe = res
      return
    return

  updateLoginStatus updateApiMe

  $scope.login = ->

    ###*
    # Calling FB.login with required permissions specified
    # https://developers.facebook.com/docs/reference/javascript/FB.login/v2.0
    ###

    ezfb.login ((res) ->

      ###*
      # no manual $scope.$apply, I got that handled
      ###

      if res.authResponse
        updateLoginStatus updateApiMe
      return
    ), scope: 'email,user_likes'
    return

  $scope.logout = ->

    ###*
    # Calling FB.logout
    # https://developers.facebook.com/docs/reference/javascript/FB.logout
    ###

    ezfb.logout ->
      updateLoginStatus updateApiMe
      return
    return

  $scope.share = ->
    ezfb.ui {
      method: 'feed'
      name: 'angular-easyfb API demo'
      picture: 'http://plnkr.co/img/plunker.png'
      link: 'http://plnkr.co/edit/qclqht?p=preview'
      description: 'angular-easyfb is an AngularJS module wrapping Facebook SDK.' + ' Facebook integration in AngularJS made easy!' + ' Please try it and feel free to give feedbacks.'
    }, (res) ->
      # res: FB.ui response
      return
    return

  ###*
  # For generating better looking JSON results
  ###

  autoToJSON = [
    'loginStatus'
    'apiMe'
  ]
  angular.forEach autoToJSON, (varName) ->
    $scope.$watch varName, ((val) ->
      $scope[varName + 'JSON'] = JSON.stringify(val, null, 2)
      return
    ), true
    return
  return


AppCtrl.$inject = ["$scope" ,"ezfb", "$window", "$location"]

UsersCtrl = ($scope, User) ->
  User.list {}
  , (data) ->
    $scope.users = data.message

    total = $scope.users.length
    deg = 0
    mas = 0
    dip = 0
    oth = 0
    angular.forEach $scope.users, (data,key)->
      switch data.qual
        when "Degree" then deg  += 1
        when "Masters" then mas  += 1
        when "Diploma" then dip  += 1
        when "Other" then oth  += 1


    loadHighcharts(deg,mas,dip,oth)
  $scope.supr = (toDell)->
    User.dell {todell:toDell},(rep)->
      if rep.error
      else if rep.mess
        User.list {}, (data) ->
          $scope.users = data.message

#---------------------------------------------------------------

  loadHighcharts = (deg,mas,dip,oth) ->


    angular.element('#chart').highcharts ( {
    chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false,
            type: 'pie'
        },
    title: {
            text: ' Qualification Visualization'
    },
    tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
    },
    plotOptions: {
       pie: {
              allowPointSelect: true,
              cursor: 'pointer',
              dataLabels: {
                enabled: true,
                format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                }
              }
            }
        },
    series: [{
          name: "graph",
          colorByPoint: true,
          data: [{
              name: "Degree",
              y: deg
          }, {
              name: "Master",
              y: mas,
              sliced: true,
          },{
              name: "Other",
              y: oth,
              sliced: true,
          }, {
              name: "Diploma",
              y: dip
          }]
        }]
    })




#---------------------------------------------------------------

UsersCtrl.$inject = ["$scope", "User"]

UserDetailCtrl = ($scope, $routeParams,$location, User) ->
  $scope.sex =["mal","femal"]
  $scope.qual =["Degree","Masters", "Diploma","Other" ]
  $scope.new = false
  User.get {userId: $routeParams.userId}
  ,(data) ->
    $scope.user = data.user
  $scope.submit = ()->
    info ={
      name: $scope.user.name
      mail: $scope.user.mail
      age: $scope.user.age
      qual: $scope.user.qual
      lang: $scope.user.lang
      tel: $scope.user.tel

    }

    User.update {user:{ id:$scope.user._id , info: info}}
    , (rep) ->
      if rep.error
        console.log error
      else if rep.mess
        console.log rep.mess
        $location.path('/home')


UserDetailCtrl.$inject = ["$scope", "$routeParams","$location", "User"]

AddUserCtrl = ($scope, User, $location) ->
  $scope.new = true
  $scope.sex =["mal","femal"]
  $scope.qual =["Degree","Masters", "Diploma","Other"]
  $scope.submit = ()->
    User.add {user : $scope.user}
    , (rep) ->
      if rep.error
      else if rep.mess

        $location.path('/home')

AddUserCtrl.$inject = ["$scope", "User", "$location"]

SocketCtrl = ($scope, Socket) ->

  Socket.on "pong", (data) ->
    $scope.response = data.data

  $scope.ping = ->
    Socket.emit("ping", {})

SocketCtrl.$inject = ["$scope", "Socket"]