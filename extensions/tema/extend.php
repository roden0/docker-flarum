<?php

use Flarum\Extend;

return [
    (new Extend\Frontend('forum'))->css(__DIR__.'/less/forum.less'),
];
