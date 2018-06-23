#!/usr/bin/env bash

# ip6tables firewall script for common LAMP servers.
#
# This file is mainly based on Jeff Geerling's firewall script (https://github.com/geerlingguy/ansible-role-firewall)
#
# Common port reference:
#   22: SSH
#   25: SMTP
#   80: HTTP
#   123: DNS
#   443: HTTPS
#   2222: SSH alternate
#   4949: Munin
#   6082: Varnish admin
#   8080: HTTP alternate (often used with Tomcat)
#   8983: Tomcat HTTP
#   8443: Tomcat HTTPS
#   9000: SonarQube
#
# @author Tobias Schifftner

# No spoofing.
if [ -e /proc/sys/net/ipv6/conf/all/rp_filter ]; then
    for filter in /proc/sys/net/ipv6/conf/*/rp_filter
    do
        echo 1 > $filter
    done
fi

# Remove all rules and chains.
ip6tables -F
ip6tables -X

if [ "$1" == "stop" ]; then
    exit 0;
fi

# Accept traffic from loopback interface (localhost).
ip6tables -A INPUT -i lo -j ACCEPT

# Forwarded ports.
{# Add a rule for each forwarded port #}
{% for forwarded_port in firewall_ipv6_forwarded_tcp_ports %}
ip6tables -t nat -I PREROUTING -p tcp --dport {{ forwarded_port.src }} -j REDIRECT --to-port {{ forwarded_port.dest }}
ip6tables -t nat -I OUTPUT -p tcp -o lo --dport {{ forwarded_port.src }} -j REDIRECT --to-port {{ forwarded_port.dest }}
{% endfor %}
{% for forwarded_port in firewall_ipv6_forwarded_udp_ports %}
ip6tables -t nat -I PREROUTING -p udp --dport {{ forwarded_port.src }} -j REDIRECT --to-port {{ forwarded_port.dest }}
ip6tables -t nat -I OUTPUT -p udp -o lo --dport {{ forwarded_port.src }} -j REDIRECT --to-port {{ forwarded_port.dest }}
{% endfor %}

# Open ports.
{# Add a rule for each open port #}
{% for port in firewall_ipv6_allowed_tcp_ports %}
ip6tables -A INPUT -p tcp -m tcp --dport {{ port }} -j ACCEPT
{% endfor %}
{% for port in firewall_ipv6_allowed_udp_ports %}
ip6tables -A INPUT -p udp -m udp --dport {{ port }} -j ACCEPT
{% endfor %}

# Accept icmp ping requests.
ip6tables -A INPUT --protocol icmpv6 -j ACCEPT --match limit --limit 30/minute

# Allow NTP traffic for time synchronization.
ip6tables -A OUTPUT -p udp --dport 123 -j ACCEPT
ip6tables -A INPUT -p udp --sport 123 -j ACCEPT

# Additional custom rules.
{% for rule in firewall_ipv6_additional_rules %}
{{ rule }}
{% endfor %}

# Allow established connections:
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Log EVERYTHING (ONLY for Debug).
# ip6tables -A INPUT -j LOG

{% if firewall_ipv6_log_dropped_packets %}
# Log other incoming requests (all of which are dropped) at 15/minute max.
ip6tables -A INPUT -m limit --limit 15/minute -j LOG --log-level 7 --log-prefix "Dropped by firewall: "
{% endif %}

# Drop all other traffic.
ip6tables -A INPUT -j DROP