# ruex

[![Gem Version](https://badge.fury.io/rb/ruex.svg)](https://badge.fury.io/rb/ruex)

A library and CLI tool that generates HTML using plain Ruby expressions.
It is intended for static site or page generation, and is not suitable as a dynamic web page renderer.

Technically, you only need to know HTML, CSS, and Ruby — nothing more.
Easy to extend when needed.

---

## Installation

```sh
gem install ruex
```

Or add to your Gemfile:

```ruby
gem "ruex"
```

---

## Quick Example

```shell
$ ruex -e 'div { p "hello" }'
<div><p>hello</p></div>

# same thing by the command pipeline
$ echo 'div { p "hello" }' | ruex
<div><p>hello</p></div>
```

## How it works

Every standard HTML tag is available as a Ruby method.

```shell
$ ruex -e 'p "hello"'
<p>hello</p>
```

### Attributes

```shell
$ ruex -e 'p "Hi", class: "msg"'
<p class="msg">Hi</p>
```

### Blocks

You can write child elements inside blocks:

```shell
$ ruex -e 'div { p "Hello" }'
<div><p>Hello</p></div>
```

### Mixing Ruby code

You can freely mix Ruby code.

```shell
$ cat list.html.rx
ul{
  %w[Foo Bar].each do |name|
    li(name)
  end
}

$ cat list.html.rx | ruex
<ul><li>Foo</li><li>Bar</li></ul>
```

### Variable binding

```shell
$ cat table.html.rx
table {
  people.each do |person|
    tr{ td(person[:name]) }
  end
}

$ cat table.html.rx | ruex -b '{people: [{name: "hoge"}, {name: "bar"}]}'
<table><tr><td>hoge</td></tr><tr><td>bar</td></tr></table>
```

### Embedding text

`text` and `_` functions embed texts in HTML:

```shell
$ ruex -e 'text "Today is a good day"'
Today is a good day

$ ruex -e '_"Today is a good day"'
Today is a good day

$ ruex -e 'div{ _"Today is a good day" }'
<div>Today is a good day</div>
```

### HTML comments

ruex does not provide a comment function.
If you want to include an HTML comment, write it directly as a string:

```shell
$ ruex -e 'div { _"<!-- note -->" }'
<div><!-- note --></div>
```

### Custom Tags

Just compose HTML using ruex expressions.

```ruby
# my_tags.rb

require 'ruex'

module MyTag
  include Ruex

  def card(title, &block)
    div(class: "card"){
      h2 title
      block.call if block_given?
    }
  end
end
```

There are a few things you should know:

- you must provide your custom tag library as a module.
- Your module name must correspond to its file name (PascalCase → snake_case).
  ex) MyTag -> my_tag.rb


You can use your library throuth `ruex` command, of course.

```shell
$ ruex -I /your/ruby/load/path -r my_tags.rb -e 'card("Hello") { p "world" }'
<div class="card"><h2>Hello</h2><p>world</p></div>
```

If you make your custom tag library as Ruby gems, you don't need to specify `-I`.

### CLI options

```shell
$ ruex -h
Render ruex expressions as HTML.

Usage:
  echo 'p "hello"' | ruex
  ruex -e 'p "hello"'
  ruex -f template.ruex

Options:
  -I, --include-path PATH     Add PATH to $LOAD_PATH
  -r, --require LIB           Require LIB and include its module into Ruex::Core
  -e, --expr EXPR             Evaluate EXPR instead of reading from stdin
  -f, --file FILE             Read Ruex DSL from FILE
  -b, --bind KEY=VALUE        Bind a variable available inside Ruex DSL
  -c, --context-file FILE     Load variables from YAML or JSON file
  -v, --version               Show Ruex version
  -h, --help                  Show this help message
```

### Using in program code

1. To use ruex in Ruby code, include `Ruex`
2. use `render` method

```ruby
require 'ruex'

include Ruex

render 'div { _"Hello, World!!" }'
```

All tag name methods such as `div`, `p` and so on are **not intended to use outside the string literals.**

## Intended Use / Safety Notes
ruex evaluates Ruby expressions directly.
Use it with trusted, developer-authored templates such as static site content.
It is not intended for rendering untrusted input in web applications.

## License

ruex is distributed under the BSD 2-Clause License (SPDX: BSD-2-Clause).
See the LICENSE file for details.

## Author

Takanobu Maekawa

https://github.com/tmkw

