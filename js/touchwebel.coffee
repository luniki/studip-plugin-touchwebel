class Authenticator
  init: () ->
    $(document).bind "showLogin", @onShowLogin
  onShowLogin: (o, e) =>
    console.log "onShowLogin", e
    $.mobile.changePage "#login"
    e.preventDefault();

auth = new Authenticator
auth.init()

#$(document).bind "mobileinit", () ->
#  console.log "mobileinit"
#  console.log $("#login")

#$ ()->
#  $("#login").data("role", "page")
#  console.log $("#login")

$(document).bind "mobileinit", () ->
  $.mobile.autoInitializePage = false

$(document).ready () ->
  console.log "ready"

  # variante 1
  unless document.location.hash == "#login"
    document.location.hash = "#login"

  # variante 2
  #$("#login").attr("data-role", "page")

  $.mobile.initializePage()
  true

#$(document).delegate "#login", "pageshow", () ->
#  console.log document.location.hash
#  $.mobile.loading("hide")


#$(document).bind 'mobileinit', (e) ->
#  console.log e
#  $.mobile.changePage "#login"
#  e.preventDefault()
#  false

  #if (!USERNAME.length)
  #  $(document).trigger "showLogin", e
