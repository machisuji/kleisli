require 'kleisli/monad'

module Kleisli
  class Maybe < Monad
    attr_reader :value

    def self.lift(value)
      if value.nil?
        None.new
      else
        Some.new(value)
      end
    end

    def ==(other)
      value == other.value
    end

    def *(other)
      self >-> f {
        other >-> val {
          Maybe.lift(f.arity > 1 ? f.curry.call(val) : f.call(val))
        }
      }
    end

    class None < Maybe
      def fmap(&f)
        self
      end

      def >(block)
        self
      end

      def or(other)
        other
      end

      def to_s
        "None"
      end
      alias inspect to_s
    end

    class Some < Maybe
      def initialize(value)
        @value = value
      end

      def fmap(&f)
        Maybe.lift(f.call(@value))
      end

      def >(block)
        block.call(@value)
      end

      def or(other)
        self
      end

      def to_s
        "Some(#{@value})"
      end
      alias inspect to_s
    end
  end
end

Maybe = Kleisli::Maybe.method(:lift)

def Maybe(v)
  Maybe.(v)
end

def None()
  Maybe(nil)
end

def Some(v)
  Maybe(v)
end
