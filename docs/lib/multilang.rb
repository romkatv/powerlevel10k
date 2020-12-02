module Multilang
  def block_code(code, full_lang_name)
    if full_lang_name
      parts = full_lang_name.split('--')
      rouge_lang_name = (parts) ? parts[0] : "" # just parts[0] here causes null ref exception when no language specified
      super(code, rouge_lang_name).sub("highlight #{rouge_lang_name}") do |match|
        match + " tab-" + full_lang_name
      end
    else
      super(code, full_lang_name)
    end
  end
end

require 'middleman-core/renderers/redcarpet'
Middleman::Renderers::MiddlemanRedcarpetHTML.send :include, Multilang
