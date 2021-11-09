class OperatorsController < ApplicationController
  before_action :find_vertex_robot
  before_action :request_to

  def create
    unless @operators.nil?
      OperatorJob.perform_later(@operators.id)
    end
    render status: :created
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
    @operators = Operator.new(operator_params)
    @operators.vertex_robot = @vertex_robot
    @operators.save
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
  end

  def operator_params
    {
      vertex_gid: params[:payload][:gid],
      webhook_url: params[:payload][:callback_url],
      entries: params[:payload][:data][:journey][:response][:entries],
      vertex: params[:payload][:data][:vertex],
      journey_user: params[:payload][:data][:journey][:user],
      journey_sn: params[:payload][:data][:journey][:sn]
    }
  end
end