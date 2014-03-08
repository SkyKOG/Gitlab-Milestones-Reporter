require 'json'
require 'gitlab'
require 'redis'

# initialise the gitlab client to access gitlab api
g = Gitlab.client(:endpoint => 'http://code.icicletech.com/api/v3/', :private_token => 'KMpLRJE8mzhuGsBv1xus')

# get all projects for the user
my_projects = Hash[g.projects.map { |project| [project.id, {name: project.name, description: project.description}]}]

# for each project add its milestones
my_projects.each do |key, value|
  my_projects[key][:milestones] = Hash[g.milestones(key).map {|milestone| [milestone.id, {title: milestone.title, count: 0, finished: 0, percentage: 0}]}]
end


























# get issues in paginated manner
g.issues(27,{:page=>1,:per_page=>100}).count

proj_ids.each {|proj_id| milestones_for_projects << g.milestones(proj_id).map {|milestone| {id: milestone.id, title: milestone.title, project_id: milestone.project_id}}}















# milestone_ids = []
# milestones_for_project.each {|milestone| milestone_ids << milestone[:id]}
