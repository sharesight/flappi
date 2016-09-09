# these can be called in app/controllers/api/api_builder/api_doc_template.rb.erb
# to help formatting api docs

module Flappi
  module DocFormatHelpers

    def qname_from(parts)
      parts.map {|p| p.to_s}.join('.')
    end

    def strip_version(full_path)
      full_path.sub( /^\/api\/v\d+/, '')
    end

    def bracket_optional(param_item)
      optional = param_item[:optional]
      res = optional ? '[' : ''
      res << param_item[:name].to_s
      res << ']' if optional
      res
    end
  end
end
