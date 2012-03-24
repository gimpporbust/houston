module UrlHelper
  
  
  
  def environments_path(*args)
    project_environments_path(*args)
  end
  
  def environment_path(environment, options={})
    project_environment_path(environment.project.to_param, environment, options)
  end
  
  def edit_environment_path(environment, options={})
    edit_project_environment_path(environment.project.to_param, environment, options)
  end
  
  
  def environments_url(*args)
    project_environments_url(*args)
  end
  
  def environment_url(environment, options={})
    project_environment_url(environment.project.to_param, environment, options)
  end
  
  def edit_environment_url(environment, options={})
    edit_project_environment_url(environment.project.to_param, environment, options)
  end
  
  
  
  def releases_path(*args)
    project_environment_releases_path(*args)
  end
  
  def release_path(release, options={})
    project_environment_release_path(release.project.to_param, release.environment.to_param, release, options)
  end
  
  def edit_release_path(release, options={})
    edit_project_environment_release_path(release.project.to_param, release.environment.to_param, release, options)
  end
  
  
  def releases_url(*args)
    project_environment_releases_url(*args)
  end
  
  def release_url(release, options={})
    project_environment_release_url(release.project.to_param, release.environment.to_param, release, options)
  end
  
  def edit_release_url(release, options={})
    edit_project_environment_release_url(release.project.to_param, release.environment.to_param, release, options)
  end
  
  
  
end
