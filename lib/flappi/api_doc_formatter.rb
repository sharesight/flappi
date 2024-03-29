# frozen_string_literal: true

# Format API documentation into the 'ApiDoc' format
#
# Pass this to Flappi::Documenter.document to select this formatter (see rake task api.rake)
#
require 'pathname'
require 'erb'

module Flappi
  module ApiDocFormatter
    # Given documentation output in 'doc' format and write to 'filename'
    def self.format(doc, filename)
      api_doc_txt = ::Flappi::ApiDocFormatter.format_to_text(doc)
      return if api_doc_txt.nil?

      File.write(filename, api_doc_txt)
    end

    def self.format_to_text(doc)
      return nil if doc.nil?

      template_path = "#{Pathname.new(method(:format).source_location.first).dirname}/api_doc_template.rb.erb"
      # NOTE: this will warn but will fail if fixed as suggested in Ruby docs
      template = ERB.new(File.read(template_path), trim_mode: '-')
      template.result(doc.instance_eval { binding })
    end
  end
end
