require_relative "test_helper"
require "minitest/autorun"
require "tempfile"
require "json"
require "yaml"

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

  def test_include_path
    Dir.mktmpdir do |dir|
      File.write("#{dir}/custom.rb", <<~RUBY)
        module Custom
          def custom_tag
            div { _"OK" }
          end
        end
      RUBY

      result = `#{CMD} -I #{dir} -r custom -e 'custom_tag'`
      assert_equal "<div>OK</div>\n", result
    end
  end

  def test_require_custom_tag
    Dir.mktmpdir do |dir|
      File.write("#{dir}/my_tag.rb", <<~RUBY)
        module MyTag
          def my_tag
            p "TAG"
          end
        end
      RUBY

      result = `#{CMD} -I #{dir} -r my_tag -e 'my_tag'`
      assert_equal "<p>TAG</p>\n", result
    end
  end

  def test_bind_option_hash_literal
    result = `#{CMD} -b '{a: "ちゃん"}' -e 'p a'`
    assert_equal "<p>ちゃん</p>\n", result
  end

  def test_bind_option_multiple_keys
    result = `#{CMD} -b '{a: 1, b: 2}' -e 'p a; p b'`
    assert_equal "<p>1</p><p>2</p>\n", result
  end

  def test_bind_option_array
    result = `#{CMD} -b '{people: [hoge, bar]}' -e 'people.each { |name| p name }'`
    assert_equal "<p>hoge</p><p>bar</p>\n", result
  end

  def test_bind_option_nested_array
    result = `#{CMD} -b '{people: [{name: "hoge"}, {name: "bar"}]}' -e 'people.each { |person| p person[:name] }'`
    assert_equal "<p>hoge</p><p>bar</p>\n", result
  end

  def test_bind_option_invalid_yaml
    result = `#{CMD} -b '{a: !!ruby/object:Foo {}}' -e 'p a' 2>&1`
    assert_match("<p>{}</p>\n", result)
  end

  def test_bind_option_not_hash
    result = `#{CMD} -b '[1,2,3]' -e 'p x' 2>&1`
    assert_match(/-b expects a Hash literal/, result)
  end

  def test_bind_option_syntax_error
    result = `#{CMD} -b '{a: 1,,}' -e 'p a' 2>&1`
    assert_match(/Invalid -b hash/, result)
  end

  def test_context_file_yaml
    Tempfile.create(["ctx", ".yml"]) do |f|
      f.write({ "msg" => "YAML_OK" }.to_yaml)
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p msg'`
      assert_equal "<p>YAML_OK</p>\n", result
    end
  end

  def test_context_file_yaml_unsafe
    Tempfile.create(["ctx", ".yml"]) do |f|
      f.write("foo: !ruby/object:OpenStruct {}\n")
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p foo' 2>&1`
      assert_match(/disallowed class/, result)
    end
  end

  def test_context_file_json
    Tempfile.create(["ctx", ".json"]) do |f|
      f.write({ msg: "JSON_OK" }.to_json)
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p msg'`
      assert_equal "<p>JSON_OK</p>\n", result
    end
  end

  def test_context_file_invalid_format
    Tempfile.create(["ctx", ".txt"]) do |f|
      f.write("invalid")
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p x' 2>&1`
      assert_match(/Unknown context file format/, result)
    end
  end

  def test_require_nested_module
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p("#{dir}/foo")
      File.write("#{dir}/foo/bar.rb", <<~RUBY)
        module Foo
          module Bar
            def nested_tag
              p "NESTED"
            end
          end
        end
      RUBY

      result = `#{CMD} -I #{dir} -r foo/bar -e 'nested_tag'`
      assert_equal "<p>NESTED</p>\n", result
    end
  end

  def test_context_file_not_found
    result = `#{CMD} -c /no/such/file.yml -e 'p x' 2>&1`
    assert_match(/No such file or directory/, result)
  end

  def test_context_file_unsupported_extension
    Tempfile.create(["ctx", ".txt"]) do |f|
      f.write("dummy")
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p x' 2>&1`
      assert_match(/Unknown context file format/, result)
    end
  end

  def test_context_file_wrong_type
    Tempfile.create(["ctx", ".yml"]) do |f|
      f.write([1, 2, 3].to_yaml)
      f.flush

      result = `#{CMD} -c #{f.path} -e 'p x' 2>&1`
      assert_match(/top-level Hash\/Map/, result)
    end
  end
end

