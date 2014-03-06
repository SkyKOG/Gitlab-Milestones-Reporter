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


# milestone_ids = []
# milestones_for_project.each {|milestone| milestone_ids << milestone[:id]}




# get issues in paginated manner
g.issues(27,{:page=>1,:per_page=>100}).count

proj_ids.each {|proj_id| milestones_for_projects << g.milestones(proj_id).map {|milestone| {id: milestone.id, title: milestone.title, project_id: milestone.project_id}}}
