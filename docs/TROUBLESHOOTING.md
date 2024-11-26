# Troubleshooting Guide

## Devbox

For devbox-specific troubleshooting, please see the [Troubleshooting section in DEVBOX.md](DEVBOX.md#troubleshooting).

## DNS

### Symptoms

If DNS resolution is not working properly for `.home.arpa` hostnames, you may see errors like:

- `nslookup: server can't find myhost.home.arpa: NXDOMAIN`
- `ping: myhost.home.arpa: Name or service not known` 
- `curl: (6) Could not resolve host: myhost.home.arpa`

In web browsers, you may see:

Chrome:
- "This site can't be reached" 
- "DNS_PROBE_FINISHED_NXDOMAIN"

Firefox:
- "Hmm. We're having trouble finding that site."
- "Server not found"

These errors indicate that your system is unable to resolve the `.home.arpa` hostnames to IP addresses, likely due to dnsmasq not running or being misconfigured.

### Resolution

1. Check if dnsmasq is running: `ps aux | grep dnsmasq`. If not, start it: `devbox run dnsmasq`
2. Check that `/etc/resolver/home.arpa` is defined. Otherwise, run `devbox run setup`
3. Check running `scutil --dns` includes a resolver for `home.arpa`. Otherwise, run `sudo rm /etc/resolver/home.arpa && devbox run setup`
