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
            p "text"
            span "more"
          }
        }
      }
    RUBY

    html = render(code)
    assert_equal "<html><body><div><p>text</p><span>more</span></div></body></html>", html
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
    html = render('div { text "abc" }')
    assert_equal "<div>abc</div>", html
  end

  def test_text_node_alias
    html = render('div { _ "xyz" }')
    assert_equal "<div>xyz</div>", html
  end

  def test_context_variables
    code = 'p name'
    html = render(code, ctx: { name: "Ruex" })
    assert_equal "<p>Ruex</p>", html
  end

  def test_context_variables_each
    code = <<~RUBY
      ul {
        items.each do |item|
          li item
        end
      }
    RUBY

    html = render(code, ctx: { items: ["a", "b", "c"] })
    assert_equal "<ul><li>a</li><li>b</li><li>c</li></ul>", html
  end
end

