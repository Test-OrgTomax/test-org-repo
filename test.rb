class Mock
  def initialize; @expects = {} end
  def expect(method, value, args = []); @expects[method] = { v: value, a: args } end
  def method_missing(m, *args)
    raise "Unexpected call #{m}" unless (exp = @expects.delete(m)) && exp[:a] == args
    exp[:v]
  end
  def verify; raise "Unmet expectations!" unless @expects.empty? end
end
