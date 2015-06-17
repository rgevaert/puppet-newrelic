class newrelic::sysmond ($license, $labels='')
{
  include newrelic::repo

  $newrelic_license = $license
  if $newrelic_license == undef{ fail('$newrelic_license not defined') }

  package { 'newrelic-sysmond':
      ensure  => latest,
      notify  => Service['newrelic-sysmond'],
      require => Class['newrelic::repo'];
  }

  file{
    '/etc/newrelic/nrsysmond.cfg':
      ensure  => present, 
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['newrelic-sysmond'],
      notify  => Service['newrelic-daemon'],
      content => template('newrelic/nrsysmond.cfg.erb');
  }

  service { 'newrelic-sysmond':
    enable     => true,
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['newrelic-sysmond'];
  }
}
