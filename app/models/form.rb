class Form
  include ActiveModel::Model
  attr_accessor :id, :title, :fields, :skylark_service

  def self.build_form(form_id)
    response =
      skylark_service.get_form(form_id)
    parse_response = JSON.parse(response)

    fields =
      parse_response['fields'].map do |field_attribute|
        Field.build_form_field(field_attribute)
      end

    Form.new(
      id: parse_response['id'],
      title: parse_response['title'],
      fields: fields,
      skylark_service: skylark_service
    )
  end

  def search_responses(search_params = {})
    query =
      search_params.each_with_object({}) do |temp, memo|
        field = fields.detect { |field| field.identity_key == temp[0].to_s }
        memo.merge!(field.id => temp[1])
      end

    query_params = {
      'query' => query
    }

    response =
      skylark_service.search_form_response(id, query_params)

    JSON.parse(response)
  end

  private

  def self.skylark_service
    @skylark_service ||= SkylarkService.new
  end
end
