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

  $config_root = '/etc/php5'

  if $::php_version == '' or versioncmp($::php_version, '5.5') >= 0 {
    $config_root_ini = "${config_root}/mods-available"

    $link_ensure = $ensure ? {
      'absent' => 'absent',
      default  => 'link',
    }

    file {
      "${config_root}/apache2/conf.d/${name}.ini":
        ensure  => $link_ensure,
        target  => "../../mods-available/${name}.ini",
        notify  => Service["httpd"];
    }

    file {
      "${config_root}/cli/conf.d/${name}.ini":
        ensure  => $link_ensure,
        target  => "../../mods-available/${name}.ini",
        notify  => Service["httpd"];
    }

  } else {
    $config_root_ini = "${config_root}/conf.d"
  }

  file {
    "${config_root_ini}/${newrelic}.ini":
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($phpini_content),
      notify  => Service["httpd"],
      require => Package['newrelic-php5'];
  }

  file {
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
