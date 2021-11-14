class Operator < ApplicationRecord
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

  private

  def assignment_request(params)
    RestClient::Request.execute(
      method: :post,
      url: webhook_url,
      payload: params,
      headers: authorization_token,
      timeout: 3
    )
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
end
