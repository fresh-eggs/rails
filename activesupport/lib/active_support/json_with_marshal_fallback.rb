module ActiveSupport
  class JsonWithMarshalFallback

    cattr_accessor :fallback_to_marshal_serialization, instance_accessor: false, default: true

    def self.dump(value)
      JSON.encode(value)
    end

    def self.load(value)
      JSON.decode(value)
    rescue ::JSON::ParserError
      if self.fallback_to_marshal_serialization
        Marshal.load(value)
      end
    end
  end
end
