# /etc/puppet/modules/hbase/manifests/master.pp

class hbase::cluster {
	# do nothing, magic lookup helper
}

class hbase::cluster::master {

    require hbase::params
    require hbase

    exec { "Start hbase":
        command => "./start-hbase.sh",
        cwd => "${hbase::params::hbase_base}/hbase-${hbase::params::version}/bin",
        user => "${hbase::params::hadoop_user}",
        alias => "start-hbase",
        path    => ["/bin", "/usr/bin", "${hbase::params::hbase_base}/hbase-${hbase::params::version}/sbin", "${hbase::params::hbase_base}/hbase-${hbase::params::version}/bin"],
    }
 
}

class hbase::cluster::slave {

    require hbase::params
    require hbase

}
