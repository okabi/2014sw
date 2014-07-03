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

# 宣言されたIF文の数
$local_ifs = 0

# 宣言されたWHILE文の数
$local_whiles = 0

# 宣言された論理演算数
$local_logicals = 0

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


  # そのノード以下に未定義関数が存在すれば、EXTERN宣言する
  def writeExtern(node)
    if node.instance_of?(Array) == true
      if node[0] == "FCALL"
        if $functions.index(node[1]) == nil
          putsFile(nil, "EXTERN", node[1])          
        end
      else
        for n in node
          writeExtern(n)
        end
      end
    end
  end


  # 数あるいは"#{name}:#{type}:level#{level}"を、コード形式に変換して返す
  def leafToCode(leaf)
    if leaf.instance_of?(String) == true
      if $local_vars[leaf] == nil
        leaf =~ /(.+):.+:level.+/
        return "[#{$1}]"
      elsif $local_vars[leaf] >= 0
        return "[ebp+#{$local_vars[leaf]}]"
      else
        return "[ebp#{$local_vars[leaf]}]"
      end
    else
      return "#{leaf}"
    end
  end

  
  # 木を掘り進んで順番にコードを生成する
  def digTree(parent_node, child_node, lvl=-1, jmp_whiles=-1)
    # 算術演算のアセンブリコード(前半共通部分)
    def writeCompute(node, lev)
      if node[2].instance_of?(String) == true
        putsFile(nil, "mov", "eax", leafToCode(node[2]))          
      elsif node[2].instance_of?(Fixnum) == true
        putsFile(nil, "mov", "dword eax", leafToCode(node[2]))          
      else
        digTree(node, node[2], lev + 1)
      end
      putsFile(nil, "push", "eax")
      if node[1].instance_of?(String) == true
        putsFile(nil, "mov", "eax", leafToCode(node[1]))
      elsif node[1].instance_of?(Fixnum) == true
        putsFile(nil, "mov", "dword eax", leafToCode(node[1]))
      else
        digTree(node, node[1], lev + 1)
      end      
    end


    # 比較演算ノードを渡して、比較演算を行うコードを出力する
    def writeComp(base_node, lv)
      def comp(node, lev)
        # 先頭要素が比較演算子
        writeCompute(node, lev)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "cmp", "eax", "ebx")                
        case node[0]
        when "=="
          putsFile(nil, "sete", "al")                  
        when "!="
          putsFile(nil, "setne", "al")                  
        when ">"
          putsFile(nil, "setg", "al")                  
        when "<"
          putsFile(nil, "setl", "al")                  
        when ">="
          putsFile(nil, "setge", "al")                  
        when "<="
          putsFile(nil, "setle", "al")                  
        end
        putsFile(nil, "movzx", "eax", "al")
        putsFile(nil, "cmp", "eax", 0)
      end
      
      def logical(node, lv)
        # 先頭要素が論理演算子
        case node[0]
        when "&&"
          $file.puts("; && ここから(#{node[1]}, #{node[2]})")
          putsFile(nil, "mov", "eax", "0")
          putsFile(nil, "push", "eax")          
          if node[1][0].instance_of?(String) == false
            digLogical(node[1], lv)
          elsif node[1][0] == "&&" || node[1][0] == "||"
            logical(node[1], lv)
          else
            comp(node[1], lv)
          end
          logicals = $local_logicals
          $local_logicals += 1        
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "je", "#{$functions[$functions.length-1]}_logical#{logicals}")
          if node[2][0].instance_of?(String) == false
            digLogical(node[2], lv)            
          elsif node[2][0] == "&&" || node[2][0] == "||"
            logical(node[2], lv)
          else
            comp(node[2], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "je", "#{$functions[$functions.length-1]}_logical#{logicals}")
          putsFile(nil, "pop", "eax")
          putsFile(nil, "mov", "eax", "1")
          putsFile(nil, "push", "eax")          
          $file.puts("#{$functions[$functions.length-1]}_logical#{logicals}:")
          putsFile(nil, "pop", "eax")          
          putsFile(nil, "cmp", "eax", 0)
          $file.puts("; && ここまで(#{node[1]}, #{node[2]})")        
        when "||"
          $file.puts("; || ここから(#{node[1]}, #{node[2]})")
          putsFile(nil, "mov", "eax", "1")
          putsFile(nil, "push", "eax")          
          if node[1][0].instance_of?(String) == false
            digLogical(node[1], lv)            
          elsif node[1][0] == "&&" || node[1][0] == "||"
            logical(node[1], lv)
          else
            comp(node[1], lv)
          end
          logicals = $local_logicals
          $local_logicals += 1        
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "jne", "#{$functions[$functions.length-1]}_logical#{logicals}")
          if node[2][0].instance_of?(String) == false
            digLogical(node[2], lv)            
          elsif node[2][0] == "&&" || node[2][0] == "||"
            logical(node[2], lv)
          else
            comp(node[2], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "jne", "#{$functions[$functions.length-1]}_logical#{logicals}")
          putsFile(nil, "pop", "eax")
          putsFile(nil, "mov", "eax", "0")
          putsFile(nil, "push", "eax")          
          $file.puts("#{$functions[$functions.length-1]}_logical#{logicals}:")
          putsFile(nil, "pop", "eax")          
          putsFile(nil, "cmp", "eax", 0)
          $file.puts("; || ここまで(#{node[1]}, #{node[2]})")        
        end
      end
      def digLogical(node, lev)
        # 論理演算のノードを掘り進む
        if node[0].instance_of?(String) == false
          digLogical(node[0], lev + 1)
        elsif node[0] == "&&" || node[0] == "||"
          logical(node, lev)
        else
          comp(node, lev)
        end
      end
      
      digLogical(base_node, lv)
    end


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
            writeExtern(parent_node[2])
            putsFile(nil, "GLOBAL", name)
            putsFile("#{name}:")           
            putsFile(nil, "push", "ebp")           
            putsFile(nil, "mov", "ebp", "esp")
            $n_local = 0
            culcNLocal(parent_node[2])
            putsFile(nil, "sub", "esp", "#{$n_local}")
            
            $file.puts("; 関数#{name}の本体ここから")
            for grandchild in parent_node[1]
              digTree(child_node, grandchild, lvl + 1, jmp_whiles)
            end
            for grandchild in parent_node[2]
              digTree(child_node, grandchild, lvl + 1, jmp_whiles)
            end
            $file.puts("; 関数#{name}の本体ここまで")
            
            putsFile("#{name}_ret:")
            putsFile(nil, "mov", "esp", "ebp")
            putsFile(nil, "pop", "ebp")
            putsFile(nil, "ret")
            $local_vars.clear
            $local_ifs = 0
            $local_whiles = 0
            $local_logicals = 0
          end
        else
          $local_vars["#{name}:#{type}:level#{level}"] = pos
          $file.puts("; local_vars: #{name}:#{type}:level#{level} => #{pos}")
        end
      when "WHILE"
        $file.puts("; WHILEここから")
        whiles = $local_whiles
        $local_whiles += 1
        $file.puts("#{$functions[$functions.length-1]}_whilestart#{whiles}:")
        writeComp(child_node[1], lvl)
        putsFile(nil, "je", "#{$functions[$functions.length-1]}_whileend#{whiles}")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1, whiles)
        end
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_whilestart#{whiles}")
        $file.puts("#{$functions[$functions.length-1]}_whilemid#{whiles}:")
        $file.puts("#{$functions[$functions.length-1]}_whileend#{whiles}:")
        $file.puts("; WHILEここまで")
      when "FOR"
        $file.puts("; FORここから")
        digTree(child_node, child_node[2], lvl, jmp_whiles)
        whiles = $local_whiles
        $local_whiles += 1
        $file.puts("#{$functions[$functions.length-1]}_whilestart#{whiles}:")
        writeComp(child_node[1], lvl)
        putsFile(nil, "je", "#{$functions[$functions.length-1]}_whileend#{whiles}")
        for grandchild in child_node[4]
          digTree(child_node[4], grandchild, lvl + 1, whiles)
        end
        $file.puts("#{$functions[$functions.length-1]}_whilemid#{whiles}:")
        digTree(child_node, child_node[3], lvl, jmp_whiles)
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_whilestart#{whiles}")
        $file.puts("#{$functions[$functions.length-1]}_whileend#{whiles}:")
        $file.puts("; FORここまで")
      when "IF"
        $file.puts("; IFここから")
        ifs = $local_ifs
        $local_ifs += 1
        writeComp(child_node[1], lvl)
        putsFile(nil, "je", "#{$functions[$functions.length-1]}_else#{ifs}")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1, jmp_whiles)
        end
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_if#{ifs}")
        $file.puts("#{$functions[$functions.length-1]}_else#{ifs}:")
        $file.puts("; この先else")
        for grandchild in child_node[3]
          digTree(child_node[3], grandchild, lvl + 1, jmp_whiles)
        end
        $file.puts("#{$functions[$functions.length-1]}_if#{ifs}:")
        $file.puts("; IFここまで")
      when "CONTINUE"
        $file.puts("; CONTINUEここから")
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_whilemid#{jmp_whiles}")        
        $file.puts("; CONTINUEここまで")
      when "BREAK"
        $file.puts("; BREAKここから")
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_whileend#{jmp_whiles}")        
        $file.puts("; BREAKここまで")
      when "FCALL"
        child_node[2].length.times do |i|
          if child_node[2][child_node[2].length-1-i].instance_of?(String) == true || child_node[2][child_node[2].length-1-i].instance_of?(Fixnum) == true
            putsFile(nil, "mov", "eax", leafToCode(child_node[2][child_node[2].length-1-i]))
          else
            digTree(child_node[2], child_node[2][child_node[2].length-1-i], lvl + 1, jmp_whiles)
          end
          putsFile(nil, "push", "eax")
        end
        putsFile(nil, "call", child_node[1])
        child_node[2].length.times do |i|
          putsFile(nil, "pop", "ebx")
        end
      when "RETURN"
        # 戻り値をeaxに設定してreturnラベルに飛ぶ
        if child_node[1].instance_of?(String) == true || child_node[1].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[1]))
        else
          digTree(child_node, child_node[1], lvl + 1, jmp_whiles)
        end
        putsFile(nil, "jmp", "#{$functions[$functions.length - 1]}_ret")        

      when "="
        # 代入命令
        $file.puts("; = ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))
          putsFile(nil, "mov", leafToCode(child_node[1]), "eax")
        elsif child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))
          putsFile(nil, "mov", leafToCode(child_node[1]), "eax")          
        else
          digTree(child_node, child_node[2], lvl + 1, jmp_whiles)
          putsFile(nil, "mov", leafToCode(child_node[1]), "eax")
        end
        $file.puts("; = ここまで(#{child_node[1]}, #{child_node[2]})")
      when "+"
        # 加算命令
        $file.puts("; + ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "add", "eax", "ebx")
        $file.puts("; + ここまで(#{child_node[1]}, #{child_node[2]})")
      when "-"
        # 減算命令
        $file.puts("; - ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "sub", "eax", "ebx")
        $file.puts("; - ここまで(#{child_node[1]}, #{child_node[2]})")
      when "*"
        # 乗算命令
        $file.puts("; * ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "imul", "eax", "ebx")
        $file.puts("; * ここまで(#{child_node[1]}, #{child_node[2]})")
      when "/"
        # 除算命令
        $file.puts("; / ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "cdq")
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "idiv", "dword ebx")
        $file.puts("; / ここまで(#{child_node[1]}, #{child_node[2]})")
      when "%"
        # 剰余命令
        $file.puts("; % ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "cdq")
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "idiv", "dword ebx")
        putsFile(nil, "mov", "eax", "edx")        
        $file.puts("; % ここまで(#{child_node[1]}, #{child_node[2]})")
      when "|"
        # OR命令
        $file.puts("; | ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "or", "eax", "ebx")
        $file.puts("; | ここまで(#{child_node[1]}, #{child_node[2]})")
      when "^"
        # XOR命令
        $file.puts("; ^ ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "xor", "eax", "ebx")
        $file.puts("; ^ ここまで(#{child_node[1]}, #{child_node[2]})")
      when "&"
        # AND命令
        $file.puts("; & ここから(#{child_node[1]}, #{child_node[2]})")
        writeCompute(child_node, lvl)
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "and", "eax", "ebx")
        $file.puts("; & ここまで(#{child_node[1]}, #{child_node[2]})")
      end    

    else
      if lvl < 0
        for grandchild in child_node
          digTree(child_node, grandchild, lvl + 1, jmp_whiles)
        end
      else
          digTree(child_node, child_node[0], lvl + 1, jmp_whiles)        
      end
    end
  end
  digTree(nil, tree)
end
