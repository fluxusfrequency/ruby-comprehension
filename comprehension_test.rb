require 'minitest/autorun'
require 'minitest/pride'
require './comprehension.rb'

class ComprehensionTest < Minitest::Test
  def test_simple_array
    result = c { 'n for n in [1, 2, 3, 4, 5]' }
    assert_equal [1, 2, 3, 4, 5], result
  end

  def test_without_block
    assert_raises(ArgumentError) { c() }
  end

  def test_array_variable
    example = [1, 2, 3, 4, 5]
    result = c { 'x for x in example' }
    assert_equal [1, 2, 3, 4, 5], result
  end

  def test_another_variable
    symbols = [:a, :b, :c, :d, :e]
    result = c { 'x for x in symbols' }
    assert_equal [:a, :b, :c, :d, :e], result
  end

  def test_with_method
    example = [1, 2, 3, 4, 5]
    result = c { 'Array i for i in example' }
    assert_equal [[1], [2], [3], [4], [5]], result
  end

  def test_with_conditional
    example = [1, 2, 3, 4, 5]
    result = c { 'i for i in example unless i.odd?' }
    assert_equal [2, 4], result
  end

  def test_with_method_and_conditional
    numbers = [1, 2, 3, 4, 5]
    result = c { 'Array i for i in numbers unless i.even?' }
    assert_equal [[1], [3], [5]], result
  end
end
