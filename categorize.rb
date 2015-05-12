#!/usr/bin/env ruby
# vim:set fileencoding=utf-8 ts=2 sw=2 sts=2 et:

# 概要:
#   ./categorize.rb [OPTION] {filename}
#     {filename}から魚データを読み込み、分類した結果を出力します
#     なお、{filename}を省略した場合は、標準入力からデータを読み込みます
#
# 使用例:
#   ./categorize.rb data/katsuo1000.csv
#
# OPTIONS
#   -c, --config=dsl
#     dslファイルから魚の分類設定を読み込みます
#     このオプションを設定しない場合、設定はこのファイルの__END__以降から読み込まれます
#
#     設定ファイルのエンコードはUTF-8にしてください
#
#   
# ** 分類設定について **
#   1.文法
#     a.kind {name}
#       name: 分類する魚の種類(正規表現が使用可能)
#
#     b.category {lower_limit}, {name}
#       lower_limit: 分類の下限値
#       name:        分類名
#
#  2.使用例
#    a.サワラを分類する場合
#      -- [sawara.txt]に下記を保存(UTF-8) --
#         kind 'サワラ'
#         category 0,  '小'
#         category 70, '中'
#         category 80, '大'
#         category 90, '特大'
#      -----------------------------
#      ./categorize.rb --config=sawara.txt data/katsuo1000.csv
#
#   b.すべてのマグロを分類する場合
#     ・魚の種類を下記のように設定する
#         kind /マグロ$/
#         (以下略)
#
# 

# 注意点
#   このプログラムはUTF-8で記述したものをShift-JISに変換しています。(解答フォーマットに合わせるため)
#   プログラムを実行する前にUTF-8に再変換して下さい。

require 'pp'
require 'optparse'
require 'csv'


module Katsuo
  DATA_ENCODING   = Encoding::WINDOWS_31J # 魚データCSVのエンコード
  CONFIG_ENCODING = Encoding::UTF_8       # 分類設定ファイルのエンコード

  # 標準入出力とのやりとりを定義
  module Interaction
    class << self
      public
      def main
        # 設定ファイルの読み込み
        opts = parse_opts!(ARGV)
        dsl, config_path, lineno = read_dsl(opts[:config_file])
        config = ConfigBuilder.read_dsl(dsl, config_path, lineno)

        # 魚データCSVの読み込み
        ARGF.set_encoding(DATA_ENCODING, __ENCODING__)
        katsuo_data = ARGF.read

        # 魚データの振り分けと表示
        bucket = CategoryBuket.new(config.kind, config.categories)
        bucket.read_csv_string(katsuo_data)
        puts bucket.description
      end

      private
      # コマンドラインオプションを解析する
      # 引数argvは変更される
      # @return [Hash]
      def parse_opts!(argv)
        opts = {}
        parser = OptionParser.new
        parser.on('-c VAL', '--config=VAL', 'use config file'){|v| opts[:config_file] = v}
        parser.parse!(argv)
        return opts
      end

      # 設定ファイルから内容を文字列として読み込みます
      # filenameにnilが与えられたとき、設定はこのファイルの__EiND__以降から読み込まれます
      # @param  [String] filename 分類方法の設定ファイルのパス
      # @return [String, String, Integer] [設定ファイルの内容, 設定ファイルのパス(デバッグ情報用), 設定ファイルの開始行番号]
      def read_dsl(filename)
        if filename
          dsl = File.read(filename, encoding: CONFIG_ENCODING)
          return [dsl, File.expand_path(filename), 1]
        else
          lineno = DATA.lineno
          dsl = DATA.read
          #return [dsl, '<DATA>', lineno]
          return [dsl, "<DATA> of '#{File.expand_path(DATA.path)}'", lineno]
        end
        raise
      end
    end
  end


  # 魚の分類
  class Category
    attr_reader :name, :range

    # @param [String] name  分類名
    # @param [Range]  range 分類の範囲
    def initialize(name, range)
      @name = name.dup.freeze
      @range = range
    end
  end

  # 魚をCategoryごとに振り分けて保持する
  class CategoryBuket
     
    # @param [String, Regexp]  kind 魚の種別
    # @param [Array<Category>] categories 分類
    def initialize(kind, categories)
      @kind = kind.dup.freeze
      @categories = categories.dup.freeze
      @buket = Hash.new{|h, k| h[k] = []}
    end

    # CSVから魚データを読み込む
    # @param  [String] str
    # @return [void]
    def read_csv_string(str)
      CSV.parse(str) do |row|
        kind = row[0]
        size = row[1].to_i
        add(size) if @kind === kind
      end
    end

    # 魚を追加する
    # @param  [Integer] kind 魚の大きさ
    # @return [void]
    def add(size)
      @categories.each do |category|
        if category.range.include?(size)
          @buket[category] << size
          break
        end
      end
    end

    # 解答の表現用文字列を返す
    # @return [String]
    def description
      result = ""
      @categories.each do |category|
        size_list = @buket[category]
        sum = size_list.inject(0, &:+)
        avg = sum.fdiv(size_list.size)
        result << "%s(%d): %.2fcm\n" % [category.name, size_list.size, avg]
      end
      return result
    end

  end

  # 魚の分類設定
  class Config
    attr_reader :kind, :categories

    def initialize(kind, categories)
      @kind = kind.dup.freeze
      @categories = categories.dup.freeze
    end
  end

  # 魚の分類設定ファイルから内容を読み出すクラス
  #   ([Fowler DSL] Expression Builder)
  # @exampe
  #   dsl = <<-EOS
  #     kind 'カツオ'
  #     category 0,  'S'
  #     category 50, 'M'
  #     category 75, 'L'
  #   EOS
  #   Configbuilder.read_dsl(dsl, '<eval>', 1)  =>
  #      #<Katsuo::Config:0xb966db18
  #       @categories=
  #        [#<Katsuo::Category:0xb966dc08 @name="S", @range=0...50>,
  #         #<Katsuo::Category:0xb966dbb8 @name="M", @range=50...75>,
  #         #<Katsuo::Category:0xb966db68 @name="L", @range=75...Infinity>],
  #       @kind="カツオ">
  #
  class ConfigBuilder
    class << self

      def read_dsl(str, filename, lineno)
        config_builder = new
        config_builder.instance_eval(str, filename, lineno)
        return config_builder.build
      end
    end

    def initialize
      @kind = nil
      @category_table = []
      @previous_lower_limit = -Float::INFINITY
    end

    # @param [String, Regexp] name 分類する魚の種類(正規表現が使用可能)
    # @return [void]
    def kind(name)
      @kind = name
    end

    # @param [Integer] lower_limit 分類の下限値
    # @param [String]  name 分類名
    # @return [void]
    def category(lower_limit, name)
      raise "lower_limit must be in ascending order." unless @previous_lower_limit < lower_limit
      @previous_lower_limit = lower_limit

      @category_table << [lower_limit, name]
    end

    # @return [Config]
    def build
      raise "kind is not specified. add 'kind <name>' to dsl." unless @kind

      fixed_category_table = @category_table + [[Float::INFINITY, "**NOT DATA**"]]
      categories = []
      fixed_category_table.each_cons(2) do |(lower_limit, name), (upper_limit, _)|
        range = (lower_limit ... upper_limit)
        category = Category.new(name, range)
        categories << category
      end
      return Config.new(@kind, categories)
    end
  end
end


if $0 == __FILE__
  Katsuo::Interaction::main
end

__END__

# dsl ---------------
kind 'カツオ'
category 0,  'S'
category 50, 'M'
category 75, 'L'

