require 'json'
require 'gitlab'
require 'redis'
require 'formatador'
require 'active_support/core_ext/integer/inflections'

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

# display output in table
File.open('gitlab-milestones.html', 'w') do |gmile|
  gmile.puts "<h1>" + "Gitlab Milestone Report " + "</h1>"
  gmile.puts "<h3>" + "Account: " + g.user.name.to_s + "</h3>"
  gmile.puts "<h3>" + "Time: " + Time.new.strftime("%a, %b #{time.day.ordinalize} %Y, %I:%M %p") + "</h3>"

  gmile.puts "<hr />"
  my_projects.keys.each do |project|
    puts my_projects[project][:name]
    milestone_status_hash = my_projects[project][:milestones].keys.map { |k| { milestone: my_projects[project][:milestones][k][:title], total: my_projects[project][:milestones][k][:count], completed: my_projects[project][:milestones][k][:finished], percentage: my_projects[project][:milestones][k][:finished].to_s + "%", remaining: my_projects[project][:milestones][k][:count] - my_projects[project][:milestones][k][:finished]}}
    Formatador.display_table(milestone_status_hash, [:milestone, :percentage, :total, :completed, :remaining])

    gmile.puts "<h2>" + my_projects[project][:name] + "</h2>"
    gmile.puts '<table border="1">'
      gmile.puts "<tr>"
        gmile.puts "<th>" + "Milestone"+"</th>"
        gmile.puts "<th>" + "Percentage"+"</th>"
        gmile.puts "<th>" + "Total"+"</th>"
        gmile.puts "<th>" + "Completed"+"</th>"
        gmile.puts "<th>" + "Remaining"+"</th>"
      gmile.puts "</tr>"
      my_projects[project][:milestones].keys.each do |t|
        gmile.puts "<tr>"
        gmile.puts "<td>" + my_projects[project][:milestones][t][:title].to_s + "</td>"
        gmile.puts "<td>" + my_projects[project][:milestones][t][:percentage].to_i.to_s + "%"+ "</td>"
        gmile.puts "<td>" + my_projects[project][:milestones][t][:finished].to_s + "</td>"
        gmile.puts "<td>" + my_projects[project][:milestones][t][:count].to_s + "</td>"
        gmile.puts "<td>" + (my_projects[project][:milestones][t][:count] - my_projects[project][:milestones][t][:finished]).to_s + "</td>"
        gmile.puts "</tr>"
      end
    gmile.puts "<table>"
  end
end
