# Format API documentation into the 'ApiDoc' format
#
# Pass this to Flappi::Documenter.document to select this formatter (see rake task api.rake)
#

module Flappi
  module ApiDocFormatter

    # Given documentation output in 'doc' format and write to 'filename'
    def self.format(doc, filename)
      return if doc.nil?

      template_path = "#{Pathname.new(method(:format).source_location.first).dirname}/api_doc_template.rb.erb"
      template = ERB.new File.read(template_path), nil, "%"
      api_doc_txt = template.result(doc.instance_eval {binding})

      File.write(filename, api_doc_txt)
    end

  end
end
