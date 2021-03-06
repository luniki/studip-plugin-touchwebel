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
We use Mustache as template engine. This function makes it a lot
easier to get a pre-compiled Mustache template.
###
compileTemplate = (name) ->
  Mustache.compile $("#tw-template-#{name}").html()


###
The HomeView just renders the "home" template.
###
tw.ui.HomeView = Backbone.View.extend
  template: compileTemplate("home")

  render: (eventName) ->
    @$el.html @template()
    @

###
The LoginView renders its template and listens to form submits then
attempting to login the user:
###
tw.ui.LoginView = Backbone.View.extend
  template: compileTemplate("login")

  render: (eventName) ->
    @$el.html @template()
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
      tw.$Session = result
      tw.$App.navigate "#home", trigger: true

    # TODO
    fail = (jqXHR, textStatus) -> console.log "fail", arguments

    $.mobile.showPageLoadingMsg()

    ###
    and authenticate the user.
    ###
    tw.model.Session.authenticate username, password, done, fail


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
tw.ui.MyCoursesView = Backbone.View.extend
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
    item = new tw.ui.MyCoursesItemView model: course
    ul = @$("ul")
    ul.append(item.render().el)
    ul.listview('refresh') if @el.parentNode
    return

  ###
  Adding a collection of items by adding every single one with #addOne.
  ###
  addAll: (collection) ->
    _.each collection.models, ((course) -> @addOne course), @
    return

  render: () ->
    @$el.html @template()
    @addAll @collection
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
tw.ui.MyCoursesItemView = Backbone.View.extend

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
This view shows the content of a course.
###
tw.ui.CourseView = Backbone.View.extend

  template: compileTemplate("course")

  initialize: ->
    ###
    Listen to changes and re-render
    ###
    @model.on "all", @render, @

  render: ->
    @$el.html @template @model.toJSON()

    ###
    Re-enhance the page, if re-rendering
    ###
    if @el.parentNode
      @$el.page("destroy").page()

    @
