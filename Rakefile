# frozen_string_literal: true

require 'confidante'
require 'rake_docker'
require 'rake_ssh'
require 'rake_terraform'
require 'rubocop/rake_task'

configuration = Confidante.configuration

RakeTerraform.define_installation_tasks(
  path: File.join(Dir.pwd, 'vendor', 'terraform'),
  version: '1.1.7'
)

RuboCop::RakeTask.new

namespace :build do
  namespace :code do
    desc 'Run all checks on the build code'
    task check: [:rubocop]

    desc 'Attempt to automatically fix issues with the build code'
    task fix: [:'rubocop:autocorrect_all']
  end
end

namespace :bootstrap do
  RakeTerraform.define_command_tasks(
    configuration_name: 'bootstrap',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'bootstrap'))

    t.source_directory = 'infra/bootstrap'
    t.work_directory = 'build'

    t.state_file =
      File.join(
        Dir.pwd,
        "state/bootstrap/#{args.deployment_identifier}.tfstate"
      )
    t.vars = configuration.vars
  end
end

namespace :domain do
  RakeTerraform.define_command_tasks(
    configuration_name: 'domain',
    argument_names: %i[deployment_identifier domain_name]
  ) do |t, args|
    configuration = configuration
                    .for_overrides(domain_name: args.domain_name)
                    .for_scope(
                      { deployment_identifier: args.deployment_identifier }
                        .merge(role: 'domain')
                    )

    t.source_directory = 'infra/domain'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end
end

namespace :certificate do
  RakeTerraform.define_command_tasks(
    configuration_name: 'certificate',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'certificate'))

    t.source_directory = 'infra/certificate'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end
end

namespace :network do
  RakeTerraform.define_command_tasks(
    configuration_name: 'network',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'network'))

    t.source_directory = 'infra/network'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end
end

namespace :cluster do
  RakeTerraform.define_command_tasks(
    configuration_name: 'cluster',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'cluster'))

    t.source_directory = 'infra/cluster'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end

  RakeSSH.define_key_tasks(
    namespace: :key,
    path: 'config/secrets/cluster/',
    comment: 'maintainers@infrablocks.io'
  )
end

namespace :registry do
  RakeTerraform.define_command_tasks(
    configuration_name: 'registry',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'registry'))

    t.source_directory = 'infra/registry'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end
end

namespace :prometheus do
  RakeTerraform.define_command_tasks(
    configuration_name: 'prometheus',
    argument_names: %i[deployment_identifier instance]
  ) do |t, args|
    configuration = configuration
                    .for_overrides(
                      instance: args.instance
                    )
                    .for_scope(
                      { deployment_identifier: args.deployment_identifier }
                        .merge(role: 'prometheus')
                    )

    t.source_directory = 'infra/prometheus'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end

  desc 'Provision all of the prometheus instances'
  task :provision_all, [:deployment_identifier] do |_, args|
    %w[1 2 3].each do |instance|
      Rake::Task['prometheus:provision'].invoke(*args.to_a.append(instance))
      Rake::Task['prometheus:provision'].reenable
    end
  end

  desc 'Destroy all of the prometheus instances'
  task :destroy_all, [:deployment_identifier] do |_, args|
    %w[3 2 1].each do |instance|
      Rake::Task['prometheus:destroy'].invoke(*args.to_a.append(instance))
      Rake::Task['prometheus:destroy'].reenable
    end
  end
end

namespace :thanos do
  RakeTerraform.define_command_tasks(
    configuration_name: 'thanos',
    argument_names: [:deployment_identifier]
  ) do |t, args|
    configuration = configuration
                    .for_scope(args.to_h.merge(role: 'thanos'))

    t.source_directory = 'infra/thanos'
    t.work_directory = 'build'

    t.backend_config = configuration.backend_config
    t.vars = configuration.vars
  end
end

namespace :deployment do
  desc 'Provision the whole end-to-end example.'
  task :provision, [:deployment_identifier, :domain_name] do |_, args|
    deployment_identifier = args.deployment_identifier
    domain_name = args.domain_name

    Rake::Task['bootstrap:provision'].invoke(deployment_identifier)
    Rake::Task['domain:provision'].invoke(deployment_identifier, domain_name)
    Rake::Task['certificate:provision'].invoke(deployment_identifier)
    Rake::Task['network:provision'].invoke(deployment_identifier)
    Rake::Task['cluster:provision'].invoke(deployment_identifier)
    Rake::Task['registry:provision'].invoke(deployment_identifier)
    Rake::Task['prometheus:provision_all'].invoke(deployment_identifier)
    Rake::Task['thanos:provision'].invoke(deployment_identifier)
  end

  desc 'Destroy the whole end-to-end example.'
  task :destroy, [:deployment_identifier, :domain_name] do |_, args|
    deployment_identifier = args.deployment_identifier
    domain_name = args.domain_name

    Rake::Task['thanos:destroy'].invoke(deployment_identifier)
    Rake::Task['prometheus:destroy_all'].invoke(deployment_identifier)
    Rake::Task['registry:destroy'].invoke(deployment_identifier)
    Rake::Task['cluster:destroy'].invoke(deployment_identifier)
    Rake::Task['network:destroy'].invoke(deployment_identifier)
    Rake::Task['certificate:destroy'].invoke(deployment_identifier)
    Rake::Task['domain:destroy'].invoke(deployment_identifier, domain_name)
    Rake::Task['bootstrap:destroy'].invoke(deployment_identifier)
  end
end
