FROM ubuntu:20.04
RUN echo 8.8.8.8 > /etc/resolv.conf
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget https://repo.zabbix.com/zabbix/6.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.2-2%2Bubuntu20.04_all.deb --no-check-certificate
RUN dpkg -i zabbix-release_6.2-2+ubuntu20.04_all.deb
RUN apt update
RUN apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent
CMD ["/bin/bash"]