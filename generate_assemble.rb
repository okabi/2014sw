# -*- coding: utf-8 -*-
# 書き出すアセンブリファイル名
$filename = ARGV[0]
if $filename == nil
  $filename = "test.asm"
end
$file = open($filename, "w")

# 宣言された関数名のリスト
$functions = []

# 宣言されたローカル変数名(レベル含む)のリスト
$local_vars = {}

# 関数culcNLocal用
$n_local = 0



# アセンブリコードを生成する
def generateAssemble(tree)
  # アセンブリコードを1行書き出す
  def putsFile(a, b=nil, c=nil, d=nil)
    $file.print("#{a}") if a != nil
    $file.print("\t#{b}") if b != nil
    $file.print("\t#{c}") if c != nil
    $file.print(", #{d}") if d != nil
    $file.puts("")
  end


  # そのノードから下に伸びるノード中で使われる相対番地の絶対値の最大値を求める
  # 大域変数$n_localに書き出される
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


  # 数あるいは"#{name}:#{type}:level#{level}"を、コード形式に変換して返す
  def leafToCode(leaf)
    if leaf.instance_of?(String) == true
      if $local_vars[leaf] != nil && $local_vars[leaf] >= 0
        return "[ebp+#{$local_vars[leaf]}]"
      else
        return "[ebp#{$local_vars[leaf]}]"
      end
    else
      return "#{leaf}"
    end
  end


  # 木を掘り進んで順番にコードを生成する
  def digTree(parent_node, child_node, lvl=-1)
    # 現在見ているノード(配列)が最も深いノードか調べる
    leaf = true
    for n in child_node
      if n.instance_of?(String) == false
        leaf = false
        break
      end
    end

    # ノードの先頭要素が文字列なら、再帰的にコード生成処理を行う
    # 宣言文以外で葉だったなら、再帰末端用コードを生成する
    if child_node[0].instance_of?(String) == true
      case child_node[0]
      when "int"
        # 関数宣言または変数宣言
        # 関数 => ("int", "#{name}:#{type}:level#{level}")
        # 変数 => ("int", "#{name}:#{type}:level#{level}(#{pos})")
        child_node[1] =~ /(.+):(.+):(.+)/
        name = $1
        type = $2
        level = $3
        pos = nil
        if level.index("level0") == nil
          # パラメータかローカル変数
          child_node[1] =~ /(.+):(.+):level(.+)\((.+)\)/
          level = $3.to_i
          pos = $4.to_i
        else
          # 大域関数か大域変数
          level =~ /level(.+)/
          level = $1.to_i
        end
        if level == 0
          # 大域関数か大域変数のとき
          if type == "VAR"
            # 大域変数のとき
            putsFile(nil, "GLOBAL", name)
            putsFile(nil, "COMMON", "#{name} 4")
          elsif type == "FUN"
            # 大域関数の時
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
            
            putsFile("#{name}ret", "mov", "esp", "ebp")
            putsFile(nil, "pop", "ebp")
            putsFile(nil, "ret")
            $local_vars.clear
          end
        else
          $local_vars["#{name}:#{type}:level#{level}"] = pos
          $file.puts("; local_vars: #{name}:#{type}:level#{level} => #{pos}")
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
        child_node[2].length.times do |i|
          putsFile(nil, "pop", "ebx")
        end
      when "="
        # 代入命令
        $file.puts("; = ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true || child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", leafToCode(child_node[1]), leafToCode(child_node[2]))
        else
          digTree(child_node, child_node[2], lvl + 1)
          putsFile(nil, "mov", leafToCode(child_node[1]), "eax")
        end
        $file.puts("; = ここまで(#{child_node[1]}, #{child_node[2]})")
      when "+"
        # 加算命令
        $file.puts("; + ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true || child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))          
          putsFile(nil, "push", "eax")
        else
          digTree(child_node, child_node[2], lvl + 1)
          putsFile(nil, "push", "eax")
        end
        if child_node[1].instance_of?(String) == true || child_node[1].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[1]))
        else
          digTree(child_node, child_node[1], lvl + 1)
        end
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "add", "eax", "ebx")
        $file.puts("; + ここまで(#{child_node[1]}, #{child_node[2]})")
      when "-"
        # 減算命令
        $file.puts("; - ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true || child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))          
          putsFile(nil, "push", "eax")
        else
          digTree(child_node, child_node[2], lvl + 1)
          putsFile(nil, "push", "eax")
        end
        if child_node[1].instance_of?(String) == true || child_node[1].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[1]))
        else
          digTree(child_node, child_node[1], lvl + 1)
        end
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "sub", "eax", "ebx")
        $file.puts("; - ここまで(#{child_node[1]}, #{child_node[2]})")
      when "*"
        # 乗算命令
        $file.puts("; * ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true || child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))          
          putsFile(nil, "push", "eax")
        else
          digTree(child_node, child_node[2], lvl + 1)
          putsFile(nil, "push", "eax")
        end
        if child_node[1].instance_of?(String) == true || child_node[1].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[1]))
        else
          digTree(child_node, child_node[1], lvl + 1)
        end
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "imul", "eax", "ebx")
        $file.puts("; * ここまで(#{child_node[1]}, #{child_node[2]})")
      when "/"
        $file.puts("; / めんどい")
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
