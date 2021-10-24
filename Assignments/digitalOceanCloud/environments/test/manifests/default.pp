node 'appserver' {
	include aptupdate
	include nodejs
	include nodeIp
}

node 'dbserver' {
	include aptupdate
	include mysql
	include nodeIp
}

class aptupdate {
  exec { "aptupdate":
      command => "/usr/bin/apt-get update",
    }
}

class nodejs{
  exec { "ca-update":
      command => "/usr/bin/apt install --reinstall ca-certificates",
    }
    exec { "apt-get-curl":
      command => "/usr/bin/apt-get install -y curl",
      require => Exec["aptupdate"],
    }

    exec { "nodesource":
     command => "/usr/bin/curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -",
     require => [
  		Exec["aptupdate"],
  		Exec["ca-update"],
  	],
    }

    exec { "apt-get-node":
      command => "/usr/bin/apt-get install -y nodejs",
      require => [
  			Exec["aptupdate"],
  			Exec["nodesource"],
  		],
    }
}

class mysql{
	exec {"mysql":
		command => '/usr/bin/apt-get install -y mysql-server',
		require => Exec["aptupdate"],
	}

	exec {"mysql-password":
		command => 'echo mysql-server mysql-server/root_password password password | sudo debconf-set-selections',
		provider => shell,
		require => [
			Exec["aptupdate"],
			Exec["mysql"],
		],
	}
}

class nodeIp{
	exec {"nodeIp":
		command => "/usr/bin/sudo echo \"$(hostname):$(/usr/bin/sudo ifconfig eth1 | grep 'inet ' | awk '{print \$2}')| head -1 \" >> /home/vagrant/Shared/ipaddress ",
		require => Exec["aptupdate"],
	}
}
