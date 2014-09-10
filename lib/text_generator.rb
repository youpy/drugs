class TextGenerator
  attr_reader :chains, :originals

  def initialize(chains, originals)
    @chains = chains
    @originals = originals
  end

  def generate
    begin
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
