require File.dirname(__FILE__) + '/../../../spec_helper'

describe "default feed xml parser" do
  context "0.5.1 (used by API v2)" do
    it "should convert into attributes hash" do
      @xml = feed_as_(:xml)
      PachubeDataFormats::Feed.new(@xml).should fully_represent_feed(:xml, @xml)
    end
  end

  context "5 (used by API v1)" do
    it "should convert into attributes hash" do
      @xml = feed_as_(:xml, :version => "5")
      PachubeDataFormats::Feed.new(@xml).should fully_represent_feed(:xml, @xml)
    end
  end
end

