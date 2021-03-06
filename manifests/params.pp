# /etc/puppet/modules/hbase/manafests/params.pp

class hbase::params {

	include java::params

	$version = $::hostname ? {
		default			=> "0.98.2",
	}
 
 	$untar_path = $::hostname ? {
		default			=> "${version}-hadoop2",
	}
 
 	$file = $::hostname ? {
		default			=> "${version}-hadoop2-bin",
	}

        $download_url = $::hostname ? {
		default			=> "http://apache.stu.edu.tw/hbase/hbase-${version}",
	}      

 	$hbase_user = $::hostname ? {
		default			=> "hbase",
	}
 
 	$hadoop_group = $::hostname ? {
		default			=> "hadoop",
	}
        
	$master = $::hostname ? {
		default			=> ["test1.openstacklocal", "test2.openstacklocal"]
	}

    $rest_gateway = $::hostname ? {
            default                 => ["test1.openstacklocal"]
    }
 
	$slaves = $::hostname ? {
		default			=> ["test3.openstacklocal", "test4.openstacklocal", "test5.openstacklocal"] 
	}

    $zookeeper_quorum = $::hostname ? {
        default         => unique(flatten([$slaves, [$master[1]]])),
    }
 
    $namenode =  $::hostname ? {
		default			=> "${master[0]}",
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
    
    $kerberos_mode = $::hostname ? {
        default            => "yes",
    }
    
    $keytab_path = $::hostname ? {
        default            => "/etc/security/keytab",
    }
    
    $kerberos_realm = $::hostname ? {
        default            => "OPENSTACKLOCAL",
    }
    
    $phoenix_version = $::hostname ? {
        default            => "4.0.0",
    }
 
}
