module Houston
  module Adapters
    module VersionControl
      class GitAdapter
        
        class << self
          
          
          
          # Public API for a VersionControl::Adapter
          # ------------------------------------------------------------------------- #
          
          def errors_with_parameters(project, location)
            location = Addressable::URI.parse(location.to_s)
            connect_to_repo!(location, project.version_control_temp_path)
            {}
          rescue Rugged::RepositoryError, CloneRepoFailed
            Rails.logger.error "#{$!.class.name}: #{$!.message}\n  #{$!.backtrace.take(7).join("\n  ")}"
            { git_location: ["might not be right. Houston can't seem to connect to it."] }
          end
          
          def build(project, location)
            location = Addressable::URI.parse(location.to_s)
            return Houston::Adapters::VersionControl::NullRepo if location.blank?
            
            begin
              connection = connect_to_repo!(location, project.version_control_temp_path)
              
              return self::Repo.new(connection) unless location.absolute?
              return self::GithubRepo.new(connection, location) if /github/ === location
              return self::RemoteRepo.new(connection, location)
            rescue Rugged::RepositoryError, Rugged::OSError
              Houston::Adapters::VersionControl::NullRepo
            end
          end
          
          def parameters
            [:git_location]
          end
          
          # ------------------------------------------------------------------------- #
          
          
          
          def connect_to_repo!(repo_uri, temp_path)
            git_path = get_local_path_to_repo(repo_uri, temp_path)
            Rugged::Repository.new(git_path)
          end
          
          def get_local_path_to_repo(repo_uri, temp_path)
            if repo_uri.absolute?
              clone!(repo_uri, temp_path) unless File.exists?(temp_path)
              temp_path
            else
              repo_uri.to_s
            end
          end
          
          def sync!(origin, local_path, async: false)
            if File.exists?(local_path)
              pull!(local_path, async: async)
            else
              clone!(origin, local_path, async: async)
            end
          end
          
          def clone!(origin_uri, temp_path, async: false)
            local_path = File.dirname(temp_path)
            target = File.basename(temp_path)
            
            ActiveRecord::Base.benchmark("\e[33m[git:clone] #{origin_uri} => #{temp_path} #{"\e[1;4mAsync" if async}\e[0m") do
              execute "cd #{local_path} && git clone --mirror #{origin_uri} #{target}", async: async
            end
          end
          
          def pull!(local_path, async: false)
            ActiveRecord::Base.benchmark("\e[33m[git:pull] #{local_path} #{"\e[1;4mAsync" if async}\e[0m") do
              execute "git --git-dir=#{local_path} remote update --prune", async: async
            end
          end
          
          def execute(command, async: false)
            if async
              pid = spawn command
              Process.detach pid
            else
              Skylight.instrument title: "git remote update" do
                raise CloneRepoFailed.new unless system command
              end
            end
          end
          
          def time_of_last_pull(git_dir)
            fetch_head = File.join(git_dir, "FETCH_HEAD")
            return 100.years.ago unless File.exists?(fetch_head)
            File.mtime fetch_head
          end
          
        end
        
      end
    end
  end
end
