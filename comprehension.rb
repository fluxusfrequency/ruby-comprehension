module Kernel
  def c(&block)
    unless block_given?
      raise ArgumentError.new('You must supply a block with a string in it')
    end
    Comprehension.new(&block).comprehend
  end
end

class Comprehension
  def initialize(&block)
    @comprehension = block.call
    @scope = block.send(:binding)
  end

  def comprehend
    if has_conditional?
      comprehend_with_conditional
    elsif basic?
      collection
    else
      eval(method_loop(collection))
    end
  end

  private

  attr_reader :comprehension, :scope

  def comprehend_with_conditional
    result = eval(conditional_loop)
    if basic?
      result
    else
      eval(method_loop(result))
    end
  end

  def basic?
    parts[0] == parts[2]
  end

  def has_conditional?
    !!comprehension.match(/(if|unless)/)
  end

  def parts
    comprehension.split(' ')
  end

  def collection
    if has_conditional?
      conditional_collection
    else
      bare_collection
    end
  end

  def conditional_collection
    i = parts.index(conditional)
    scope.send(:eval, parts[i - 1])
  end

  def bare_collection
    result = comprehension.scan(/\[.*\]/).last
    if result
      eval(result)
    else
      scope.send(:eval, parts.last)
    end
  end

  def method_loop(coll)
    "#{coll}.map { |x| scope.send(method, x) }"
  end

  def conditional_loop
    if conditional == 'if'
      "#{collection}.select { |x| x.send(condition) }"
    else
      "#{collection}.reject { |x| x.send(condition) }"
    end
  end

  def method
    parts[0]
  end

  def conditional
    comprehension[/if/] || comprehension[/unless/]
  end

  def condition
    i = parts.index(conditional)
    # This implementation works for method calls like n.odd?,
    # but not things like `!n`
    parts[i + 1].split('.')[1]
  end

end
