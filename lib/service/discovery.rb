require_relative '../core/service'
require 'digest/sha2'
require 'thread'

class DiscoveryService < Service

    DEFAULT_WATCH_DIR = "packages"

    required_features :framework, :config
    optional_features :logger
    provided_features :discovery

    def init
        @package_db = { installed: [] }
    end

    def start
        watch_dir = @config['watch_dir'] || DEFAULT_WATCH_DIR
        @watch_dir = watch_dir
        @watch_queue = Queue.new

        @watch_thread = Thread.new do 
            stop = false

            while !stop do
                stop = stop_requested?

                scan_packages

                i = @config['sleep_interval'] || 5
                sleep i
            end
        end
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
    end

    def scan_new_packages
        if File.exist? @watch_dir and File.directory? @watch_dir
            Dir.foreach @watch_dir do |entry|
                if File.directory? entry
                    scan_package entry
                end
            end
        end
    end

    def scan_removed_packages
        if File.exist? @watch_dir and File.directory? @watch_dir
            removed_entries = @package_db[:installed].keys - Dir.entries(@watch_dir)
        end
    end

    def scan_package(package_name)
        package_descriptor = "#{@watch_dir}/#{package_name}/package.yaml"

        if File.exist? package_descriptor
            descriptor = Psych.load_file package_descriptor

            load_package package_name, descriptor
        end
    end

    def load_package(internal_id, package_descriptor)
        pkg_hash = Digest::SHA256.hexdigest(package_descriptor.to_s)

        candidates = @package_db[:installed].find_all { |entry| entry[:hash] == pkg_hash }

        if candidates.empty?
            entry = package_descriptor
            @package_db[internal_id] = entry
        end
    end

    def stop
        @watch_queue << :stop
        @watch_thread.join unless @watch_thread.nil?
    end
end
