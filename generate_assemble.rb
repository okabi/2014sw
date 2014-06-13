# -*- coding: utf-8 -*-
$filename = ARGV[0]
if $filename == nil
  $filename = "test.asm"
end
$file = open($filename, "w")
$functions = []
$local_vars = {}
$n_local = 0

def generateAssemble(tree)
  def putsFile(a, b=nil, c=nil, d=nil)
    $file.print("#{a}") if a != nil
    $file.print("\t#{b}") if b != nil
    $file.print("\t#{c}") if c != nil
    $file.print(", #{d}") if d != nil
    $file.puts("")
  end

  def culcNLocal(node)
    for n in node
      if n[0] == "int"
        n[1] =~ /.+:.+:level.+\(-(.+)\)/
        $n_local = $1.to_i if $1.to_i > $n_local
      elsif n[0] == "WHILE"
        culcNLocal(n[2])
      elsif n[0] == "IF"
        culcNLocal(n[2])
        culcNLocal(n[3])
      end
    end
  end

  def digTree(parent_node, child_node, lvl=-1)
    if child_node[0].instance_of?(String) == true
      case child_node[0]
      when "int"
        child_node[1] =~ /(.+):(.+):(.+)/
        name = $1
        type = $2
        level = $3
        pos = nil
        if level.index("level0") == nil
          child_node[1] =~ /(.+):(.+):level(.+)\((.+)\)/
          level = $3.to_i
          pos = $4.to_i
        else
          level =~ /level(.+)/
          level = $1.to_i
        end
        if level == 0
          if type == "VAR"
            putsFile(nil, "GLOBAL", name)
            putsFile(nil, "COMMON", name, 4)
          elsif type == "FUN"
            $functions.push(name)
            putsFile(nil, "GLOBAL", name)
            putsFile(name, "push", "ebp")           
            putsFile(nil, "mov", "ebp", "esp")
            $n_local = 0
            culcNLocal(parent_node[2])
            putsFile(nil, "sub", "esp", "#{$n_local}")
            
            $file.puts("; 関数#{name}の本体ここから")
            for grandchild in parent_node[2]
              digTree(child_node, grandchild, lvl + 1)
            end
            $file.puts("; 関数#{name}の本体ここまで")
            
            putsFile("Lret", "mov", "esp", "ebp")
            putsFile(nil, "pop", "ebp")
            putsFile(nil, "ret")
            $local_vars.clear
          end
        else
          $local_vars["#{name}:level#{level}"] = pos
          $file.puts("; local_vars: #{name}:level#{level} => #{pos}")
        end
      when "WHILE"
        $file.puts("; WHILEここから")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1)
        end
        $file.puts("; WHILEここまで")
      when "IF"
        $file.puts("; IFここから")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1)
        end
        $file.puts("; この先else")
        for grandchild in child_node[3]
          digTree(child_node[3], grandchild, lvl + 1)
        end
        $file.puts("; IFここまで")
      when "FCALL"
        # 引数に数式が使われている場合は上手くいかないので、もう少し検討する
        child_node[2].length.times do |i|
          putsFile(nil, "push", "#{child_node[2][child_node[2].length-1-i]}")
        end
        if $functions.index(child_node[1]) == nil
          putsFile(nil, "EXTERN", child_node[1])          
        end
          putsFile(nil, "call", child_node[1])                  
      end
    else
      if lvl < 0
        for grandchild in child_node
          digTree(child_node, grandchild, lvl + 1)
        end
      else
          digTree(child_node, child_node[0], lvl + 1)        
      end
    end
  end
  digTree(nil, tree)
end
