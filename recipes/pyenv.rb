#
# Cookbook:: chef-elk
# Recipe:: pyenv
#
# Copyright:: 2019, hankehly, MIT License.

pyenv_system_install 'system'

pyenv_python node['chef-elk']['python_version']
pyenv_global node['chef-elk']['python_version']

pyenv_plugin 'virtualenv' do
  git_url 'https://github.com/pyenv/pyenv-virtualenv'
end

pyenv_pip 'awscli'

package 'python3.6-dev'
package 'libmysqlclient-dev'

