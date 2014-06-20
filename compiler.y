# $Id: compiler.y
#
# TinyC compiler

class Tinyc
  prechigh
    right DATATYPE
    right IF
    right ELSE
    right WHILE
    right RETURN
    left LE
    left GE
    left EQUAL
    left NOTEQUAL
    left LOGICALAND
    left LOGICALOR
    left '*' '/' '%'
    left '+' '-'
    left '<' '>'
    right '='
    right '(' '{'
    left ')' '}'
  preclow

rule
  program
      : external_declaration
        {
	  if @error_num > 0
            result = ''
          end
        } 
      | program external_declaration
        {
	  if @error_num > 0
            result = ''
          else
	    result = val[0] + val[1] 
          end
        }  
  external_declaration
      : declaration
      {
	result = val[0]
      }
      | function_definition
      {
	result = [val[0]]
      }
  declaration
      : DATATYPE declarator_list ';'
        {
	  result = []
	  for i in val[1]
	    check = findObject(i, 'VAR')
	    if check['level'] == @level
	      error(0, i, check['level'])
	    else
  	      check2 = findObject(i, 'FUN')
	      if check2['level'] == @level
	        error(1, i, check2['level']) 
	      else
	        if check['level'] >= 0
	          warning(0, i, check['level'])
                end
                if check2['level'] >= 0
	          warning(1, i, check2['level'])
		end
		@stack.push(Object.new(i, @level, 'VAR', 0))
	      end
	    end
	    @add_sp -= 4
	    i += ':VAR:level' + @level.to_s
            if @level > 0
              i += "(#{@add_sp})"
	    end
	    result += [ [val[0], i ] ]
	  end
        }  
  declarator_list
      : declarator
        {
	  result = [val[0]]
        }
      | declarator_list ',' declarator
        {
	  result += [val[2]]
        }  
  declarator
      : IDENTIFIER
  function_definition
      : DATATYPE IDENTIFIER '('
        {
          @level += 1
	  @add_sp = 4
	  @stack.push(Object.new('_UNKNOWN', 0, 'FUN', 0))
	}   
        parameter_type_list_opt ')' 
	{
	  @add_sp = 0
	}
        compound_statement
        {
	  popStack(@level)
	  @level -= 1
  	  check = findObject(val[1], 'VAR')
	  if check['level'] >= 0
	    error(0, val[1], check['level'])
	  else
  	    check2 = findObject(val[1], 'FUN')
	    if check2['level'] >= 0
	      error(1, val[1], check2['level'])
	    else
	      if val[4] == nil
                changeFunctionInfo(val[1], 0)
	      else
                changeFunctionInfo(val[1], val[4].length)
              end
	    end
	  end
	  while @error_stack.length > 0
            obj = @error_stack.pop
  	    check = findObject(obj.name, 'FUN')
	    if check['level'] < 0
	      warning(2, obj.name, -1)
	      insertStackUndefFun(obj.name, obj.offset)
	    elsif obj.offset != check['size']
	      error(2, obj.name, check['size'])
	    end	    
          end
	  result = [ [val[0], val[1]+':FUN:level0'], val[4], val[7] ]
        }  
  parameter_type_list
      : parameter_declaration
        {
	  result = [val[0]]
	}
      | parameter_type_list ',' parameter_declaration
        {
          result = val[0] + [val[2]]
        }  
  parameter_type_list_opt
      : parameter_type_list
      | /* none */
      {
	result = []
      }
  parameter_declaration
      : DATATYPE declarator
        {
	  check = findObject(val[1], 'VAR')
	  if check['level'] == @level
	    error(0, val[1], check['level'])
	  else
  	    check2 = findObject(val[1], 'FUN')
	    if check2['level'] == @level
	      error(1, val[1], check2['level']) 
	    else
	      if check['level'] >= 0
	        warning(0, val[1], check['level'])
              end
	      if check2['level'] >= 0
	        warning(1, val[1], check2['level'])
	      end
  	      @stack.push(Object.new(val[1], @level, 'VAR', 0))
	      @add_sp += 4
	      val[1] += ':VAR:level' + @level.to_s + "(#{@add_sp})"
	    end
	  end
	  result = [val[0], val[1]]
        }  
  statement
      : ';'
        {
	  result = ''
        }       
      | expression ';'
        {
	  result = val[0]
        }       
      | compound_statement
      | IF '(' expression ')' statement
        {
	  result = [['IF'] + val[2] + [val[4], []]]
        }       
      | IF '(' expression ')' statement ELSE statement
        {
	  result = [['IF'] + val[2] + [val[4], val[6]]]
        }       
      | WHILE '(' expression ')' statement
        {
	  result = [['WHILE'] + val[2] + [val[4]]]
        }       
      | RETURN expression ';'
        {
	  result = [['RETURN'] + val[1]]
        }       
  compound_statement
      : '{'
        {
	  @level += 1
        }   
        declaration_list_opt statement_list_opt '}'
        {
	  popStack(@level)
	  @level -= 1
	  result = []
          if val[2] != nil
	    result += val[2]
	  end
	  if val[3] != nil
	    result += val[3]
	  end
        }       
  declaration_list
      : declaration
      | declaration_list declaration
        {
	  result = [val[0], val[1]]
        }
  declaration_list_opt
      : declaration_list
      | /* none */
  statement_list
      : statement
      | statement_list statement
        {
	  result = val[0] + val[1]
        }       
  statement_list_opt
      : statement_list
      | /* none */
  expression
      : assign_expr
        {
	  result = [val[0]]
	}
      | expression ',' assign_expr
        {
	  result = [val[0], val[2]]
        }       
  assign_expr
      : logical_OR_expr
      | IDENTIFIER '=' assign_expr
        {
  	  check = findObject(val[0], 'VAR')
	  if check['level'] < 0
	    error(3, val[0], -1)
	  end
	  val[0] += ":VAR:level#{check['level']}"
	  result = ['=', val[0], val[2]]
        }       
  logical_OR_expr
      : logical_AND_expr
      | logical_OR_expr LOGICALOR logical_AND_expr
        {
	  result = ['||', val[0], val[2]]
        }
  logical_AND_expr
      : equality_expr
      | logical_AND_expr LOGICALAND equality_expr
        {
	  result = ['&&', val[0], val[2]]
        }
  equality_expr
      : relational_expr
      | equality_expr EQUAL relational_expr
        {
	  result = ['==', val[0], val[2]]
        }
      | equality_expr NOTEQUAL relational_expr
        {
	  result = ['!=', val[0], val[2]]
        }
  relational_expr
      : add_expr
      | relational_expr '<' add_expr
        {
	  result = ['<', val[0], val[2]]
        }
      | relational_expr '>' add_expr
        {
	  result = ['>', val[0], val[2]]
        }
      | relational_expr LE add_expr
        {
	  result = ['<=', val[0], val[2]]
        }
      | relational_expr GE add_expr
        {
	  result = ['>=', val[0], val[2]]
        }
  add_expr
      : mult_expr
      | add_expr '+' mult_expr
        {
	  result = ['+', val[0], val[2]]
        }
      | add_expr '-' mult_expr
        {
	  result = ['-', val[0], val[2]]
        }
  mult_expr
      : unary_expr
      | mult_expr '*' unary_expr
        {
	  result = ['*', val[0], val[2]]
        }
      | mult_expr '/' unary_expr
        {
	  result = ['/', val[0], val[2]]
        }
  unary_expr
      : posifix_expr
      | '-' unary_expr
        {
	  result = -(val[1].to_i).to_s
        }
  posifix_expr
      : primary_expr
      | IDENTIFIER '(' argument_expression_list_opt ')'
        {
  	  check = findObject(val[0], 'FUN')
	  if check['level'] < 0
            if val[2] != nil
	      @error_stack.push(Object.new(val[0], 0, 'UNDEFFUN', val[2].length))
	    else
	      @error_stack.push(Object.new(val[0], 0, 'UNDEFFUN', 0))
            end
	  elsif (val[2] == nil && check['size'] != 0) || val[2].length != check['size']
	    error(2, val[0], check['size'])
	  end
          if val[2] == nil
	    result = ['FCALL',val[0], []]
	  else
	    result = ['FCALL',val[0]] + [val[2]]
          end
        }
  primary_expr
      : IDENTIFIER
        {
  	  check = findObject(val[0], 'VAR')
	  if check['level'] < 0
	    error(3, val[0], -1)
	  end
	  val[0] += ":VAR:level#{check['level']}"
          result = val[0]
	}
      | CONSTANT
      | '(' expression ')'
        {
	  result = [val[1]]
        }
  argument_expression_list
      : assign_expr
        {
	  result = [val[0]]
        }  
      | argument_expression_list ',' assign_expr
        {
	  result = val[0] + [val[2]]
        }
  argument_expression_list_opt
      : argument_expression_list
      | /* none */
