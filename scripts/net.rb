require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

template = File.read("../template/servers.json")
ca = File.read("../static/ca.crt")

cfg = {
  ca: ca,
  cipher: "AES-256-CBC",
  digest: "SHA1",
  compressionFraming: 0,
  keepAliveSeconds: 10,
  keepAliveTimeoutSeconds: 60,
  renegotiatesAfterSeconds: 0,
  checksEKU: true
}

recommended = {
  id: "default",
  name: "Default",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
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
  }
}

dns_override = {
  id: "dns",
  name: "Custom DNS",
  comment: "256-bit encryption",
  ovpn: {
    cfg: cfg,
    endpoints: [
      "UDP:1400",
      "TCP:1401"
    ]
  }
}

presets = [
  recommended,
  dns_override
]

defaults = {
  :username => "1234567890",
  :country => "US"
}

###

servers = []

json = JSON.parse(template)
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

      server = {
        :id => id,
        :country => code,
        :hostname => hostname,
        :addrs => addresses
      }
      server[:area] = area if !area.empty?
      server[:num] = num
      servers << server
    }
  }
}

###

infra = {
  :servers => servers,
  :presets => presets,
  :defaults => defaults
}

puts infra.to_json
puts
