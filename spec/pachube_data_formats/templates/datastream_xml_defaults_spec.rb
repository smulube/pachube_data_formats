require File.dirname(__FILE__) + '/../../spec_helper'

describe "default datastream xml templates" do
  before(:each) do
    @datastream = PachubeDataFormats::Datastream.new(datastream_as_(:hash))
  end

  context "0.5.1 (used by API V2)" do
    it "should be the default" do
      @datastream.generate_xml("0.5.1").should == @datastream.to_xml
    end

    it "should represent Pachube EEML" do
      xml = Nokogiri.parse(@datastream.generate_xml("0.5.1"))
      xml.should describe_eeml_for_version("0.5.1")
      xml.should contain_datastream_eeml_for_version("0.5.1")
    end

    it "should handle a lack of tags" do
      @datastream.tags = nil
      lambda {@datastream.generate_xml("0.5.1")}.should_not raise_error
    end

    it "should handle a lack of datapoints" do
      @datastream.datapoints = []
      xml = @datastream.generate_xml("0.5.1")
      Nokogiri.parse(xml).xpath("//xmlns:datapoints").should be_empty
    end

    it "should ignore blank attributes" do
      @datastream.unit_symbol = nil
      @datastream.unit_label = "Woohoo"
      @datastream.unit_type = "Type A"
      Nokogiri.parse(@datastream.generate_xml("0.5.1")).at_xpath("//xmlns:unit").attributes["symbol"].should be_nil
    end

    it "should ignore blank units" do
      @datastream.unit_symbol = nil
      @datastream.unit_label = nil
      @datastream.unit_type = nil
      Nokogiri.parse(@datastream.generate_xml("0.5.1")).at_xpath("//xmlns:unit").should be_nil
    end
  end

  context "5 (used by API V1)" do

    it "should represent Pachube EEML" do
      xml = Nokogiri.parse(@datastream.generate_xml("5"))
      xml.should describe_eeml_for_version("5")
      xml.should contain_datastream_eeml_for_version("5")
    end

    it "should handle a lack of tags" do
      @datastream.tags = nil
      lambda {@datastream.generate_xml("5")}.should_not raise_error
    end

    it "should ignore blank attributes" do
      @datastream.max_value = nil
      @datastream.unit_symbol = nil
      @datastream.unit_label = "Woohoo"
      @datastream.unit_type = "Type A"
      Nokogiri.parse(@datastream.generate_xml("5")).at_xpath("//xmlns:unit").attributes["symbol"].should be_nil
      Nokogiri.parse(@datastream.generate_xml("5")).at_xpath("//xmlns:value").attributes["maxValue"].should be_nil
    end

    it "should ignore blank units" do
      @datastream.unit_symbol = nil
      @datastream.unit_label = nil
      @datastream.unit_type = nil
      Nokogiri.parse(@datastream.generate_xml("5")).at_xpath("//xmlns:unit").should be_nil
    end
  end
end

