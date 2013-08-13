class newrelic::php5($license, $config_content = 'newrelic/newrelic.cfg.erb', $phpini_content = 'newrelic/php.ini.erb' )
{
    include newrelic::repo

    $newrelic_license = $license

    package {
      'newrelic-php5':
        ensure  => latest,
        notify  => Service['newrelic-daemon'],
        require => Class['newrelic::repo'];
    }
  
    if $newrelic_license == undef{ fail("$newrelic_license not defined") }

    service {
      'newrelic-daemon':
        enable  => true,
        ensure  => running,
        hasstatus => true,
        hasrestart => true,
        require => Package['newrelic-php5'];
    }

    file {
      '/etc/php5/conf.d/newrelic.ini':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template($phpini_content),
        require => Package['newrelic-php5'],
        notify  => Class['apache'];
      '/etc/newrelic/newrelic.cfg':
        ensure  => present, 
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Package['newrelic-php5'],
        notify  => Service['newrelic-daemon'],
        content => template($config_content);
    }
}
