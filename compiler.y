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
  external_declaration
      : declaration
      | function_definition
  declaration
      : DATATYPE declarator_list ';'
  declarator_list
      : declarator
      | declarator_list ',' declarator
  declarator
      : IDENTIFIER
  function_definition
      : DATATYPE declarator '(' parameter_type_list_opt ')' compound_statement
  parameter_type_list
      : parameter_declaration
      | parameter_type_list ',' parameter_declaration
  parameter_type_list_opt
      : parameter_type_list
      | /* none */
  parameter_declaration
      : DATATYPE declarator
  statement
      : ';'
      | expression ';'
      | compound_statement
      | IF '(' expression ')' statement
      | IF '(' expression ')' statement ELSE statement
      | WHILE '(' expression ')' statement
      | RETURN expression ';'
  compound_statement
      : '{' declaration_list_opt statement_list_opt '}'
  declaration_list
      : declaration
      | declaration_list declaration
  declaration_list_opt
      : declaration_list
      | /* none */
  statement_list
      : statement
      | statement_list statement
  statement_list_opt
      : statement_list
      | /* none */
  expression
      : assign_expr
      | expression ',' assign_expr
  assign_expr
      : logical_OR_expr
      | IDENTIFIER '=' assign_expr
  logical_OR_expr
      : logical_AND_expr
      | logical_OR_expr LOGICALOR logical_AND_expr
  logical_AND_expr
      : equality_expr
      | logical_AND_expr LOGICALAND equality_expr
  equality_expr
      : relational_expr
      | equality_expr EQUAL relational_expr
      | equality_expr NOTEQUAL relational_expr
  relational_expr
      : add_expr
      | relational_expr '<' add_expr
      | relational_expr '>' add_expr
      | relational_expr LE add_expr
      | relational_expr GE add_expr
  add_expr
      : mult_expr
      | add_expr '+' mult_expr
      | add_expr '-' mult_expr
  mult_expr
      : unary_expr
      | mult_expr '*' unary_expr
      | mult_expr '/' unary_expr
  unary_expr
      : posifix_expr
      | '-' unary_expr
  posifix_expr
      : primary_expr
      | IDENTIFIER '(' argument_expression_list_opt ')'
  primary_expr
      : IDENTIFIER
      | CONSTANT
      | '(' expression ')'
  argument_expression_list
      : assign_expr
      | argument_expression_list ',' assign_expr
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
# puts str.inspect
if str != nil
  str.chop!
  begin
    puts "success!!! \n result => #{parser.parse(str)}"
  rescue ParseError
    puts $!
  end
end

