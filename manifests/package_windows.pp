# @summary Manage the Qualys agent's package installation
#
# Install or uninstall the Qualys agent package on windows
#
class qualys_agent::package_windows {

  if $qualys_agent::manage_package {
    # Force package remove if agent ensure is "absent"
    $ensure = $qualys_agent::ensure ? {
      present => $qualys_agent::package_ensure,
      absent  => 'absent',
    }

    archive { "C:/Windows/Temp/${qualys_agent::package_filename_final}":
      ensure       => present,
      source       => $qualys_agent::package_url,
      proxy_server => $qualys_agent::proxy,
    }

    package { 'qualys_agent':
      ensure   => $ensure,
      source   => "c:/Windows/Temp/${qualys_agent::package_filename_final}",
      install_options => [ CustomerId={${qualys_agent::customer_id}} ActivationId={${qualys_agent::activation_id}} ],
      name     => $qualys_agent::package_name,
    }

    if $qualys_agent::proxy {
      exec { 'set proxy config':
        command     => "C:\Program Files\Qualys\QualysAgent\QualysProxy.exe /u $qualys_agent::proxy",
        refreshonly => true,
        require     => Package['qualys_agent'],
      }
    }
  }
}