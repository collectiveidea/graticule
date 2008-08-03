require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class HashTest < Test::Unit::TestCase
  
  def test_flatten_empty
    assert_equal({}, {}.flatten)
  end

  def test_flatten_on_already_flat
    assert_equal({:a => 1}, {:a => 1}.flatten)
  end
  
  def test_flatten
    actual = {:a => {:b => 1, :c => {:d => 2}}, :e => 3}.flatten
    expected = {:b => 1, :d => 2, :e => 3}
    assert_equal expected, actual
  end
end