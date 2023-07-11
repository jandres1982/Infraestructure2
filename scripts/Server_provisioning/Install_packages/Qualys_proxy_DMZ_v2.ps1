param([string]$sub)
switch ($sub) {
    "s-sis-eu-prod-01" {
        $Proxy = "http://slsnwg1000.global.schindler.com:3128"
        $registryPath = "HKLM:\Software\qualys\Proxy"
        $Name = "URL"
        $value = $Proxy
        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
        Restart-Service -Name QualysAgent -Force
    }
    "s-sis-eu-nonprod-01" {
        $Proxy = "http://slsnwg1000.global.schindler.com:3128"
        $registryPath = "HKLM:\Software\qualys\Proxy"
        $Name = "URL"
        $value = $Proxy
        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
        Restart-Service -Name QualysAgent -Force
    }

    "s-sis-ap-prod-01" {
        $Proxy = "http://slsnwg1000.global.schindler.com:3128"
        $registryPath = "HKLM:\Software\qualys\Proxy"
        $Name = "URL"
        $value = $Proxy
        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
        Restart-Service -Name QualysAgent -Force
    }

    "s-sis-ch-prod-01" {
        $Proxy = "http://slsnwg1000.global.schindler.com:3128"
        $registryPath = "HKLM:\Software\qualys\Proxy"
        $Name = "URL"
        $value = $Proxy
        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
        Restart-Service -Name QualysAgent -Force
    }
    "s-sis-ch-nonprod-01" {
        $Proxy = "http://slsnwg1000.global.schindler.com:3128"
        $registryPath = "HKLM:\Software\qualys\Proxy"
        $Name = "URL"
        $value = $Proxy
        New-Item -Path $registryPath -Force
        New-ItemProperty -Path $registryPath -Name $name -Value $value -Force
        Restart-Service -Name QualysAgent -Force
    }
}
#netsh winhttp reset proxy

#netsh winhttp show proxy

