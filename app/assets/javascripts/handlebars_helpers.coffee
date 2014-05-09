Handlebars.registerHelper 'formatDuration', (seconds)->
  if seconds < Duration.HOUR
    minutes = Math.floor(seconds / Duration.MINUTE)
    unit = if minutes == 1 then 'minute' else 'minutes'
    "#{minutes} #{unit}"
  else if seconds < Duration.DAY
    hours = Math.floor(seconds / Duration.HOUR)
    unit = if hours == 1 then 'hour' else 'hours'
    "#{hours} #{unit}"
  else
    days = Math.floor(seconds / Duration.DAY)
    unit = if days == 1 then 'day' else 'days'
    "#{days} #{unit}"

Handlebars.registerHelper 'formatDate', (timestamp)->
  Date.create(timestamp).format('ddd mmm d')

Handlebars.registerHelper 'formatDateWithYear', (timestamp)->
  return "" unless timestamp
  date = Date.create(timestamp)
  date.format('mmm d') + "<span class=\"year\">#{date.format('yyyy')}</span>"

Handlebars.registerHelper 'formatTime', (timestamp)->
  Date.create(timestamp).format('ddd mmm d, yyyy h:mmt')

Handlebars.registerHelper 'markdown', (markdown)->
  converter = new Markdown.Converter()
  html = converter.makeHtml(markdown)
  App.emojify(html)

Handlebars.registerHelper 'emojify', (string)->
  App.emojify(string)

Handlebars.registerHelper 'classForAge', (seconds)->
  if seconds < (6 * Duration.HOUR)
    'infant'
  else if seconds < (2 * Duration.DAY)
    'child'
  else if seconds < (7 * Duration.DAY)
    'adult'
  else if seconds < (4 * Duration.WEEK)
    'senior'
  else if seconds < (26 * Duration.WEEK)
    'old'
  else
    'ancient'

Handlebars.registerHelper 'radioButton', (object, id, name, value, selectedValue)->
  id = "#{object}_#{id}_#{name}_#{value}"
  input = "<input type=\"radio\" id=\"#{id}\" name=\"#{name}\" value=\"#{value}\""
  input = input + ' checked="checked"' if value == selectedValue
  "#{input} />"

Handlebars.registerHelper 'formatTicketSummary', (message)->
  App.formatTicketSummary(message)

Handlebars.registerHelper 'linkToCommit', (commit)->
  sha = commit.sha[0...8]
  if commit.linkTo
    "<a href=\"#{commit.linkTo}\" target=\"_blank\">#{sha}</a>"
  else
    sha

Handlebars.registerHelper 'testerAvatar', (email, size, title)->
  tester = window.testers.findByEmail(email)
  gravatarUrl = "http://www.gravatar.com/avatar/#{MD5(email.toLowerCase().trim())}?r=g&d=retro&s=#{size * 2}"
  "<img src=\"#{gravatarUrl}\" width=\"#{size}\" height=\"#{size}\" rel=\"tooltip\" title=\"#{tester.get('name')}\" />"
  
Handlebars.registerHelper 'userAvatar', (size)->
  user = window.user
  gravatarUrl = "http://www.gravatar.com/avatar/#{MD5(user.get('email').toLowerCase().trim())}?r=g&d=retro&s=#{size * 2}"
  "<img src=\"#{gravatarUrl}\" width=\"#{size}\" height=\"#{size}\" rel=\"tooltip\" title=\"#{user.get('name')}\" />"
  
Handlebars.registerHelper 'avatar', (email, size, title)->
  return "" unless email
  gravatarUrl = "http://www.gravatar.com/avatar/#{MD5(email.toLowerCase().trim())}?r=g&d=retro&s=#{size * 2}"
  if title
    "<img src=\"#{gravatarUrl}\" width=\"#{size}\" height=\"#{size}\" rel=\"tooltip\" title=\"#{title}\" />"
  else
    "<img src=\"#{gravatarUrl}\" width=\"#{size}\" height=\"#{size}\" />"
  
Handlebars.registerHelper 'ifEq', (v1, v2, block)->
  if v1 == v2
    block.fn(@)
  else
    block.inverse(@)

Handlebars.registerHelper 'summarizeAntecedents', (antecedents)->
  html = ''
  for kind, antecedents of _.groupBy(antecedents, (antecedent)-> antecedent.kind)
    html += "#{kind} <span class=\"badge\">#{antecedents.length}</span>"
  html
