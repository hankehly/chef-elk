#
# Cookbook:: chef-elk 
# Recipe:: elk
#
# Copyright:: 2019, hankehly, MIT License.

include_recipe 'rsyslog::client'
include_recipe 'java'
include_recipe 'elasticsearch'
include_recipe 'td-agent'

aws_access_key_id = data_bag_item('aws', 'credentials')['aws_access_key_id']
aws_secret_access_key = data_bag_item('aws', 'credentials')['aws_secret_access_key']

td_agent_source 'in_syslog' do
  type 'syslog'
  tag 'system'
  parameters({port: node['rsyslog']['port'], bind: '0.0.0.0', protocol_type: 'tcp'})
end

td_agent_match 'chef-elk.out_copy' do
  type 'copy'
  tag 'chef-elk.**'

  parameters(
      store: [{
                  '@type' : 'elasticsearch',
                  host: 'localhost',
                  port: 9200,
                  logstash_format: true,
                  logstash_prefix: '${tag}',
                  buffer: [{
                               '@type' : 'file',
                               path: '/var/log/td-agent/buffer/chef-elk/elasticsearch',
                               timekey_use_utc: true
                           }]
              }, {
                  '@type' : 's3',
                  aws_key_id: aws_access_key_id,
                  aws_sec_key: aws_secret_access_key,
                  s3_bucket: 'octo-waffle',
                  s3_region: 'us-east-1',
                  path: 'chef-elk/log/',
                  buffer: [{
                               '@type' : 'file',
                               path: '/var/log/td-agent/buffer/chef-elk/s3',
                               timekey_use_utc: true
                           }]
              }]
  )

  action :create
end

td_agent_match 'syslog.out_elasticsearch' do
  type 'elasticsearch'
  tag '{chef-elk.**,system.**,unattended-upgrades}'
  parameters({
                 host: 'localhost',
                 port: 9200,
                 logstash_format: true,
                 logstash_prefix: '${tag}'
             })
  action :create
end

include_recipe 'kibana::kibana6'

