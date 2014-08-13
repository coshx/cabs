window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}
window.Routes ||= []

Map = Game.Map

Game.randomRoute = ->
  n = Routes.length - 1
  Routes[Math.round(Math.random() * n)]

Game.Map.load()
Game.objects = []

$ ->
  $("#welcome-message").fadeIn()
  Game.canvas = document.getElementById('canvas')
  Game.canvas.addEventListener 'mousedown', (e) ->
    killed = 0
    mouseX = e.layerX
    mouseY = e.layerY
    for object in Game.objects.filter(Game.alive)
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      a = 10
      if mouseX > x - a - object.width / 2 && mouseX < x + object.width / 2 + a && mouseY > y - a -  object.height / 2 && mouseY < y + object.height / 2 + a
        object.kill(true)
        killed = killed + 1
  Game.canvas.addEventListener 'mousemove', (e) ->
    mouseX = e.layerX
    mouseY = e.layerY
    selected = 0
    for object in Game.objects.filter(Game.alive)
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      a = 10
      if mouseX > x - a && mouseX < x + object.width + a && mouseY > y - a && mouseY < y + object.height + a
        Game.selectedObject = object
        selected += 1
    Game.selectedObject = null if selected == 0
  canvas = Game.canvas
  canvas.width = Game.Map.width
  canvas.height = Game.Map.height
  Game.ctx = canvas.getContext("2d")
  ctx = Game.ctx
  ctx.fillStyle = "#000000"
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.render(0)
  $("#welcome-message .button").click ->
    Game.main()
    $("#welcome-message").fadeOut()
    Game.objects.push new Game.Objects.BlackUberCar()

  $("#game-over-button").click ->
    Game.User.score = 0.0
    $("#positive-scores").fadeOut()
    $("#negative-scores").fadeOut()
    $("#save-score").fadeIn()
    $("#score-board").fadeOut()
    $("#score").text("$0.00")
    Game.lastTime = Date.now()
    Game.startTime = Date.now()
    $("#game-over").fadeOut()
    Game.User.synced = false

  $("#save-score .button").click ->
    Game.User.saveScore $("#save-score input").val(), Game.User.score
    $("#save-score").fadeOut()
    $("#score-board").fadeIn()

Game.render = (index) ->
  ctx = Game.ctx
  canvas = Game.canvas
  ctx.fillStyle = '#345678'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  Game.Map.render()
  Game.selectedObject.drawRoute() if Game.selectedObject
  for object in Game.objects
    object.render(index)

Game.alive = (a) ->
  a.alive

Game.totalTime = 60
Game.lastTime = Date.now()
Game.startTime = Date.now()


Game.updateTimer = ->
  Game.timer = Game.totalTime - Math.round((Game.lastTime - Game.startTime) / 1000)
  if Game.timer <= 0
    for object in Game.objects.filter(Game.alive)
      object.kill()
    if Game.User.score > 0
      $("#positive-scores").fadeIn()
    else
      $("#negative-scores").fadeIn()
    $("#game-over").fadeIn()
    Game.User.renderScoreBoard()
    $("#game-over .scores").text(Math.abs(Game.User.score).toFixed(2))
    Game.timer = 0
  # not to update every 1/60 second
  if Game.timer != Game.lastTimer
    $("#timer").text(Game.timer)
    if Game.timer == 20
      $("#prime-time").fadeIn()
      Game.User.getScores() unless Game.User.synced
    if Game.timer == 10
      $('#prime-time').addClass('animated bounceIn')

  maxCars = ((60 - Game.timer) / 6) + 4
  minCars = ((60 - Game.timer) / 12) + 2
  if Game.objects.filter(Game.alive).length < maxCars && Game.timer > 0

    if (Game.timer != Game.lastTimer) || Game.objects.filter(Game.alive).length < minCars
      Game.spawnCar()

  Game.lastTimer = Game.timer


Game.spawnCar = ->
  if Math.round(Math.random() * 100) > 97
    Game.objects.push new Game.Objects.LyftCar()
  else if Math.round(Math.random() * 100) > 60
    Game.objects.push new Game.Objects.BlackUberCar()
  else
    Game.objects.push new Game.Objects.XUberCar()

#main loop
Game.main = ->
  now = Date.now()
  dt = (now - Game.lastTime) / 1000.0
  Game.updateTimer()
  Game.lastTime = now
  if Game.timer >= 0
    Game.render(dt)
  window.setTimeout Game.main, 1000 / 60
