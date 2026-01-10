require "minitest/autorun"
require "tempfile"

class TestRuexCLI < Minitest::Test
  BIN = File.expand_path("../../bin/ruex", __FILE__)
  CMD = %(ruby -Ilib #{BIN})

  def test_expr_option
    result = `#{CMD} -e 'p "hello"'`
    assert_equal "<p>hello</p>\n", result
  end

  def test_file_option
    Tempfile.create(["sample", ".ruex"]) do |f|
      f.write('div { p "hi" }')
      f.flush

      result = `#{CMD} -f #{f.path}`
      assert_equal "<div><p>hi</p></div>\n", result
    end
  end

  def test_stdin
    result = `echo 'p "xyz"' | #{CMD}`
    assert_equal "<p>xyz</p>\n", result
  end

  def test_version
    result = `#{CMD} -v`
    refute_empty result
  end

  def test_help
    result = `#{CMD} -h`
    assert_match(/Usage:/, result)
  end

  def test_unknown_option
    result = `#{CMD} --unknown 2>&1`
    assert_match(/Unknown option/, result)
  end
end

