require 'chefspec'

describe 'tomcat::default' do
  let (:chef_run) { ChefSpec::ChefRunner.new.converge 'tomcat::default' }
  it 'should create the setenv' do
    expect(chef_run).to create_file_with_content 'setenv.sh','JAVA_OPTS="-Djava.awt.headless=true -Xms64m -Xmx2048m"'
  end
end
