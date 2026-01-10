module Ruex
  require 'ruex/core'

  def render(code, ctx: {})
    Core.new.render(code, ctx: ctx)
  end
end
