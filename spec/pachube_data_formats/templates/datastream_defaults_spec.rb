require File.dirname(__FILE__) + '/../../spec_helper'

describe "default datastream templates" do
  before(:each) do
    @datastream = PachubeDataFormats::Datastream.new(datastream_as_(:hash))
  end

  describe "json" do
    it "should default to 1.0.0" do
      @datastream.generate_json("1.0.0").should == @datastream.as_json
    end

    it "should represent Pachube JSON 1.0.0 (used by API v2)" do
      json = @datastream.generate_json("1.0.0")
      json[:id].should == @datastream.id
      json[:version].should == "1.0.0"
      json[:at].should == @datastream.updated.iso8601(6)
      json[:current_value].should == @datastream.current_value
      json[:max_value].should == @datastream.max_value.to_s
      json[:min_value].should == @datastream.min_value.to_s
      json[:tags].should == @datastream.tags.split(',').map(&:strip).sort{|a,b| a.downcase <=> b.downcase}
      json[:unit].should == {
        :type => @datastream.unit_type,
        :symbol => @datastream.unit_symbol,
        :label => @datastream.unit_label
      }
    end

    it "should represent Pachube JSON 0.6-alpha (used by API v1)" do
      json = @datastream.generate_json("0.6-alpha")
      json[:id].should == @datastream.id
      json[:version].should == "0.6-alpha"
      json[:values].first[:recorded_at].should == @datastream.updated.iso8601
      json[:values].first[:value].should == @datastream.current_value
      json[:values].first[:max_value].should == @datastream.max_value.to_s
      json[:values].first[:min_value].should == @datastream.min_value.to_s
      json[:tags].should == @datastream.tags.split(',').map(&:strip).sort{|a,b| a.downcase <=> b.downcase}
      json[:unit].should == {
        :type => @datastream.unit_type,
        :symbol => @datastream.unit_symbol,
        :label => @datastream.unit_label
      }
    end

    it "should ignore tags if nil (1.0.0)" do
      @datastream.tags = nil
      json = @datastream.generate_json("1.0.0")
      json[:tags].should be_nil
    end

    it "should ignore tags if nil (0.6-alpha)" do
      @datastream.tags = nil
      json = @datastream.generate_json("0.6-alpha")
      json[:tags].should be_nil
    end

    it "should ignore tags if blank (1.0.0)" do
      @datastream.tags = []
      json = @datastream.generate_json("1.0.0")
      json[:tags].should be_nil
    end

    it "should ignore tags if blank (0.6-alpha)" do
      @datastream.tags = []
      json = @datastream.generate_json("0.6-alpha")
      json[:tags].should be_nil
    end

    it "should ignore nil unit elements (1.0.0)" do
      @datastream.unit_symbol = nil
      json = @datastream.generate_json("1.0.0")
      json[:unit][:symbol].should be_nil
    end

    it "should ignore nil unit elements (0.6-alpha)" do
      @datastream.unit_symbol = nil
      json = @datastream.generate_json("0.6-alpha")
      json[:unit][:symbol].should be_nil
    end

    it "should ignore unit if none of the elements are set (1.0.0)" do
      @datastream.unit_label = nil
      @datastream.unit_symbol = nil
      @datastream.unit_type = nil
      json = @datastream.generate_json("1.0.0")
      json[:unit].should be_nil
    end

    it "should ignore unit if none of the elements are set (0.6-alpha)" do
      @datastream.unit_label = nil
      @datastream.unit_symbol = nil
      @datastream.unit_type = nil
      json = @datastream.generate_json("0.6-alpha")
      json[:unit].should be_nil
    end

    it "should ignore unit if all the elements are blank (1.0.0)" do
      @datastream.unit_label = ''
      @datastream.unit_symbol = ''
      @datastream.unit_type = ''
      json = @datastream.generate_json("1.0.0")
      json[:unit].should be_nil
    end

    it "should ignore unit if all the elements are blank (0.6-alpha)" do
      @datastream.unit_label = ''
      @datastream.unit_symbol = ''
      @datastream.unit_type = ''
      json = @datastream.generate_json("0.6-alpha")
      json[:unit].should be_nil
    end
  end
end

