'use strict'

angular.module 'scomp'
.service 'nmapDataApi', ($http) ->
  typeahead: (val) ->

    $http.get '/proxy', 
      params:
        uri: 'http://ac.map.naver.com/ac?st=01&r_lt=01&r_format=json&t_koreng=1&q_enc=UTF-8&r_enc=UTF-8&r_unicode=0&r_escape=1&frm=pcweb&q=' + encodeURIComponent(val)
        # uri: 'http://map.naver.com/search2/local.nhn?sm=hty&searchCoord=127.1053945%3B37.360644&isFirstSearch=true&menu=route&mpx=02135550%3A37.360644%2C127.1053945%3AZ12%3A0.0106543%2C0.0032185&query=' + encodeURIComponent(val)
    .then (response) ->
      results = []
      for item in response.data.items
        for each in item
          results.push each
      results


  search: (name) ->

    $http.get '/proxy', 
      params:
        uri: 'http://map.naver.com/search2/local.nhn?sm=hty&searchCoord=127.1053945%3B37.360644&isFirstSearch=true&menu=route&mpx=02135550%3A37.360644%2C127.1053945%3AZ12%3A0.0106543%2C0.0032185&query=' + encodeURIComponent(name)
    .then (response) ->
      console.log response.data
      # results = []

      # for item in response.data.items
      #   for each in item
      #     results.push each
      # results



.controller 'ApiMainController', ($scope, markdown, $http, $q, nmapDataApi) ->
  vm = @

  vm.markdownOptions =
    context: {}
    markdown: markdown

  console.log vm.markdownOptions

  uri = '/proxy'

  vm.typeahead = nmapDataApi.typeahead

  nmapDataApi.search '그린팩토리'


  

  return