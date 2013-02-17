require "net/http"
require "nokogiri"

module Novaposhta
  class Api

    WEB_SERVICE_POINT = "http://orders.novaposhta.ua/xml.php"

    attr_accessor :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def cities
      xml = create_request_xml do |xml|
        xml.city
      end
      request_and_parse(xml, Novaposhta::Parser::CityParser.new).cities.sort {|x,y| x.ru.downcase <=> y.ru.downcase}
    end

    def city_warehouses
      xml = create_request_xml do |xml|
        xml.citywarehouses
      end
      request_and_parse(xml, Novaposhta::Parser::CityParser.new).cities.sort {|x,y| x.ru.downcase <=> y.ru.downcase}
    end

    def warehouses(city_name = nil)
      xml = create_request_xml do |xml|
        xml.warenhouse
        xml.filter city_name if !city_name.nil?
      end
      request_and_parse(xml, Novaposhta::Parser::WarehouseParser.new).warehouses
    end

    private
    def create_request_xml(&xml)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.file {
          xml.auth api_key
          yield xml
        }
      end

      builder.to_xml
    end

    def request_and_parse(xml, parser)
      result = request(xml)
      parse(result, parser)
    end

    def request(xml)
      uri = URI(WEB_SERVICE_POINT)
      puts uri.request_uri
      req = Net::HTTP::Post.new(uri.request_uri)
      req.body = xml
      req.content_type = "text/xml"

      http = Net::HTTP.new(uri.host, uri.port)
      http.request(req).body
    end

    def parse(xml, parser)
      p = Nokogiri::XML::SAX::Parser.new(parser)
      p.parse(xml)
      parser
    end
  end
end