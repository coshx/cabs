window.Game ||= {}
window.Assets ||= {}
Game.Objects = {}

Game.User =
  score: 0.0
  addScore: (score) ->
    if score > 0.0
      @score = @score + score
      @scoreFlash(score)
      @render()
  render: ->
    $("#score").text("$" + @score.toFixed(2))
  scoreFlash: (score) ->
    $(".local-score-wrapper").stop().fadeIn(0)
    $("#local-score").text("$" + score.toFixed(2))
    $(".local-score-wrapper").fadeOut(2000)

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
    Game.Map.width -  (coordinate - Game.Map.bottomRight[1]) * Game.Map.px * -1 - @width / 2
  toY: (coordinate) ->
    Game.Map.height - (coordinate - Game.Map.bottomRight[0]) * Game.Map.py  - @height / 2
  getPos: ->
    @pos[0] = @toX @route[0][1]
    @pos[1] = @toY @route[0][0]
  getNextDestination: ->
    @distance = 0
    @currentDestination = @currentDestination + 1
    if @route[@currentDestination]
      @distCoordinates = @route[@currentDestination]
      @distPos = []
      @distPos[1] = @toY @distCoordinates[0]
      @distPos[0] = @toX @distCoordinates[1]
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
      @kill()
  loaded: false
  deadImage:  Assets.BlackUber.explodeSprite
  lowFareImage: Assets.BlackUber.lowFareSprite
  midFareImage: Assets.BlackUber.midFareSprite
  highFareImage: Assets.BlackUber.highFareSprite

  uturn: 0
  alive: true
  distance: 0
  totalDistance: 0
  constructor: ->
    @route = Game.randomRoute()
    @width = 70
    @height = 70
    @pos = [0, 0]
    @currentDestination = 0
    @load()
    @getPos()
    @getNextDestination()
    @explosionTime = 20
  makeUturn: ->
    if @uturn <= 0
      @uturn = 180
  kill: (scores) ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.addScore(@fare()) if scores
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

  getDistance: (point1, point2) ->
    xs = point2[0] - point1[0]
    xs = xs * xs

    ys = point2[1] - point1[1]
    ys = ys * ys

    Math.sqrt( xs + ys )

  fare: ->
    base = 2.0
    (@totalDistance / 1000) + base

  move: (index) ->
    if @alive
      lag = index * 100
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
          if @pos[0] > x - a && @pos[0] < x + object.width + a && @pos[1] > y - a && @pos[1] < y + object.height + a
            object.kill()
            @kill()


  render: (index) ->
    unless @exploded
      unless @alive
        @explosionTime = @explosionTime - 1
        @exploded = true if @explosionTime <= 0
      @move(index)
      ctx = Game.ctx
      x = @pos[0] + @width /2 + Game.Map.pos[0]
      y = @pos[1] + @height/2 + Game.Map.pos[1]
      ctx.save()
      ctx.translate(x, y)
      ctx.rotate(@angle * Math.PI / 180)
      if @sprite
        ctx.drawImage(@currentSprite(), -@width/2, -@height/3*2)
      ctx.restore()

class Game.Objects.UberCar extends Game.Objects.Car
  image: Assets.BlackUber.sprite
  constructor: ->
    super

class Game.Objects.LyftCar extends Game.Objects.Car
  image: Assets.Lyft.sprite
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
      x = @pos[0] + @width /2 + Game.Map.pos[0]
      y = @pos[1] + @height/2 + Game.Map.pos[1]
      if @sprite
        ctx.drawImage(@currentSprite(), x, y)




