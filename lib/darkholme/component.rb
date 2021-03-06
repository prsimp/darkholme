module Darkholme
  # Top-level class for storing data on an Entity that a System uses
  class Component
    @next_bit = 0
    @bits = {}

    # Get a unique bit for a Component class
    #
    # @param klass [Class] The class to generate (or look up) the bit for
    #
    # @return [Fixnum] The bit for that class
    def self.bit_for(klass)
      @bits[klass] ||= @next_bit += 1
    end

    # Get the current instance's class' bit
    #
    # @return [Fixnum] The bit for the instance's class
    def bit
      Component.bit_for(self.class)
    end
  end
end
