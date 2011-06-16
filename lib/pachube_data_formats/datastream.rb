module PachubeDataFormats
  class Datastream
    ALLOWED_KEYS = %w(feed_id id feed_creator current_value datapoints max_value min_value tags unit_label unit_symbol unit_type updated)
    ALLOWED_KEYS.each { |key| attr_accessor(key.to_sym) }
    VALID_UNIT_TYPES = %w(basicSI derivedSI conversionBasedUnits derivedUnits contextDependentUnits)

    include PachubeDataFormats::Templates::JSON::DatastreamDefaults
    include PachubeDataFormats::Templates::XML::DatastreamDefaults
    include PachubeDataFormats::Templates::CSV::DatastreamDefaults
    include PachubeDataFormats::Parsers::JSON::DatastreamDefaults
    include PachubeDataFormats::Parsers::XML::DatastreamDefaults

    include Validations
    # validate :before, :join_tags

    # validates_presence_of :id
    # validates_length_of :current_value, :maximum => 255
    # validates_length_of :tags, :maximum => 255
    # validates_inclusion_of :unit_type, :in => VALID_UNIT_TYPES,
    #                                    :allow_nil => true,
    #                                    :message => "is not a valid unit_type (pick one from #{VALID_UNIT_TYPES} or leave blank)"
    # validates_format_of :id, :with => /\A[\w\-\+\.]+\Z/
    #

    def valid?
      pass = true
      [:id].each do |attr|
        if self.send(attr).blank?
          errors[attr] = ["can't be blank"]
          pass = false
        end
      end
      if !unit_type.blank?
        if !VALID_UNIT_TYPES.include?(unit_type)
          errors[:unit_type] = ["is not a valid unit_type (pick one from #{VALID_UNIT_TYPES.join(', ')} or leave blank)"]
          pass = false
        end
      end
      if current_value && current_value.length > 255
        errors[:current_value] = ["is too long (maximum is 255 characters)"]
        pass = false
      end
      if tags
        join_tags
        if tags && tags.length > 255
          errors[:tags] = ["is too long (maximum is 255 characters)"]
          pass = false
        end
      end

      unless self.id =~ /\A[\w\-\+\.]+\Z/
        errors[:id] = ["is invalid"]
        pass = false
      end
      if self.id.blank?
        errors[:id] = ["can't be blank"]
        pass = false
      end

      unless self.feed_id.to_s =~ /\A\d*\Z/
        errors[:feed_id] = ["is invalid"]
        pass = false
      end

      return pass
    end

    def initialize(input = {})
      if input.is_a? Hash
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
      ALLOWED_KEYS.each { |key| self.send("#{key}=", input[key]) }
    end

    def datapoints
      @datapoints.nil? ? [] : @datapoints
    end

    def datapoints=(array)
      return unless array.is_a?(Array)
      @datapoints = []
      array.each do |datapoint|
        if datapoint.is_a?(Datapoint)
          @datapoints << datapoint
        elsif datapoint.is_a?(Hash)
          @datapoints << Datapoint.new(datapoint)
        end
      end
    end

    def as_json(options = {})
      options[:version] ||= "1.0.0"
      generate_json(options.delete(:version), options)
    end

    def to_json(options = {})
      ::JSON.generate as_json(options)
    end

    def to_xml(options = {})
      options[:version] ||= "0.5.1"
      generate_xml(options.delete(:version), options)
    end

    def to_csv(options = {})
      options[:version] ||= "2"
      generate_csv(options.delete(:version), options)
    end

    private

    def join_tags
      self.tags = tags.sort{|a,b| a.downcase <=> b.downcase}.join(',') if tags.is_a?(Array)
    end
  end
end

