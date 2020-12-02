# -*- coding: utf-8 -*- #
# frozen_string_literal: true

# this is based on https://github.com/rouge-ruby/rouge/blob/master/lib/rouge/themes/monokai_sublime.rb
# but without the added background, and changed styling for JSON keys to be soft_yellow instead of white

module Rouge
    module Themes
      class MonokaiSublimeSlate < CSSTheme
        name 'monokai.sublime.slate'

        palette :black          => '#000000'
        palette :bright_green   => '#a6e22e'
        palette :bright_pink    => '#f92672'
        palette :carmine        => '#960050'
        palette :dark           => '#49483e'
        palette :dark_grey      => '#888888'
        palette :dark_red       => '#aa0000'
        palette :dimgrey        => '#75715e'
        palette :emperor        => '#555555'
        palette :grey           => '#999999'
        palette :light_grey     => '#aaaaaa'
        palette :light_violet   => '#ae81ff'
        palette :soft_cyan      => '#66d9ef'
        palette :soft_yellow    => '#e6db74'
        palette :very_dark      => '#1e0010'
        palette :whitish        => '#f8f8f2'
        palette :orange         => '#f6aa11'
        palette :white          => '#ffffff'

        style Generic::Heading,                 :fg => :grey
        style Literal::String::Regex,           :fg => :orange
        style Generic::Output,                  :fg => :dark_grey
        style Generic::Prompt,                  :fg => :emperor
        style Generic::Strong,                  :bold => false
        style Generic::Subheading,              :fg => :light_grey
        style Name::Builtin,                    :fg => :orange
        style Comment::Multiline,
              Comment::Preproc,
              Comment::Single,
              Comment::Special,
              Comment,                          :fg => :dimgrey
        style Error,
              Generic::Error,
              Generic::Traceback,               :fg => :carmine
        style Generic::Deleted,
              Generic::Inserted,
              Generic::Emph,                    :fg => :dark
        style Keyword::Constant,
              Keyword::Declaration,
              Keyword::Reserved,
              Name::Constant,
              Keyword::Type,                    :fg => :soft_cyan
        style Literal::Number::Float,
              Literal::Number::Hex,
              Literal::Number::Integer::Long,
              Literal::Number::Integer,
              Literal::Number::Oct,
              Literal::Number,
              Literal::String::Char,
              Literal::String::Escape,
              Literal::String::Symbol,          :fg => :light_violet
        style Literal::String::Doc,
              Literal::String::Double,
              Literal::String::Backtick,
              Literal::String::Heredoc,
              Literal::String::Interpol,
              Literal::String::Other,
              Literal::String::Single,
              Literal::String,                  :fg => :soft_yellow
        style Name::Attribute,
              Name::Class,
              Name::Decorator,
              Name::Exception,
              Name::Function,                   :fg => :bright_green
        style Name::Variable::Class,
              Name::Namespace,
              Name::Entity,
              Name::Builtin::Pseudo,
              Name::Variable::Global,
              Name::Variable::Instance,
              Name::Variable,
              Text::Whitespace,
              Text,
              Name,                             :fg => :white
        style Name::Label,                      :fg => :bright_pink
        style Operator::Word,
              Name::Tag,
              Keyword,
              Keyword::Namespace,
              Keyword::Pseudo,
              Operator,                         :fg => :bright_pink
      end
    end
  end
