###
Declare the global $App object (the initial $ indicates a global
variable). We need it to dynamically navigate between routes etc.
###
window.$App = $App = {}

###
***************************************************************************
* MODELS
***************************************************************************
###

###
SessionModel is not the typical Model as one does not want to store
the password on the client side. So this is just a simple class to
hold the user`s name and id and to create a new instance by providing
the credentials.
###
class SessionModel

  @authenticate: (username, password, done, fail) ->

    ###
    Instead of interacting with the RestIP plugin, we have to call our
    mothership to login as the RestIP plugin does not allow
    unauthorized endpoints as of now.
    ###
    xhr = $.ajax
        url: "#{PLUGIN_URL}login"
        dataType: 'json'
        data: { username: username, password: password }
        type: 'POST'

    ###
    Call the fail callback, if there is one.
    ###
    xhr.fail fail if fail

    ###
    Create a new SessionModel off the response and call the done
    callback, if there is one.
    ###
    xhr.done (msg) ->
      session = new SessionModel msg
      done(session) if done

    return

  constructor: (creds) ->
    {@id, @name} = creds


  ###
  Just for convenience. In Stud.IP unauthorized users have an empty
  name and "nobody" as their id.
  ###
  authenticated: () ->
    @id isnt "nobody"

###
As the webpage contains the initial USER data (id and name),
pre-populate the global $Session (the initial $ indicates a global
variable) with these. This way we spare us an initial AJAX call.
###
$Session = new SessionModel USER

###
Simple wrapper around the RestipPlugin endpoint '/api/courses'.
Needs a custom response parser, as it is namespaced like this:
{courses: [{<1st course>}, {<2nd course>}, ...]}
###
window.Courses = Backbone.Collection.extend
  url: ->
    "#{API_URL}api/courses"

  parse: (response) ->
    response?.courses

###
***************************************************************************
* VIEWS
***************************************************************************
###


###
We use Mustache as template engine. This function makes it a lot
easier to get a pre-compiled Mustache template.
###
compileTemplate = (name) ->
  Mustache.compile $("#tw-template-#{name}").html()


###
The HomeView just renders the "home" template.
###
window.HomeView = Backbone.View.extend
  template: compileTemplate("home")

  render: (eventName) ->
    @$el.html @template
    @

###
The LoginView renders its template and listens to
###
window.LoginView = Backbone.View.extend
  template: compileTemplate("login")

  render: (eventName) ->
    $(@el).html @template({})
    @

  events:
    "click input[type=button]": "attemptLogin"
    "submit #loginForm":        "attemptLogin"

  attemptLogin: () ->
    username = @$el.find("input[name=username]").val()
    password = @$el.find("input[name=password]").val()
    done = (result) ->
      $Session = result
      $App.navigate "#home", trigger: true

    # TODO
    fail = (jqXHR, textStatus) -> console.log "fail", arguments

    $.mobile.showPageLoadingMsg()
    SessionModel.authenticate username, password, done, fail

    false
###

###
window.MyCoursesView = Backbone.View.extend
  template: compileTemplate("my-courses")

  initialize: () ->
    @collection.on 'add',   @addOne, @
    @collection.on 'reset', @addAll, @
    return

  $content: (selector = "")->
    @$ "[data-role=content] #{selector}"

  addOne: (course, collection) ->
    item = new MyCoursesItemView model: course
    @$content("ul").append item.render().el
    return

  addAll: (collection) ->
    _.each collection.models, ((course) -> @addOne course), @
    @$content("ul").listview()
    return

  render: (eventName) ->
    @$el.html @template courses: @collection.toJSON()
    @

#  onReset: (collection) ->
#    template = @template
#      courses: @collection.toJSON()
#
#    @$el.page("destroy")
#    @render()
#    @$el.page()
#    @$("ul").listview()

###
Each item in the list of my courses has an own view. This way it is
lot easier to add it to the list of courses and to offer additional
actions for each one.
###
window.MyCoursesItemView = Backbone.View.extend

  ###
  Each item is a <li/>.
  ###
  tagName: "li"

  ###
  Just as an example…
  ###
  events:
    "swipe": ()-> alert JSON.stringify @model

  template: compileTemplate("my-courses-item")

  ###
  Render the template filled with the data of the model.
  ###
  render: ->
    @$el.html @template @model.toJSON()
    @





###########################################################################
requireSession = () ->
  (callback) ->
    ->
      if $Session.authenticated()
        callback.apply(this, arguments)
      else
        @navigate "login", trigger: true

AppRouter = Backbone.Router.extend

  initialize: () ->
    @firstPage = true

  routes:
    "":            "home"
    "home":        "home"
    "login":      "login"
    "my-courses": "myCourses"

  home:
    requireSession() \
    ->
      @changePage new HomeView()

  myCourses:
    requireSession() \
    ->
      courses = new Courses()
      @changePage new MyCoursesView(collection: courses)
      courses.fetch()

  login:
    () ->
      @changePage new LoginView()


  changePage: (page) ->
    $(page.el).attr('data-role', 'page')
    page.render()
    $('body').append $ page.el
    transition = $.mobile.defaultPageTransition

    if @firstPage
      transition = 'none'
      @firstPage = false

    $.mobile.changePage $ page.el,
      changeHash: false
      transition: transition

#
#
#


$(document).ready () ->
  $App = new AppRouter()
  Backbone.history.start()
