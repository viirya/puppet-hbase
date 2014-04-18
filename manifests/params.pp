# /etc/puppet/modules/hbase/manafests/params.pp

class hbase::params {

	include java::params

	$version = $::hostname ? {
		default			=> "0.98.1",
	}
 
 	$untar_path = $::hostname ? {
		default			=> "${version}-hadoop2",
	}
 
 	$file = $::hostname ? {
		default			=> "${version}-hadoop2-bin",
	}
 
 	$hbase_user = $::hostname ? {
		default			=> "hbase",
	}
 
 	$hadoop_group = $::hostname ? {
		default			=> "hadoop",
	}
        
	$master = $::hostname ? {
		default			=> "localhost",
	}
 
	$slaves = $::hostname ? {
		default			=> ["localhost"] 
	}
 
    $namenode =  $::hostname ? {
		default			=> "${master}",
	}            
 
	$hdfsport = $::hostname ? {
		default			=> "8020",
	}
 
	$rootdir = $::hostname ? {
		default			=> "hbase",
	}
 
	$java_home = $::hostname ? {
		default			=> "${java::params::java_base}/jdk${java::params::java_version}",
	}

	$hadoop_base = $::hostname ? {
		default			=> "/opt/hadoop",
	}
 
	$hadoop_conf = $::hostname ? {
		default			=> "${hadoop_base}/hadoop/conf",
	}
 
	$hbase_base = $::hostname ? {
		default			=> "/opt/hbase",
	}
 
	$hbase_conf = $::hostname ? {
		default			=> "${hbase_base}/hbase/conf",
	}
 
    $hbase_user_path = $::hostname ? {
		default			=> "/home/${hbase_user}",
	}             

}
