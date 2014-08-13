window.Game ||= {}
window.Assets ||= {}
Game.Objects = {}

Game.User =
  score: 0.0
  addScore: (score) ->
    if score > 0.0
      @score = @score + score
      @scoreFlash(score, "#33FF99")
      @render()
  subtractScore: (score) ->
    if score > 0.0
      @score = @score - (score / 2)
      @scoreFlash(score, "#B00000")
      @render()
  render: ->
    $("#score").text("$" + @score.toFixed(2))
  scoreFlash: (score, color) ->
    $(".local-score-wrapper").stop().show(0)
    $('#local-score').removeClass()
    $('#local-score').addClass('animated bounceIn')
    $("#local-score").text("$" + score.toFixed(2))
    $("#local-score").css("color", color)
    $(".local-score-wrapper").fadeOut(2000)
  saveScore: ->
    UserScore = Parse.Object.extend("UserScore")
    userScore = new UserScore()
    userScore.save(
      name: "bar"
      score: 132
    ).then (object) ->
      alert("saved")
  getScores: ->
    UserScore = Parse.Object.extend("UserScore")
    query = new Parse.Query(UserScore)
    query.ascending("score")
    query.limit(10)
    query.find
      success: (results) ->
        alert("Successfully retrieved " + results.length + " scores.");
      error: (error) ->
        alert("Error: " + error.code + " " + error.message);

Game.Map =
  topLeft: [40.758014, -74.013621]
  bottomRight: [40.733368, -73.959291]
  pos: [0, 0]
  image: Assets.Map.sprite
  width: 1251
  height: 766
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image
    @px = Game.Map.width /  (Game.Map.bottomRight[1] - Game.Map.topLeft[1])
    @py = Game.Map.height / (Game.Map.topLeft[0] - Game.Map.bottomRight[0])

  render: (index) ->
    ctx = Game.ctx
    x =  @pos[0]
    y =  @pos[1]
    if @sprite
      ctx.drawImage(@sprite, x, y)

