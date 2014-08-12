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
  kill: ->
    @alive = false
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.User.addScore()
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
  route: [[40.73956, -73.98887], [40.73985, -73.98956000000001], [40.739909999999995, -73.98969000000001], [40.740249999999996, -73.99053], [40.741609999999994, -73.99374], [40.74161, -73.99374], [40.74222, -73.99329], [40.74262, -73.99301], [40.74268, -73.99296], [40.74272, -73.99293], [40.742889999999996, -73.9928], [40.743559999999995, -73.99231], [40.74417, -73.99187], [40.7448, -73.99142], [40.745419999999996, -73.99096], [40.746019999999994, -73.99052], [40.746649999999995, -73.99007], [40.74726999999999, -73.98962], [40.74788999999999, -73.98917], [40.74850999999999, -73.98871], [40.74909999999999, -73.98826], [40.74918999999999, -73.98819], [40.749779999999994, -73.98776000000001], [40.75046, -73.98729], [40.751079999999995, -73.98685], [40.75169999999999, -73.98641], [40.75231999999999, -73.98597000000001], [40.75294999999999, -73.98552000000001], [40.75354999999999, -73.98504000000001], [40.75417999999999, -73.98460000000001], [40.75418, -73.9846], [40.75505, -73.98668], [40.75505, -73.98668], [40.75434, -73.98691000000001], [40.75434, -73.98691], [40.75378, -73.98557]]  
  image: Assets.BlackUber.sprite
  constructor: ->
    super

class Game.Objects.LyftCar extends Game.Objects.Car
  route: [[40.73927, -74.00141], [40.73854, -73.99969], [40.73736, -73.99687], [40.736000000000004, -73.99364], [40.735730000000004, -73.99302], [40.7357, -73.99295000000001], [40.7352, -73.99174000000001], [40.73509, -73.99148000000001], [40.73498, -73.99122000000001], [40.7348, -73.99078000000002], [40.7345, -73.99010000000001], [40.73442, -73.9899], [40.73395, -73.98879000000001], [40.73328, -73.98720000000002], [40.73328, -73.9872], [40.73397, -73.9867], [40.734609999999996, -73.98622999999999], [40.7352, -73.98580999999999], [40.73577, -73.98536999999999], [40.736360000000005, -73.98494999999998], [40.73695000000001, -73.98452999999998], [40.73754000000001, -73.98408999999998], [40.73816000000001, -73.98364999999998], [40.73883000000001, -73.98314999999998], [40.73883, -73.98315], [40.73788, -73.98091], [40.736869999999996, -73.97854], [40.736639999999994, -73.97798999999999], [40.73658, -73.97784999999999], [40.73629, -73.97715999999998], [40.736059999999995, -73.97660999999998], [40.735929999999996, -73.97631999999997], [40.735479999999995, -73.97522999999997], [40.735429999999994, -73.97511999999996], [40.73537999999999, -73.97496999999996], [40.735339999999994, -73.97484999999996], [40.73534, -73.97485], [40.73548, -73.9748], [40.735620000000004, -73.97479], [40.73577, -73.97479], [40.735870000000006, -73.97479], [40.73595, -73.97479], [40.73595, -73.97479], [40.735960000000006, -73.97476], [40.735980000000005, -73.97473000000001], [40.73599000000001, -73.97471], [40.73601000000001, -73.97469], [40.73603000000001, -73.97467999999999], [40.736050000000006, -73.97465999999999], [40.736090000000004, -73.97464999999998], [40.73613, -73.97463999999998], [40.736180000000004, -73.97463999999998], [40.736230000000006, -73.97463999999998], [40.73630000000001, -73.97461999999997], [40.736380000000004, -73.97459999999997], [40.73649, -73.97456999999997], [40.736580000000004, -73.97452999999997], [40.73668000000001, -73.97448999999997], [40.736760000000004, -73.97445999999998], [40.736850000000004, -73.97440999999998], [40.73691, -73.97435999999998], [40.73697, -73.97429999999997], [40.73699, -73.97427999999996]]
  image: Assets.Lyft.sprite
  constructor: ->
    super
    @width = 68
    @height = 54
  render: (index) ->
    @move(index)
    ctx = Game.ctx
    x = @pos[0] + @width /2 + Game.Map.pos[0]
    y = @pos[1] + @height/2 + Game.Map.pos[1]
    console.log x, y
    if @sprite
      ctx.drawImage(@currentSprite(), x, y)




