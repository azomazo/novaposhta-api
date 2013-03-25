module Novaposhta
  class Order

    DEFAULT_DATE = Date.today

    attr_reader :hash

    def initialize(hash = {})
      @hash = hash
    end

    def saturday?
      %w(true 1).include?(@hash[:saturday].to_s)
    end

    def convert
      date = DEFAULT_DATE if date.nil?
      date = date.strftime('%Y-%m-%d') if !date.is_a?(String)
      date_desired  = date_desired.strftime('%Y-%m-%d') if !date_desired.nil? and !date_desired.is_a?(String)
    end

    def method_missing(method_name, *args)
      mname = method_name.id2name
      len = args.length
      if mname.chomp!('=') && method_name != :[]=
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
        modifiable[new_ostruct_member(mname)] = args[0]
      elsif len == 0 && method_name != :[]
        @hash[method_name]
      else
        ""
      end
    end
  end

  module PayType
    CASH = "1"
    CASHLESS = "2"
  end

  module Payer
    RECIPIENT = "0"
    SENDER = "1"
    THIRD_PERSON = "2"
  end

  module REDELIVERY_PAYMENT_PAYER
    RECIPIENT = "1"
    SENDER = "2"
  end

  module REDELIVERY_TYPE
    DOCUMENTS = "1"
    MONEY = "2"
    CONTAINERS = "3"
    PRODUCT = "4"
    OTHER = "5"
  end
end