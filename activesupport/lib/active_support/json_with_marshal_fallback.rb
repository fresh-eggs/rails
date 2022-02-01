module ActiveSupport
  class JsonWithMarshalFallback
    MARSHAL_SIGNATURE = "\x04\x08"

    cattr_accessor :fallback_to_marshal_deserialization, instance_accessor: false, default: true
    cattr_accessor :use_marshal_serialization, instance_accessor: false, default: true

    def self.dump(value)
      if self.use_marshal_serialization
        Marshal.dump(value)
      else
        JSON.encode(value)
      end
    end

    def self.load(value)
      raise ::JSON::ParserError if value.start_with?(MARSHAL_SIGNATURE)
      JSON.decode(value)
    rescue ::JSON::ParserError
      if self.fallback_to_marshal_deserialization
        Marshal.load(value)
      else
        raise
      end
    end
  end
end
