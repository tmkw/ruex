require "minitest/autorun"
require "ruex"

class TestRuexCore < Minitest::Test
  include Ruex

  def test_simple_tag
    html = render("p 'hello'")
    assert_equal "<p>hello</p>", html
  end

  def test_nested_tags
    code = <<~RUBY
      html {
        body {
          div {
            p "p text"
            span "more"
          }
        }
      }
    RUBY

    html = render(code)
    assert_equal "<html><body><div><p>p text</p><span>more</span></div></body></html>", html
  end

  def test_boolean_attribute_true
    html = render('input disabled: true')
    assert_equal '<input disabled>', html
  end

  def test_boolean_attribute_false
    html = render('input disabled: false')
    assert_equal '<input>', html
  end

  def test_text_node
    html = render('div { text "p abc" }')
    assert_equal "<div>p abc</div>", html
  end

  def test_text_node_alias
    html = render('div { _ "span xyz" }')
    assert_equal "<div>span xyz</div>", html
  end

  def test_context_variable
    code = 'p a'
    html = render(code, ctx: { a: "Ruex" })
    assert_equal "<p>Ruex</p>", html
  end

  def test_context_variables_interpolation
    code = 'p "hello, #{name}"'
    html = render(code, ctx: { name: "Ruex" })
    assert_equal "<p>hello, Ruex</p>", html
  end

  def test_context_variables_multi_key
    code = 'p greeting; p  name'
    html = render(code, ctx: { greeting: "Hey!", name: "Ruex" })
    assert_equal "<p>Hey!</p><p>Ruex</p>", html
  end

  def test_context_variables_each
    code = <<~RUBY
      ul {
        items.each do |item|
          li item[:name]
        end
      }
    RUBY

    html = render(code, ctx: { items: [{name: "a"}, {name: "b"}, {name: "c"}] })
    assert_equal "<ul><li>a</li><li>b</li><li>c</li></ul>", html
  end
end

