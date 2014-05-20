# /etc/puppet/modules/hbase/manifests/master.pp
 
define hbaseprinciple {
    exec { "create Hbase principle ${name}":
        command => "kadmin.local -q 'addprinc -randkey hbase/$name@${hbase::params::kerberos_realm}'",
        user => "root",
        group => "root",
        path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
        alias => "add-princ-hbase-${name}",
        onlyif => "test ! -e ${hbase::params::keytab_path}/${name}.hbase.service.keytab",
    }
}
 
define hbasekeytab {
    exec { "create Hbase keytab ${name}":
        command => "kadmin.local -q 'ktadd -k ${hbase::params::keytab_path}/${name}.hbase.service.keytab hbase/$name@${hbase::params::kerberos_realm}'",
        user => "root",
        group => "root",
        path    => ["/usr/sbin", "/usr/kerberos/sbin", "/usr/bin"],
        onlyif => "test ! -e ${hbase::params::keytab_path}/${name}.hbase.service.keytab",
        alias => "create-keytab-hbase-${name}",
        require => [ Exec["add-princ-hbase-${name}"] ],
    }
}
 
class hbase::cluster {
	# do nothing, magic lookup helper
}

 
class hbase::cluster::kerberos {

    require hbase::params
 
    if $hbase::params::kerberos_mode == "yes" {

        file { "${hbase::params::keytab_path}":
            ensure => "directory",
            owner => "root",
            group => "${hbase::params::hadoop_group}",
            mode => "750",
            alias => "keytab-path",
        }
 
        hbaseprinciple { $hbase::params::master: 
            require => File["keytab-path"],
        }
 
        hbaseprinciple { $hbase::params::slaves: 
            require => File["keytab-path"],
        }
 
        hbasekeytab { $hbase::params::master: 
            require => File["keytab-path"],
        }
 
        hbasekeytab { $hbase::params::slaves: 
            require => File["keytab-path"],
        }

    }
}
 
class hbase::cluster::master {

    require hbase::params
    require hbase

    exec { "Start hbase":
        command => "./start-hbase.sh",
        cwd => "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/bin",
        user => "${hbase::params::hbase_user}",
        alias => "start-hbase",
        path    => ["/bin", "/usr/bin", "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/sbin", "${hbase::params::hbase_base}/hbase-${hbase::params::untar_path}/bin"],
    }
 
}

class hbase::cluster::slave {

    require hbase::params
    require hbase
 
 
}
