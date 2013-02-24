# /etc/puppet/modules/hbase/manafests/params.pp

class hbase::params {

	include java::params

	$version = $::hostname ? {
		default			=> "0.95-SNAPSHOT",
	}

 	$hadoop_user = $::hostname ? {
		default			=> "hduser",
	}
 
 	$hadoop_group = $::hostname ? {
		default			=> "hadoop",
	}
        
	$master = $::hostname ? {
		default			=> "master.hadoop",
	}
 
	$slaves = $::hostname ? {
		default			=> ["slave01.hadoop", "slave02.hadoop"] 
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
 
    $hadoop_user_path = $::hostname ? {
		default			=> "/home/${hadoop_user}",
	}             

}
