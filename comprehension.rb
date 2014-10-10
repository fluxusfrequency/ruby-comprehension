module ListComprehension
  def c(&block)
    raise ArgumentError.new('You must supply a block with a string in it') unless block_given?
    Comprehension.new(&block).comprehend
  end
end

class Comprehension
  def initialize(&block)
    @comprehension = block.call
    @scope = block.send(:binding)
  end

  def comprehend
    if basic?
      BasicComprehension.new(comprehension, scope).comprehend
    else
      MethodComprehension.new(comprehension, scope).comprehend
    end
  end

  private

  attr_reader :comprehension, :scope

  def basic?
    parts[0] == parts[2]
  end


  def parts
    @parts ||= comprehension.split(' ')
  end

  def collection
    if has_conditional?
      i = parts.index(conditional)
      scope.send(:eval, parts[i - 1])
    else
      result = comprehension.slice(/\[.*\]/)
      return eval(result) if result
      scope.send(:eval, parts.last)
    end
  end

  def conditional_loop
    if conditional == 'if'
      collection.select { |x| x.send(condition) }
    else
      collection.reject { |x| x.send(condition) }
    end
  end

  def conditional
    comprehension.slice(/(if|unless)/)
  end

  def has_conditional?
    !!conditional
  end

  def condition
    i = parts.index(conditional)
    parts[i + 1].split('.').last
  end

end

class BasicComprehension < Comprehension
  def initialize(comprehension, scope)
    @comprehension = comprehension
    @scope = scope
  end

  def comprehend
    if has_conditional?
      conditional_loop
    else
      collection
    end
  end
end

class MethodComprehension < Comprehension
  def initialize(comprehension, scope)
    @comprehension = comprehension
    @scope = scope
  end

  def comprehend
    if has_conditional?
      method_loop(conditional_loop)
    else
      method_loop(collection)
    end
  end

  def method_loop(coll)
    coll.map { |x| scope.send(method, x) }
  end

  def method
    parts.first
  end
end
