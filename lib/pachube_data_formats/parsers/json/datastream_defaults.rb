module PachubeDataFormats
  module Parsers
    module JSON
      module DatastreamDefaults
        def from_json(json)
          hash = ::JSON.parse(json)
          case hash['version']
          when '1.0.0'
            transform_1_0_0(hash)
          when '0.6-alpha'
            transform_0_6_alpha(hash)
          end
        end

        private

        # As produced by http://www.pachube.com/api/v2/FEED_ID/datastreams/DATASTREAM_ID.json
        def transform_1_0_0(hash)
          hash["id"] = hash.delete("id")
          hash["updated"] = hash.delete("at")
          hash["current_value"] = hash.delete("current_value")
          hash["tags"] = hash["tags"].join(',') if hash["tags"]
          if unit = hash.delete('unit')
            hash['unit_type'] = unit['type']
            hash['unit_symbol'] = unit['symbol']
            hash['unit_label'] = unit['label']
          end
          hash
        end

        # As produced by http://www.pachube.com/api/v1/FEED_ID/datastreams/DATASTREAM_ID.json
        def transform_0_6_alpha(hash)
          hash["id"] = hash.delete("id")
          hash["updated"] = hash["values"].first.delete("recorded_at")
          hash["current_value"] = hash["values"].first.delete("value")
          hash["max_value"] = hash["values"].first.delete("max_value")
          hash["min_value"] = hash["values"].first.delete("min_value")
          hash["tags"] = hash["tags"].join(',') if hash["tags"]
          if unit = hash.delete('unit')
            hash['unit_type'] = unit['type']
            hash['unit_symbol'] = unit['symbol']
            hash['unit_label'] = unit['label']
          end
          hash
        end

      end
    end
  end
end

