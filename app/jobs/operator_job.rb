class OperatorJob < ApplicationJob
  queue_as :default

  def perform(vertex_gid)
    operators = Operator.find_by(id: vertex_gid)

    vertex_field_attributes =
      operators.entries.each_with_object([]) do |entry, vertex_field_attribute|
        vertex_field_attribute << { field_id: entry.dig('field_id'), value: entry.dig('value') }
      end

    route = operators.route(vertex_field_attributes, operators.journey_user["id"])
    next_vertices_id = JSON.parse(route)["next_vertices"][0]["id"]
    operators.approve("", next_vertices_id)
  end
end

