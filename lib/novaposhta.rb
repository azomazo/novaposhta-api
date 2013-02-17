require "novaposhta/api"

require "novaposhta/warehouse"

require "novaposhta/parsers/city_parser"
require "novaposhta/parsers/warehouse_parser"

module Novaposhta
  def self.new(api_key)
    Novaposhta::Api.new(api_key)
  end
end