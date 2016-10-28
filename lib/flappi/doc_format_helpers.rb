# frozen_string_literal: true
# these can be called in app/controllers/api/api_builder/api_doc_template.rb.erb
# to help formatting api docs

module Flappi
  module DocFormatHelpers
    def qname_from(parts)
      parts.map(&:to_s).join('.')
    end

    def strip_version(full_path)
      full_path.sub(/^\/api\/v\d+/, '')
    end

    def bracket_optional(param_item)
      optional = param_item[:optional]
      res = (optional ? '[' : '').dup
      res << param_item[:name].to_s

      if param_item[:default_doc]
        res << "=#{param_item[:default_doc]}"
      else
        res << "=#{param_item[:default]}" unless param_item[:default].nil?
      end

      res << ']' if optional
      res
    end
  end
end
