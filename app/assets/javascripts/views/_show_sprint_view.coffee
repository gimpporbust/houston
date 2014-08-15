class @ShowSprintView extends Backbone.View
  
  initialize: ->
    @sprintId = @options.sprintId
    @sprintStart = @options.sprintStart
    @template = HandlebarsTemplates['sprints/show']
    @tasks = _.sortBy @options.sprintTasks, (task)-> task.projectTitle
    super
  
  setStart: (@sprintStart)-> @
  setTasks: (sprintTasks)->
    @tasks = _.sortBy sprintTasks, (task)-> task.projectTitle
    @
  
  render: ->
    return @ unless @tasks
    for task in @tasks
      task.completed = !!task.firstReleaseAt || !!task.firstCommitAt
      task.open = !task.completed
    
    @$el.html @template()
    @renderBurndownChart(@tasks)
  
  renderBurndownChart: (tasks)->
    
    # The time range of the Sprint
    today = new Date()
    monday = @sprintStart
    sunday = 1.day().before(monday)
    days = (i.days().after(sunday) for i in [0..5])
    
    # Sum progress by day;
    # Find the total amount of effort to accomplish
    committedByDay = {}
    completedByDay = {}
    totalEffort = 0
    for task in tasks
      effort = +task.effort
      if task.firstReleaseAt
        day = App.truncateDate App.parseDate(task.firstReleaseAt)
        effort = 0 if day < monday # this task was released before this sprint started!
        
        completedByDay[day] = (completedByDay[day] || 0) + effort
        committedByDay[day] = (committedByDay[day] || 0) + effort unless task.firstCommitAt
      
      if task.firstCommitAt
        day = App.truncateDate App.parseDate(task.firstCommitAt)
        effort = 0 if day < monday # this task was released before this sprint started!
        
        committedByDay[day] = (committedByDay[day] || 0) + effort
      totalEffort += effort
    
    # for debugging
    window.completedByDay = completedByDay
    
    # Transform into remaining effort by day:
    # Iterate by day in case there are some days
    # where no progress was made
    toChartData = (progressByDay)->
      remainingEffort = totalEffort
      data = [
        day: sunday
        effort: Math.ceil(remainingEffort)
      ]
      for day in days
        unless day > today
          remainingEffort -= (progressByDay[day] || 0)
          data.push
            day: day
            effort: Math.ceil(remainingEffort)
      data
    
    new Houston.BurndownChart()
      .days(days)
      .totalEffort(totalEffort)
      .addLine('committed', toChartData(committedByDay))
      .addLine('completed', toChartData(completedByDay))
      .render()