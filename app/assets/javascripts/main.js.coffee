window.Game ||= {}
window.Assets ||= {}
Game.Objects ||= {}
window.Routes ||= []

Game.totalTime = 21

Map = Game.Map

Game.randomRoute = ->
  n = Routes.length - 1
  Routes[Math.round(Math.random() * n)]

Game.objects = []
Game.Map.load(Game.Map.render)

Game.isMobile =
  Android: ->
    return /Android/i.test(navigator.userAgent)
  BlackBerry: ->
    return /BlackBerry/i.test(navigator.userAgent)
  iOS: ->
    return /iPhone|iPad|iPod/i.test(navigator.userAgent)
  Windows: ->
    return /IEMobile/i.test(navigator.userAgent)
  any: ->
    return (@Android() || @BlackBerry() || @iOS() || @Windows())

Game.centerPopup = (id) ->
  message = $("#{id} .message")
  messageHeight = message.height()
  newHeight = -messageHeight/2
  message.css("margin-top", newHeight)

$ ->

  if Game.isMobile.any()
    Game.touchRadius = 25
    $("html").addClass("mobile")
  else
    Game.touchRadius = 10

  $("#welcome-message").fadeIn 400, ->
    Game.centerPopup("#welcome-message")

  Game.canvas = document.getElementById('canvas')

  Game.canvas.addEventListener 'mousedown', (e) ->
    killed = 0
    mouseX = e.layerX
    mouseY = e.layerY
    for object in Game.objects.filter(Game.alive)
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      if mouseX > x - Game.touchRadius - object.width / 2 && mouseX < x + object.width / 2 + Game.touchRadius && mouseY > y - Game.touchRadius -  object.height / 2 && mouseY < y + object.height / 2 + Game.touchRadius
        object.kill(true)
        killed = killed + 1
  Game.canvas.addEventListener 'mousemove', (e) ->
    mouseX = e.layerX
    mouseY = e.layerY
    selected = 0
    for object in Game.objects.filter(Game.alive)
      x = object.pos[0] + Map.pos[0]
      y = object.pos[1] + Map.pos[1]
      if mouseX > x - Game.touchRadius && mouseX < x + object.width + Game.touchRadius && mouseY > y - Game.touchRadius && mouseY < y + object.height + Game.touchRadius
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
  $("#welcome-message .button").click ->
    Game.main()
    $("#welcome-message").fadeOut()
    Game.objects.push new Game.Objects.BlackUberCar()
    Game.objects.push new Game.Objects.XUberCar()

    Game.lastTime = Date.now()
    Game.startTime = Date.now()

  $(".toggle-fullscreen").click ->
    # alternative standard method
    if not document.fullscreenElement and not document.mozFullScreenElement and not document.webkitFullscreenElement # current working methods
      if document.documentElement.requestFullscreen
        document.documentElement.requestFullscreen()
      else if document.documentElement.mozRequestFullScreen
        document.documentElement.mozRequestFullScreen()
      else document.documentElement.webkitRequestFullscreen Element.ALLOW_KEYBOARD_INPUT  if document.documentElement.webkitRequestFullscreen
    else
      if document.cancelFullScreen
        document.cancelFullScreen()
      else if document.mozCancelFullScreen
        document.mozCancelFullScreen()
      else document.webkitCancelFullScreen()  if document.webkitCancelFullScreen
    return

  $("#game-over-button").click ->
    Game.User.score = 0.0
    Game.User.lastBonusLevel = 0
    $(".hide-on-board-show.game-over").fadeIn()
    $("#positive-scores").fadeOut()
    $("#negative-scores").fadeOut()
    $("#save-score").fadeIn()
    $("#score-board").fadeOut()
    $("#score").text("$0.00")
    Game.lastTime = Date.now()
    Game.startTime = Date.now()
    Game.timer = Game.totalTime
    $("#game-over").fadeOut()
    Game.User.synced = false
    Game.objects.push new Game.Objects.BlackUberCar()
    Game.objects.push new Game.Objects.XUberCar()

  $("#save-score .button").click ->
    Game.User.saveScore $("#save-score input").val(), Game.User.score
    $("#save-score").fadeOut()
    $(".hide-on-board-show").fadeOut()
    $("#score-board").fadeIn 400, ->
      setTimeout (->
        Game.centerPopup("#game-over")
        ),300

  $("#full-screen").click ->
    docElm=document.body
    if docElm.requestFullScreen
      docElm.requestFullScreen()
    else if docElm.mozRequestFullScreen
      docElm.mozRequestFullScreen()
    else if docElm.webkitRequestFullScreen
      docElm.webkitRequestFullScreen(Element.ALLOW_KEYBOARD_INPUT)

Game.render = (index) ->
  Game.Map.render()
  Game.selectedObject.drawRoute() if Game.selectedObject
  for object in Game.objects
    object.render(index) if object

Game.alive = (a) ->
  a.alive

Game.lastTime = Date.now()
Game.startTime = Date.now()
Game.bonusTime = 0

Game.gameOver = ->
  for object in Game.objects.filter(Game.alive)
    object.kill()
  if Game.User.score > 0
    $("#positive-scores").fadeIn()
  else
    $("#negative-scores").fadeIn()
  $("#prime-time").fadeOut(0)
  title = Game.User.title()
  $("#game-title").text(title.title)
  $("#share-button").html("<div class='fb-share-button' data-type='button' data-width='70px' data-href='http://www.angry.cab/title/#{title.slug}'></div>")
  window.FB.XFBML.parse(document.getElementById('share-button'));
  $("#game-over .scores").text(Math.abs(Game.User.score).toFixed(2))
  $("#game-over").fadeIn 400, ->
    Game.centerPopup("#game-over")
  Game.timer = 0


Game.updateTimer = (bonus) ->
  Game.timer = Game.totalTime - Math.round((Game.lastTime - Game.startTime) / 1000) unless Game.timer <= 0
  if bonus
    Game.bonusTime = bonus / 1000
    Game.startTime += bonus
  # not to update every 1/60 second
  if Game.timer != Game.lastTimer
    $("#timer").text(Game.timer)
    if Game.bonusTime > 0
      $("#timer").css("color", "#33FF99")
      Game.bonusTime -= 1
    else
      $("#timer").css("color", "red")
    if Game.timer == 20
      $("#prime-time").fadeIn()
      Game.User.getScores() unless Game.User.synced
    if Game.timer == 10
      $('#prime-time').addClass('animated bounceIn')
    if Game.timer <= 0
      Game.gameOver()


  maxCars = ((60 - Game.timer) / 10) + 4
  maxCars -= 1 if Game.timer > 40 
  minCars = ((60 - Game.timer) / 12) + 2
  if Game.objects.filter(Game.alive).length < maxCars && 0 < Game.timer < 57

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
