# Portable privacy - Raspberry Pi

## Why

This project is about setting up a Raspberry Pi to have a small portable device that can offer 
a nice base layer of privacy when moving around.

At the place we call home it's easy to have systems in place that guarantee to a fair degree our privacy while surfing the internet, 
but when traveling around is a bit different.

One approach would be to have everything installed on the laptop, so it always runs when we open the computer, but that
approach is exclusive to the machine in use, and we want to be able to also benefit of it from the phone, and maybe share the 
private access point with someone we trust.

It also offers an extra layer, so we can add extra security on the computer and the Pi device to control traffic 
more granular.

## What

- [DietPi](https://dietpi.com/)
- [Pi-hole](https://pi-hole.net/)
- [Unbound](https://docs.pi-hole.net/guides/dns/unbound/)
- OpenVPN
- iptables

### DietPi

It's a minimal and lightweight distribution based on Debian. Just what's needed to run some daemons and have a shell.

### Pi-hole

It's a software that will act as our initial DNS server. It keeps a list of already identified domains used 
for advertising, and when any of those is requested, Pi-hole returns the IP of a local web server running on
the same Pi that contains a blank page. This way it blocks lots of ads just from the DNS request.

On the cases when the domain is not the denylist, it forwards the request to an upstream server(Unbound),
and it caches the results, thus optimizing future performance.

### Unbound

It's a traversal DNS server. It means that instead of asking the complete domain to a single server,
it breaks the domain on the different levels, it starts on the TLD server, and it keeps asking who is
the server holding the next level down. Once it gets to the authoritative server holding the IP, it fetches the wanted IP
and returns it to the client.

This way we don't ask the data we want to a single server, but instead we split our requests with small pieces of 
information, making it harder to follow the path.

### OpenVPN

It's a software to set and use private networks. In our setup is used as a client to connect to a server 
of our choice.

### iptables

It's a software that allows to configure packet filtering rules. We will use it to have a 
[kill-switch](https://en.wikipedia.org/wiki/Internet_kill_switch) in place, so in case our VPN goes down for any
reason our traffic doesn't go into the clear.

## How

The two scripts are in the user's home, so they can be invoked easily.

Apart from those, this was added on `/etc/sysctl.conf`:

```
net.ipv4.ip_forward=1

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
```

to enable forwarding, and to disable IPv6. (VPNs still have issues with it and can be a security issue to keep it enabled)

Then on `/etc/network/interfaces`, on the config of my ethernet interface on the Pi, this was added:

```
pre-up /root/default_rules.sh
```

so the default secure rules are added to iptables even before the interface is up, this way when the laptop 
is connected the kill-switch is already in place.

Then I can easily login into the Pi and start the VPN connection. 

If for any reason there's the need to bypass the VPN and use a clear connection, we can switch to it by manually
executing `danger_will_robinson.sh`

## Possible improvements

- Allow to add an extra wireless interface that also is routed through the VPN, on demand
- MITM the traffic from ethernet interface to mask browsing details like user-agent, resolution, etc
- Trigger OpenVPN connection automatically when a link to internet is up