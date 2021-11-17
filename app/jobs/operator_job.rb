class OperatorJob < ApplicationJob
  queue_as :default

  def perform(operator_id)
    operator = Operator.find_by(id: operator_id)

    route = operator.route([], operator.journey_user["id"])
    route_response = JSON.parse(route)["next_vertices"]

    if operator.match_user_info?
      operator.approve("比对信息通过", operator.get_next_vertice_id(route_response))
    else
      operator.refuse("比对信息不通过")
    end
  end
end
