# frozen_string_literal: true

module Flappi
  module VersionPlan
    #====== Flappi::Version plan DSL follows ======

    # Define an acceptable version
    # An optional block can define flavours for that version
    def version(version_text)
      @version_flavours = []
      yield if block_given?
      (@available_versions ||= []) << make_version_def(version_text, @version_flavours)

      @version_flavours = nil
    end

    # define a flavour 'name'
    # If inside a version's block, defines flavours for the version, otherwise defines global flavours
    def flavour(name)
      flavour = name

      if @version_flavours.nil?
        (@available_versions || []).each do |v|
          v[:allowed_flavours] << flavour unless flavour.blank?
        end
      else
        @version_flavours << flavour unless flavour.blank?
      end
    end

    #====== end DSL ==========

    # Return the lowest version definition without a flavour
    # or with the lowest value in sort if all have flavours
    def minimum_version
      lowest_no_flavour = available_version_definitions.versions_array
                                                       .select { |v| v.flavour.nil? }
                                                       .min_by(&:to_s)
      return lowest_no_flavour unless lowest_no_flavour.nil?

      available_version_definitions.versions_array
                                   .min_by(&:to_s)
    end

    # Return all the available version definitions
    def available_version_definitions
      Flappi::Versions.new(@available_versions
          .map { |av| av[:allowed_flavours].map { |fl| Flappi::Version.new(av[:version], fl, self) } }
          .flatten
          .sort_by(&:to_s)
          .uniq(&:to_s))
    end

    # Given a version text, parse and return an Flappi::Version
    def parse_version(version_text)
      return nil unless version_text

      version_text_stripped = version_text.sub(/^[A-Za-z]*/, '')
      tagged_version_components = version_text_stripped.split(/(?=[.\-])/) || [] # positive lookahead regular expression retains separators on start
      version_components = tagged_version_components.map { |v| v.sub(/^[.\-]/, '') }

      version_array, flavour = if tagged_version_components.last.index('-')&.zero?
                                 [version_components[0...-1], version_components.last]
                               else
                                 [version_components, '']
                               end

      Flappi::Version.new(version_array, flavour, self)
    end

    # Given a semicolon separated list of (full) version texts,
    # parse and return an Flappi::Versions
    # The text 'default' in the list is substituted by the default_versions
    # Used to parse a list of allowed versions defined against an OAuth application
    def parse_versions(versions_text, default_versions = [], normalise_each = false)
      case default_versions
      when Flappi::Versions
        default_versions = default_versions.versions_array
      when String
        default_versions = parse_versions(default_versions).versions_array
      end

      versions_array = (versions_text || '').split(';').map(&:strip)
      complete_versions_array = versions_array.map do |version_text|
        if version_text == 'default'
          default_versions
        else
          [parse_version(version_text)]
        end
      end.flatten

      complete_versions_array = complete_versions_array.map(&:normalise) if normalise_each

      Flappi::Versions.new(complete_versions_array)
    end

    # Given a version rule (defined against an endpoint), parse this into an array of supported versions
    # (for an endpoint or field)
    # rules are of the form:
    # equals, eq: version_number (can omit trailing minors or flavours which will be wildcarded)
    # ne: version_number (as above)
    # after, gt: version_nunber
    # before, lt: version_number
    # gte, ge: version_nunber
    # lte, le: version_nunber
    def expand_version_rule(*version_rule_args)
      version_rules = Flappi::Utils::ArgUtils.paired_args(*version_rule_args)

      supported_versions = []
      version_rules.each do |version_rule|
        case version_rule[0].to_sym
        when :equals, :eq, :matches
          supported_versions += available_version_definitions.versions_array.select { |av| av == parse_version(version_rule[1]) }
        when :ne
          supported_versions += available_version_definitions.versions_array.reject { |av| av == parse_version(version_rule[1]) }
        when :after, :gt
          supported_versions += available_version_definitions.versions_array.select { |av| av > parse_version(version_rule[1]) }
        when :before, :lt
          supported_versions += available_version_definitions.versions_array.select { |av| av < parse_version(version_rule[1]) }
        when :gte, :ge
          supported_versions += available_version_definitions.versions_array.select { |av| av >= parse_version(version_rule[1]) }
        when :lte, :le
          supported_versions += available_version_definitions.versions_array.select { |av| av <= parse_version(version_rule[1]) }
        else
          raise "Rule type #{version_rule[0]} not supported yet, sorry..."
        end
      end

      Flappi::Versions.new(supported_versions.uniq(&:to_s))
    end

    def version_sig_size
      @version_sig_size ||= @available_versions.map { |v| v[:version].size }.max
    end

    private

    def make_version_def(id, flavours)
      parsed_version = parse_version(id)
      m = parsed_version.version_array

      flavour_names = flavours
      flavour_names << parsed_version.flavour if parsed_version.flavour

      {
        version: m,
        allowed_flavours: flavour_names.sort.uniq
      }
    end
  end
end
