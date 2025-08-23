<?php
// PHP 8–safe autoloader for legacy PHPMailer filenames
if (!function_exists('PHPMailerAutoload')) {
    function PHPMailerAutoload($classname) {
        $dir = __DIR__ . '/';
        $map = [
            'PHPMailer' => 'class.phpmailer.php',
            'SMTP'      => 'class.smtp.php',
            'POP3'      => 'class.pop3.php',
        ];
        if (isset($map[$classname])) {
            $file = $dir . $map[$classname];
            if (is_readable($file)) {
                require $file;
            }
        }
    }
}
spl_autoload_register('PHPMailerAutoload', true, true);
