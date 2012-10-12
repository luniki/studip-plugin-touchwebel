
window.app = app = {}

###########################################################################

class SessionModel

  @authenticate: (username, password, done, fail) ->
    xhr = $.ajax
        url: "#{PLUGIN_URL}login"
        dataType: 'json'
        data: { username: username, password: password }
        type: 'POST'

    xhr.fail fail if fail

    xhr.done (msg) ->
      session = new SessionModel msg
      done(session) if done

  constructor: (creds) ->
    {@id, @name} = creds

  authenticated: () ->
    @id isnt "nobody"

$Session = new SessionModel USER

###########################################################################

class Courses extends Backbone.Collection
  url: ->
    "#{API_URL}api/courses"

  parse: (response) ->
    response?.courses


window.Courses = Courses
###########################################################################

compileTemplate = (name) ->
  Mustache.compile $("#tw-template-#{name}").html()

class window.HomeView extends Backbone.View
  template: compileTemplate("home")

  render: (eventName) ->
    $(@el).html @template({})
    @


class window.MyCoursesView extends Backbone.View
  template: compileTemplate("my-courses")

  initialize: () ->
    #@collection.on 'add',   @addOne, @
    @collection.on 'reset', @onReset, @
    @collection.on 'all',   (event) -> console.log "MCV: ", event, arguments

  addOne: (course, collection) ->
    #console.log "addOne", arguments
    @$el.find("[data-role=content]").append "<p>#{course.get('title')}</p>"
    #view = new TodoView({model: todo});
    #  this.$("#todo-list").append(view.render().el);

  onReset: (collection) ->
    @collection = collection

    template = @template
      courses: @collection.toJSON()

    @$el.page("destroy")
    @render()
    @$el.page()
    @$("ul").listview()


  render: (eventName) ->
    @$el.html @template
      courses: @collection.toJSON()
    @


class window.LoginView extends Backbone.View
  template: compileTemplate("login")

  render: (eventName) ->
    $(@el).html @template({})
    @

  events:
    "submit #loginForm": "attemptLogin"
    "click input[type=button]": "attemptLogin"

  attemptLogin: () =>
    username = @$el.find("input[name=username]").val()
    password = @$el.find("input[name=password]").val()
    done = (result) ->
      $Session = result
      app.navigate "#home", trigger: true

    # TODO
    fail = (jqXHR, textStatus) -> console.log "fail", arguments

    $.mobile.showPageLoadingMsg()
    SessionModel.authenticate username, password, done, fail
    false



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
  app = new AppRouter()
  Backbone.history.start()
