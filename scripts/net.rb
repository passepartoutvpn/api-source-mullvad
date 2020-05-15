require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.read("../template/servers.json")
ca = File.read("../static/ca.crt")

cfg = {
    ca: ca,
    cipher: "AES-256-CBC",
    ping: 10,
    reneg: 0,
    eku: true
}

external = {
    hostname: "${id}.mullvad.net"
}

recommended_cfg = cfg.dup
recommended_cfg["ep"] = [
    "UDP:1194",
    "UDP:1195",
    "UDP:1196",
    "UDP:1197",
    "UDP:1301",
    "UDP:1302",
    "UDP:53",
    "TCP:443",
    "TCP:80"
]
recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: recommended_cfg,
    external: external
}

dns_override_cfg = cfg.dup
dns_override_cfg["ep"] = [
    "UDP:1400",
    "TCP:1401"
]
dns_override = {
    id: "dns",
    name: "Custom DNS",
    comment: "256-bit encryption",
    cfg: dns_override_cfg,
    external: external
}

presets = [
    recommended,
    dns_override
]

defaults = {
    :username => "1234567890",
    :pool => "us",
    :preset => "default"
}

###

pools = []

json = JSON.parse(servers)
json["countries"].each { |country|
    country["cities"].each { |city|
        code = country["code"].upcase
        area = city["name"]

        city["relays"].each { |relay|
            id = relay["hostname"]
            hostname = "#{id.downcase}.mullvad.net"
            num = id.split("-").last.to_i

            addresses = [relay["ipv4_addr_in"]]
            addresses.map! { |a|
                IPAddr.new(a).to_i
            }

            pool = {
                :id => id,
                :country => code,
                :hostname => hostname,
                :addrs => addresses
            }
            pool[:area] = area if !area.empty?
            pool[:num] = num
            pools << pool
        }
    }
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
