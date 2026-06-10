require "net/http"
require "json"

class RetellController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[web_call call_data]
  skip_after_action :verify_authorized, only: %i[web_call call_data]
  skip_after_action :verify_policy_scoped, only: %i[web_call call_data]
  
  def web_call
    agent_id = ENV.fetch("RETELL_AGENT_ID", nil)
    api_key = ENV.fetch("RETELL_API_KEY", nil)
    
    if agent_id.blank? || api_key.blank?
      render json: { error: "Missing RETELL_API_KEY or RETELL_AGENT_ID" }, status: :service_unavailable
      return
    end
    
    uri = URI("https://api.retellai.com/v2/create-web-call")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Bearer #{api_key}"
    request["Content-Type"] = "application/json"
    request.body = {
      agent_id: agent_id,
      retell_llm_dynamic_variables: {
        current_date: Time.current.in_time_zone("Europe/Madrid").strftime("%Y-%m-%d"),
        current_time: Time.current.in_time_zone("Europe/Madrid").strftime("%H:%M"),
        timezone: "Europe/Madrid"
      }
    }.to_json

    response = http.request(request)

    Rails.logger.info("Retell status: #{response.code}")
    Rails.logger.info("Retell body: #{response.body}")

    body = JSON.parse(response.body)

    unless response.code == "201"
      render json: { error: body["message"] || body["error"] || "Retell API error" }, status: :bad_gateway
      return
    end

    render json: {
      access_token: body["access_token"],
      call_id: body["call_id"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Retell JSON parse error: #{e.message}")

    render json: {
      error: "Retell returned an invalid response. Check Rails logs."
    }, status: :bad_gateway
  rescue StandardError => e
    Rails.logger.error("Retell web_call error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n"))

    render json: {
      error: e.message
    }, status: :internal_server_error
  end

  def call_data
    call_id = params[:call_id]
    api_key = ENV.fetch("RETELL_API_KEY", nil)

    if call_id.blank?
      render json: { error: "Missing call_id" }, status: :bad_request
      return
    end

    uri = URI("https://api.retellai.com/v2/get-call/#{call_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{api_key}"

    response = http.request(request)
    body = JSON.parse(response.body)

    Rails.logger.info("Retell get-call status: #{response.code}")
    # Rails.logger.info("Retell get-call body: #{response.body}")

    unless response.code == "200"
      render json: { error: body["message"] || body["error"] || "Retell get-call error" }, status: :bad_gateway
      return
    end

    variables = body["collected_dynamic_variables"]

    render json: {
      call_id: body["call_id"],
      status: body["call_status"],
      variables: variables,
      transcript: body["transcript"]
    }
  rescue JSON::ParserError => e
    Rails.logger.error("Retell call_data JSON parse error: #{e.message}")
    render json: { error: "Retell returned invalid JSON" }, status: :bad_gateway
  rescue StandardError => e
    Rails.logger.error("Retell call_data error: #{e.class} - #{e.message}")
    render json: { error: e.message }, status: :internal_server_error
  end
end

