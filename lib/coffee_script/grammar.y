class Parser

# Declare tokens produced by the lexer
token IF ELSE UNLESS
token NUMBER STRING REGEX
token TRUE FALSE YES NO ON OFF
token IDENTIFIER PROPERTY_ACCESS
token CODE PARAM NEW RETURN
token TRY CATCH FINALLY THROW
token BREAK CONTINUE
token FOR IN WHILE
token SWITCH WHEN
token DELETE INSTANCEOF TYPEOF
token SUPER EXTENDS
token NEWLINE
token COMMENT
token JS
token INDENT OUTDENT

# Declare order of operations.
prechigh
  nonassoc UMINUS NOT '!' '!!' '~' '++' '--'
  left     '*' '/' '%'
  left     '+' '-'
  left     '<<' '>>' '>>>'
  left     '&' '|' '^'
  left     '<=' '<' '>' '>='
  right    '==' '!=' IS ISNT
  left     '&&' '||' AND OR
  right    '-=' '+=' '/=' '*=' '%='
  right    DELETE INSTANCEOF TYPEOF
  left     '.'
  right    INDENT
  left     OUTDENT
  right    THROW FOR IN WHILE WHEN NEW SUPER ELSE
  left     UNLESS EXTENDS IF
  left     ASSIGN '||=' '&&='
  right    RETURN '=>'
preclow

