require "nokogiri/xml/sax/document"

module Novaposhta
  module Parser
    class CityParser < Nokogiri::XML::SAX::Document

      def initialize
        @cities = []
        @current_city = {}
        @city_element = false
        @tag_content = ''
      end

      def cities
        return @cities
      end

      def start_element(name, attrs = [])
        return if name != "city" && !@city_element
        case name
          when "city"
            @current_city = {}
            @city_element = true
          when "id"
            @tag_content = "id"
          when "nameRu"
            @tag_content = "ru"
          when "nameUkr"
            @tag_content = "ukr"
        end
      end

      def characters(string)
        return if @tag_content.empty?
        @current_city[@tag_content.to_sym] = string
        @tag_content = ''
      end

      def end_element(name)
        if name == "city"
          @city_element = false
          @cities << Novaposhta::City.new(@current_city) if !@current_city.empty?
        end
      end
    end
  end
end
