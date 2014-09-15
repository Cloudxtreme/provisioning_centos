execute "Clean rapidsms_ureport" do
  cwd "/home/ureport/code/ureport/ureport_project/rapidsms_ureport"
  command "git reset --hard HEAD"
  action :run
end
