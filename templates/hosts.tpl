all:
    hosts:
      master-1:
        ansible_host: "${ip_addr}"
        ip: ${ip_addr}
        access_ip: ${ip_addr}