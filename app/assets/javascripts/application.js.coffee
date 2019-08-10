#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require turbolinks
#= require_tree .

ready = ->
    $(".bs-tooltip").tooltip
        placement: "bottom"
        container: "body"
        trigger: "hover"
    .click ->
        $(this).tooltip 'hide'

# HAX because Turbolinks
$(document).ready ready
$(document).on "turbolinks:load", ready
