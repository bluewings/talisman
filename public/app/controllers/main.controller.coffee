'use strict'

angular.module 'scomp'
.filter 'duration', ->
  (duration) ->
    display = []
    totalMinutes = Math.floor(duration / 60)
    hours = Math.floor(totalMinutes / 60)
    minutes = totalMinutes % 60
    if hours
      display.push hours + '시간'
    display.push minutes + '분'
    display.join ' '

.filter 'roadSummary', ($filter) ->
  (roadSummary) ->
    results = []
    for road in roadSummary
      results.push road.road_name + ' (' + $filter('number')(road.distance / 1000, 2) + 'km)'
    results.join ' → '

.service 'nmapDataApi', ($http) ->

  getPaths = (steps, paths = []) ->
    for step in steps
      if step.path
        points = step.path.split /\s+/
        for point in points
          chunk = point.split ','
          if chunk.length is 2
            latlng = nhn.mapcore.CoordConverter.fromInnerToLatLng(new nhn.api.map.Inner(chunk[0], chunk[1]))
            paths.push [latlng.x, latlng.y]
      else if step.steps
        getPaths step.steps, paths
    paths

  typeahead: (val) ->
    uri = ['http://ac.map.naver.com/ac']
    uri.push '?st=01'
    uri.push '&r_lt=01'
    uri.push '&r_format=json'
    uri.push '&t_koreng=1'
    uri.push '&q_enc=UTF-8'
    uri.push '&r_enc=UTF-8'
    uri.push '&r_unicode=0'
    uri.push '&r_escape=1'
    uri.push '&frm=pcweb'
    uri.push '&q=' + encodeURIComponent(val)

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      results = []
      for item in response.data.items
        for each in item
          results.push each
      results

  search: (name) ->
    uri = ['http://map.naver.com/search2/local.nhn']
    uri.push '?sm=hty'
    uri.push '&searchCoord=127.1053945%3B37.360644'
    uri.push '&isFirstSearch=true'
    uri.push '&menu=route'
    uri.push '&mpx=02135550%3A37.360644%2C127.1053945%3AZ12%3A0.0106543%2C0.0032185'
    uri.push '&query=' + encodeURIComponent(name)

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      response.data.result.site.list

  findCarRoute: (from, to) ->
    uri = ['http://map.naver.com/spirra/findCarRoute.nhn']
    uri.push '?route=route3'
    uri.push '&output=json'
    uri.push '&result=web3'
    uri.push '&coord_type=naver'
    uri.push '&search=2'
    uri.push '&car=0'
    uri.push '&mileage=12.4'
    uri.push "&start=#{from.x},#{from.y}," + encodeURIComponent(from.name.replace(/\s+/g, '+'))
    uri.push "&destination=#{to.x},#{to.y}," + encodeURIComponent(to.name.replace(/\s+/g, '+'))
    uri.push '&via='

    $http.get '/proxy', 
      params:
        uri: uri.join ''
    .then (response) ->
      routes = response.data.routes
      for route in routes
        route.paths = getPaths route.legs[0].steps
      routes



.controller 'ApiMainController', ($scope, markdown, $timeout, $element, $http, $q, nmapDataApi) ->
  vm = @

  vm.findCarRoute = ->
    if vm.input.from.selected and vm.input.to.selected
      nmapDataApi.findCarRoute vm.input.from.selected, vm.input.to.selected
      .then (routes) ->
        vm.routes = routes
        console.log routes
        return
    return

  vm.selectRoute = (route) ->
    vm.route = route
    console.log route
    return

  vm.input = 
    from:
      text: ''
      selected: null
    to:
      text: ''
      selected: null
    query: nmapDataApi.typeahead
    edit: (type, edit = true) ->
      self = @
      self[type]._edit = edit
      if self[type].selected and self[type]._edit
        self[type].text = self[type].selected.name
      else
        self[type].text = ''
      return
    onselect: (type, item) ->
      self = @
      nmapDataApi.search item
      .then (results) ->
        self[type].selected = results[0]
        vm.input[type].text = ''
        delete vm.input[type]._edit
        if type is 'from' and !vm.input.to.selected
          vm.input.edit('to')
        return
      return

  $scope.$watch 'vm.input.from._edit', (edit) ->
    if edit
      $timeout ->
        $element.find('.form-from input').select()
        return
    return

  $scope.$watch 'vm.input.to._edit', (edit) ->
    if edit
      $timeout ->
        $element.find('.form-to input').select()
        return
    return

  vm.input.onselect 'from', '일월초등학교'
  vm.input.onselect 'to', '그린팩토리'

  $timeout ->
    vm.findCarRoute()
  , 1000

  return