end

---- header
---- inner

  class Object
    def initialize(name, level, type, offset)
      @name = name
      @level = level
      @type = type
      @offset = offset
    end
    def changeType(type) 
      @type = type
    end
    attr_reader :level, :type
    attr_accessor :name, :offset
  end

  def initialize()
    @stack = []
    @level = 0
    @error_stack = []
    @error_num = 0
    @add_sp = 0
  end

  def popStack(level)
    while @stack[@stack.length-1].level >= level
      if @stack[@stack.length-1].type == 'VAR'
        if @stack[@stack.length-1].level == 1
	  @add_sp -= 4
        else
	  @add_sp += 4
        end
      end
      @stack.pop
    end
  end

  def findObject(name, type)
    ret = {}
    ret['level'] = -1
    ret['size'] = -1
    i = @stack.length-1
    while i >= 0
      if @stack[i].name == name && @stack[i].type == type
        ret['level'] = @stack[i].level
        ret['size'] = @stack[i].offset
        break
      end
      i -= 1
    end
    return ret
  end

  def insertStackUndefFun(name, size)
    obj = Object.new(name, 0, 'UNDEFFUN', size)
    i = @stack.length - 1
    while i >= 0
      if @stack[i].level == 0
        break
      else
	i -= 1
      end
    end
    if i > 0
      @stack = @stack[0..(i-1)] + [obj] + @stack[i..(@stack.length-1)]
    else
      @stack = [obj] + @stack
    end	
  end

  def changeFunctionInfo(name, size)
    i = @stack.length - 1
    while i >= 0
      if @stack[i].type == 'FUN'
	@stack[i].name = name
	@stack[i].offset = size
	break
      end
      i -= 1
    end
  end

  def error(type, name, level)
    @error_num += 1
    print "error: "
    if type == 0
      puts "Variable '#{name}' is already defined at same level(level#{level})."
    elsif type == 1
      puts "Function '#{name}' is already defined at same level(level#{level})."
    elsif type == 2
      puts "Parameter-length of function '#{name}' is #{level}."
    elsif type == 3
      puts "Variable '#{name}' is NOT defined."
    else
      puts "Undefined type."
    end
  end

  def warning(type, name, level)
    print "warning: "
    if type == 0
      puts "Variable '#{name}' is already defined at level #{level}."
    elsif type == 1
      puts "Function '#{name}' is already defined at level #{level}."
    elsif type == 2
      puts "Function '#{name}' is NOT defined."
    else
      puts "Undefined type."
    end
  end
  
  def parse(str)
    @q = []
    until str.empty?
      # puts str.inspect
      case str
      when /\A\s+/
      when /\A\d+/
        @q.push [:CONSTANT, $&.to_i]
      when /\A(&&)/
        @q.push [:LOGICALAND, $&]
      when /\A(\|\|)/
        @q.push [:LOGICALOR, $&]
      when /\A(int)/
        @q.push [:DATATYPE, $&]
      when /\A(if)/
        @q.push [:IF, $&]
      when /\A(else)/
        @q.push [:ELSE, $&]
      when /\A(while)/
        @q.push [:WHILE, $&]
      when /\A(<=)/
        @q.push [:LE, $&]
      when /\A(>=)/
        @q.push [:GE, $&]
      when /\A(==)/
        @q.push [:EQUAL, $&]
      when /\A(!=)/
        @q.push [:NOTEQUAL, $&]
      when /\A(return)/
        @q.push [:RETURN, $&]
      when /\A[a-zA-Z]\w*/
	@q.push [:IDENTIFIER, $&]
      when /\A.|\n/o
        s = $&
        @q.push [s, s]
      end
      str = $'
    end
    @q.push [false, '$end']
    do_parse
  end

  def next_token
    @q.shift
  end

