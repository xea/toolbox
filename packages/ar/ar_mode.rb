require 'console/mode'
require 'console/table'
require 'ast'

include AST::Sexp

class ActiveRecordMode < BaseMode

    mode_id :activerecord
    access_from :home, "ar :namespace_id?", "Enter ActiveRecord browser"

    register_command(:exit_mode, "exit", "Exit ActiveRecord browser") { |intp| intp.modes.exit_mode }
    register_command(:list_model, "list :model_id", "List model instances")
    register_command(:use_namespace, "use :namespace_id", "Use the current namespace")

    register_command(:show_namespaces, "show namespaces", "Show registered namespaces") { |intp, ar, out|
        pt = PrinTable.new

        nss = ar.namespaces.map { |ns| ns.id.to_s }

        out.puts pt.print([ "NAMESPACE" ], [ nss ])
        out.puts "#{nss.length} entries"
    }

    register_command(:show_models, "show models", "Show registered models") { |intp, ar, out|
        pt = PrinTable.new

        # [ { id: id, class_name: Example } ]
        nss = @ns.nil? ? ar.namespaces : [ @ns ]

        entries = nss.map do |namespace|
            namespace.registered_models.map do |model|
                [ namespace.id, model[:id], model[:class_name].to_s ]
            end
        end

        out.puts pt.print([ "NAMESPACE", "MODEL ID", "CLASS" ], entries.flatten(1))
        out.puts "#{entries.length} entries"
    }

    def post_enter(out, ar, namespace_id)
        use_namespace out, ar, namespace_id unless namespace_id.nil?
    end

    def use_namespace(out, ar, namespace_id)
        @ns = ar.namespace(namespace_id.to_s.to_sym)

        out.puts "Currently used namespace: #{@ns.id}"
    end

    def dynamic_command(input)
        tokens = ARQLLexer.new.tokenize(input)[:tokens]
        ast, remaining_tokens = ARQLCommandParser.new.parse(tokens)

        begin
            command_list = ARQLProcessor.new.process ast

            action = -> {
                command_list.reduce(@ns) { |acc, msg| acc.send msg[0], *(msg[1]), &msg[2] }
            }

            Command.new(:dynamic, "", "", { dynamic: true }, &action)
        rescue e
            
        end
    end

    def list_model(out, ar, model_id)
        model = @ns.lookup(model_id.to_sym)

        if model.nil?
            out.puts "Couldn't find selected model"
        else
            pt = PrinTable.new

            out.puts pt.print(model[:class_name].new.filter_fields(:verbose), model[:class_name].all.map { |instance| instance.flatten_fields(:verbose) }, :db)
        end
    end
end

class ARQLProcessor < AST::Processor

    def initialize
        super
    end

    def on_select_expr(node)
        selexpr = process_all(node).flatten(1)

        selexpr
    end

    def on_model_expr(node)
        process_all(node).flatten(1)
    end

    def on_model_ids(node)
        process_all(node).map { |n|
            [
                [ :lookup, [ n.to_s.to_sym ] ],
                [ :[], [ :class_name  ] ]
            ]
        }.flatten(1)
    end

    def on_model_id(node)
        node.children.first
    end

    def on_model_clause(node)
        if node.children.empty?
            [[ :all, [] ]]
        else
            node.children.first.map { |key, value|
                [ :where, [ { key.to_sym => value } ] ]
            }
        end
    end

    def on_partition_expr(node)
        part = node.children.first
        result = []

        if part[:limit] >= 0
            result << [ :limit, [ part[:limit] ] ]
        end

        if part[:offset] > 0
            result << [ :offset, [ part[:offset] ] ]
        end

        result
    end

    def on_verbosity(node)
        [[ :map, [], lambda { |e|
            e.flatten_fields(node.children.first)
        } ]]
    end

end

