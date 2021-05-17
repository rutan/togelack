require 'mongoid'

# @see https://github.com/mongodb/mongoid/pull/4944
module Mongoid
  module Errors
    class MongoidError < StandardError
      def translate(key, options)
        ::I18n.translate("#{BASE_KEY}.#{key}", **options)
      end
    end
  end
end
