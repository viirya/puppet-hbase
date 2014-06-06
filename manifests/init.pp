# /etc/puppet/modules/hbase/manafests/init.pp

class hbase {

    require hbase::params
    
    group { "${hbase::params::hadoop_group}":
        ensure => present,
        gid => "800",
        alias => "hbase-group",
    }
    
    user { "${hbase::params::hbase_user}":
        ensure => present,
        comment => "Hadoop",
        password => "!!",
        #uid => "800",
        gid => "800",
        shell => "/bin/bash",
        home => "${hbase::params::hbase_user_path}",
        require => Group["hbase-group"],
    }
    
    file { "${hbase::params::hbase_user_path}":
        ensure => "directory",
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        alias => "${hbase::params::hbase_user}-home",
        require => [ User["${hbase::params::hbase_user}"], Group["hbase-group"] ]
    }

    file { "${hbase::params::hbase_user_path}/.ssh/":
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "700",
        ensure => "directory",
        alias => "${hbase::params::hbase_user}-ssh-dir",
    }

    file { "${hbase::params::hbase_user_path}/.ssh/id_rsa.pub":
        ensure => present,
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "644",
        source => "puppet:///modules/hbase/ssh/id_rsa.pub",
        require => File["${hbase::params::hbase_user}-ssh-dir"],
    }

    file { "${hbase::params::hbase_user_path}/.ssh/id_rsa":
        ensure => present,
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "600",
        source => "puppet:///modules/hbase/ssh/id_rsa",
        require => File["${hbase::params::hbase_user}-ssh-dir"],
    }

    file { "${hbase::params::hbase_user_path}/.ssh/config":
        ensure => present,
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "600",
        source => "puppet:///modules/hbase/ssh/config",
        require => File["${hbase::params::hbase_user}-ssh-dir"],
    }

    file { "${hbase::params::hbase_user_path}/.ssh/authorized_keys":
        ensure => present,
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        mode => "644",
        source => "puppet:///modules/hbase/ssh/id_rsa.pub",
        require => File["${hbase::params::hbase_user}-ssh-dir"],
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
        command => "wget '${hbase::params::download_url}/hbase-${hbase::params::file}.tar.gz'",
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
        onlyif => "test 0 -eq $(ls -al ${hbase::params::hbase_base}/hbase-${hbase::params::untar_path} | grep -c bin)",
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

    if $hbase::params::phoenix_version !=  "" {
        file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/lib/phoenix-core-${hbase::params::phoenix_version}-incubating.jar":
            ensure => present,
            owner => "${hbase::params::hbase_user}",
            group => "${hbase::params::hadoop_group}",
            mode => "644",
            alias => "hbase-phoenix",
            source => "puppet:///modules/hbase/lib/phoenix-core-${hbase::params::phoenix_version}-incubating.jar",
            require => [ Exec["untar-hbase"], File["hbase-app-dir"] ],
        }
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

    exec { "set hbase_home":
        command => "echo 'export HBASE_HOME=${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}' >> /etc/profile.d/hadoop.sh",
        alias => "set-hbasehome",
        user => "root",
        require => [File["hbase-app-dir"], User["${hbase::params::hbase_user}"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        onlyif => "test 0 -eq $(grep -c HBASE_HOME /etc/profile.d/hadoop.sh)",
    }
 
    exec { "set hbase path":
        command => "echo 'export PATH=${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/bin:\$PATH' >> /etc/profile.d/hadoop.sh",
        alias => "set-hbasepath",
        user => "root",
        before => Exec["set-hbasehome"],
        require => [File["hbase-app-dir"], User["${hbase::params::hbase_user}"]],
        path    => ["/bin", "/usr/bin", "/usr/sbin"],
        onlyif => "test 0 -eq $(grep -c '${hbase::params::hbase_base}/hbase-${hbase::params::file}/bin' /etc/profile.d/hadoop.sh)",
    }

    file { "${hbase::params::hbase_user_path}/.bashrc":        
        ensure => present,
        owner => "${hbase::params::hbase_user}",
        group => "${hbase::params::hadoop_group}",
        alias => "${hbase::params::hbase_user}-bashrc",
        content => template("hbase/home/bashrc.erb"),
        require => User["${hbase::params::hbase_user}"]    
    }
 
 
    if $hbase::params::kerberos_mode == "yes" {
 
        file { "${hbase::params::keytab_path}":
            ensure => "directory",
            owner => "root",
            group => "${hbase::params::hadoop_group}",
            mode => "750",
            alias => "keytab-path",
        }
 
        file { "${hbase::params::keytab_path}/hbase.service.keytab":
            ensure => present,
            owner => "root",
            group => "${hbase::params::hadoop_group}",
            mode => "440",
            source => "puppet:///modules/hbase/keytab/${fqdn}.hbase.service.keytab",
            require => File["keytab-path"],
        }
 
        if member($hbase::params::rest_gateway, $fqdn) {
            file { "${hbase::params::keytab_path}/hbase_rest.service.keytab":
                ensure => present,
                owner => "root",
                group => "${hbase::params::hadoop_group}",
                mode => "440",
                source => "puppet:///modules/hbase/keytab/${fqdn}.hbase_rest.service.keytab",
                require => File["keytab-path"],
            }
        }
 
        file { "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/conf/jaas.conf":
            owner => "${hbase::params::hbase_user}",
            group => "${hbase::params::hadoop_group}",
            mode => "644",
            alias => "jaas-cfg",
            require => File["hbase-app-dir"],
            content => template("hbase/conf/jaas.conf.erb"),
        }

    }
 
    #exec { "set hbase_home":
    #   command => "echo 'export HBASE_HOME=${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}' >> ${hbase::params::hbase_user_path}/.bashrc",
    #   alias => "set-hbasehome",
    #   user => "${hbase::params::hbase_user}",
    #   require => [File["hbase-app-dir"], User["${hbase::params::hbase_user}"]],
    #   path    => ["/bin", "/usr/bin", "/usr/sbin"],
    #   onlyif => "test 0 -eq $(grep -c HBASE_HOME ${hbase::params::hbase_user_path}/.bashrc)",
    #
    #
    #exec { "set hbase path":
    #   command => "echo 'export PATH=${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/bin:\$PATH' >> ${hbase::params::hbase_user_path}/.bashrc",
    #   alias => "set-hbasepath",
    #   user => "${hbase::params::hbase_user}",
    #   before => Exec["set-hbasehome"],
    #   require => [File["hbase-app-dir"], User["${hbase::params::hbase_user}"]],
    #   path    => ["/bin", "/usr/bin", "/usr/sbin"],
    #   onlyif => "test 0 -eq $(grep -c '${hbase::params::hbase_base}/hbase-${hbase::params::file}/bin' ${hbase::params::hbase_user_path}/.bashrc)",
    #

}
