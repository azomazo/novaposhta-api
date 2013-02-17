module Novaposhta
  class City

    def initialize(hash)
      @hash = hash
    end

    def id
      @hash[:id].to_i
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
