class newrelic::sysmond ($license)
{
    include newrelic::repo

    $newrelic_license = $license

    package { "newrelic-sysmond":
        ensure  => latest,
        notify  => Service['newrelic-sysmond'],
        require => Class["newrelic::repo"];
    }
  
    if $newrelic_license == undef{ fail('$newrelic_license not defined') }

    Exec['newrelic-set-license', 'newrelic-set-ssl'] {
      path +> ['/usr/local/sbin', '/usr/local/bin', '/usr/sbin', '/usr/bin', '/sbin', '/bin']
    }

    exec { "newrelic-set-license":
        unless  => "egrep -q '^license_key=${newrelic_license}$' /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set license_key=${newrelic_license}",
        require => Package['newrelic-sysmond'],
        notify => Service['newrelic-sysmond'];
    }

    exec { "newrelic-set-ssl":
        unless  => "egrep -q ^ssl=true$ /etc/newrelic/nrsysmond.cfg",
        command => "nrsysmond-config --set ssl=true",
        require => Package['newrelic-sysmond'],
        notify => Service['newrelic-sysmond'];
    }

    service { "newrelic-sysmond":
        enable  => true,
        ensure  => running,
        hasstatus => true,
        hasrestart => true,
        require => Package['newrelic-sysmond'];
    }
}
