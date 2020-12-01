# frozen_string_literal: true

require 'english'
require 'rubocop'

ADDED_OR_MODIFIED = /A|AM|^M/.freeze
FILE_EXTENSIONS_TO_CONSIDER = ['.rb', '.rake'].freeze

changed_files = `git status --porcelain`.split(/\n/)
                                        .select { |file_name_with_status| file_name_with_status =~ ADDED_OR_MODIFIED }
                                        .map { |file_name_with_status| file_name_with_status.split(' ')[1] }
                                        .select { |file_name| FILE_EXTENSIONS_TO_CONSIDER.include?(File.extname(file_name)) || file_name == 'Gemfile' }
                                        .join(' ')

system("bundle exec rubocop #{changed_files}") unless changed_files.empty?

exit $CHILD_STATUS.to_s[-1].to_i
