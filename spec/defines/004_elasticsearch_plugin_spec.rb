require 'spec_helper'

describe 'elasticsearch::plugin', :type => 'define' do

  let(:title) { 'mobz/elasticsearch-head/1.0.0' }
  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '6',
    :scenario => '',
    :common => ''
  } end
  let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}}'}

  context "Add a plugin" do

    let :params do {
      :ensure     => 'present',
      :module_dir => 'head',
      :instances  => 'es-01'
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
    it { should contain_exec('install_plugin_mobz/elasticsearch-head/1.0.0').with(:command => '/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head/1.0.0', :creates => '/usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
    it { should contain_file('/usr/share/elasticsearch/plugins/head/.name').with(:content => 'mobz/elasticsearch-head/1.0.0') }
    it { should contain_exec('purge_plugin_head_old').with(:onlyif => "test -e /usr/share/elasticsearch/plugins/head && test \"$(cat /usr/share/elasticsearch/plugins/head/.name)\" != 'mobz/elasticsearch-head/1.0.0'", :command => '/usr/share/elasticsearch/bin/plugin --remove head', :before => 'Exec[install_plugin_mobz/elasticsearch-head/1.0.0]') }
  end

  context "Remove a plugin" do

    let :params do {
      :ensure     => 'absent',
      :module_dir => 'head',
      :instances  => 'es-01'
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
    it { should contain_exec('remove_plugin_mobz/elasticsearch-head/1.0.0').with(:command => '/usr/share/elasticsearch/bin/plugin --remove head', :onlyif => 'test -d /usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
  end

  context "Use a proxy" do

    let :params do {
      :ensure     => 'present',
      :module_dir => 'head',
      :instances  => 'es-01',
      :proxy_host => 'my.proxy.com',
      :proxy_port => 3128
    } end

    it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
    it { should contain_exec('install_plugin_mobz/elasticsearch-head/1.0.0').with(:command => '/usr/share/elasticsearch/bin/plugin -DproxyPort=3128 -DproxyHost=my.proxy.com -install mobz/elasticsearch-head/1.0.0', :creates => '/usr/share/elasticsearch/plugins/head', :notify => 'Elasticsearch::Service[es-01]') }
    it { should contain_file('/usr/share/elasticsearch/plugins/head/.name').with(:content => 'mobz/elasticsearch-head/1.0.0') }
    it { should contain_exec('purge_plugin_head_old').with(:onlyif => "test -e /usr/share/elasticsearch/plugins/head && test \"$(cat /usr/share/elasticsearch/plugins/head/.name)\" != 'mobz/elasticsearch-head/1.0.0'", :command => '/usr/share/elasticsearch/bin/plugin --remove head', :before => 'Exec[install_plugin_mobz/elasticsearch-head/1.0.0]') }

  end

end
