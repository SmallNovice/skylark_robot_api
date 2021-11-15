class Operator < ApplicationRecord
  include Skylark::Tools
  belongs_to :vertex_robot

  def route(vertex_field_attributes = [], propose_id = nil)
    params = route_params(vertex_field_attributes, propose_id)

    assignment_request(params)
  end

  def refuse(vertex_field_attributes = [], comment = '')
    params = refuse_params(vertex_field_attributes, comment)

    assignment_request(params)
  end

  def approve(comment, next_vertex_id, next_reviewer_ids = [])
    params = approve_params(comment, next_vertex_id, next_reviewer_ids)

    assignment_request(params)
  end

  def match_user_info?
    @flow_fields_value = parameters_to_hash(entries)

    key, value = @flow_fields_value.first

    form_response_fields = Form.build_form(vertex_robot.external_settings["user_white_list"]).search_responses(key => value)[0]

    form_fields_value = parameters_to_hash(form_response_fields)

    %w(name id_card street).each do |_key|
      return false unless form_fields_value[_key.to_sym] == @flow_fields_value[_key.to_sym]
    end
  end

  def get_next_vertice_id(route_response)
    next_vertice = route_response.detect { |next_vertice| @flow_fields_value[:street] == next_vertice['name'] }
    next_vertice['id']
  end

  private

  def assignment_request(params)
    Skylark::Tools.retryable do
      RestClient::Request.execute(
        method: :post,
        url: webhook_url,
        payload: params,
        headers: authorization_token,
        timeout: 3
      )
    end
  end

  def authorization_token
    { Authorization: encode_secret }
  end

  def webhook_secret
    vertex_robot.webhook_secret
  end

  def encode_secret
    JWT.encode time_payload, webhook_secret, 'HS256'
  end

  def time_payload
    now = Time.now.to_i

    { iat: now, exp: now + 60, noncestr: SecureRandom.base58 }
  end

  def approve_params(comment, next_vertex_id, next_reviewer_ids = [])
    {
      assignment: {
        operation: 'approve',
        comment: comment,
        next_vertex_id: next_vertex_id,
        next_reviewer_ids: next_reviewer_ids
      }
    }
  end

  def refuse_params(vertex_field_attributes, comment)
    params = { assignment: { operation: 'refuse', comment: comment } }

    unless vertex_field_attributes.empty?
      params[:assignment][:response_attributes] = {
        entries_attributes: vertex_field_attributes
      }
    end

    params
  end

  def route_params(vertex_field_attributes, propose_id = nil)
    params = { assignment: { operation: 'route' } }

    unless vertex_field_attributes.empty?
      params[:assignment][:response_attributes] = {
        entries_attributes: vertex_field_attributes
      }
    end

    if propose_id
      params.merge(user_id: propose_id)
    else
      params
    end
  end

  def parameters_to_hash(parameters_to_converted)
    {
      name: parameters_to_converted.dig('mapped_values', 'name', 'text_value', 0),
      id_card: parameters_to_converted.dig('mapped_values', 'id_card', 'text_value', 0),
      street: parameters_to_converted.dig('mapped_values', 'street', 'text_value', 0)
    }
  end
end
