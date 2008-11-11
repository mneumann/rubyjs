module UnifiedRuby
  #
  # The ||= operator.
  #
  # For example:
  #
  #     a = a || "hallo"
  #
  #         [:lasgn, :a, [:or, [:lvar, :a], [:str, "hallo"]]],
  #
  #     a ||= "hallo" 
  #
  #         [:op_asgn_or, [:lvar, :a], [:lasgn, :a, [:str, "hallo"]]]]]]
  #
  # We rewrite the one to the other.
  #
  def rewrite_op_asgn_or(exp)
    raise if exp.size != 3
    _, lhs, asgn = *exp

    rhs = asgn.pop # e.g. [:str, "hallo"]
    asgn.push(s(:or, lhs, rhs))
    
    return asgn
  end

  #
  # The &&= operator.
  #
  # See rewrite_op_asgn_and for more details.
  #
  def rewrite_op_asgn_and(exp)
    raise if exp.size != 3
    _, lhs, asgn = *exp

    rhs = asgn.pop
    asgn.push(s(:and, lhs, rhs))
    
    return asgn
  end
end
