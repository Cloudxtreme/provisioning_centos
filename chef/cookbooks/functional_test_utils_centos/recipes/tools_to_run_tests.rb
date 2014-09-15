%w{x11-xserver-utils firefox firefox-branding xfonts-100dpi xfonts-100dpi-transcoded xfonts-cyrillic xfonts-tipa xvfb ant tidy}.each do |pkg|
  package pkg do
    action :install
  end
end
