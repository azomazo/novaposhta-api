require "novaposhta/api"

require "novaposhta/city"
require "novaposhta/order"
require "novaposhta/warehouse"

require "novaposhta/parsers/city_parser"
require "novaposhta/parsers/order_parser"
require "novaposhta/parsers/warehouse_parser"

module Novaposhta
  def self.new(key = nil)
    Novaposhta::Api.new(key.nil? ? self.api_key : key)
  end

  def self.api_key
    @@api_key
  end

  def self.api_key=(key)
    @@api_key = key
  end
end