class Ruex
  TAGS = [
    # Document metadata
    {name: :html},
    {name: :head},
    {name: :title},
    {name: :base, void: true},
    {name: :link, void: true, boolean: [:disabled]},
    {name: :meta, void: true},
    {name: :style},
    {name: :script, boolean: [:async, :defer, :nomodule]},
    {name: :noscript},
    {name: :template},

    # Sections
    {name: :body},
    {name: :section},
    {name: :nav},
    {name: :article},
    {name: :aside},
    {name: :h1},
    {name: :h2},
    {name: :h3},
    {name: :h4},
    {name: :h5},
    {name: :h6},
    {name: :header},
    {name: :footer},
    {name: :address},
    {name: :main},

    # Grouping content
    {name: :p},
    {name: :hr, void: true},
    {name: :pre},
    {name: :blockquote},
    {name: :ol},
    {name: :ul},
    {name: :li},
    {name: :dl},
    {name: :dt},
    {name: :dd},
    {name: :figure},
    {name: :figcaption},
    {name: :div},

    # Text-level semantics
    {name: :a},
    {name: :em},
    {name: :strong},
    {name: :small},
    {name: :s},
    {name: :cite},
    {name: :q},
    {name: :dfn},
    {name: :abbr},
    {name: :data},
    {name: :time},
    {name: :code},
    {name: :var},
    {name: :samp},
    {name: :kbd},
    {name: :sub},
    {name: :sup},
    {name: :i},
    {name: :b},
    {name: :u},
    {name: :mark},
    {name: :ruby},
    {name: :rt},
    {name: :rp},
    {name: :bdi},
    {name: :bdo},
    {name: :span},
    {name: :br, void: true},
    {name: :wbr, void: true},

    # Edits
    {name: :ins},
    {name: :del},

    # Embedded content
    {name: :picture},
    {name: :source, void: true},
    {name: :img, void: true},
    {name: :iframe},
    {name: :embed, void: true},
    {name: :object},
    {name: :param, void: true},
    {name: :video, boolean: [:autoplay, :controls, :loop, :muted]},
    {name: :audio, boolean: [:autoplay, :controls, :loop, :muted]},
    {name: :track, void: true},
    {name: :map},
    {name: :area, void: true},

    # Forms
    {name: :form, boolean: [:novalidate]},
    {name: :label},
    {name: :input, void: true, boolean: [:disabled, :readonly, :required, :autofocus, :multiple, :hidden, :formnovalidate, :checked]},
    {name: :button, boolean: [:disabled, :autofocus, :formnovalidate]},
    {name: :select, boolean: [:disabled, :multiple, :required, :autofocus]},
    {name: :datalist},
    {name: :optgroup, boolean: [:disabled]},
    {name: :option, boolean: [:disabled, :selected]},
    {name: :textarea, boolean: [:disabled, :readonly, :required, :autofocus]},
    {name: :output},
    {name: :progress},
    {name: :meter},
    {name: :fieldset, boolean: [:disabled]},
    {name: :legend},

    # Interactive elements
    {name: :details},
    {name: :summary},
    {name: :dialog},
    {name: :menu},
    {name: :menuitem},

    # Scripting
    {name: :canvas},
    {name: :slot},
    {name: :portal}
  ]

  def initialize
    @output = ''
  end

  def render_attrs(attrs, boolean_attrs)
    parts = []

    # --- data 属性の展開 ---
    if attrs.key?(:data)
      data_hash = attrs.delete(:data)
      data_hash.each do |k, v|
        html_key = "data-#{k.to_s.gsub('_', '-')}"
        parts << %(#{html_key}="#{v}")
      end
    end

    attrs.each do |k, v|
      if boolean_attrs&.include?(k)
        # --- boolean 属性の処理 ---
        parts << k.to_s if v   # true のときだけ出力
      else
        # --- 通常属性 ---
        parts << %(#{k}="#{v}")
      end
    end

    parts.join(" ")
  end

  def render_tag(tag_def, args, attrs, block)
    name = tag_def[:name]
    void = tag_def[:void]
    boolean_attrs = tag_def[:boolean] || []

    attr_str = %( #{render_attrs(attrs, boolean_attrs)}) unless attrs.empty?

    if void
      @output << "<#{name}#{attr_str}>"
      return
    end

    @output << "<#{name}#{attr_str}>"

    if block
      block.call
    elsif args.first
      @output << args.first.to_s
    end

    @output << "</#{name}>"
  end

  TAGS.each do |tag|
    define_method(tag[:name]) do |*args, **attrs, &block|
      render_tag(tag, args, attrs, block)
    end
  end

  # for text node
  def text(str)
    @output << str.to_s
  end

  alias _ text

  def render(code, ctx: {})
    @output = ""

    b = binding
    ctx.each do |k, v|
      b.local_variable_set(k, v)
    end

    eval(code, b , __FILE__, __LINE__)
    @output
  end
end
