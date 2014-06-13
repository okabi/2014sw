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
	  result = [['IF'] + val[2] + [val[4]]]
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
      elsif n[0] == "IF" || n[0] == "WHILE"
        culcNLocal(n[2])
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

