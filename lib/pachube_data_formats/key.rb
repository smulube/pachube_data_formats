module PachubeDataFormats
  class Key
    ALLOWED_KEYS = %w(id key label user expires_at permissions private_access)
    ALLOWED_KEYS.each { |key| attr_accessor(key.to_sym) }
    NESTED_KEYS = %w(permissions)

    include PachubeDataFormats::Templates::JSON::KeyDefaults
    #include PachubeDataFormats::Templates::XML::KeyDefaults
    include PachubeDataFormats::Parsers::JSON::KeyDefaults
    include PachubeDataFormats::Parsers::XML::KeyDefaults

    include Validations

    def valid?
      pass = true
      [:label, :permissions, :user].each do |attr|
        if self.send(attr).blank?
          errors[attr] = ["can't be blank"]
          pass = false
        end
      end

      permissions.each do |permission|
        unless permission.valid?
          permission.errors.each do |attr, permission_errors|
            errors["permissions_#{attr}".to_sym] = ([*errors["permissions_#{attr}".to_sym]] | [*permission_errors]).compact
          end
          pass = false
        end
      end

      return pass
    end

    # Build an instance from either a Hash, a JSON string, or an XML document
    def initialize(input = {})
      if input.is_a?(Hash)
        self.attributes = input
      elsif input.strip[0...1].to_s == "{"
        self.attributes = from_json(input)
      else
        self.attributes = from_xml(input)
      end
    end

    def attributes
      h = {}
      ALLOWED_KEYS.each do |key|
        value = self.send(key)
        h[key] = value unless value.nil?
      end
      return h
    end

    def attributes=(input)
      return if input.nil?
      input.deep_stringify_keys!
      ALLOWED_KEYS.each { |key| self.send("#{key}=", input[key]) }
      NESTED_KEYS.each { |key|
        self.send("#{key}=".to_sym, input["#{key}_attributes"]) unless input["#{key}_attributes"].nil?
      }
      return attributes
    end

    def as_json(options = nil)
      generate_json(options || {})
    end

    def to_json(options = nil)
      ::JSON.generate as_json(options)
    end

    def permissions
      return [] if @permissions.nil?
      @permissions
    end

    def permissions=(array)
      return unless array.is_a?(Array)
      @permissions = []
      array.each do |permission|
        if permission.is_a?(Permission)
          @permissions << permission
        elsif permission.is_a?(Hash)
          @permissions << Permission.new(permission)
        end
      end
    end

    def private_access?
      @private_access || false
    end

    def id
      @id.nil? ? @key : @id
    end
  end
end
