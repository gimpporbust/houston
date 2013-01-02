class TestRun < ActiveRecord::Base
  
  belongs_to :project
  
  validates_presence_of :project_id, :commit
  validates :results_url, :presence => true, :if => :completed?
  
  before_create :trigger_build!
  
  
  
  alias_method :start!, :save!
  
  def short_commit
    commit[0...8]
  end
  
  def completed?
    completed_at.present?
  end
  
  def has_results?
    result.present?
  end
  
  def trigger_build!
    Rails.logger.info "[test-run] POST #{trigger_build_url}"
    response = Faraday.post(trigger_build_url)
    if response.status == 404
      Rails.logger.info "[test-run] Attempting to create a job on http://ci.cphepdev.com for #{project.slug}"
      create_job_or_fail!
      
      Rails.logger.info "[test-run] POST #{trigger_build_url}"
      response = Faraday.post(trigger_build_url)
      raise Houston::CI::Error unless response.status == 200
    end
  end
  
  def create_job_or_fail!
    client = Jenkins::Client.new
    client.url = "http://ci.cphepdev.com"
    
    template = ERB.new(File.read(Rails.root.join("config.xml.erb")))
    git_url = project.version_control_location
    config = template.result(binding)
    
    job = Jenkins::Client::Job.new(name: project.slug, client: client)
    success = job.create!(config)
    raise Houston::CI::Error unless success
  end
  
  def trigger_build_url
    "http://ci.cphepdev.com/job/#{project.slug}/buildWithParameters?COMMIT_SHA=#{commit}&CALLBACK_URL=#{callback_url}"
  end
  
  def callback_url
    Rails.application.routes.url_helpers
      .web_hook_url(host: Houston.config.host, project_id: project.slug, hook: "post_build")
  end
  
  def completed!(results_url)
    self.completed_at = Time.now unless completed?
    self.results_url = results_url
    save!
    fetch_results! unless has_results?
  end
  
  def fetch_results!
    Rails.logger.warn "[test-run] GET #{results_url}"
    response = Faraday.get(results_url)
    
    # Assumes structure of Jenkins testReport
    results = JSON.parse(response.body)
    self.duration = results["duration"] * 1000 # convert seconds to milliseconds
    self.fail_count = results["failCount"]
    self.pass_count = results["passCount"]
    self.skip_count = results["skipCount"]
    self.details = results["suites"].each_with_index.each_with_object({}) { |(item, i), hash| hash[i.to_s] = item }
    
    if fail_count > 0
      self.result = "fail"
    elsif pass_count > 0
      self.result = "pass"
    end
    
    self.save!
    
    Houston.observer.fire "test_run:complete", self
  end
  
  
  
end