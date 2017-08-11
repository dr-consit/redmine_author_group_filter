module RedmineAuthorGroupFilter
	module  IssueQueryPatch
		def self.included(base)
			base.send(:include, InstanceMethods)
			base.class_eval do
				unloadable
				alias_method_chain :initialize_available_filters, :author_group
			end
		end

		module InstanceMethods
			def initialize_available_filters_with_author_group
				result = initialize_available_filters_without_author_group
				group_values = Group.givable.visible.collect {|g| [g.name, g.id.to_s] }
				add_available_filter("author_of_group",
					:type => :list_optional, :values => group_values
				) unless group_values.empty?
			end
  def sql_for_author_of_group_field(field, operator, value)
    if operator == '*' # Any group
      groups = Group.givable
      operator = '=' # Override the operator since we want to find by assigned_to
    elsif operator == "!*"
      groups = Group.givable
      operator = '!' # Override the operator since we want to find by assigned_to
    else
      groups = Group.where(:id => value).to_a
    end
    groups ||= []

    members_of_groups = groups.inject([]) {|user_ids, group|
      user_ids + group.user_ids + [group.id]
    }.uniq.compact.sort.collect(&:to_s)

    '(' + sql_for_field("author_id", operator, members_of_groups, Issue.table_name, "author_id", false) + ')'
  end
		end
	end
end