rule

  # All parsing will end in this rule, being the trunk of the AST.
  Root:
    /* nothing */                     { result = Expressions.new([]) }
  | Terminator                        { result = Expressions.new([]) }
  | Expressions                       { result = val[0] }
  ;

  # Any list of expressions or method body, seperated by line breaks or semis.
  Expressions:
    Expression                        { result = Expressions.new(val) }
  | Expressions Terminator Expression { result = val[0] << val[2] }
  | Expressions Terminator            { result = val[0] }
  ;

  # All types of expressions in our language.
  Expression:
    Value
  | Call
  | Code
  | Operation
  | Range
  | Assign
  | If
  | Try
  | Throw
  | Return
  | While
  | For
  | Switch
  | Extends
  | Comment
  ;

  Block:
    INDENT Expressions OUTDENT        { result = val[1] }
  | INDENT OUTDENT                    { result = Expressions.new([]) }
  ;

  # All tokens that can terminate an expression.
  Terminator:
    "\n"
  | ";"
  ;

  # All hard-coded values.
  Literal:
    NUMBER                            { result = LiteralNode.new(val[0]) }
  | STRING                            { result = LiteralNode.new(val[0]) }
  | JS                                { result = LiteralNode.new(val[0]) }
  | REGEX                             { result = LiteralNode.new(val[0]) }
  | BREAK                             { result = LiteralNode.new(val[0]) }
  | CONTINUE                          { result = LiteralNode.new(val[0]) }
  | TRUE                              { result = LiteralNode.new(true) }
  | FALSE                             { result = LiteralNode.new(false) }
  | YES                               { result = LiteralNode.new(true) }
  | NO                                { result = LiteralNode.new(false) }
  | ON                                { result = LiteralNode.new(true) }
  | OFF                               { result = LiteralNode.new(false) }
  ;

  # Assignment to a variable.
  Assign:
    Value ASSIGN Expression           { result = AssignNode.new(val[0], val[2]) }
  ;

  # Assignment within an object literal.
  AssignObj:
    IDENTIFIER ASSIGN Expression      { result = AssignNode.new(ValueNode.new(val[0]), val[2], :object) }
  | STRING ASSIGN Expression          { result = AssignNode.new(ValueNode.new(LiteralNode.new(val[0])), val[2], :object) }
  | Comment                           { result = val[0] }
  ;

  # A return statement.
  Return:
    RETURN Expression                 { result = ReturnNode.new(val[1]) }
  ;

  # A comment.
  Comment:
    COMMENT                           { result = CommentNode.new(val[0]) }
  ;

  # Arithmetic and logical operators
  # For Ruby's Operator precedence, see:
  # https://www.cs.auckland.ac.nz/references/ruby/ProgrammingRuby/language.html
  Operation:
    '!' Expression                    { result = OpNode.new(val[0], val[1]) }
  | '!!' Expression                   { result = OpNode.new(val[0], val[1]) }
  | '-' Expression = UMINUS           { result = OpNode.new(val[0], val[1]) }
  | NOT Expression                    { result = OpNode.new(val[0], val[1]) }
  | '~' Expression                    { result = OpNode.new(val[0], val[1]) }
  | '--' Expression                   { result = OpNode.new(val[0], val[1]) }
  | '++' Expression                   { result = OpNode.new(val[0], val[1]) }
  | DELETE Expression                 { result = OpNode.new(val[0], val[1]) }
  | TYPEOF Expression                 { result = OpNode.new(val[0], val[1]) }
  | Expression '--'                   { result = OpNode.new(val[1], val[0], nil, true) }
  | Expression '++'                   { result = OpNode.new(val[1], val[0], nil, true) }

  | Expression '*' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '/' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '%' Expression         { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '+' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '-' Expression         { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '<<' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '>>' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '>>>' Expression       { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '&' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '|' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '^' Expression         { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '<=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '<' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '>' Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '>=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '==' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '!=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression IS Expression          { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression ISNT Expression        { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '&&' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '||' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression AND Expression         { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression OR Expression          { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression '-=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '+=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '/=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '*=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '%=' Expression        { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '||=' Expression       { result = OpNode.new(val[1], val[0], val[2]) }
  | Expression '&&=' Expression       { result = OpNode.new(val[1], val[0], val[2]) }

  | Expression INSTANCEOF Expression  { result = OpNode.new(val[1], val[0], val[2]) }
  ;

  # Function definition.
  Code:
    ParamList "=>" Block              { result = CodeNode.new(val[0], val[2]) }
  | "=>" Block                        { result = CodeNode.new([], val[1]) }
  ;

  # The parameters to a function definition.
  ParamList:
    PARAM                             { result = val }
  | ParamList "," PARAM               { result = val[0] << val[2] }
  ;

  # Expressions that can be treated as values.
  Value:
    IDENTIFIER                        { result = ValueNode.new(val[0]) }
  | Literal                           { result = ValueNode.new(val[0]) }
  | Array                             { result = ValueNode.new(val[0]) }
  | Object                            { result = ValueNode.new(val[0]) }
  | Parenthetical                     { result = ValueNode.new(val[0]) }
  | Value Accessor                    { result = val[0] << val[1] }
  | Invocation Accessor               { result = ValueNode.new(val[0], [val[1]]) }
  ;

  # Accessing into an object or array, through dot or index notation.
  Accessor:
    PROPERTY_ACCESS IDENTIFIER        { result = AccessorNode.new(val[1]) }
  | Index                             { result = val[0] }
  | Range                             { result = SliceNode.new(val[0]) }
  ;

  # Indexing into an object or array.
  Index:
    "[" Expression "]"                { result = IndexNode.new(val[1]) }
  ;

  # An object literal.
  Object:
    "{" AssignList "}"                { result = ObjectNode.new(val[1]) }
  ;

  # Assignment within an object literal (comma or newline separated).
  AssignList:
    /* nothing */                     { result = [] }
  | AssignObj                         { result = val }
  | AssignList "," AssignObj          { result = val[0] << val[2] }
  | AssignList Terminator AssignObj   { result = val[0] << val[2] }
  | AssignList ","
      Terminator AssignObj            { result = val[0] << val[3] }
  | INDENT AssignList OUTDENT         { result = val[1] }
  ;

  # All flavors of function call (instantiation, super, and regular).
  Call:
    Invocation                        { result = val[0] }
  | NEW Invocation                    { result = val[1].new_instance }
  | Super                             { result = val[0] }
  ;

  # Extending an object's prototype.
  Extends:
    Value EXTENDS Value               { result = ExtendsNode.new(val[0], val[2]) }
  ;

  # A generic function invocation.
  Invocation:
    Value "(" ArgList ")"             { result = CallNode.new(val[0], val[2]) }
  | Invocation "(" ArgList ")"        { result = CallNode.new(val[0], val[2]) }
  ;

  # Calling super.
  Super:
    SUPER "(" ArgList ")"             { result = CallNode.new(:super, val[2]) }
  ;

  # The range literal.
  Range:
    "[" Value "." "." Value "]"       { result = RangeNode.new(val[1], val[4]) }
  | "[" Value "." "." "." Value "]"   { result = RangeNode.new(val[1], val[5], true) }
  ;

  # The array literal.
  Array:
    "[" ArgList "]"                   { result = ArrayNode.new(val[1]) }
  ;

  # A list of arguments to a method call, or as the contents of an array.
  ArgList:
    /* nothing */                     { result = [] }
  | Expression                        { result = val }
  | ArgList "," Expression            { result = val[0] << val[2] }
  | ArgList Terminator Expression     { result = val[0] << val[2] }
  | ArgList "," Terminator Expression { result = val[0] << val[3] }
  | INDENT ArgList OUTDENT            { result = val[1] }
  ;

  # Try/catch/finally exception handling blocks.
  Try:
    TRY Block Catch                   { result = TryNode.new(val[1], val[2][0], val[2][1]) }
  | TRY Block FINALLY Block           { result = TryNode.new(val[1], nil, nil, val[3]) }
  | TRY Block Catch
      FINALLY Block                   { result = TryNode.new(val[1], val[2][0], val[2][1], val[4]) }
  ;

  # A catch clause.
  Catch:
    CATCH IDENTIFIER Block            { result = [val[1], val[2]] }
  ;

  # Throw an exception.
  Throw:
    THROW Expression              { result = ThrowNode.new(val[1]) }
  ;

  # Parenthetical expressions.
  Parenthetical:
    "(" Expression ")"                { result = ParentheticalNode.new(val[1], val[0].line) }
  ;

  # The while loop. (there is no do..while).
  While:
    WHILE Expression Block            { result = WhileNode.new(val[1], val[2]) }
  ;

  # Array comprehensions, including guard and current index.
  # Looks a little confusing, check nodes.rb for the arguments to ForNode.
  For:
    Expression FOR
      ForVariables ForSource          { result = ForNode.new(val[0], val[3][0], val[2][0], val[3][1], val[2][1]) }
  | FOR ForVariables ForSource Block  { result = ForNode.new(val[3], val[2][0], val[1][0], val[2][1], val[1][1]) }
  ;

  # An array comprehension has variables for the current element and index.
  ForVariables:
    IDENTIFIER                        { result = val }
  | IDENTIFIER "," IDENTIFIER         { result = [val[0], val[2]] }
  ;

  # The source of the array comprehension can optionally be filtered.
  ForSource:
    IN Expression                     { result = [val[1]] }
  | IN Expression
    WHEN Expression                   { result = [val[1], val[3]] }
  ;

  # Switch/When blocks.
  Switch:
    SWITCH Expression INDENT
      Whens OUTDENT                   { result = val[3].rewrite_condition(val[1]) }
  | SWITCH Expression INDENT
      Whens ELSE Block OUTDENT        { result = val[3].rewrite_condition(val[1]).add_else(val[5]) }
  ;

  # The inner list of whens.
  Whens:
    When                              { result = val[0] }
  | Whens When                        { result = val[0] << val[1] }
  ;

  # An individual when.
  When:
    WHEN Expression Block             { result = IfNode.new(val[1], val[2], nil, {:statement => true}) }
  | WHEN Expression Block Terminator  { result = IfNode.new(val[1], val[2], nil, {:statement => true}) }
  | Comment
  ;

  # All of the following nutso if-else destructuring is to make the
  # grammar expand unambiguously.

  IfBlock:
    IF Expression Block               { result = IfNode.new(val[1], val[2]) }
  ;

  # An elsif portion of an if-else block.
  ElsIf:
    ELSE IfBlock                      { result = val[1].force_statement }
  ;

  # Multiple elsifs can be chained together.
  ElsIfs:
    ElsIf                             { result = val[0] }
  | ElsIfs ElsIf                      { result = val[0].add_else(val[1]) }
  ;

  # Terminating else bodies are strictly optional.
  ElseBody
    /* nothing */                     { result = nil }
  | ELSE Block                        { result = val[1] }
  ;

  # All the alternatives for ending an if-else block.
  IfEnd:
    ElseBody                          { result = val[0] }
  | ElsIfs ElseBody                   { result = val[0].add_else(val[1]) }
  ;

  # The full complement of if blocks, including postfix one-liner ifs and unlesses.
  If:
    IfBlock IfEnd                     { result = val[0].add_else(val[1]) }
  | Expression IF Expression          { result = IfNode.new(val[2], Expressions.new([val[0]]), nil, {:statement => true}) }
  | Expression UNLESS Expression      { result = IfNode.new(val[2], Expressions.new([val[0]]), nil, {:statement => true, :invert => true}) }
  ;

end

---- header
module CoffeeScript

---- inner
  # Lex and parse a CoffeeScript.
  def parse(code)
    # Uncomment the following line to enable grammar debugging, in combination
    # with the -g flag in the Rake build task.
    # @yydebug = true
    @tokens = Lexer.new.tokenize(code)
    do_parse
  end

  # Retrieve the next token from the list.
  def next_token
    @tokens.shift
  end

  # Raise a custom error class that knows about line numbers.
  def on_error(error_token_id, error_value, value_stack)
    raise ParseError.new(token_to_str(error_token_id), error_value, value_stack)
  end

---- footer
end