module PachubeDataFormats
  class Feed
    # The order of these keys is the order attributes are assigned in. (i.e. id should come before datastreams)
    ALLOWED_KEYS = %w(id creator owner_login datastreams description email feed icon location_disposition location_domain location_ele location_exposure location_lat location_lon location_name location_waypoints private status tags title updated created website auto_feed_url csv_version)
    ALLOWED_KEYS.each { |key| attr_accessor(key.to_sym) }

    include PachubeDataFormats::Templates::JSON::FeedDefaults
    include PachubeDataFormats::Templates::XML::FeedDefaults
    include PachubeDataFormats::Templates::CSV::FeedDefaults
    include PachubeDataFormats::Parsers::JSON::FeedDefaults
    include PachubeDataFormats::Parsers::XML::FeedDefaults
    include PachubeDataFormats::Parsers::CSV::FeedDefaults

    include Validations

    def valid?
      pass = true
      if title.blank?
        errors[:title] = ["can't be blank"]
        pass = false
      end

      duplicate_datastream_ids = datastreams.inject({}) {|h,v| h[v.id]=h[v.id].to_i+1; h}.reject{|k,v| v==1}.keys
      if duplicate_datastream_ids.any?
        errors[:datastreams] = ["can't have duplicate IDs: #{duplicate_datastream_ids.join(',')}"]
        pass = false
      end

      datastreams.each do |ds|
        unless ds.valid?
          ds.errors.each { |attr, ds_errors|
            errors["datastreams_#{attr}".to_sym] = ([*errors["datastreams_#{attr}".to_sym]] | [*ds_errors]).compact
          }
          pass = false
        end
      end

      return pass
    end

    def initialize(input = {}, csv_version = nil)
      if input.is_a?(Hash)
        self.attributes = input
      elsif input.strip[0...1].to_s == "{"
        self.attributes = from_json(input)
      elsif input.strip[0...5].to_s == "<?xml" || input.strip[0...5].to_s == "<eeml"
        self.attributes = from_xml(input)
      else
        self.attributes = from_csv(input, csv_version)
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

    def datastreams
      return [] if @datastreams.nil?
      @datastreams
    end

    def attributes=(input)
      return if input.nil?
      input.deep_stringify_keys!
      ALLOWED_KEYS.each { |key| self.send("#{key}=", input[key]) }
      return attributes
    end

    def datastreams=(array)
      return unless array.is_a?(Array)
      @datastreams = []
      array.each do |datastream|
        if datastream.is_a?(Datastream)
          @datastreams << datastream
        elsif datastream.is_a?(Hash)
          @datastreams << Datastream.new(datastream)
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

  end
end


