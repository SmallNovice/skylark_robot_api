class OperatorJob < ApplicationJob
  queue_as :default

  def perform(operator_id)
    operator = Operator.find_by(id: operator_id)

    flow_fields_value = parameters_to_hash(operator.entries)

    key, value = flow_fields_value.first
    form_response_fields = Form.build_form(operator.vertex_robot.external_settings["user_white_list"]).search_responses(key => value)[0]

    form_fields_value = parameters_to_hash(form_response_fields)

    if judge(form_fields_value, flow_fields_value)
      route = operator.route([],operator.journey_user["id"])
      operator.approve("比对信息通过", get_next_vertice_id(route, flow_fields_value))
    else
      operator.refuse("比对信息不通过")
    end
  end

  private

  def judge(form_fields_value, flow_fields_value)
    %w(name id_card street).each do |_key|
      return false unless form_fields_value[_key.to_sym] == flow_fields_value[_key.to_sym]
    end
  end

  def get_next_vertice_id(route, flow_fields_value)
    JSON.parse(route)["next_vertices"].each do |next_vertice|
      if flow_fields_value[:street] == next_vertice['name']
        return next_vertice['id']
      end
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
