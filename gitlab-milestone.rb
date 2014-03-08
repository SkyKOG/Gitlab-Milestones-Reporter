require 'json'
require 'gitlab'
require 'redis'

# initialise the gitlab client to access gitlab api
g = Gitlab.client(:endpoint => 'http://code.icicletech.com/api/v3/', :private_token => 'KMpLRJE8mzhuGsBv1xus')

# get all projects for the user
my_projects = Hash[g.projects.map { |project| [project.id, {name: project.name, description: project.description}]}]

# for each project add its milestones and remove projects which dont have milestone
my_projects.each do |k, v|
  my_projects[k][:milestones] = Hash[g.milestones(k).map {|milestone| [milestone.id, {title: milestone.title, count: 0, finished: 0, percentage: 0}]}]
  my_projects.delete(k) if my_projects[k][:milestones].empty?
end

# calculate count / finished issues for milestones of each project
my_projects.keys.each do |project|
  i = 1
  loop do
    issues_in_this_page = g.issues(project,{:page=>i,:per_page=>100})
    break if issues_in_this_page.empty?
    issues_in_this_page.reject! { |c| c.milestone.nil? }
    issues_in_this_page.each do |issue|
      my_projects[project][:milestones][issue.milestone.id][:count]+=1
      my_projects[project][:milestones][issue.milestone.id][:finished]+=1 if issue.state == "closed"
    end
    i+=1
  end

  # calculate % of completed milestone
  my_projects[project][:milestones].keys.each do |k|
    my_projects[project][:milestones][k][:percentage] = my_projects[project][:milestones][k][:finished].to_f / my_projects[project][:milestones][k][:count]*100 unless my_projects[project][:milestones][k][:finished] == 0
  end
end
