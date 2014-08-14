window.Game ||= {}
window.Assets ||= {}
Game.Objects = {}

Game.User =
  score: 0.0
  addScore: (score) ->
    if score > 0.0
      @score = @score + score
      @render()
  subtractScore: (score) ->
    if score > 0.0
      @score = @score - (score / 2)
      @render()
  render: ->
    $("#score").text("$" + @score.toFixed(2))
  saveScore: (name, score) ->
    UserScore = Parse.Object.extend("UserScore")
    userScore = new UserScore()
    @name = name
    userScore.save(
      name: name
      score: score
    ).then (object) =>
      @addUserToScores()
  getScores: ->
    @synced = true
    UserScore = Parse.Object.extend("UserScore")
    query = new Parse.Query(UserScore)
    query.descending("score")
    query.limit(9)
    query.find
      success: (results) =>
        @scores = []
        $.each results, (i, s) =>
          @scores.push
            name: s.attributes.name
            score: s.attributes.score

      error: (error) ->
        @scores = []
  addUserToScores: ->
    @scores.push
      name: @name
      score: @score
    @renderScoreBoard()
  renderScoreBoard: ->
    scoreBoard = "<tr class='scoreboard-header'><td><b>Name</b></td><td><b>Score</b></td></tr>"
    $.each @scores, (i, s) =>
      scoreBoard += "<tr><td>#{s.name}</td><td>#{s.score.toFixed(2)}</td></tr>"
    $("#score-board table").html(scoreBoard)

Game.Map =
  topLeft: [40.758014, -74.013221]
  bottomRight: [40.733368, -73.958891]
  pos: [0, 0]
  image: Assets.Map.sprite
  width: 1251
  height: 766
  load: (callback) ->
    image = new Image()
    image.src = @image
    @sprite = image
    @px = Game.Map.width /  (Game.Map.bottomRight[1] - Game.Map.topLeft[1])
    @py = Game.Map.height / (Game.Map.topLeft[0] - Game.Map.bottomRight[0])
    $(image).load =>
      callback.call(@)

  render: (index) ->
    ctx = Game.ctx
    x =  @pos[0]
    y =  @pos[1]
    if @sprite
      ctx.drawImage(@sprite, x, y)

class Game.Objects.ScoreFlash
  constructor: (pos, score, direction) ->
    @pos = pos
    @score = score
    if direction == "+"
      @color = "#33FF99"
      @symbol = "+"
    else
      @color = "#B00000"
      @symbol = "-"
    @duration = 0.5
    @startTime = Date.now()

  render: (index) ->
    @duration -= index
    xPos = @pos[0] + (@duration * 10) - 50
    yPos = @pos[1] + (@duration * 100) - 50
    size = 40 + (20 - @duration * 40)

    ctx = Game.ctx
    ctx.save()

    ctx.font = "#{size}px Digital"
    ctx.fillStyle = @color
    ctx.fillText(@symbol + @score.toFixed(2), xPos, yPos)
    ctx.restore()
    @currentTime = Game.timer
    if @duration < 0
      Game.objects.splice(Game.objects.indexOf(@), 1)



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
    routeDefined = false
    while not routeDefined
      @route = Game.randomRoute()
      unless @positionMatch([@toX @route[0][1], @toY @route[0][0]])
        routeDefined = true
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
  drawSimpleRoute: ->
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
  drawRoute: ->
    n = @route.length - 1
    i = 0
    ctx = Game.ctx
    ctx.save()
    ctx.beginPath()
    ctx.lineWidth = 2
    ctx.strokeStyle = '#999999'
    while i < n
      if @currentDestination == i
        ctx.moveTo(@pixelsRoute[i][0], @pixelsRoute[i][1])
        ctx.lineTo(@pos[0], @pos[1])
        ctx.stroke()
        ctx.beginPath()
        ctx.strokeStyle = '#33FF33';
        ctx.moveTo(@pos[0], @pos[1])
        ctx.lineTo(@pixelsRoute[i + 1][0], @pixelsRoute[i + 1][1])
      else
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
    fare = @fare()
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.objects.push new Game.Objects.ScoreFlash(@pos, fare, "+") if scores
    Game.User.addScore(fare) if scores
  
  arrive: ->
    @complete = true
    @alive = false
    half_fare = (@fare() / 2.0)
    Game.objects.splice(Game.objects.indexOf(@), 1)
    Game.objects.unshift(@)
    Game.objects.push new Game.Objects.ScoreFlash(@pos, half_fare, "-")
    Game.User.subtractScore(half_fare)

  currentSprite: ->
    if @alive
      if @totalDistance < 250
        @sprite
      else if @totalDistance < 500
        @lowFareSprite
      else if @totalDistance < 1000
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
    distanceMultiplier = @totalDistance / 300
    distanceMultiplier = 1 if distanceMultiplier < 1
    distanceMultiplier = 3 if distanceMultiplier > 3
    base = @totalDistance / 100
    base * distanceMultiplier * @typeMultiplier

  positionMatch: (pos) ->
    result = false
    for object in Game.objects.filter(Game.alive)
      unless object == @
        x = object.pos[0]
        y = object.pos[1]
        a = 0
        if pos[0] > x - a && pos[0] < x + (0.2 * object.width) + a && pos[1] > y - a && pos[1] < y + (0.6 * object.height) + a
          result = object
    result

  move: (index) ->
    if @alive
      lag = index * 70
      @distance = @distance + lag
      if @distance >= @currentDistance
        @pos = @distPos
        @totalDistance += @getDistance(@pos, @distPos)
        @getNextDestination()
      else
        x = Math.sin(@angle * Math.PI/180) * lag
        y = Math.cos(@angle * Math.PI/180) * lag
        @pos[0] = @pos[0] + x
        @pos[1] = @pos[1] - y
        @totalDistance += @getDistance([0, 0], [x, y])
      object = @positionMatch(@pos, )
      if object
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
  typeMultiplier: 1.5
  constructor: ->
    super

class Game.Objects.XUberCar extends Game.Objects.Car
  image: Assets.XUber.sprite
  lowFareImage: Assets.XUber.lowFareSprite
  midFareImage: Assets.XUber.midFareSprite
  highFareImage: Assets.XUber.highFareSprite
  typeMultiplier: 1.0
  constructor: ->
    super

class Game.Objects.LyftCar extends Game.Objects.Car
  image: Assets.Lyft.sprite
  lowFareImage: Assets.Lyft.lowFareSprite
  midFareImage: Assets.Lyft.midFareSprite
  highFareImage: Assets.Lyft.highFareSprite
  typeMultiplier: 2.0

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
