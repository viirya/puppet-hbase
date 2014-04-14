# /etc/puppet/modules/hbase/manifests/master.pp

class hbase::cluster {
	# do nothing, magic lookup helper
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
