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
      | program external_declaration
        {
	  result = [val[0], val[1]] 
        }  
  external_declaration
      : declaration
      | function_definition
  declaration
      : DATATYPE declarator_list ';'
        {
	  result = []
	  for i in val[1]
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
      : DATATYPE declarator '(' parameter_type_list_opt ')' compound_statement
        {
	  result = [ [val[0], val[1]], val[3], val[5] ]
        }  
  parameter_type_list
      : parameter_declaration
        {
	  result = [val[0]]
	}
      | parameter_type_list ',' parameter_declaration
        {
          result = [val[0]] + [val[2]]
        }  
  parameter_type_list_opt
      : parameter_type_list
      | /* none */
  parameter_declaration
      : DATATYPE declarator
        {
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
      : '{' declaration_list_opt statement_list_opt '}'
        {
	  result = []
          if val[1] != nil
	    result += val[1]
	  end
	  if val[2] != nil
	    result += val[2]
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
	  result = ['FCALL',val[0]] + [val[2]]
        }
  primary_expr
      : IDENTIFIER
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
	  result = [val[0], val[2]]
        }
  argument_expression_list_opt
      : argument_expression_list
      | /* none */
end

---- header
# $Id: calc.y,v 1.4 2005/11/20 13:29:32 aamine Exp $
---- inner
  
  def parse(str)
    @q = []
    until str.empty?
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
    puts "success!!! \n result => \n#{parser.parse(str)}"
  rescue ParseError
    puts $!
  end
end

