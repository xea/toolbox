require_relative '../core/service'
require 'digest/sha2'
require 'thread'

class DiscoveryService < Service

    DEFAULT_WATCH_DIR = "packages"

    # Check packages every 5 seconds by default
    DEFAULT_SCAN_INTERVAL = 5

    CONFIG_WATCH_DIR = "watch_dir"
    CONFIG_SCAN_INTERVAL = "scan_interval"

    required_features :framework, :config
    optional_features :logger
    provided_features :discovery

    def init
        @package_db = { installed: {} }
    end

    def start
        watch_dir = @config[CONFIG_WATCH_DIR] || DEFAULT_WATCH_DIR
        @watch_dir = watch_dir
        @watch_queue = Queue.new

        interval = @config[CONFIG_SCAN_INTERVAL] || DEFAULT_SCAN_INTERVAL

        after(0.1) do
            do_scan
        end

        @scanner = every(interval) do
            do_scan
        end
    end

    def do_scan
        begin
            scan_packages
        rescue => e
            p e.backtrace.join("\n")
            @logger.error "Error caught during package discovery #{e.message}"
        end
    end

    def stop
        @scanner.cancel
    end

    def scan_packages
        new_pkgs = scan_new_packages
        old_pkgs = scan_removed_packages

        def step_install(pkgs)
            clear_new_pkgs = pkgs.find_all { |pkg| pkg[:descriptor]['dependencies'].nil? or pkg[:descriptor]['dependencies'].empty? }
            dep_new_pkgs = pkgs - clear_new_pkgs

            # First, load packages without dependencies
            clear_new_pkgs.each do |pkg|
                load_package pkg[:id], pkg[:descriptor]
            end

            # Second, try loading naively
            unresolved_pkgs = dep_new_pkgs.find_all do |pkg|
                load_package pkg[:id], pkg[:descriptor]
            end

            # If there are still unresolved packages, we'll try loading them again
            # in the next iteration.

            # TODO building a dependency tree would be great
        end

        step_install(new_pkgs)

        @logger.debug "Scan finished"
    end

    def scan_new_packages
        @logger.debug "Scanning new packages in directory #{@watch_dir}"

        if File.exist? @watch_dir and File.directory? @watch_dir
            (Dir.entries(@watch_dir) - [ ".", ".." ]).map do |entry|
                if File.directory? "#{@watch_dir}/#{@entry}"
                    scan_package entry
                else
                    nil
                end
            end
        else
            []
        end
    end

    def scan_removed_packages
        @logger.debug "Scanning old packages"

        if File.exist? @watch_dir and File.directory? @watch_dir
            removed_entries = @package_db[:installed].keys - Dir.entries(@watch_dir)
            @logger.debug "Removed packages: #{removed_entries}"
            # TODO actually remove packages
            removed_entries
        else
            []
        end
    end

    def scan_package(package_name)
        # ignore locked packages
        @logger.debug "Scanning #{package_name}"
        return if File.exist? "#{@watch_dir}/#{package_name}/.lock"

        package_descriptor = "#{@watch_dir}/#{package_name}/package.yaml"

        if File.exist? package_descriptor
            @logger.debug "Found package #{package_name}"
            descriptor = Psych.load_file package_descriptor

            if package_valid? descriptor
                { id: package_name, descriptor: descriptor }
                #load_package package_name, descriptor
            else
                @logger.error "Not loading package #{package_name} because package is invalid"
                nil
            end
        else
            puts "No descriptor found"
            nil
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
            # try resolving dependencies
            unless package_descriptor['dependencies'].nil?
                unresolved_deps = package_descriptor['dependencies'].find_all { |dep| @package_db[:installed].keys.member? dep }

                unless unresolved_deps.empty?
                    @logger.error("Can't resolve dependencies: #{unresolved_deps} for package #{internal_id}")
                    return false
                end
            end

            main_file = "#{@watch_dir}/#{internal_id}/#{internal_id}.rb"
            load main_file

            entry = package_descriptor
            entry[:hash] = pkg_hash

            @package_db[:installed][internal_id] = entry

            @framework.begin_tx do |tx|
                (entry['services'] || {}).each do |pkg_service_id, pkg_service|
                    begin
                        @logger.debug "Trying to register service #{pkg_service_id}"
                        service_class = Kernel.const_get(pkg_service['class'].to_sym)
                        tx.register_service(pkg_service_id.to_sym, service_class)
                        @logger.info "Registered new package service #{pkg_service_id}"

                    rescue => e
                        @logger.error e.message
                    end
                end

                tx.commit_stage if tx.dirty?
                tx.process_service_queue
                tx.commit
            end

            true
        else
            @logger.debug "Package #{internal_id} is already installed. Skipping"

            false
        end
    end
end
