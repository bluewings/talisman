'use strict'

angular.module 'scomp'
.controller 'ApiMainController', ($scope, markdown, $http, $q) ->
  vm = @

  vm.markdownOptions =
    context: {}
    markdown: markdown

  console.log vm.markdownOptions

  uri = '/proxy'

  vm.getLocation = (val) ->
    deferred = $q.defer()


    $http.get '/proxy', {
      params: {
        uri: 'http://ac.map.naver.com/ac?st=01&r_lt=01&r_format=json&t_koreng=1&q_enc=UTF-8&r_enc=UTF-8&r_unicode=0&r_escape=1&frm=pcweb&q=' + encodeURIComponent(val)
      }
    }
    .then (response) ->
      console.log '>>>>>>>>>>>'
      results = []

      for item in response.data.items

        for each in item
          results.push each

      results



      # response.data






    # return


    # deferred.promise


  $http.get '/proxy', {
    params: {
      uri: 'http://ac.map.naver.com/ac?st=01&r_lt=01&r_format=json&t_koreng=1&q_enc=UTF-8&r_enc=UTF-8&r_unicode=0&r_escape=1&frm=pcweb&q=' + encodeURIComponent('일월초등학교')
    }
  }
  .then (response) ->
    console.log '>>>>>>>>>>>'

    console.log response.data


  

  return