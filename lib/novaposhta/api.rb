require "net/http"
require "nokogiri"
require "pdfkit"
require "tempfile"

module Novaposhta
  class Api

    WEB_SERVICE_POINT = "http://orders.novaposhta.ua/xml.php"
    PRINTED_FORM_TTH_POINT = "http://orders.novaposhta.ua/pformn.php"
    PRINTED_FORM_MARKERS_POINT = "http://orders.novaposhta.ua/print_formm.php"

    attr_accessor :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def order(orders=[])
      return [] if orders.empty?
      xml = create_request_xml do |xml|
        orders.each do |o|
          order = o.is_a?(Hash) ? Novaposhta::Order.new(o) : o
          xml.order(order.hash.select{|k,v| !v.is_a?(Hash)}) do |xml_order|
            order.hash.select{|k, v| v.is_a?(Hash)}.each do |k, v|
              xml_order.send(k, v)
            end
          end
        end
      end

      request_and_parse(xml, Novaposhta::Parser::OrderParser.new(orders)).orders
    end

    def close(ttn_ids=[])
      return {} if ttn_ids.empty?
      xml = create_request_xml do |xml|
        ttn_ids.each do |ttn_id|
          xml.close = ttn_id
        end
      end

      request_and_parse(xml, Novaposhta::Parser::CloseParser.new).closes
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

    def printed_form_ttn(ttn_id, options = {})
      options = {:copy_count => 1,
                 :o => ttn_id,
                 :token => api_key,
                 :file_to => Tempfile.new(['ttn', '.pdf']).path
                }.merge(options)
      options[:file_to] = options[:file_to].path if options[:file_to].is_a?(File)

      # TODO check that ttn_id not exists
      url_options = {:o => options[:o], :num_copy => options[:copy_count], :token => options[:token]}
      kit = PDFKit.new("#{PRINTED_FORM_TTH_POINT}?#{url_options.map{|k,v| "#{k}=#{v}"}.join("&")}", :orientation => "Landscape")
      kit.to_file(options[:file_to])
    end

    def printed_form_markers(ttn_id, options = {})
      options = {:o => ttn_id,
                 :token => api_key,
                 :file_to => Tempfile.new(['markers', '.pdf']).path
      }.merge(options)
      options[:file_to] = options[:file_to].path if options[:file_to].is_a?(File)

      # TODO check that ttn_id not exists
      url_options = {:o => options[:o], :token => options[:token]}
      kit = PDFKit.new("#{PRINTED_FORM_MARKERS_POINT}?#{url_options.map{|k,v| "#{k}=#{v}"}.join("&")}", :orientation => "Landscape")
      kit.to_file(options[:file_to])
    end

    private
    def create_request_xml(&xml)
      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
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

    def to_pdf(uri)
      uri = URI.parse(uri) if uri.is_a?(String)

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)

      response = http.request(request)
      if !response.response['Location'].nil?
        return to_pdf(URI(response.response['Location']))
      end


    end
  end
end