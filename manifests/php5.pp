class newrelic::php5($license)
{
    include newrelic::repo

    $newrelic_license = $license

    package { "newrelic-php5":
        ensure  => latest,
        notify  => Service['newrelic-daemon'],
        require => Class["newrelic::repo"];
    }
  
    if $newrelic_license == undef{ fail('$newrelic_license not defined') }

    service { "newrelic-daemon":
        enable  => true,
        ensure  => running,
        hasstatus => true,
        hasrestart => true,
        require => Package['newrelic-php5'];
    }
}
