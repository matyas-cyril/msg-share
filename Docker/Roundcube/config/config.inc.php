<?php
    $config['plugins'] = [
        'archive',
        'ziddownload',
    ];
    $config['log_driver'] = 'stdout';
    $config['zipdownload_selection'] = true;
    $config['des_key'] = 'IMs6J7SQwCzOFcOvV9AngNKr';
    $config['enable_spellcheck'] = true;
    $config['spellcheck_engine'] = 'pspell';
    $config['imap_vendor'] = 'cyrus';
    include(__DIR__ . '/config.docker.inc.php');
