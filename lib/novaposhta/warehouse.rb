module Novaposhta
  class Warehouse

    def initialize(hash)
      @hash = hash
    end

    def id
      @hash[:id].to_i
    end

    def max_weight_allowed
      @hash[:max_weight_allowed].to_i
    end

    def method_missing(method_name, *args)
      if @hash.key?(method_name)
        @hash[method_name]
      else
        super
      end
    end
  end
end