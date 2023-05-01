module DecorateSerializer
  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      def serializable_hash(_options = nil)
        self.class.attr_lists.index_with { |n|
          public_send(n)
        }
      end
    end
  end

  module ClassMethods
    def attr(*args)
      @_args = args
    end

    def attr_lists
      @_args || []
    end
  end
end
