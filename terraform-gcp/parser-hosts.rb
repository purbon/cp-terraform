#!/usr/bin/env ruby

require "json"

json_data=File.read("state.json")

data = JSON.parse(json_data)

resources = data["values"]["root_module"]["child_modules"][0]

machines = {}
resources.each do |resource|

  resource.each do |v|
    next unless v.is_a?(Array)

    instances = v.filter { |e| e["address"].start_with?("google_compute_instance") }

    instances.each do |i|
      ip = i["values"]["network_interface"][0]["network_ip"]
      nat_ip = i["values"]["network_interface"][0]["access_config"][0]["nat_ip"]
      if not machines[ip]
        machines[ip] = {:ip => ip, :nat_ip => nat_ip}
      end
    end

    addresses = v.filter { |e| e["address"].start_with?("google_dns_record_set") }
    addresses.each do |e|
        ip = e["values"]["rrdatas"].first
        machines[ip][:name] = e["values"]["name"]
    end

  end
end

machines.each_pair do |k,v|

  puts "#{v[:nat_ip]}\t#{v[:name] ? v[:name] : "bastion"}"
end
