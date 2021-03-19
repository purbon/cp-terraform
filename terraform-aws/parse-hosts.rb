#!/usr/bin/env ruby

require "json"

system("terraform show -json > state.json")

json_data=File.read("state.json")

data = JSON.parse(json_data)

machines = {}

data["values"]["root_module"]["child_modules"].each do |resources|
  resources.each do |resource|
    resource.each do |v|
      next unless v.is_a?(Array)

      instances = v.filter { |e| e["address"].start_with?("aws_route53_record") }

      instances.each do |i|
        ip = i["values"]["records"][0]
        name = i["values"]["fqdn"]
        if not machines[ip]
          machines[ip] = {:ip => ip}
          machines[ip][:name] = name
        end
      end



    end
  end
end

machines.each_pair do |k,v|
  puts "#{v[:ip]}\t#{v[:name] ? v[:name] : "bastion"}"
end
