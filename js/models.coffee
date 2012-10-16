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
Session is not the typical Model as one does not want to store the
password on the client side. So this is just a simple class to hold
the user`s name and id and to create a new instance by providing the
credentials.
###
class tw.model.Session

  @authenticate: (username, password, done, fail) ->

    ###
    Instead of interacting with the RestIP plugin, we have to call our
    mothership to login as the RestIP plugin does not allow
    unauthorized endpoints as of now.
    ###
    xhr = $.ajax
        url: "#{tw.PLUGIN_URL}login"
        dataType: 'json'
        data: { username: username, password: password }
        type: 'POST'

    ###
    Call the fail callback, if there is one.
    ###
    xhr.fail fail if fail

    ###
    Create a new Session off the response and call the done
    callback, if there is one.
    ###
    xhr.done (msg) ->
      session = new tw.model.Session msg
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
Simple wrapper around the RestipPlugin endpoint '/api/courses'.
Needs a custom response parser, as it is namespaced like this:
{courses: [{<1st course>}, {<2nd course>}, ...]}
###
tw.model.Courses = Backbone.Collection.extend
  url: ->
    "#{tw.API_URL}api/courses"

  parse: (response) ->
    response?.courses
