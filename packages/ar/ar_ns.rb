
class ActiveRecordNameSpaceProxy

    def id
        @id
    end

    def initialize(id, ns)
        @id = id
        @ns = ns
    end

    def registered_models
        @ns.registered_models
    end

    def lookup(model_id)
        @ns.lookup(model_id)
    end
end

module ActiveRecordNameSpace

    def id
        ""
    end

    def registered_models
        # Example: [ { class_name: ExampleModel } ]
        []
    end

    def lookup(model_id)
        nil
    end
end

module ActiveRecordBaseProxy
    def core_fields
        [ :id ]
    end

    def essential_fields
        []
    end

    def basic_fields
        []
    end

    def verbose_fields
        []
    end

    def filter_fields(verbosity)
        case verbosity
        when :core
            core_fields
        when :essential
            core_fields + essential_fields
        when :basic
            core_fields + essential_fields + basic_fields
        when :verbose
            core_fields + essential_fields + basic_fields + verbose_fields
        else
            attributes.keys
        end
    end

    def flatten_fields(verbosity)
        filter_fields(verbosity).map { |attr| resolve_attribute(attr) }
    end

	def sql_switch(id, map, default)
		"CASE" + map.collect { |k, v|
			" WHEN #{id} = #{k.kind_of?(String) ? "'" + k.to_s + "'" : k}" +
			" THEN #{v.kind_of?(String)? "'" + v + "'" : v} " }
				.join(" ") + "ELSE #{default.kind_of?(String)? "'" + default + "'" : default} END"
	end

    def resolve_attribute(key)
        if respond_to? "format_#{key}".to_sym
            self.send "format_#{key}".to_sym
        else
            attributes[key.to_s]
        end
    end

    def reflookup(relation, rid, desc)
        rel = send relation

        if rel.nil?
            "0"
        elsif rel.kind_of? ActiveRecord::Base
            "#{rel.send desc} (#{rel.send rid})"
        end
    end
end
