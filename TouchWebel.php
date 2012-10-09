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

class TouchWebel extends StudipPlugin
{
    function __construct()
    {
        parent::__construct();

        # do something
    }

    function show_action()
    {
        echo $this->getTemplateFactory()->render('index',
                                                 $this->getTemplateArgs());
    }


    private function getTemplateFactory()
    {
        require_once 'vendor/flexi/lib/mustache_template.php';
        $factory = new Flexi_TemplateFactory(dirname(__FILE__) . '/templates');
        $factory->add_handler('mustache', 'Flexi_MustacheTemplate');
        return $factory;
    }

    private function getTemplateArgs()
    {
        return array('plugin_url' => $this->getPluginUrl(),
                     'userid'     => $GLOBALS['user']->id,
                     'username'   => $GLOBALS['user']->username);
    }
}
