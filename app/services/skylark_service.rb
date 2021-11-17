class SkylarkService
  include Skylark::Tools
  attr_reader :appid, :appsecret, :namespace_id, :host

  def initialize
    @namespace_id = 14
    @appid = '1818e888554137be28504ea8619b6dd853009b93177e2e78c87922cb5c0d0591'
    @appsecret = '4fd078c9fef8ee0f1311e2d1661619c5b87ed9749b038ded3e52d576cfec1fb9'
    @host = 'https://skylarkly.com/'
  end

  def get_form(form_id)
    Skylark::Tools.retryable do
      RestClient::Request.execute(
        method: :get,
        url: get_form_url(form_id),
        headers: authorization_token,
        timeout: 3
      )
    end
  end

  def search_form_response(form_id, payload, page = 1, per_page = 24)
    RestClient::Request.execute(
      method: :get,
      url: search_form_response_url(form_id, page, per_page),
      payload: payload,
      headers: authorization_token,
      timeout: 3
    )
  end

  private

  def search_form_response_url(form_id, page, per_page)
    "#{@host}/api/v4/forms/#{form_id}/responses/search?page=#{page}&per_page=#{per_page}"
  end

  def authorization_token
    { Authorization: "#{@appid}:#{encode_secret}" }
  end

  def get_form_url(form_id)
    "#{@host}/api/v4/forms/#{form_id}"
  end

  def encode_secret
    JWT.encode(
      {
        'namespace_id': @namespace_id,
      },
      @appsecret,
      'HS256',
      typ: 'JWT', alg: 'HS256'
    )
  end
end
