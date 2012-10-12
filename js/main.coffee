###
# Copyright (c) 2012 - <mlunzena@uos.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
###

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
    @$el.html @template()
    @

###
The LoginView renders its template and listens to form submits then
attempting to login the user:
###
window.LoginView = Backbone.View.extend
  template: compileTemplate("login")

  render: (eventName) ->
    $(@el).html @template()
    @

  ###
  listen to submit events and …
  ###
  events:
    "submit #loginForm": "attemptLogin"

  attemptLogin: (event) ->

    ###
    (Make sure to prevent the default action of the form.)
    ###
    event.preventDefault()

    ###
    get the user´s input,
    ###
    username = @$el.find("input[name=username]").val()
    password = @$el.find("input[name=password]").val()

    ###
    define the callbacks,
    ###
    done = (result) ->
      $Session = result
      $App.navigate "#home", trigger: true

    # TODO
    fail = (jqXHR, textStatus) -> console.log "fail", arguments

    $.mobile.showPageLoadingMsg()

    ###
    and authenticate the user.
    ###
    SessionModel.authenticate username, password, done, fail


###

The MyCoursesView is the most complicated of the views. Its
responsibilities are:

  * to render an empty list <ul/>
  * listen to its collection
  * if an item is added to the collection,
    add a list item to the list
  * if multiple items are added to the collection
    (e.g. after a fetch or reset),
    add every single item to the list.

###
window.MyCoursesView = Backbone.View.extend
  template: compileTemplate("my-courses")

  ###
  Listen to the events of the collection.
  ###
  initialize: () ->
    @collection.on 'add',   @addOne, @
    @collection.on 'reset', @addAll, @
    return

  ###
  Adding a single item consists of creating a view for that item and
  of appending the rendered view to the <ul/> element and then refresh
  the listview.
  ###
  addOne: (course, collection) ->
    item = new MyCoursesItemView model: course
    @$("ul").append(item.render().el).listview('refresh')
    return

  ###
  Adding a collection of items by adding every single one with #addOne.
  ###
  addAll: (collection) ->
    _.each collection.models, ((course) -> @addOne course), @
    return

  render: () ->
    @$el.html @template()
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
  Just as an example, a listener for dblclick…
  ###
  events:
    "dblclick": ()-> alert JSON.stringify @model

  template: compileTemplate("my-courses-item")

  ###
  Render the template filled with the data of the model.
  ###
  render: ->
    @$el.html @template @model.toJSON()
    @

###
***************************************************************************
* ROUTING
***************************************************************************
###


###
A function combinator that makes ensures that the callback is only
valid for authorised users. Otherwise `redirect` to the #login page.
###
requireSession = () ->
  (callback) ->
    ->
      if $Session.authenticated()
        callback.apply(this, arguments)
      else
        @navigate "login", trigger: true

###
The singleton AppRouter containing the handlers for all the routes.
###
AppRouter = Backbone.Router.extend

  ###
  @firstPage is used to prevent sliding in the first page.
  ###
  initialize: () ->
    @firstPage = true

  routes:
    "":           "home"
    "home":       "home"
    "login":      "login"
    "my-courses": "myCourses"
    "course/:id": "course"

  ###
  Authorised route changing page to a HomeView.
  ###
  home:
    requireSession() \
    ->
      @changePage new HomeView()

  ###
  Authorised route changing page to a MyCoursesView.

  It instantiates a course collection, changes the page to the
  MyCoursesView (parameterized with that collection) and fetches the
  collection from the server. (In the process the view gets notified
  and renders itself.)
  ###
  myCourses:
    requireSession() \
    ->
      courses = new Courses()
      @changePage new MyCoursesView(collection: courses)
      courses.fetch()

  ###
  Just a dummy, authorised route handler. To be continued …
  ###
  course:
    requireSession() \
    (id) ->
      alert "Show course: '#{id}'"

  ###
  Authorised route changing page to a HomeView.
  ###
  login:
    () ->
      @changePage new LoginView()

  ###
  Internal function to be used by the route handlers.

  `page` is a Backbone.View which is added as a jQuery mobile page to
  the pageContainer. Eventually, after all the setup mojo and
  everything is in place, the `jQuery mobile way`(TM) of changing
  pages is invoked.
  ###
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


###
***************************************************************************
* BOOTSTRAP
***************************************************************************
###

###
Initialize the router and start Backbone hash listening magic
###
$(document).ready () ->
  $App = new AppRouter()
  Backbone.history.start()
