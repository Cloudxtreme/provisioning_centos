#package "locales" do
#  action :install
#end

locale = "en_US.UTF-8"
encoding = "UTF-8"
language = "en_US"

ruby_block "Set locale for this session" do
    block do
        ENV["LANG"] = locale
        ENV["LC_ALL"] = locale
    end
end

execute "Set locale permanently" do
    command "localedef -c -f #{encoding} -i #{language} #{locale}"
end

execute "Set timezone" do
    command 'echo "Etc/UTC" > /etc/timezone'
end