class ARQLCommandParser

    def initialize
    end

    def parse(tokens)
        raise "Empty input" if tokens.nil? or tokens.length == 0

        if tokens.first.type == :word
            case tokens.first.children.first.to_s.downcase
            when "select"
                parse_select(tokens[1..-1])
            else
                raise "Unknown command: #{tokens.first.children.first.to_s}"
            end
        else
            raise "Commands must start with letters"
        end
    end

    def parse_select(tokens)
        model, remaining_tokens = parse_model_expression(tokens)
        partition, remaining_tokens = parse_partition_expression(remaining_tokens, true)
        verbosity, remaining_tokens = parse_verbosity_expression(remaining_tokens, true)

        [ s(:select_expr, model, partition, verbosity), remaining_tokens ]
    end

    # Used to parse expressions that can return a single model name or a list of model names
    # TODO currently this supports only singular model expressions
    # eg. (:model_expr, [:user, :domain])
    def parse_model_expression(tokens)
        raise "Missing model definition" if tokens.nil? or tokens.length == 0

        if tokens.length > 0 and tokens.first.type == :word
            model_ids = tokens.first.children.reduce(s(:model_ids)){ |acc, c| acc.append(s(:model_id, c)) }
            model_clause, remaining_tokens = parse_clause(tokens[1..-1], true)
            [ s(:model_expr, model_ids, model_clause), remaining_tokens ]
        else
            raise "Invalid model definition: #{tokens.first.to_s}"
        end
    end

    # It is used to parse clause expressions that introduce restrictions on model definitions
    # similarly to WHERE clauses in SQL
    def parse_clause(tokens, may_fail = false)
        raise "Missing clause definition" if !may_fail and (tokens.nil? or tokens.length == 0)

        if tokens.length > 0 and tokens.first.type == :brace_open
            if tokens.find { |token| token.type == :brace_close }.nil?
                raise "Unmatched closing brace"
            else
                clause_tokens = tokens[1..-1].take_while { |token| token.type != :brace_close }

                [ s(:model_clause, parse_key_value_pairs(clause_tokens)), tokens[(2 + clause_tokens.length)..-1] ]
            end
        elsif may_fail
            [ s(:model_clause), tokens ]
        else
            raise "Invalid clause syntax at: #{tokens.first.to_s}"
        end
    end

    def parse_key_value_pairs(tokens)
        tokens.reduce({ state: :key, current_key: nil, data: {}}) { |acc, x|
            case acc[:state]
            when :key
                case x.type
                when :word
                    # delimiter state means the : symbol between the key and the value
                    acc[:state] = :delimiter
                    acc[:current_key] = x.children.first
                when :number
                    # separator state means the , symbol between key-value pairs
                    acc[:state] = :separator
                    acc[:id] = x.children.first
                else
                    raise "Invalid key definition: #{x.children.first.to_s}"
                end
            when :separator
                if x.type == :symbol and x.children.first == ","
                    acc[:state] = :key
                    acc[:current_key] = nil
                else
                    raise "Invalid key separator: #{x.children.first.to_s}"
                end
            when :delimiter
                if x.type == :symbol and x.children.first == ":"
                    acc[:state] = :value
                else
                    raise "Invalid delimiter: #{x.children.first.to_s}"
                end
            when :value
                case x.type
                when :word
                    acc[:state] = :separator
                    acc[:data][acc[:current_key]] = x.children.first
                when :number
                    acc[:state] = :separator
                    acc[:data][acc[:current_key]] = x.children.first
                when :quoted
                    acc[:state] = :separator
                    acc[:data][acc[:current_key]] = x.children.first
                else
                    raise "Illegal value: #{x.children.first.to_s}"
                end
            end

            acc
        }[:data]
    end

    def parse_partition_expression(tokens, may_fail = false)
        raise "Missing partition definition" if !may_fail and (tokens.nil? or tokens.length == 0)

        s(:partition_expr, { limit: -1, offset: 0 })
    end

    def parse_verbosity_expression(tokens, may_fail = false)
        raise "Missing verbosity definition" if !may_fail and (tokens.nil? or tokens.length == 0)

        return [ s(:verbosity, :default), [] ] if tokens.nil? or tokens.length == 0

        case tokens.first.children.first
        when "+"
            [ s(:verbosity, :verbose), tokens[1..-1] ]
        when "!"
            [ s(:verbosity, :full), tokens[1..-1] ]
        else
            [ s(:verbosity, :default), tokens ]
        end
    end
end

# Active Record Query Language
class ARQLLexer
    def tokenize(input)
        input.to_s.strip.chars.reduce({ tokens: [], mode: :neutral }) { |acc, current|
            case acc[:mode]
            when :neutral
                read_neutral acc, current
            when :word
                read_word acc, current
            when :number
                read_number acc, current
            when :quoted
                read_quoted acc, current
            end
        }
    end

    def read_neutral(acc, current)
        case current
        when /[a-zA-Z]/
            { tokens: acc[:tokens] << s(:word, current), mode: :word }
        when /[0-9]/
            { tokens: acc[:tokens] << s(:number, current), mode: :number }
        when /[{]/
            { tokens: acc[:tokens] << s(:brace_open), mode: :neutral }
        when /[}]/
            { tokens: acc[:tokens] << s(:brace_close), mode: :neutral }
        when /'/
            { tokens: acc[:tokens] << s(:quoted, ""), mode: :quoted }
        when /[\s]/
            acc
        else
            { tokens: acc[:tokens] << s(:symbol, current), mode: :neutral }
        end
    end

    def read_word(acc, current)
        case current
        when /[\s]/
            { tokens: acc[:tokens], mode: :neutral }
        when /[{]/
            { tokens: acc[:tokens] << s(:brace_open), mode: :neutral }
        when /[}]/
            { tokens: acc[:tokens] << s(:brace_close), mode: :neutral }
        when /[a-zA-Z0-9_-]/
            { tokens: acc[:tokens][0...-1] << s(:word, (acc[:tokens][-1].children[0] + current)), mode: :word }
        else
            { tokens: acc[:tokens] << s(:symbol, current), mode: :neutral }
        end
    end

    def read_number(acc, current)
        case current
        when /[0-9]/
            { tokens: acc[:tokens][0...-1] << s(:number, acc[:tokens][-1].children[0] + current), mode: :number }
        when /[{]/
            { tokens: acc[:tokens] << s(:brace_open), mode: :neutral }
        when /[}]/
            { tokens: acc[:tokens] << s(:brace_close), mode: :neutral }
        when /[\s]/
            { tokens: acc[:tokens], mode: :neutral }
        else
            read_neutral({ tokens: acc[:tokens], mode: :neutral }, current)
        end
    end

    def read_quoted(acc, current)
        case current
        when /'/
            { tokens: acc[:tokens], mode: :neutral }
        else
            { tokens: acc[:tokens][0...-1] << s(:quoted, acc[:tokens][-1].children[0] + current), mode: :quoted }
        end
    end
end

class Object
    def map(&func)
        func.call self
    end
end
