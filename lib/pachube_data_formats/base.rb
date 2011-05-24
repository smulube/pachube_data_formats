require 'pachube_data_formats/base/instance_methods'

module PachubeDataFormats
  # Provide an interface for your model objects by extending this module:
  # extend PachubeDataFormats::Base
  #
  # This provides the following configuration class method:
  # is_pachube_data_format:
  #   - specifies that this model represents all or part of a Pachube feed
  module Base

      # Provides methods for converting between the different Pachube API data formats
      # An example for a model representing a Pachube feed:
      #
      #   is_pachube_data_format :feed
      #
      # A datastream
      #
      #   is_pachube_data_format :datastream
      #
      # To specify custom field mappings or map methods onto a field
      #
      #   is_pachube_data_format :feed, {:title => :my_custom_instance_method, :status => :determine_feed_state}
      #
      def is_pachube_data_format(klass, options = {})
        @options = options
        case klass
        when :feed
          @pachube_data_format_class = PachubeDataFormats::Feed
        when :datastream
          @pachube_data_format_class = PachubeDataFormats::Datastream
        when :datapoint
          @pachube_data_format_class = PachubeDataFormats::Datapoint
        else
          @pachube_data_format_class = nil
        end

        class << self
          def pachube_data_format_mappings
            @options
          end

          def pachube_data_format_class
            @pachube_data_format_class
          end
        end

        send :include, PachubeDataFormats::Base::InstanceMethods
      end
  end
end

