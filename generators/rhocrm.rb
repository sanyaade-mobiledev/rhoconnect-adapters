require 'rubygems'
require 'rhosync'

#puts File.dirname('rhosync')

#require File.join('rhosync', '..','..','generators','rhosync')
require 'templater'

module Rhocrm
  extend Templater::Manifold
  extend Rhocrm
  
  desc <<-DESC
    Rhocrm generator
  DESC
  
  class BaseGenerator < Templater::Generator
    def class_name
      name.gsub('-', '_').camel_case
    end
    
    def underscore_name
      Rhosync.under_score(name)
    end
    
    def crm_backend
      crm
    end

    def gem_version
      VERSION
    end 
    
    alias_method :module_name, :class_name
  end
  
  class SourceGenerator < BaseGenerator
    def self.source_root
      File.join(File.dirname(__FILE__), 'templates', 'source')
    end

    desc <<-DESC
      Generates a new source adapter based on CRM object.
      
      Required:
        <name>        - source name(i.e. Account)
        <CRM base>    - name of the CRM backend
    DESC

    first_argument :name, :required => true, :desc => "source name"
    second_argument :crm, :required => true, :desc => "CRM backend name"

    template :source do |template|
      template.source = 'source_adapter.rb'
      template.destination = "sources/#{underscore_name}.rb"
      settings_file = File.join(@destination_root,'settings','settings.yml')
      settings = YAML.load_file(settings_file)
      settings[:sources] ||= {}
      settings[:sources][class_name] = {:poll_interval => 300}
      File.open(settings_file, 'w' ) do |file|
        file.write "#Sources" + {:sources => settings[:sources]}.to_yaml[3..-1]
        envs = {}
        [:development,:test,:production].each do |env|
          envs[env] = settings[env]
        end
        file.write envs.to_yaml[3..-1]
      end
    end
    
#    template :source_spec do |template|
#      template.source = 'source_spec.rb'
#      template.destination = "spec/sources/#{underscore_name}_spec.rb"
#    end
#  end
  
#  add :app, AppGenerator
  add :source, SourceGenerator
end