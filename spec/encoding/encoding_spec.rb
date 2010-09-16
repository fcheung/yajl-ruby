# encoding: UTF-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

class Dummy2
  def to_json
    "{\"hawtness\":true}"
  end
end

describe "Yajl JSON encoder" do
  FILES = Dir[File.dirname(__FILE__)+'/../../benchmark/subjects/*.json']

  FILES.each do |file|
     it "should encode #{File.basename(file)} to an IO" do
       # we don't care about testing the stream subject as it has multiple JSON strings in it
       if File.basename(file) != 'twitter_stream.json'
         input = File.new(File.expand_path(file), 'r')
         io = StringIO.new
         encoder = Yajl::Encoder.new
         hash = Yajl::Parser.parse(input)
         encoder.encode(hash, io)
         io.rewind
         hash2 = Yajl::Parser.parse(io)
         io.close
         input.close
         hash.should == hash2
       end
     end
   end

   FILES.each do |file|
     it "should encode #{File.basename(file)} and return a String" do
       # we don't care about testing the stream subject as it has multiple JSON strings in it
       if File.basename(file) != 'twitter_stream.json'
         input = File.new(File.expand_path(file), 'r')
         encoder = Yajl::Encoder.new
         hash = Yajl::Parser.parse(input)
         output = encoder.encode(hash)
         hash2 = Yajl::Parser.parse(output)
         input.close
         hash.should == hash2
       end
     end
   end

   FILES.each do |file|
     it "should encode #{File.basename(file)} call the passed block, passing it a String" do
       # we don't care about testing the stream subject as it has multiple JSON strings in it
       if File.basename(file) != 'twitter_stream.json'
         input = File.new(File.expand_path(file), 'r')
         encoder = Yajl::Encoder.new
         hash = Yajl::Parser.parse(input)
         output = ''
         encoder.encode(hash) do |json_str|
           output << json_str
         end
         hash2 = Yajl::Parser.parse(output)
         input.close
         hash.should == hash2
       end
     end
   end

  it "should encode with :pretty turned on and a single space indent, to an IO" do
    output = "{\n \"foo\": 1234\n}"
    obj = {:foo => 1234}
    io = StringIO.new
    encoder = Yajl::Encoder.new(:pretty => true, :indent => ' ')
    encoder.encode(obj, io)
    io.rewind
    io.read.should == output
  end

  it "should encode with :pretty turned on and a single space indent, and return a String" do
    output = "{\n \"foo\": 1234\n}"
    obj = {:foo => 1234}
    encoder = Yajl::Encoder.new(:pretty => true, :indent => ' ')
    output = encoder.encode(obj)
    output.should == output
  end

  it "should encode with :pretty turned on and a tab character indent, to an IO" do
    output = "{\n\t\"foo\": 1234\n}"
    obj = {:foo => 1234}
    io = StringIO.new
    encoder = Yajl::Encoder.new(:pretty => true, :indent => "\t")
    encoder.encode(obj, io)
    io.rewind
    io.read.should == output
  end

  it "should encode with :pretty turned on and a tab character indent, and return a String" do
    output = "{\n\t\"foo\": 1234\n}"
    obj = {:foo => 1234}
    encoder = Yajl::Encoder.new(:pretty => true, :indent => "\t")
    output = encoder.encode(obj)
    output.should == output
  end

  it "should encode with it's class method with :pretty and a tab character indent options set, to an IO" do
    output = "{\n\t\"foo\": 1234\n}"
    obj = {:foo => 1234}
    io = StringIO.new
    Yajl::Encoder.encode(obj, io, :pretty => true, :indent => "\t")
    io.rewind
    io.read.should == output
  end

  it "should encode with it's class method with :pretty and a tab character indent options set, and return a String" do
    output = "{\n\t\"foo\": 1234\n}"
    obj = {:foo => 1234}
    output = Yajl::Encoder.encode(obj, :pretty => true, :indent => "\t")
    output.should == output
  end

  it "should encode with it's class method with :pretty and a tab character indent options set, to a block" do
    output = "{\n\t\"foo\": 1234\n}"
    obj = {:foo => 1234}
    output = ''
    Yajl::Encoder.encode(obj, :pretty => true, :indent => "\t") do |json_str|
      output = json_str
    end
    output.should == output
  end

  it "should encode multiple objects into a single stream, to an IO" do
    io = StringIO.new
    obj = {:foo => 1234}
    encoder = Yajl::Encoder.new
    5.times do
      encoder.encode(obj, io)
    end
    io.rewind
    output = "{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}"
    io.read.should == output
  end

  it "should encode multiple objects into a single stream, and return a String" do
    obj = {:foo => 1234}
    encoder = Yajl::Encoder.new
    json_output = ''
    5.times do
      json_output << encoder.encode(obj)
    end
    output = "{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}{\"foo\":1234}"
    json_output.should == output
  end

  it "should encode all map keys as strings" do
    Yajl::Encoder.encode({1=>1}).should eql("{\"1\":1}")
  end

  it "should check for and call #to_json if it exists on custom objects" do
    d = Dummy2.new
    Yajl::Encoder.encode({:foo => d}).should eql('{"foo":{"hawtness":true}}')
  end

  it "should encode a hash where the key and value can be symbols" do
    Yajl::Encoder.encode({:foo => :bar}).should eql('{"foo":"bar"}')
  end

  it "should encode using a newline or nil terminator" do
    Yajl::Encoder.new(:terminator => "\n").encode({:foo => :bar}).should eql("{\"foo\":\"bar\"}\n")
    Yajl::Encoder.new(:terminator => nil).encode({:foo => :bar}).should eql("{\"foo\":\"bar\"}")
  end

  it "should encode using a newline or nil terminator, to an IO" do
    s = StringIO.new
    Yajl::Encoder.new(:terminator => "\n").encode({:foo => :bar}, s)
    s.rewind
    s.read.should eql("{\"foo\":\"bar\"}\n")

    s = StringIO.new
    Yajl::Encoder.new(:terminator => nil).encode({:foo => :bar}, s)
    s.rewind
    s.read.should eql("{\"foo\":\"bar\"}")
  end

  it "should encode using a newline or nil terminator, using a block" do
    s = StringIO.new
    Yajl::Encoder.new(:terminator => "\n").encode({:foo => :bar}) do |chunk|
      s << chunk
    end
    s.rewind
    s.read.should eql("{\"foo\":\"bar\"}\n")

    s = StringIO.new
    nilpassed = false
    Yajl::Encoder.new(:terminator => nil).encode({:foo => :bar}) do |chunk|
      nilpassed = true if chunk.nil?
      s << chunk
    end
    nilpassed.should be_true
    s.rewind
    s.read.should eql("{\"foo\":\"bar\"}")
  end

  it "should not encode NaN" do
    lambda {
      Yajl::Encoder.encode(0.0/0.0)
    }.should raise_error(Yajl::EncodeError)
  end

  it "should not encode Infinity or -Infinity" do
    lambda {
      Yajl::Encoder.encode(1.0/0.0)
    }.should raise_error(Yajl::EncodeError)
    lambda {
      Yajl::Encoder.encode(-1.0/0.0)
    }.should raise_error(Yajl::EncodeError)
  end

  it "should encode with :ascii_only and not escape codepoints below U+0080" do
    hash = {"\x7F is not escaped" => "<- plain ascii"}
    encoder = Yajl::Encoder.new(:ascii_only => true)
    output = encoder.encode(hash)
    output.should eql("{\"\x7F is not escaped\":\"<- plain ascii\"}")
  end

  it "should encode with :ascii_only and escape codepoints in the U+0080 to U+07FF" do
    hash = {"\xC2\x80 to \xDF\xBF are escaped" => "<- those are unicode"}
    encoder = Yajl::Encoder.new(:ascii_only => true)
    output = encoder.encode(hash)
    output.should eql("{\"\\u0080 to \\u07FF are escaped\":\"<- those are unicode\"}")
  end

  it "should encode with :ascii_only and escape codepoints in the U+0800 to U+FFFF" do
    hash = {"\xE0\xA0\x80 to \xEF\xBF\xBF are escaped" => "<- those are unicode"}
    encoder = Yajl::Encoder.new(:ascii_only => true)
    output = encoder.encode(hash)
    output.should eql("{\"\\u0800 to \\uFFFF are escaped\":\"<- those are unicode\"}")
  end

  it "should encode with :ascii_only and escape codepoints in the U+010000 to U+10FFFF" do
    hash = {"\xF0\x90\x80\x80 and \xF0\xA9\xA8\x9C are escaped" => "<- those are unicode"} #U+029A1C
    encoder = Yajl::Encoder.new(:ascii_only => true)
    output = encoder.encode(hash)
    output.should eql("{\"\\uD800\\uDC00 and \\uD866\\uDE1C are escaped\":\"<- those are unicode\"}")
  end
  
  it "should default to ascii only if default_to_ascii_only set" do
    Yajl::Encoder.default_to_ascii_only = true

    begin
      hash = {"\xE1\x8F\x88\xC4\x99" => "<- those are unicode"}
      encoder = Yajl::Encoder.new()
      output = encoder.encode(hash)
      output.should eql("{\"\\u13C8\\u0119\":\"<- those are unicode\"}")

    ensure
      Yajl::Encoder.default_to_ascii_only = false
    end
  end

  if RUBY_VERSION =~ /^1.9/
    it "should return a string encoded in utf-8 if Encoding.default_internal is nil" do
      Encoding.default_internal = nil
      hash = {"浅草" => "<- those are unicode"}
      Yajl::Encoder.encode(hash).encoding.should eql(Encoding.find('utf-8'))
    end

    it "should return a string encoded in utf-8 even if Encoding.default_internal *is* set" do
      Encoding.default_internal = Encoding.find('utf-8')
      hash = {"浅草" => "<- those are unicode"}
      Yajl::Encoder.encode(hash).encoding.should eql(Encoding.default_internal)
      Encoding.default_internal = Encoding.find('us-ascii')
      hash = {"浅草" => "<- those are unicode"}
      Yajl::Encoder.encode(hash).encoding.should eql(Encoding.find('utf-8'))
    end
  end
end