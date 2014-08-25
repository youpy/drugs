require 'open-uri'
require 'uri'
require 'digest/md5'
require 'mongoid'
require 'nokogiri'

if mongo_uri = ENV['MONGOHQ_URL']
  Mongoid.database = Mongo::Connection.from_uri(mongo_uri).
    db(URI.parse(mongo_uri).path.gsub(/^\//, ''))
else
  host = 'localhost'
  port = Mongo::Connection::DEFAULT_PORT
  Mongoid.database = Mongo::Connection.new(host, port).db('markov_chains')
end

class MarkovChain
  include Mongoid::Document
  include Mongoid::Timestamps

  field :id_str, :type => String
  field :chains, :type => String
  field :originals, :type => Array
  field :title, :type => String
  field :url, :type => String
  field :xpath, :type => String
  index :id_str, :unique => true

  def self.generate_id(url, xpath)
    Digest::MD5.hexdigest(url + xpath).to_s
  end

  def self.create_from_url_and_xpath(url, xpath)
    id_str = generate_id(url, xpath)

    doc = Nokogiri::HTML(open(url))
    title = doc.xpath('//title')[0].text
    chains = Hash.new {|h, k| h[k] = Array.new }
    originals = doc.css(xpath).map {|a| a.text }
    originals.each do |original|
      ['', 'BOD', original.split(//), 'EOD', ''].flatten.each_cons(3) do |first, second, third|
        chains[first + second] << third #unless chains[first + second].include?(third)
      end
    end

    instance = find_or_create_by(id_str: id_str)
    instance.url = url
    instance.xpath = xpath

    # http://stackoverflow.com/questions/9759972/what-characters-are-not-allowed-in-mongodb-field-names
    instance.chains = JSON.generate(chains)

    instance.originals = originals
    instance.title = title
    instance.save!
    instance
  end

  def generate
    begin
      chains = JSON.parse(self.chains)
      chars = []
      char = 'BOD'
      until char =~ /EOD/
        if char == 'BOD'
          char = char + chains[char].sample
        else
          char = char[-1] + chains[char].sample
        end

        chars << char[-1]
      end
      result = chars[0..-2].join
    end while originals.include?(result)

    result
  end
end
