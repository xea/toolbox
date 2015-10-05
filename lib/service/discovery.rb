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

=begin
        @watch_thread = Thread.new do 
            stop = false

            while !stop do
                stop = stop_requested?

                begin
                    scan_packages
                rescue => e
                    p e.backtrace.join("\n")
                    @logger.error "Error caught during package discovery #{e.message}"
                end

                i = @config['sleep_interval'] || 5
                sleep i
            end
        end
=end
    end

    def stop
        @scanner.cancel
#        @watch_queue << :stop
#        @watch_thread.join unless @watch_thread.nil?
    end

    def stop_requested?
        if @watch_queue.length > 0
            event = @watch_queue.pop

            case event
            when :stop
                true
            end
        end
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
            puts "Removed packages: #{removed_entries}"
        end
    end

    def scan_package(package_name)
        package_descriptor = "#{@watch_dir}/#{package_name}/package.yaml"
        main_file = "#{@watch_dir}/#{package_name}/#{package_name}.rb"

        if File.exist? package_descriptor
            @logger.debug "Found package #{package_name}"
            descriptor = Psych.load_file package_descriptor

            load main_file
            load_package package_name, descriptor
        else 
            puts "not found"
        end
    end

    def load_package(internal_id, package_descriptor)
        pkg_hash = Digest::SHA256.hexdigest(package_descriptor.to_s)

        candidates = @package_db[:installed].values.find_all { |entry| entry[:hash] == pkg_hash }

        if candidates.empty?
            entry = package_descriptor
            @package_db[:installed][internal_id] = entry

            (entry['services'] || []).each do |pkg_service_id, pkg_service|
                begin
                    service_class = Kernel.const_get(pkg_service['class'].to_sym)
                    service = service_class.new
                    @framework.register_service pkg_service, service
                rescue => e
                    @logger.error e.message
                end
            end
        end
    end
end
