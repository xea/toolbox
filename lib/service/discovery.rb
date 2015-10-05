require_relative '../core/service'
require 'digest/sha2'
require 'thread'

class DiscoveryService < Service

    DEFAULT_WATCH_DIR = "packages"

    # Check packages every 5 seconds by default
    DEFAULT_SCAN_INTERVAL = 5  

    required_features :framework, :config
    optional_features :logger
    provided_features :discovery

    def init
        @package_db = { installed: {} }
    end

    def start
        watch_dir = @config['watch_dir'] || DEFAULT_WATCH_DIR
        @watch_dir = watch_dir
        @watch_queue = Queue.new

        interval = @config['sleep_interval'] || DEFAULT_SCAN_INTERVAL

        @scanner = every(interval) do
            begin
                scan_packages
            rescue => e
                p e.backtrace.join("\n")
                @logger.error "Error caught during package discovery #{e.message}"
            end
        end
    end

    def stop
        @scanner.cancel
#        @watch_queue << :stop
#        @watch_thread.join unless @watch_thread.nil?
    end

    def scan_packages
        scan_new_packages
        scan_removed_packages
        @logger.debug "Scan finished"
    end

    def scan_new_packages
        @logger.debug "Scanning new packages"

        if File.exist? @watch_dir and File.directory? @watch_dir
            (Dir.entries(@watch_dir) - [ ".", ".." ]).each do |entry|
                if File.directory? "#{@watch_dir}/#{@entry}"
                    scan_package entry
                end
            end
        end
    end

    def scan_removed_packages
        @logger.debug "Scanning old packages"

        if File.exist? @watch_dir and File.directory? @watch_dir
            removed_entries = @package_db[:installed].keys - Dir.entries(@watch_dir)
            @logger.debug "Removed packages: #{removed_entries}"
            # TODO actually remove packages
        end
    end

    def scan_package(package_name)
        # ignore locked packages
        return if File.exist? "#{@watch_dir}/#{package_name}/.lock"

        package_descriptor = "#{@watch_dir}/#{package_name}/package.yaml"

        if File.exist? package_descriptor
            @logger.debug "Found package #{package_name}"
            descriptor = Psych.load_file package_descriptor

            if package_valid? descriptor
                load_package package_name, descriptor
            else
                @logger.error "Not loading package #{package_name} because package is invalid"
            end
        else 
            puts "not found"
        end
    end

    def package_valid?(descriptor)
        # TODO package hash and digital signature checking
        true
    end

    def load_package(internal_id, package_descriptor)
        pkg_hash = Digest::SHA256.hexdigest(package_descriptor.to_s)

        candidates = @package_db[:installed].values.find_all { |entry| entry[:hash] == pkg_hash }

        if candidates.empty?
            main_file = "#{@watch_dir}/#{internal_id}/#{internal_id}.rb"
            load main_file

            entry = package_descriptor
            entry[:hash] = pkg_hash

            @package_db[:installed][internal_id] = entry

            (entry['services'] || {}).each do |pkg_service_id, pkg_service|
                begin
                    @logger.debug "Trying to register service #{pkg_service_id}"
                    service_class = Kernel.const_get(pkg_service['class'].to_sym)
                    service = service_class.new
                    @framework.register_service(pkg_service, service) 
                    @logger.info "Registered new package service #{pkg_service_id}"
                rescue => e
                    @logger.error e.message
                end
            end
        else
            @logger.debug "Package #{internal_id} is already installed. Skipping"
        end
    end
end
