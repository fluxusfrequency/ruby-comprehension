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
    if !has_conditional?
      return collection if basic?
      eval(method_loop(collection))
    else
      result = eval(conditional_loop)
      return result if basic?
      eval(method_loop(result))
    end
  end

  private

  attr_reader :comprehension, :scope

  def basic?
    parts[0] == parts[2]
  end

  def has_conditional?
    !!comprehension.match(/(if|unless)/)
  end

  def parts
    @parts ||= comprehension.split(' ')
  end

  def collection
    if has_conditional?
      i = parts.index(conditional)
      scope.send(:eval, parts[i - 1])
    else
      result = comprehension.scan(/\[.*\]/).last
      if result
        return eval(result)
      else
        scope.send(:eval, parts.last)
      end
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
    # only occurs if not basic
    parts[0]
  end

  def conditional
    comprehension.match(/(if|unless)/)[0]
  end

  def condition
    i = parts.index(conditional)
    parts[i + 1].split('.')[1]
  end

end
