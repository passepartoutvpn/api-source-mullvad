require "json"
require "resolv"
require "ipaddr"

cwd = File.dirname(__FILE__)
Dir.chdir(cwd)

ca = File.read("../certs/ca.pem")
countries = ["US", "FR", "DE", "ES", "IT"]
bogus_ip = 16909060

###

pools = []
countries.each { |k|
    id = k.downcase
    hostname = "#{id}.sample-vpn-provider.bogus"

    #print "Resolving #{hostname} ..."
    #addresses = Resolv.getaddresses(hostname)

    addresses = []
    3.times {
        addresses << bogus_ip
        bogus_ip += 1
    }
    addresses.map! { |a|
        IPAddr.new(a, Socket::AF_INET)
    }

    pool = {
        :id => id,
        :name => "Sample #{k}",
        :country => k,
        :hostname => hostname,
        :addrs => addresses
    }
    pools << pool
}

recommended = {
    id: "recommended",
    name: "Recommended",
    comment: "128-bit encryption",
    cfg: {
        ep: [
            "UDP:1194",
            "TCP:443",
        ],
        cipher: "AES-128-GCM",
        auth: "SHA1",
        ca: ca,
        frame: 1,
        ping: 60,
        reneg: 3600
    }
}
presets = [recommended]

defaults = {
    :username => "myusername",
    :pool => "us",
    :preset => "recommended"
}

###

infra = {
    :pools => pools,
    :presets => presets,
    :defaults => defaults
}

puts infra.to_json
puts
