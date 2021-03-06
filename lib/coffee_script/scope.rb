module CoffeeScript

  # Scope objects form a tree corresponding to the shape of the function
  # definitions present in the script. They provide lexical scope, to determine
  # whether a variable has been seen before or if it needs to be declared.
  class Scope

    attr_reader :parent, :variables, :temp_variable

    # Initialize a scope with its parent, for lookups up the chain.
    def initialize(parent=nil)
      @parent = parent
      @variables = {}
      @temp_variable = @parent ? @parent.temp_variable : '__a'
    end

    # Look up a variable in lexical scope, or declare it if not found.
    def find(name, remote=false)
      found = check(name, remote)
      return found if found || remote
      @variables[name.to_sym] = :var
      found
    end

    # Define a local variable as originating from a parameter in current scope
    # -- no var required.
    def parameter(name)
      @variables[name.to_sym] = :param
    end

    # Just check to see if a variable has already been declared.
    def check(name, remote=false)
      return true if @variables[name.to_sym]
      @parent && @parent.find(name, true)
    end

    # You can reset a found variable on the immediate scope.
    def reset(name)
      @variables[name.to_sym] = false
    end

    # Find an available, short, name for a compiler-generated variable.
    def free_variable
      @temp_variable.succ! while check(@temp_variable)
      @variables[@temp_variable.to_sym] = :var
      @temp_variable.dup
    end

    def any_declared?
      !declared_variables.empty?
    end

    # Return the list of variables first declared in current scope.
    def declared_variables
      @variables.select {|k, v| v == :var }.map {|pair| pair[0].to_s }.sort
    end

  end

end