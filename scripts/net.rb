require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

###

servers = File.foreach("../template/servers.csv")
ca = File.read("../template/ca.crt")

cfg = {
    ca: ca,
    ep: [
        "UDP:1194",
        "UDP:1195",
        "UDP:1196",
        "UDP:1197",
        "UDP:1301",
        "UDP:1302",
        "UDP:53",
        "TCP:443",
        "TCP:80"
    ],
    cipher: "AES-256-CBC",
    auth: "SHA1",
    frame: 0,
    ping: 10,
    reneg: 3600,
    eku: true
}

recommended = {
    id: "default",
    name: "Default",
    comment: "256-bit encryption",
    cfg: cfg
}
presets = [recommended]

defaults = {
    :username => "1234567890",
    :pool => "us",
    :preset => "default"
}

###

pools = []
servers.with_index { |line, n|
    id, country, area, hostname, udp_joined, tcp_joined = line.strip.split(",")

    # XXX: can't use per-server ports, endpoints must be shared
    #udp = udp_joined.split("-")
    #tcp = tcp_joined.split("-")

    addresses = nil
    if ARGV.include? "noresolv"
        addresses = []
    else
        addresses = Resolv.getaddresses(hostname)
    end
    addresses.map! { |a|
        IPAddr.new(a).to_i
    }

    pool = {
        :id => id,
        :country => country.upcase,
        :hostname => hostname,
        :addrs => addresses
    }
    pool[:area] = area if !area.empty?
    pools << pool
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
