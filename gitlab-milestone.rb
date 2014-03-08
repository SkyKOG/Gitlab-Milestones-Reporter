require 'json'
require 'gitlab'
require 'redis'

g = Gitlab.client(:endpoint => 'http://code.icicletech.com/api/v3/', :private_token => 'KMpLRJE8mzhuGsBv1xus')

# Get all projects for the user
my_projects = g.projects.map { |project| {id: project.id, name: project.name, description: project.description}}

# get ids for all the projects
proj_ids = []
my_projects.each {|project| proj_ids <<  project[:id]}

# create an array containing, array of milestones for each project
milestones_for_projects = []
proj_ids.each {|proj_id| milestones_for_projects << g.milestones(proj_id).map {|milestone| {id: milestone.id, title: milestone.title, project_id: milestone.project_id}}}
milestones_for_projects.reject! { |c| c.empty? }

# Retrieve projects having milestones
projects_having_milestones = []
milestones_for_projects.each { |mile_proj| projects_having_milestones << mile_proj.first[:project_id] }


# fetch issues for each project belonging to a project milestone
all_issues = []

projects_having_milestones.each do |project|
  i = 1
  loop do
    issues_in_this_page = g.issues(project,{:page=>i,:per_page=>100})
    break if issues_in_this_page.empty?
    issues_in_this_page.reject! { |c| c.milestone.nil? }
    issues_in_this_page.map {|issue_in_this_page| all_issues << {issue_id: issue_in_this_page.id, issue_title: issue_in_this_page.title, issue_state: issue_in_this_page.state, project_id: issue_in_this_page.project_id, milestone_id: issue_in_this_page.milestone.id }}
    i+=1
  end
end




# get issues in paginated manner
g.issues(27,{:page=>1,:per_page=>100}).count

proj_ids.each {|proj_id| milestones_for_projects << g.milestones(proj_id).map {|milestone| {id: milestone.id, title: milestone.title, project_id: milestone.project_id}}}















# milestone_ids = []
# milestones_for_project.each {|milestone| milestone_ids << milestone[:id]}
