window.Game ||= {}
window.Assets ||= {}
Game.Objects = {}

Game.User =
  score: 0
  addScore: ->
    @score = @score + 1
    @render()
  render: ->
    $("#score").text(@score)

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
  uturn: 0
  alive: true
  distance: 0
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
    Game.User.addScore() if scores
  currentSprite: ->
    if @alive
      @sprite
    else
      @deadSprite
  load: ->
    image = new Image()
    image.src = @image
    @sprite = image
    image = new Image()
    image.src = @deadImage
    @deadSprite = image

  getDistance: (point1, point2) ->
    xs = point2[0] - point1[0]
    xs = xs * xs

    ys = point2[1] - point1[1]
    ys = ys * ys

    Math.sqrt( xs + ys )

  move: (index) ->
    if @alive
      x = @pos[0]
      y = @pos[1]

      if (y < @width || x < @height || x > Game.canvas.width - @width|| y > Game.canvas.height - @height)&&(@uturn <= 0)
        @makeUturn()
      lag = index * 100
      x = Math.sin(@angle * Math.PI/180) * lag
      y = Math.cos(@angle * Math.PI/180) * lag
      @pos[0] = @pos[0] + x
      @pos[1] = @pos[1] - y
      @distance = @distance + index * 100
      if @distance >= @currentDistance
        @getNextDestination()

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




