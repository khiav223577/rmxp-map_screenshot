class Object
  def __addr__
    self.__id__ << 1
  end
  
  def tap
    yield(self)
    return self
  end
  
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      __send__(*a, &b)
    end
  end
  
  def in?(another_object)
    begin
      another_object.include?(self)
    rescue NoMethodError
      raise ArgumentError.new("The parameter passed to #in? must respond to #include?")
    end
  end
  
  def singleton_class
    class << self; self; end
  end
    
  def define_singleton_method(method_name, &block)
    singleton_class.send(:define_method, method_name, &block)
  end

  def remove_instance_variables_with_nil_value!
    instance_variables.each do |var|
      remove_instance_variable(var) if instance_variable_get(var).is_a?(NilClass)
    end
  end

  def nested_remove_instance_variables_with_nil_value!
    return if @nested_remove_instance_variables_with_nil_value
    # $analyze[self.type] += 1
    @nested_remove_instance_variables_with_nil_value = true
    remove_instance_variables_with_nil_value!
    instance_variables.each do |var|
      instance_variable_get(var).nested_remove_instance_variables_with_nil_value!
    end
    remove_instance_variable(:@nested_remove_instance_variables_with_nil_value)
  end
end
