'use strict'

angular.module 'scomp'
.controller 'ApiMainController', ($scope, markdown) ->
  vm = @

  vm.markdownOptions =
    context: {}
    markdown: markdown

  console.log vm.markdownOptions

  return