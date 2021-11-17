class Liaoliao::OperatorsController < ApplicationController
  before_action :find_vertex_robot
  before_action :request_to

  def receive
    OperatorJob.perform_later(@operator.id)
    head :ok
  end

  private

  def request_to
    case params['action_type']
    when 'change'
      create_or_update_vertex
    when 'run'
      set_operators
    end
  end

  def set_operators
    @operator = @vertex_robot.operators.new(operator_params)
    @operator.save
  end

  def find_vertex_robot
    @vertex_robot = VertexRobot.find_by(vertex_gid: params.dig('gid'))
  end

  def create_or_update_vertex
    if @vertex_robot
      @vertex_robot.update(
        webhook_secret: params.dig('payload', 'webhook_secret'),
        fields_attributes: params.dig('payload', 'flow', 'fields'),
        vertices_attributes: params.dig('payload', 'flow', 'vertices'),
        external_settings: params.dig('payload', 'flow', 'external_settings')
      )
    else
      VertexRobot.create(
        vertex_gid: params.dig('gid'),
        webhook_secret: params.dig('payload', 'webhook_secret'),
        fields_attributes: params.dig('payload', 'flow', 'fields'),
        vertices_attributes: params.dig('payload', 'flow', 'vertices'),
        external_settings: params.dig('payload', 'flow', 'external_settings')
      )
    end
    head :ok
  end

  def operator_params
    {
      vertex_gid: params[:payload][:gid],
      webhook_url: params[:payload][:callback_url],
      entries: params[:payload][:data][:journey][:response],
      vertex: params[:payload][:data][:vertex],
      journey_user: params[:payload][:data][:journey][:user],
      journey_sn: params[:payload][:data][:journey][:sn]
    }
  end
end