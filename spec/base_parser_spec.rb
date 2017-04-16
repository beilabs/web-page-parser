# -*- coding: utf-8 -*-
require 'spec_helper'

share_as :AllPageParsers do
  it "is initialized with a hash containing :url and :page keys" do
    wpp = WebPageParser::BaseParser.new(@valid_options)
    wpp.url.should == @valid_options[:url]
    wpp.page.should == @valid_options[:page]
  end

  it "should return an empty array when there is no content available" do
    content = WebPageParser::BaseParser.new.content
    content.should be_a_kind_of Array
    content.empty?.should be_true
  end

  it "should use guid_from_url if available" do
    class GuidTestPageParser < WebPageParser::BaseParser 
      def guid_from_url
        "guidfromurl"
      end
    end
    GuidTestPageParser.new.guid.should == nil
    GuidTestPageParser.new(:url => 'someurl').guid.should == 'guidfromurl'
  end

  context "when hashing the content" do
    before :each do
      @wpp = WebPageParser::BaseParser.new(@valid_options)
      @hash = @wpp.hash
    end

    it "calculates a hash using the title" do
      @wpp.instance_eval("@title='different'")
      @wpp.hash.should_not == @hash
    end

    it "does not calculates a hash using the date" do
      @wpp.instance_eval("@date=Time.now")
      @wpp.hash.should == @hash
    end

    it "calculates a hash using the content" do
      @wpp.instance_eval("@content=['different']")
      @wpp.hash.should_not == @hash
    end
  end
end

describe WebPageParser::BaseParser do
  it_should_behave_like AllPageParsers

  before :each do
    @valid_options = {
      :url => 'http://news.bbc.co.uk',
      :page => '<html></html>',
      :valid_hash => 'cfcd208495d565ef66e7dff9f98764da'
    }
  end

end

describe WebPageParser::BaseRegexpParser do
  it_should_behave_like AllPageParsers

  before :each do
    @valid_options = {
      :url => 'http://news.bbc.co.uk',
      :page => "<html>£</html>"
    }
  end


  it "should decode basic html entities" do
    bp = WebPageParser::BaseRegexpParser.new
    entities = {
      '&quot;' => '"',
      '&apos;' => "'",
      '&amp;' => "&",
      '&pound;' => '£',
      '&aacute;' => 'á'
    }
    entities.each do |e,v|
      bp.decode_entities(e).should == v
    end
  end

  it "should accept utf8" do
    wpp = WebPageParser::BaseRegexpParser.new(@valid_options)
    wpp.page.should == "<html>£</html>"
  end

end
