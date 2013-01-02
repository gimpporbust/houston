class ProjectHooksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  
  def trigger
    @project = Project.find_by_slug(params[:project_id])
    unless @project
      render text: "A project with the slug '#{params[:project_id]}' could not be found", status: 404
      return
    end
    
    payload = params.except(:action, :controller).merge({
      sender: {
        ip: request.remote_ip,
        agent: request.user_agent
      }
    })
    
    Houston.observer.fire "hooks:#{params[:hook]}", payload
    
    head 200
  end
  
  
end