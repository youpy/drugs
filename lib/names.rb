require 'open-uri'
require 'uri'
require 'digest/md5'

Bundler.require

class Names
  DIR = File.dirname(__FILE__) + '/../data/'

  attr_reader :digest

  def self.create_from_url_and_xpath(url, xpath)
    digest = save(url, xpath)
    new(digest)
  end

  def initialize(digest)
    @digest = digest
  end

  def self.save(url, xpath)
    digest = Digest::MD5.hexdigest(url + xpath).to_s
    doc = Nokogiri::HTML(open(url))
    title = doc.xpath('//title')[0].text
    chains = Hash.new {|h, k| h[k] = Array.new }
    originals = doc.css(xpath).map {|a| a.text }
    originals.each do |original|
      ['', 'BOD', original.split(//), 'EOD', ''].flatten.each_cons(3) do |first, second, third|
        chains[first + second] << third #unless chains[first + second].include?(third)
      end
    end
    File.write DIR + digest + '.json', JSON.pretty_generate(originals: originals, chains: chains, title: title, url: url)
    digest
  end

  def file
    DIR + digest + '.json'
  end

  def json
    @json ||= JSON.parse File.read file
  end

  def title
    json['title']
  end

  def url
    json['url']
  end

  def generate
    unless File.exist?(file)
      save
    end

    begin
      chains = json['chains']
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
    end while json['originals'].include?(result)

    result
  end
end
