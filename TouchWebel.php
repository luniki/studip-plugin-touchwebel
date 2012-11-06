<?php

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

class TouchWebel extends StudipPlugin implements SystemPlugin
{
    function show_action()
    {
        echo $this->getTemplateFactory()->render('index',
                                                 $this->getTemplateArgs());
    }

    function login_action()
    {
        $username = Request::get("username");
        $password = Request::get("password");

        if (isset($username) && isset($password)) {
            $result = StudipAuthAbstract::CheckAuthentication($username, $password);
        }

        if (!isset($result) || $result['uid'] === false) {
            $this->fail(401, "Login Failed");
            return;
        }

        $id = get_userid($username);
        if (isset($id)) {
            $this->start_session($id);
        }

        echo json_encode(array('id' => $id, 'name' => $username));
    }


    private function getTemplateFactory()
    {
        $factory = new Flexi_TemplateFactory(dirname(__FILE__) . '/templates');
        return $factory;
    }

    private function getTemplateArgs()
    {
        return array('assets_url' => $this->getPluginUrl(),
                     'plugin_url' => $this->pluginURL($this),
                     'api_url'    => $this->pluginURL("RestipPlugin"),
                     'userid'     => $GLOBALS['user']->id,
                     'username'   => $GLOBALS['user']->username);
    }

    private function pluginURL($plugin)
    {
        $url = PluginEngine::getURL($plugin, array(), '');
        return current(explode('?', $url));
    }

    private function fail($code, $reason)
    {
        header(sprintf('HTTP/1.1 %d %s', $code, $reason), TRUE, $code);
    }

    private function start_session($user_id)
    {
        global $perm, $user, $auth, $sess, $forced_language, $_language;


        $user = new Seminar_User();
        $user->start($user_id);

        foreach (array(
                     "uid" => $user_id,
                     "perm" => $user->perms,
                     "uname" => $user->username,
                     "auth_plugin" => $user->auth_plugin,
                     "exp" => time() + 60 * 15,
                     "refresh" => time()
                 ) as $k => $v) {
            $auth->auth[$k] = $v;
        }

        $auth->nobody = false;


        $sess->regenerate_session_id(array('auth', 'forced_language','_language'));
        $sess->freeze();
    }
}
