<? /* prevent direct access */ if (!defined("STUDIP\\ENV")) exit; ?>
<!DOCTYPE html>
<html>

  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Touchwebel template</title>

    <link rel="stylesheet" href="<?= htmlReady($assets_url) ?>/css/jquery.mobile-1.2.0.css" />
    <link rel="stylesheet" href="<?= htmlReady($assets_url) ?>/css/touchwebel.css" />

    <?= $this->render_partial("_include_js_templates") ?>

    <script src="<?= htmlReady($assets_url) ?>/js/lib/jquery-1.8.2.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/lib/underscore.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/lib/mustache.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/lib/backbone.js"></script>

    <script src="<?= htmlReady($assets_url) ?>/js/config.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/lib/jquery.mobile-1.2.0.js"></script>

    <script src="<?= htmlReady($assets_url) ?>/js/bootstrap.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/models.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/views.js"></script>
    <script src="<?= htmlReady($assets_url) ?>/js/router.js"></script>

    <script>
    tw.API_URL    = "<?= htmlReady($api_url) ?>";
    tw.ASSETS_URL = "<?= htmlReady($assets_url) ?>";
    tw.PLUGIN_URL = "<?= htmlReady($plugin_url) ?>";
    tw.USER       = { id: "<?= htmlReady($userid) ?>", name: "<?= htmlReady($username) ?>" };
    </script>

  </head>

  <body>
  </body>
</html>
