require 'google/apis/vision_v1'
require 'uri'
require 'net/http'
require_relative '../serializers/doc'

class DocsController < ApplicationController
  HPE_HOST    = 'https://api.havenondemand.com/1/api/sync'
  HPE_API_KEY = '27b7ef89-6068-497c-8531-d289ee3639f9'
  PREDEFINED_COLLECTION_NOA = '96123' # Notice of Assessment collection
  PREDEFINED_COLLECTION_INVOICE = '96137' #  Invoice Collection
  PREDEFINED_COLLECTION_SEQUENCE = '254300' # NOA_INVOICE_CS  Collection Sequence

  def index
    success! Serializers::Doc.represent(Doc.all.to_a)
  end

  def create
    image_data = params[:image_data].split(',').last

    doc = Doc.new(raw_data: image_data, name: params[:name])
    doc.content = analyse_content(image_data)
    doc.classification = classify_content(doc.content)

    if doc.save
      created! ::Serializers::Doc.represent(doc)
    else
      invalid_request! message: doc.errors.full_messages.first
    end
  end

protected

  def index_params
    params.permit()
  end

  def create_params
    params.permit(:image_data, :name)
  end

  def analyse_content(image_data)
    uri = URI('https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDviHNPjNnnLxV_O9hPgEucOqpofo-rqas')

    req = Net::HTTP::Post.new(uri)
    req.content_type = 'application/json'
    req.body =
      {
        "requests" => [
          {
            "image" => {
              "content" => image_data
            },
            "features" => [
              {
                "type" => "TEXT_DETECTION"
              }
            ]
          }
        ]
      }.to_json

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.request(req)
    extract_content(res)
  end

  def extract_content(res)
    parsed_response = JSON.parse(res.body, symbolize_names: true)
    annotations = parsed_response[:responses] && parsed_response[:responses].first && parsed_response[:responses].first[:textAnnotations]

    if annotations
      annotations.map{|data| data[:description]}.join(' ')
    else
      ""
    end
  end

  def classify_content(content)
    uri = URI("#{HPE_HOST}/classifydocument/v1")

    req = Net::HTTP::Post.new(uri)
    req.set_form_data({
      "apikey" => HPE_API_KEY,
      "json" => {
        "document" => [
          {
            "title" => params[:name],
            "content" => content
          }
        ]
      }.to_json,
      "collection_sequence" => PREDEFINED_COLLECTION_SEQUENCE
    })

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    res = http.request(req)

    extract_classification(res)
  end

  def extract_classification(res)
    parsed_response = JSON.parse(res.body, symbolize_names: true)
    parsed_response[:result].first[:matched_collections].first[:name]
  end
end
