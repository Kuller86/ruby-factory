# frozen_string_literal: true

# * Here you must define your `Factory` class.
# * Each instance of Factory could be stored into variable. The name of this variable is the name of created Class
# * Arguments of creatable Factory instance are fields/attributes of created class
# * The ability to add some methods to this class must be provided while creating a Factory
# * We must have an ability to get/set the value of attribute like [0], ['attribute_name'], [:attribute_name]
#
# * Instance of creatable Factory class should correctly respond to main methods of Struct
# - each
# - each_pair
# - dig
# - size/length
# - members
# - select
# - to_a
# - values_at
# - ==, eql?

class Factory
  class << self
    def new(*properties, &block)
      if properties.first.is_a? String
        return const_set(properties.shift, create_class(*properties, &block))
      end

      create_class(*properties, &block)
    end

    def create_class(*properties, &block)
      Class.new do
        attr_accessor(*properties)

        define_method :initialize do |*arguments|
          raise ArgumentError, 'Wrong number of parameters' if arguments.length != properties.length

          properties.each_with_index { |property, index| instance_variable_set "@#{property}", arguments[index] }
        end

        define_method :[] do |property|
          instance_variable_get property.is_a?(Integer) ? instance_variables[property] : "@#{property}"
        end

        define_method :[]= do |property, value|
          instance_variable_set property.is_a?(Integer) ? instance_variables[property] : "@#{property}", value
        end

        def ==(other)
          self.class == other.class && to_a == other.to_a
        end
        alias_method :eql?, :==

        def to_a
          instance_variables.collect { |value| instance_variable_get value }
        end

        def dig(*keys)
          keys.inject(self) { |values, key| values[key] if values }
        end

        def each(&block)
          to_a.each(&block)
        end

        def each_pair(&block)
          members.zip(to_a).each(&block)
        end

        define_method :members do
          properties
        end

        def size
          instance_variables.size
        end
        alias_method :length, :size

        def select(&block)
          to_a.select(&block)
        end

        def values_at(*keys)
          to_a.values_at(*keys)
        end

        class_eval(&block) if block_given?
      end
    end
  end
end
