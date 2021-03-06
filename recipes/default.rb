#
# Cookbook:: chef-elk 
# Recipe:: default
#
# Copyright:: 2019, hankehly, MIT License.

include_recipe 'apt'
include_recipe 'build-essential'
include_recipe 'nodejs'

package 'jq'

locale 'set locale' do
  lang 'en_US.utf8'
  lc_all 'en_US.utf8'
end

include_recipe 'chef-elk::pyenv'
include_recipe 'chef-elk::elk'
include_recipe 'chef-elk::gcloud-sdk'

