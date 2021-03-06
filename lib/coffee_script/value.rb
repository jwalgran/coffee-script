module CoffeeScript

  # Instead of producing raw Ruby objects, the Lexer produces values of this
  # class, wrapping native objects tagged with line number information.
  class Value
    attr_reader :value, :line

    def initialize(value, line)
      @value, @line = value, line
    end

    def to_str
      @value.to_s
    end
    alias_method :to_s, :to_str

    def to_sym
      to_str.to_sym
    end

    def inspect
      @value.inspect
    end

    def ==(other)
      @value == other
    end

    def [](index)
      @value[index]
    end

    def eql?(other)
      @value.eql?(other)
    end

    def hash
      @value.hash
    end
  end

end