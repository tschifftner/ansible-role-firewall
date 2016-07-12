# Ansible Role: Firewall

[![Build Status](https://travis-ci.org/tschifftner/ansible-role-firewall.svg)](https://travis-ci.org/tschifftner/ansible-role-firewall)

Installs a firewall (shell script that manages iptables) on Debian/Ubuntu linux servers.

## Requirements

None.

## Dependencies

None.

## Role Variables

Available variables are listed below, along with default values (see `defaults/main.yml`):

### Default variables

Used to have some default variables
```
# Variables for defaults (like SSH)
firewall_default_allowed_tcp_ports: [22]
firewall_default_allowed_udp_ports: []
firewall_default_forwarded_tcp_ports: []
firewall_default_forwarded_udp_ports: []
firewall_default_additional_rules: []
```

### Variables for groups

Used to define firewall settings per group
```
firewall_groups_allowed_tcp_ports: []
firewall_groups_allowed_udp_ports: []
firewall_groups_forwarded_tcp_ports: []
firewall_groups_forwarded_udp_ports: []
firewall_groups_additional_rules: []
```

### Variables for hosts

Used to define firewall settings per host
```
firewall_hosts_allowed_tcp_ports: []
firewall_hosts_allowed_udp_ports: []
firewall_hosts_forwarded_tcp_ports: []
firewall_hosts_forwarded_udp_ports: []
firewall_hosts_additional_rules: []
```

### Enable firewall checks

A cronjob will be setup to check regularly if firewall is running.
If not, the firewall will try to start.

```
firewall_enable_test_cronjob: true
```


### Drop log packages

```
firewall_log_dropped_packets: true
```

## Example Playbook

    - hosts: server
      vars:
        firewall_allowed_default_tcp_ports:
          - 22 # ssh
          - 80 # http
        
        firewall_additional_rules:
          - 'iptables -I INPUT -p tcp -s 10.10.10.1 --dport 4949 -j ACCEPT'

      roles:
        - { role: tschifftner.firewall }

## Supported OS
Ansible          | Debian Jessie    | Ubuntu 14.04    | Ubuntu 12.04
:--------------: | :--------------: | :-------------: | :-------------: 
2.1              | Yes              | Yes             | Yes

## License

MIT / BSD

## Author Information

 - [Tobias Schifftner](https://twitter.com/tschifftner), [ambimax® GmbH](https://www.ambimax.de)