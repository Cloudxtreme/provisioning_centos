#!/usr/bin/env ruby

puts
puts 'Before we do anything else, make sure you have all of the following files in ~/.chef/:'
puts ' - validation.pem'
puts ' - ur_data_bag_key'
puts ' - precise64.box (this is a default Vagrant base box, can be downloaded easily)'


errors = Array.new

`vagrant -v`
if $? != 0
  errors << 'Install Vagrant'
end

`vagrant plugin list | grep vagrant-omnibus`
if $? != 0
  errors << 'Install Vagrant''s Omnibus plugin'
end

`chef-client -v | grep 11.4.4`
if $? != 0
  errors << 'Make sure Chef v11.4.4 is installed'
end

if errors.any?
  puts
  puts
  puts 'Please fix the following issues:'
  errors.each { |error| puts " - #{error}"}
  exit 1
end

puts
puts 'Looks good BRO/GAL -- keep rocking'
puts
