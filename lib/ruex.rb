class Ruex
  require 'yaml'

  TAGS = YAML.load_file([__dir__, "tags.yml"].join('/'))

  def initialize
    @output = ''
  end

  def render_attrs(attrs, boolean_attrs)
    parts = []

    # data attributes
    if attrs.key?(:data)
      data_hash = attrs.delete(:data)
      data_hash.each do |k, v|
        html_key = "data-#{k.to_s.gsub('_', '-')}"
        parts << %(#{html_key}="#{v}")
      end
    end

    attrs.each do |k, v|
      if boolean_attrs&.include?(k)
        # boolean attributes
        parts << k.to_s if v   # use only when the option is enabled
      else
        # normal attributes
        parts << %(#{k}="#{v}")
      end
    end

    parts.join(" ")
  end

  def render_tag(tag_def, args, attrs, block)
    name = tag_def['name']
    void = tag_def[':void']
    boolean_attrs = tag_def[':boolean'] || []

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
    define_method(tag['name']) do |*args, **attrs, &block|
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