---- footer

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
    # 比較演算ノードを渡して、比較演算を行うコードを出力する
    def writeComp(base_node, lv)
      def comp(node, lev)
        # 先頭要素が比較演算子
        if node[2].instance_of?(String) == true || node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(node[2]))          
          putsFile(nil, "push", "eax")
        else
          digTree(node, node[2], lev + 1)
          putsFile(nil, "push", "eax")
        end
        if node[1].instance_of?(String) == true || node[1].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(node[1]))
        else
          digTree(node, node[1], lev + 1)
        end
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
          if node[1][0].instance_of?(String) == false || node[1][0] == "&&" || node[1][0] == "||"
            logical(node[1], lv)
          else
            comp(node[1], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "je", "#{$functions[$functions.length-1]}_logical#{$local_logicals}")
          if node[1][0].instance_of?(String) == false || node[2][0] == "&&" || node[2][0] == "||"
            logical(node[2], lv)
          else
            comp(node[2], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "je", "#{$functions[$functions.length-1]}_logical#{$local_logicals}")
          putsFile(nil, "pop", "eax")
          putsFile(nil, "mov", "eax", "1")
          putsFile(nil, "push", "eax")          
          $file.puts("#{$functions[$functions.length-1]}_logical#{$local_logicals}:")
          putsFile(nil, "pop", "eax")          
          $local_logicals += 1        
          putsFile(nil, "cmp", "eax", 0)
          $file.puts("; && ここまで(#{node[1]}, #{node[2]})")        
        when "||"
          $file.puts("; || ここから(#{node[1]}, #{node[2]})")
          putsFile(nil, "mov", "eax", "1")
          putsFile(nil, "push", "eax")          
          if node[1][0].instance_of?(String) == false || node[1][0] == "&&" || node[1][0] == "||"
            logical(node[1], lv)
          else
            comp(node[1], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "jne", "#{$functions[$functions.length-1]}_logical#{$local_logicals}")
          if node[1][0].instance_of?(String) == false || node[2][0] == "&&" || node[2][0] == "||"
            logical(node[2], lv)
          else
            comp(node[2], lv)
          end
          putsFile(nil, "cmp", "eax", "0")          
          putsFile(nil, "jne", "#{$functions[$functions.length-1]}_logical#{$local_logicals}")
          putsFile(nil, "pop", "eax")
          putsFile(nil, "mov", "eax", "0")
          putsFile(nil, "push", "eax")          
          $file.puts("#{$functions[$functions.length-1]}_logical#{$local_logicals}:")
          putsFile(nil, "pop", "eax")          
          $local_logicals += 1        
          putsFile(nil, "cmp", "eax", 0)
          $file.puts("; || ここまで(#{node[1]}, #{node[2]})")        
        end
      end
      
      if base_node[0] == "&&" || base_node[0] == "||"
        logical(base_node, lv)
      else
        comp(base_node, lv)
      end
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
            putsFile(nil, "GLOBAL", name)
            putsFile(name, "push", "ebp")           
            putsFile(nil, "mov", "ebp", "esp")
            $n_local = 0
            culcNLocal(parent_node[2])
            putsFile(nil, "sub", "esp", "#{$n_local}")
            
            $file.puts("; 関数#{name}の本体ここから")
            for grandchild in parent_node[1]
              digTree(child_node, grandchild, lvl + 1)
            end
            for grandchild in parent_node[2]
              digTree(child_node, grandchild, lvl + 1)
            end
            $file.puts("; 関数#{name}の本体ここまで")
            
            putsFile("#{name}_ret", "mov", "esp", "ebp")
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
        $file.puts("#{$functions[$functions.length-1]}_whilestart#{$local_whiles}:")
        writeComp(child_node[1], lvl)
        putsFile(nil, "je", "#{$functions[$functions.length-1]}_whileend#{$local_whiles}")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1)
        end
        putsFile(nil, "jmp", "#{$functions[$functions.length-1]}_whilestart#{$local_whiles}")
        $file.puts("#{$functions[$functions.length-1]}_whileend#{$local_whiles}:")
        $local_whiles += 1
        $file.puts("; WHILEここまで")
      when "IF"
        $file.puts("; IFここから")
        writeComp(child_node[1], lvl)
        putsFile(nil, "je", "#{$functions[$functions.length-1]}_if#{$local_ifs}")
        for grandchild in child_node[2]
          digTree(child_node[2], grandchild, lvl + 1)
        end
        $file.puts("#{$functions[$functions.length-1]}_if#{$local_ifs}:")
        $local_ifs += 1
        $file.puts("; この先else")
        for grandchild in child_node[3]
          digTree(child_node[3], grandchild, lvl + 1)
        end
        $file.puts("; IFここまで")
      when "FCALL"
        # 引数に数式が使われている場合は上手くいかないので、もう少し検討する
        child_node[2].length.times do |i|
          if child_node[2][child_node[2].length-1-i].instance_of?(String) == true || child_node[2][child_node[2].length-1-i].instance_of?(Fixnum) == true
            putsFile(nil, "mov", "eax", leafToCode(child_node[2][child_node[2].length-1-i]))
          else
            digTree(child_node[2], child_node[2][child_node[2].length-1-i], lvl + 1)
          end
          putsFile(nil, "push", "eax")
        end
        if $functions.index(child_node[1]) == nil
          putsFile(nil, "EXTERN", child_node[1])          
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
          digTree(child_node, child_node[1], lvl + 1)
        end
        putsFile(nil, "jmp", "#{$functions[$functions.length - 1]}_ret")        

      when "="
        # 代入命令
        $file.puts("; = ここから(#{child_node[1]}, #{child_node[2]})")
        if child_node[2].instance_of?(String) == true
          putsFile(nil, "mov", leafToCode(child_node[1]), leafToCode(child_node[2]))
        elsif child_node[2].instance_of?(Fixnum) == true
          putsFile(nil, "mov", "eax", leafToCode(child_node[2]))
          putsFile(nil, "mov", leafToCode(child_node[1]), "eax")          
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
        # 除算命令
        $file.puts("; / ここから(#{child_node[1]}, #{child_node[2]})")
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
        putsFile(nil, "cdq")
        putsFile(nil, "pop", "ebx")        
        putsFile(nil, "idiv", "dword ebx")
        $file.puts("; / ここまで(#{child_node[1]}, #{child_node[2]})")
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





parser = Tinyc.new

str = ''
while true
  add = gets
  if add == nil
    break
  else
    str += add
  end
end
if str != nil
  str.chop!
  begin
    puts "parse success!!!"
    tree = parser.parse(str)
    puts " result => \n#{tree}"
    generateAssemble(tree)
  rescue ParseError
    puts $!
  end
end
