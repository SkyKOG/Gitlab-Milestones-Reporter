require 'json'
require 'gitlab'
require 'redis'

g = Gitlab.client(:endpoint => 'http://code.icicletech.com/api/v3/', :private_token => 'KMpLRJE8mzhuGsBv1xus')

# Get all projects for the user
my_projects = g.projects.map { |project| {id: project.id, name: project.name, description: project.description}}

# get ids for all the projects
proj_ids = []
my_projects.each {|project| proj_ids <<  project[:id]}

# Get a particular milestone
milestones_for_project = g.milestones(27).map {|milestone| {id: milestone.id, title: milestone.title}}
milestone_ids = []
milestones_for_project.each {|milestone| milestone_ids << milestone[:id]}




# get issues in paginated manner
g.issues(27,{:page=>1,:per_page=>100}).count
