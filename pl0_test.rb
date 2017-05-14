# frozen_string_literal: true
load 'pl0'

require 'parslet/convenience'
require 'minitest'
require 'minitest/autorun'
require 'minitest/pride'

class ParserTest < MiniTest::Test
  def setup
    @parser = Parser.new
  end

  def test_print_statement
    tree = @parser.statement.parse('p 4')
  end

  def test_print_statement
    tree = @parser.statement.parse('p foo')
  end

  def test_assignment
    tree = @parser.statement.parse('a =  4')
  end

  def test_if_else_statement
    input = <<~EOS
      if (true) {
        b = 45
      } else {
        foo = bar
      }
    EOS

    tree = @parser.statement.parse(input)
  end

  def test_nested_statements
    input = <<~EOS
      while (i < 4) {
          if ( foo == bar ) {
              p "HELLO"
          } else {}
      }
    EOS

    tree = @parser.statement.parse_with_debug(input)
  end

  def test_while_loop
    input = <<~EOS
      while(true) {
        foo = 1 + b
      }
    EOS

    tree = @parser.statement.parse(input)
  end

  def test_while_loop2
    input = <<~EOS
      while (i > 1) {
        foo = 1 + b
        a = 3
      }
    EOS

    tree = @parser.while_statement.parse(input)
  end

  def test_exp
    tree = @parser.exp.parse "2 + 4 * 2"
  end

  def test_exp2
    tree = @parser.exp.parse "5 <= (3-9/2)"
  end

  def test_exp3
    tree = @parser.exp.parse "!!(5*5) == foo"
  end

  def test_exp3
    tree = @parser.exp.parse 'i > 0'
  end

  def test_program
    input = <<~EOS
      a=3
      b=false
      c=a*b

      if (true) {} else {

      }

      p c
    EOS
    tree = @parser.parse(input)
  end

  def test_program2
    @parser.parse('')
  end

  def test_program3
    input = <<~EOS
      i = 10
      while (i > 0) {
          p i
          i = i - 1
      }
    EOS

    @parser.parse input
  end
end

class InterpreterTest < MiniTest::Test
  def setup
    @i = Interpreter.new
  end

  def test_int_literal
    result = @i.interpret_exp '3'
    assert_equal 3, result
  end

  def test_string_literal
    result = @i.interpret_exp '"foobar"'
    assert_equal "foobar", result
  end

  def test_single_asignment
    result = @i.interpret 'a = 10'
    assert_equal @i.variables['a'], 10
  end

  def test_bool_literal
    result = @i.interpret_exp 'true'
    assert_equal true, result

    result = @i.interpret_exp 'false'
    assert_equal false, result
  end

  def test_interpret_print_statement
    assert_output /34/ do
      @i.interpret 'p 17*2'
    end
  end

  def test_addition
    result = @i.interpret_exp '2 + 2'
    assert_equal 4, result

    result = @i.interpret_exp '2 + 2 + 2'
    assert_equal 6, result

    result = @i.interpret_exp '2 + 2-3'
    assert_equal 1, result
  end

  def test_multiplication
    result = @i.interpret_exp '4*3'
    assert_equal 12, result

    result = @i.interpret_exp '3*16/2'
    assert_equal 24, result
  end

  def test_precedence
    result = @i.interpret_exp '2 + 8 * 3 / 2'
    assert_equal 14, result
  end

  def test_comparison
    result = @i.interpret_exp '2 < 4'
    assert_equal true, result

    result = @i.interpret_exp '2 > 4'
    assert_equal false, result

    result = @i.interpret_exp '4 == 2 + 2'
    assert_equal true, result

    result = @i.interpret_exp '6-2 <= 4+4+4-4'
    assert_equal true, result
  end

  def test_if_statement
    input = <<~EOS
      if (3 < 8) {
        p "hello"
      } else {
        p "bye"
     }
    EOS

    assert_output /hello/ do
      @i.interpret input
    end
  end

  def test_assignment
    input = <<~EOS
      a = 3
      foo = a
      a = 99
      p foo
      p a
    EOS

    assert_output /3\n99/ do
      @i.interpret input
    end
  end

  def test_paren_exp
    input = '(2 + 8) * 11'
    result = @i.interpret_exp input
    assert_equal 110, result
  end

  def test_modulo
    input = '3 * 9 % 2'
    result = @i.interpret_exp input
    assert_equal 1, result
  end

  def test_program
    input = <<~EOS
      foo = 2
      bar = 34
      baz = foo + bar / 2
      p baz + 4
    EOS

    assert_output /23/ do
      @i.interpret input
    end
  end

  def test_program2
    input = <<~EOS
      foo = 2
      bar = 34  
      baz = (foo + bar) / 2
      p baz + 4
    EOS

    assert_output /22/ do
      @i.interpret input
    end
  end

  def test_program3
    input = <<~EOS
      i = 10

      while (i > 0) {
          p i
          i = i - 1
      }
    EOS

    assert_output /10\n9\n8\n7\n6\n5\n4\n3\n2\n1/ do
      @i.interpret input
    end
  end

  def test_program4
    input = <<~EOS
      i = 1
      while (i <= 20)
      {
          if (i % 3 == 0)
          {
              p "Foo"
          } else {}

          if (i % 5 == 0)
          {
              p "Bar"
          } else {}

          i = i + 1
      }
    EOS

    expected = <<~EOS
      Foo
      Bar
      Foo
      Foo
      Bar
      Foo
      Foo
      Bar
      Foo
      Bar
    EOS

    assert_output /#{expected}/ do
      @i.interpret input
    end
  end
end
