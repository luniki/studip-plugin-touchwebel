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

require_once 'public/plugins_packages/UOL/RestipPlugin/classes/APIPlugin.php';

class TouchWebelAPI extends StudipPlugin implements APIPlugin
{

    public function describeRoutes()
    {
        return array(
            '/courses/:course_id/wiki'       => _('Wikiseitenindex'),
            '/courses/:course_id/wiki/:page' => _('Wikiseite'),
        );
    }

    public function routes(&$router)
    {
        $conditions = array(
            'course_id' => '[0-9a-f]{32}'
        );

        $router->get('/courses/:course_id/wiki', function ($course_id) use ($router) {
                $router->render(TouchWebelAPI::listWikiPagesForCourse($course_id));
            })
            ->conditions($conditions);

        $router->get('/courses/:course_id/wiki/:page', function ($course_id, $page) use ($router) {
                $page = TouchWebelAPI::getWikiPageForCourse($course_id, $page);
                if (empty($page)) {
                    $router->halt(404, 'Not found.');
                    return;
                }
                $router->render($page);
            })
            ->conditions($conditions);
    }

    static function listWikiPagesForCourse($course_id)
    {
        $query = "SELECT DISTINCT keyword FROM wiki WHERE range_id = ? ORDER BY keyword ASC";
        $stmt = DBManager::get()->prepare($query);
        $stmt->execute(array($course_id));
        return $stmt->fetchAll(PDO::FETCH_COLUMN);
    }

    static function getWikiPageForCourse($course_id, $page)
    {
        $query = "SELECT * FROM wiki WHERE range_id = ? AND keyword = ? ORDER BY version DESC LIMIT 1";
        $stmt = DBManager::get()->prepare($query);
        $stmt->execute(array($course_id, $page));
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
