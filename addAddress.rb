$add_sp = 0

def addAddress(tree)
  if tree[0].instance_of?(String)
    if tree[0] == "int"
      if tree[1] =~ /:level0/
        $add_sp = 0
      elsif tree[1] =~ /:level1/
        if $add_sp <= 0
          $add_sp = 8
        end
        tree[1] += "(#{$add_sp})"
        $add_sp += 4
      else
        if $add_sp >= 0
          $add_sp = -4
        end
        tree[1] += "(#{$add_sp})"
        $add_sp -= 4        
      end
    end
  else
    for child in tree
      addAddress(child)
    end
  end
end
