module Novaposhta
  module Parser
    class OrderParser < Nokogiri::XML::SAX::Document
      attr_reader :orders

      def initialize(orders)
        @orders = orders
      end

      def start_element(name, attrs = [])
        return if name.downcase != "order"
        case name.downcase
          when "order"
            order_id, ttn_id = parse_attrs(attrs)
            set_ttn_id(order_id, ttn_id)
        end
      end

      private
      def set_ttn_id(order_id, ttn_id)
        @orders.each { |o|
          if o.is_a?(Hash) and o[:order_id] == order_id.to_s
            o[:ttn_id] = ttn_id.to_s
          elsif o.order_id == order_id.to_s
            o.ttn_id = ttn_id.to_s
          end
        }
      end

      def parse_attrs(attrs=[])
        order_id = ""
        ttn_id = ""
        attrs.each do |attr|
          if attr[0].downcase == "id"
            order_id = attr[1]
          elsif attr[0].downcase == "np_id"
            ttn_id = attr[1]
          end
        end

        return order_id, ttn_id
      end
    end
  end
end