class Game.Objects.Car
  toX: (coordinate) ->
    Game.Map.width -  (coordinate - Game.Map.bottomRight[1]) * Game.Map.px * -1
  toY: (coordinate) ->
    Game.Map.height - (coordinate - Game.Map.bottomRight[0]) * Game.Map.py 
  getPos: ->
    @pos[0] = @toX @route[0][1]
    @pos[1] = @toY @route[0][0]
  getNextDestination: ->
    @distance = 0
    @currentDestination = @currentDestination + 1
    if @route[@currentDestination]
      @distCoordinates = @route[@currentDestination]
      @distPos = @pixelsRoute[@currentDestination]
      ex = @distPos[0]
      ey = @distPos[1]
      cx = @pos[0]
      cy = @pos[1]
      dy = ey - cy
      dx = ex - cx
      @angle = Math.atan2(dy, dx)
      @angle *= 180/Math.PI
      @angle = @angle + 90
      @currentDistance = @getDistance(@pos, @distPos)
    else
      @arrive()
  loaded: false
  deadImage:  Assets.BlackUber.explodeSprite
  completeImage: Assets.completeSprite


  uturn: 0
  alive: true
  distance: 0
  totalDistance: 0
  constructor: ->
    @route = Game.randomRoute()
    @getPixelsRoute()
    @getLifeTime()
    @width = 70
    @height = 70
    @pos = [0, 0]
    @currentDestination = 0
    @load()
    @getPos()
    @getNextDestination()
    @explosionTime = 20
  getLifeTime: ->
    n = @route.length - 1
    i = 0
    @lifeDistance = 0
    while i < n
      distance = @getDistance(@pixelsRoute[i], @pixelsRoute[i + 1])
      @lifeDistance += distance
      i++
  drawRoute: ->
    n = @route.length - 1
    i = 0
    ctx = Game.ctx
    ctx.save()
    ctx.beginPath()
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#33FF33';
    while i < n
      ctx.moveTo(@pixelsRoute[i][0], @pixelsRoute[i][1])
      ctx.lineTo(@pixelsRoute[i + 1][0], @pixelsRoute[i + 1][1])
      i++
    ctx.stroke()
    ctx.restore()
  getPixelsRoute: ->
    @pixelsRoute = []
    $.each @route, (i, r) =>
      @pixelsRoute.push [@toX(r[1]), @toY(r[0])]
  kill: (scores) ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.addScore(@fare()) if scores
  arrive: () ->
    @complete = true
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.subtractScore(@fare() / 2.0)

  currentSprite: ->
    if @alive
      if @totalDistance < 4000
        @sprite
      else if @totalDistance < 8000
        @lowFareSprite
      else if @totalDistance < 16000
        @midFareSprite
      else
        @highFareSprite
    else
      if @complete
        @completeFlag
      else
        @deadSprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image

    image = new Image()
    image.src = @lowFareImage
    @lowFareSprite = image

    image = new Image()
    image.src = @midFareImage
    @midFareSprite = image

    image = new Image()
    image.src = @highFareImage
    @highFareSprite = image

    image = new Image()
    image.src = @deadImage
    @deadSprite = image

    image = new Image()
    image.src = @completeImage
    @completeFlag = image

  getDistance: (point1, point2) ->
    xs = point2[0] - point1[0]
    xs = xs * xs

    ys = point2[1] - point1[1]
    ys = ys * ys

    Math.sqrt( xs + ys )

  fare: ->
    base = (@totalDistance / 600) - 3.0
    base = 0 if base < 0
    ((@totalDistance / 1000) + base) * @fareMultiplier

  move: (index) ->
    if @alive
      lag = index * 70
      @distance = @distance + lag
      if @distance >= @currentDistance
        @pos = @distPos
        @getNextDestination()
      else
        x = Math.sin(@angle * Math.PI/180) * lag
        y = Math.cos(@angle * Math.PI/180) * lag
        @pos[0] = @pos[0] + x
        @pos[1] = @pos[1] - y
      @totalDistance += @distance
      for object in Game.objects.filter(Game.alive)
        unless object == @
          x = object.pos[0]
          y = object.pos[1]
          a = 0
          if @pos[0] > x - a && @pos[0] < x + (0.2 * object.width) + a && @pos[1] > y - a && @pos[1] < y + (0.6 * object.height) + a
            object.kill()
            @kill()

  render: (index) ->
    unless @exploded
      unless @alive
        @explosionTime = @explosionTime - 1
        @exploded = true if @explosionTime <= 0
      @move(index)
      ctx = Game.ctx
      x = @pos[0] + Game.Map.pos[0]
      y = @pos[1] + Game.Map.pos[1]
      if @complete
        ctx.drawImage(@currentSprite(), x-@width/2 +20, y-@height/2 - 60)
      else
        ctx.save()
        ctx.translate(x, y)
        ctx.rotate(@angle * Math.PI / 180)
        if @sprite
          ctx.drawImage(@currentSprite(), -@width/2, -@height/2)
        ctx.restore()

class Game.Objects.BlackUberCar extends Game.Objects.Car
  image: Assets.BlackUber.sprite
  lowFareImage: Assets.BlackUber.lowFareSprite
  midFareImage: Assets.BlackUber.midFareSprite
  highFareImage: Assets.BlackUber.highFareSprite
  fareMultiplier: 1.3
  constructor: ->
    super

class Game.Objects.XUberCar extends Game.Objects.Car
  image: Assets.XUber.sprite
  lowFareImage: Assets.XUber.lowFareSprite
  midFareImage: Assets.XUber.midFareSprite
  highFareImage: Assets.XUber.highFareSprite
  fareMultiplier: 1.0
  constructor: ->
    super

class Game.Objects.LyftCar extends Game.Objects.Car
  image: Assets.Lyft.sprite
  lowFareImage: Assets.Lyft.lowFareSprite
  midFareImage: Assets.Lyft.midFareSprite
  highFareImage: Assets.Lyft.highFareSprite
  fareMultiplier: 2.0

  constructor: ->
    super
    @width = 68
    @height = 54
  render: (index) ->
    unless @exploded
      unless @alive
        @explosionTime = @explosionTime - 1
        @exploded = true if @explosionTime <= 0

      @move(index)
      ctx = Game.ctx
      x = @pos[0] + Game.Map.pos[0]
      y = @pos[1] + Game.Map.pos[1]
      if @complete
        ctx.drawImage(@currentSprite(), x-@width/2 +20, y-@height/2 - 60)
      else
        ctx.save()
        ctx.translate(x, y)
        if @sprite
          ctx.drawImage(@currentSprite(), -@width/2, -@height/2)
        ctx.restore()
