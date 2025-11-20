<?php
/**
 * Local application configuration
 *
 * Insert your local database credentials here
 * and provide the email address the system should use.
 */

return array(
    'db' => array(
        'database' => $_ENV["MYSQL_DATABASE"],
        'username' => $_ENV["MYSQL_USER"],
        'password' => $_ENV["MYSQL_PASSWORD"],

        'hostname' => $_ENV["DATABASE_URL"],
        'port' => $_ENV["DATABASE_PORT"],
        'driver_options' => array(
        PDO::MYSQL_ATTR_SSL_CA => '/etc/ssl/certs/ca-certificates.crt',
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
        ),
    ),
    'mail' => array(
        'type' => $_ENV["MAIL_TYPE"], // 'sendmail', 'smtp' or 'smtp-tls'
        'address' => $_ENV["MAIL_ADDRESS"], // info@bookings.example.com
            // Make sure 'bookings.example.com' matches the hosting domain when using type 'sendmail'

        'host' => $_ENV["MAIL_SMTP_HOST"], // for 'smtp' type only, otherwise remove or leave as is
        'user' => $_ENV["MAIL_SMTP_USER"], // for 'smtp' type only, otherwise remove or leave as is
        'pw'   => $_ENV["MAIL_SMTP_PW"], // for 'smtp' type only, otherwise remove or leave as is

        'port' => $_ENV["MAIL_SMTP_PORT"], // for 'smtp' type only, otherwise remove or leave as is
        'auth' => $_ENV["MAIL_SMTP_AUTH"], // for 'smtp' type only, change this to 'login' if you have problems with SMTP authentication
    ),
    'i18n' => array(
        'choice' => array(
            'en-GB' => 'English',

            // More possible languages:
            // 'fr-FR' => 'Français',
            // 'hu-HU' => 'Magyar',
        ),

        'currency' => 'GBP',

        // The language is usually detected from the user's web browser.
        // If it cannot be detected automatically and there is no cookie from a manual language selection,
        // the following locale will be used as the default "fallback":
        'locale' => 'en-GB',
    ),
);

