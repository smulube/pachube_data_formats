module PachubeDataFormats
  module Validations
    attr_accessor :errors
    def errors
      @errors ||= {}
    end
  end
end

