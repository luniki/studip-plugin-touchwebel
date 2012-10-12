<? /* prevent direct access */ if (!defined("STUDIP\\ENV")) exit; ?>

<? foreach (glob($this->_factory->get_path() . "js/*.mustache") as $template) { ?>
<script id="tw-template-<?= htmlReady(current(explode(".", basename($template))))?>" type="text/html">
<? include $template ?>
</script>
<? } ?>
