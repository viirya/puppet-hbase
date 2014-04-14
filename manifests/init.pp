# /etc/puppet/modules/hbase/manafests/init.pp

class hbase {

	require hbase::params
	
    group { "${hbase::params::hadoop_group}":
    	ensure => present,
    	gid => "800",
        alias => "hadoop",
    }
    
    user { "${hbase::params::hbase_user}":
    	ensure => present,
    	comment => "Hadoop",
    	password => "!!",
    	#uid => "800",
    	#gid => "800",
    	shell => "/bin/bash",
    	home => "${hbase::params::hbase_user_path}",
    	require => Group["hadoop"],
    }
    
    file { "${hbase::params::hbase_user_path}":
    	ensure => "directory",
    	owner => "${hbase::params::hbase_user}",
    	group => "${hbase::params::hadoop_group}",
    	alias => "${hbase::params::hbase_user}-home",
    	require => [ User["${hbase::params::hbase_user}"], Group["hadoop"] ]
    }
 
	file {"${hbase::params::hbase_base}":
		ensure => "directory",
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-base",
	}

 	file {"${hbase::params::hbase_conf}":
		ensure => "directory",
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-conf",
        require => [File["hbase-base"], Exec["untar-hbase"]],
        before => [File["hbase-site-xml"], File["hdfs-site-xml-link"], File["hbase-env-sh"]]
	}
 
    exec { "download ${hbase::params::hbase_base}/hbase-${hbase::params::file}.tar.gz":
        command => "wget 'http://apache.stu.edu.tw/hbase/hbase-${hbase::params::version}/hbase-${hbase::params::file}.tar.gz'",
        cwd => "${hbase::params::hbase_base}",
        alias => "download-hbase",
        user => "${hbase::params::hbase_user}",
        before => Exec["untar-hbase"],
        require => File["hbase-base"],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        #onlyif => "test -d ${hbase::params::hbase_base}/hbase-${hbase::params::version}",
        creates => "${hbase::params::hbase_base}/hbase-${hbase::params::file}.tar.gz",
    }

    file { "${hbase::params::hbase_base}/hbase-${hbase::params::file}.tar.gz":
    	mode => 0644,
        ensure => present,
    	owner => "${hbase::params::hbase_user}",
    	group => "${hbase::params::hadoop_group}",
    	alias => "hbase-source-tgz",
    	before => Exec["untar-hbase"],
    	require => [File["hbase-base"], Exec["download-hbase"]],
    }
    
	exec { "untar hbase-${hbase::params::file}.tar.gz":
		command => "tar xfvz hbase-${hbase::params::file}.tar.gz",
		cwd => "${hbase::params::hbase_base}",
		creates => "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}",
		alias => "untar-hbase",
		refreshonly => true,
		subscribe => File["hbase-source-tgz"],
		user => "${hbase::params::hbase_user}",
		before => [ File["hbase-symlink"], File["hbase-app-dir"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
	}

	file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}":
		ensure => "directory",
		mode => 0644,
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		alias => "hbase-app-dir",
        require => Exec["untar-hbase"],
	}
		
	file { "${hbase::params::hbase_base}/hbase":
		force => true,
		ensure => "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}",
		alias => "hbase-symlink",
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		require => File["hbase-source-tgz"],
		before => [ File["hbase-site-xml"], File["hdfs-site-xml-link"], File["hbase-env-sh"]]
	}
	
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/conf/hbase-site.xml":
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hbase-site-xml",
		content => template("hbase/conf/hbase-site.xml.erb"),
	}

	file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/conf/hdfs-site.xml":
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hdfs-site-xml-link",
        ensure => link,
        target => "${hbase::params::hadoop_conf}/hdfs-site.xml",
	}
 
	file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/conf/hbase-env.sh":
		owner => "${hbase::params::hbase_user}",
		group => "${hbase::params::hadoop_group}",
		mode => "644",
		alias => "hbase-env-sh",
		content => template("hbase/conf/hbase-env.sh.erb"),
	}
	
    file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/conf/regionservers":
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "644",
        alias => "hbase-slave",
        content => template("hbase/conf/regionservers.erb"),
    }

 	file { "/etc/security/limits.conf":
		owner => "root",
		group => "root",
		mode => "644",
		alias => "limit-conf",
		content => template("hbase/etc/limits.conf.erb"),
	}

 	file { "/etc/pam.d/common-session":
		owner => "root",
		group => "root",
		mode => "644",
		alias => "common-session",
		content => template("hbase/etc/common-session.erb"),
	}
    
}
