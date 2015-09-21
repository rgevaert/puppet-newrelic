# Newrelic system monitoring
class newrelic::sysmond ($license, $ensure = 'present', $labels='')
{
  include newrelic::repo

  case $ensure {
    'present': {
      $package_ensure = 'latest'
      $service_ensure = 'running'
      $link_ensure    = 'link'
      $file_ensure    = 'present'
    }
    'absent': {
      $package_ensure = 'absent'
      $service_ensure = 'stopped'
      $link_ensure    = 'absent'
      $file_ensure    = 'absent'
    }
    default: {fail('ensure must be present or absent')}
  }

  $newrelic_license = $license
  if $newrelic_license == undef{ fail('$newrelic_license not defined') }

  package { 'newrelic-sysmond':
      ensure  => $package_ensure,
      notify  => Service['newrelic-sysmond'],
      require => Class['newrelic::repo'];
  }

  file{
    '/etc/newrelic/nrsysmond.cfg':
      ensure  => $file_ensure,
      owner   => 'newrelic',
      group   => 'newrelic',
      mode    => '0640',
      require => Package['newrelic-sysmond'],
      notify  => Service['newrelic-sysmond'],
      content => template('newrelic/nrsysmond.cfg.erb');
  }

  service { 'newrelic-sysmond':
    ensure     => $service_ensure,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['newrelic-sysmond'];
  }
}
