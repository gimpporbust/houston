module Houston
  module Adapters
    module TicketTracker
      class UnfuddleAdapter
        class Ticket
          
          
          
          def initialize(connection, attributes)
            @connection       = connection
            @raw_attributes   = attributes
            @severity         = get_severity_name(attributes["severity_id"]) if attributes["severity_id"]
            @component        = get_component_name(attributes["component_id"]) if attributes["component_id"]
            
            # required
            @remote_id        = attributes["id"]
            @number           = attributes["number"]
            @summary          = attributes["summary"]
            @description      = attributes["description"]
            @reporter_email   = attributes["reporter_email"]
            @resolution       = attributes["resolution"]
            @milestone_id     = attributes["milestone_id"]
            @type             = get_type
            @created_at       = Time.parse(attributes["created_at"]) if attributes["created_at"]
            @closed_at        = Time.parse(attributes["closed_on"]) if attributes["closed_on"]
            
            # optional
            @tags             = get_tags
            @antecedents      = get_antecedents
            @deployment       = get_custom_value(Houston::TMI::NAME_OF_DEPLOYMENT_FIELD)
            @prerequisites    = parse_prerequisites(attributes["associations"])
            @due_date         = attributes["due_on"]
          end
          
          attr_reader :raw_attributes,
                      
                      :remote_id,
                      :number,
                      :summary,
                      :description,
                      :reporter_email,
                      :resolution,
                      :milestone_id,
                      :type,
                      :created_at,
                      :closed_at,
                      
                      :tags,
                      :antecedents,
                      :deployment,
                      :prerequisites,
                      :severity,
                      :component,
                      :due_date
          
          def attributes
            { remote_id:      remote_id,
              number:         number,
              summary:        summary,
              description:    description,
              reporter_email: reporter_email,
              resolution:     resolution,
              milestone_id:   milestone_id,
              type:           type,
              created_at:     created_at,
              closed_at:      closed_at,
              
              tags:           tags,
              antecedents:    antecedents,
              deployment:     deployment,
              prerequisites:  prerequisites,
              due_date:       due_date }
          end
          
          
          
          def resolve!
            unless %w{resolved closed}.member? @raw_attributes["status"].to_s.downcase
              Skylight.instrument title: "Resolve Unfuddle Ticket" do
                ticket = unfuddle.ticket(remote_id)
                ticket.update_attributes!("status" => "Resolved", "resolution" => "fixed")
              end
            end
          end
          
          def close!
            Skylight.instrument title: "Close Unfuddle Ticket" do
              ticket = unfuddle.ticket(remote_id)
              ticket.update_attributes!("status" => "closed")
            end
          end
          
          def reopen!
            unless %w{closed}.member? @raw_attributes["status"].to_s.downcase
              Skylight.instrument title: "Reopen Unfuddle Ticket" do
                ticket = unfuddle.ticket(remote_id)
                ticket.update_attributes!("status" => "Reopened", "resolution" => "", deployment_field => 0)
              end
            end
          end
          
          
          
          def set_milestone!(milestone_id)
            Skylight.instrument title: "Update Unfuddle Ticket" do
              ticket = unfuddle.ticket(remote_id)
              ticket.update_attribute("milestone_id", milestone_id || 0)
            end
          end
          
          
          
          def create_comment!(comment)
            Skylight.instrument title: "Create Unfuddle Comment" do
              unfuddle.as_user(comment.user) do
                ticket = unfuddle.ticket(remote_id)
                ticket.create_comment("body" => comment.body).id
              end
            end
          end
          
          def update_comment!(comment)
            Skylight.instrument title: "Update Unfuddle Comment" do
              unfuddle.as_user(comment.user) do
                unfuddle_comment = comment(comment.remote_id)
                return unless unfuddle_comment
                
                unfuddle_comment.project_id = unfuddle.project_id
                unfuddle_comment.update_attributes!("body" => comment.body)
              end
            end
          end
          
          def destroy_comment!(comment)
            Skylight.instrument title: "Destroy Unfuddle Comment" do
              unfuddle_comment = comment(comment.remote_id)
              return unless unfuddle_comment
              
              unfuddle_comment.project_id = unfuddle.project_id
              unfuddle_comment.destroy!
            end
          end
          
          
          
          # !todo: refactor this method to be more generic and abstract
          def update_attribute(attribute, value)
            case attribute
            when :deployment
              Skylight.instrument title: "Update Unfuddle Ticket" do
                id = unfuddle.find_custom_field_value_by_value!(Houston::TMI::NAME_OF_DEPLOYMENT_FIELD, value).id
                ticket = unfuddle.ticket(remote_id)
                ticket.update_attributes!(deployment_field => id)
              end
              
            else
              raise NotImplementedError
            end
          end
          
          
          
          def get_custom_value(custom_field_name)
            unfuddle_ticket = @raw_attributes
            
            retried_once = false
            begin
              custom_field_key = custom_field_name.underscore.gsub(/\s/, "_")
              
              key = find_in_cache_or_execute("#{custom_field_key}_field") do
                connection.get_ticket_attribute_for_custom_value_named!(custom_field_name) rescue "undefined"
              end
              
              value_id = unfuddle_ticket[key]
              return nil if value_id.blank?
              find_in_cache_or_execute("#{custom_field_key}_value_#{value_id}") do
                connection.find_custom_field_value_by_id!(custom_field_name, value_id).value
              end
            rescue
              if retried_once
                raise
              else
                
                # If an error occurred above, it may be because
                # we cached the wrong value for something.
                retried_once = true
                connection.invalidate_cache!("#{custom_field_key}_field", "#{custom_field_key}_value_#{value_id}")
                retry
              end
            end
          end
          
          
          
        private
          
          attr_reader :connection
          alias :unfuddle :connection
          
          delegate :find_in_cache_or_execute,
                   :invalidate_cache,
                   :deployment_field,
                   :to => :connection
          
          
          
          def get_type
            identify_type_proc = unfuddle.config[:identify_type]
            identify_type_proc.call(self) if identify_type_proc
          end
          
          def get_tags
            identify_tags_proc = unfuddle.config[:identify_tags]
            return [] unless identify_tags_proc
            identify_tags_proc.call(self)
          end
          
          def get_antecedents
            identify_antecedents_proc = unfuddle.config[:identify_antecedents]
            return [] unless identify_antecedents_proc
            identify_antecedents_proc.call(self)
          end
          
          
          
          def parse_prerequisites(associations)
            Array.wrap(associations)
              .select { |assocation| assocation["relationship"] == "parent" }
              .map { |assocation| assocation["ticket"]["number"] }
          end
          
          
          
          def get_severity_name(severity_id)
            severity = unfuddle.severities.find { |severity| severity.id == severity_id }
            severity && severity.name
          end
          
          def get_component_name(component_id)
            component = unfuddle.components.find { |component| component.id == component_id }
            component && component.name
          end
          
          
          
          def comment(remote_comment_id)
            return nil unless remote_comment_id
            
            ticket = unfuddle.ticket(remote_id)
            ticket.comment(remote_comment_id)
          end
          
          
        end
      end
    end
  end
end
