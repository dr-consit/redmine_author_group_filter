require 'redmine'

ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue_query'
  IssueQuery.send(:include, RedmineAuthorGroupFilter::IssueQueryPatch)
end

Redmine::Plugin.register :redmine_author_group_filter do
  requires_redmine :version_or_higher => '3.0.1'

  name 'Redmine author group filter'
  author 'David Robinson'
  description "Provides ability to filter by authors group"
  version '0.1.0'
end
