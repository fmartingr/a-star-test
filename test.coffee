class Grid
  terrain: []
  start:
    x: null
    y: null
  end:
    x: null
    y: null

  constructor: ->
    @element = document.getElementsByTagName('grid')[0]
    @x = parseInt @element.getAttribute 'x'
    @y = parseInt @element.getAttribute 'y'
    if not @element
      @error 'Could not found <grid> in DOM!'
      false
    else
      @log "#{@x}x#{@y} grid created."
      @makeTerrain()
      @showTerrain()

  makeTerrain: ->
    for y in [0..@y]
      @terrain.push (new Terrain(x, y) for x in [0..@x])

  showTerrain: ->
    yy = 0
    xx = 0
    for y in [1..@y]
      if yy < @y then yy++ else yy = 1
      for x in [1..@x]
        if xx < @x then xx++ else xx = 1
        @makeGrid xx, yy, x

    element = document.getElementsByTagName('terrain')[0]
    gridSize = parseInt(element.clientWidth) * @x + 2*@x
    @element.style.width = "#{gridSize}px"
    @log @element.style.width

  makeGrid: (_x, _y, _terrain) ->
    element = document.createElement 'terrain'
    element.setAttribute 'x', _x
    element.setAttribute 'y', _y

    # Position span
    span = document.createElement 'span'
    span.className = 'position'
    element.appendChild span

    # Distance span (F)
    span = document.createElement 'span'
    span.className = 'f'
    element.appendChild span

    # Movement cost (G)
    span = document.createElement 'span'
    span.className = 'g'
    element.appendChild span

    # Heuristic distance (H)
    span = document.createElement 'span'
    span.className = 'h'
    element.appendChild span

    $$(element).children('.position').text("#{_x},#{_y}")

    @element.appendChild element
    @terrain[_y][_x]?.element = $$("terrain[x='#{_x}'][y='#{_y}']").get(0)
    @terrain[_y][_x].updateElement()

  makeSolid: (_x, _y) ->
    @terrain[_y][_x].setType()

  error: (msg) ->
    console.error msg

  log: (msg) ->
    console.log msg

  setStart: (_x, _y) ->
    @start =
      x: _x
      y: _y

  cleanStart: ->
    yy = 0
    xx = 0
    for y in [1..@y]
      if yy < @y then yy++ else yy = 1
      for x in [1..@x]
        if xx < @x then xx++ else xx = 1
        if @terrain[yy][xx].start
          @terrain[yy][xx].setAir()
          @terrain[yy][xx].updateElement()
          return @setStart null, null

  setEnd: (_x, _y) ->
    @end =
      x: _x
      y: _y

  cleanEnd: ->
    yy = 0
    xx = 0
    for y in [1..@y]
      if yy < @y then yy++ else yy = 1
      for x in [1..@x]
        if xx < @x then xx++ else xx = 1
        if @terrain[yy][xx].end
          @terrain[yy][xx].setAir()
          @terrain[yy][xx].updateElement()
          return @setEnd null, null


class Terrain
# types: air, liquid, solid
  type: 'air'
  color: 'lightblue'
  image: 'dirt'
  movement: 10 # Movement value (NOT G!!)
  element: null
  start: false
  end: false
  parent: null
  near: []
  manhattan: null # Heuristic
  path: 0 # total path value to this terrain (G)
  pathValue: 0 # Heuristic + total path value (F)

  constructor: (@x, @y) ->

  isSolid: ->
    @type is not 'air'

  set: (_type) ->
    switch _type
      when "air" then @setAir()
      when "water" then @setWater()
      when "solid" then @setSolid()
      when "start" then @setStart()
      when "end" then @setEnd()

  unsetPoints: ->
    @start = false
    @end = false

  setSolid: ->
    @unsetPoints()
    @setType()
    @color = 'brown'
    @image = 'cobblestone'
    @movement = 0
    @updateElement()

  setWater: ->
    @unsetPoints()
    @setType 'liquid'
    @image = 'water'
    @color = 'blue'
    @movement = 12
    @updateElement()

  setAir: ->
    @unsetPoints()
    @setType 'air'
    @image = 'dirt'
    @color = 'lightblue'
    @movement = 10
    @updateElement()

  setStart: ->
    grid.cleanStart()
    @unsetPoints()
    @start = true
    @color = 'green'
    @image = null;
    @movement = 10
    @setType 'air'
    @updateElement()

  setEnd: ->
    grid.cleanEnd()
    @unsetPoints()
    @end = true
    @color = 'red'
    @image = null;
    @movement = 10
    @setType 'air'
    @updateElement()

  colorOpen: ->
    @element.style.border = 'green 1px solid'

  colorClosed: ->
    @element.style.border = 'blue 1px solid'

  colorPath: ->
    @element.style.border = 'yellow 1px solid'

  calculateManhattan: ->
    if grid.end.x?
      x = Math.abs @x - grid.end.x
      y = Math.abs @y - grid.end.y
      value = (x + y) * 10
      @manhattan = value
      $$(@element).children('.h').text "#{value}"

  calculate: (path) ->
    @calculateManhattan()
    @path = path + @movement
    #@path = path + 10 + (@movement - 10)
    @pathValue = @path + @manhattan
    $$(@element).children('.f').text @pathValue
    $$(@element).children('.g').text @path

  updateElement: ->
    if @element
      @element.style.backgroundColor = @color
      if @image?
        @element.style.backgroundImage = "url('img/#{@image}.png')"
      else
        @element.style.backgroundImage = ""

  setType: (_type = "solid") ->
    @type = _type

  walkable: ->
    @movement

  getNearTerrain: ->
    if not @near.length
      @near = []
      for x in [@x-1..@x+1]
        for y in [@y-1..@y+1]
          if not (@x == x and @y == y)
            if x != 0 and y != 0
              if @x == x or @y == y # Avoid diagonals!
                if grid.terrain[y]?[x]?.walkable?()
                  @near.push {'x': parseInt(x), 'y': parseInt(y)}

  highlight: (light = true) ->
    if light
      @element.style.backgroundColor = 'white'
      @element.style.backgroundImage = ''
    else
      @updateElement()

  highlightNear: (light = true) ->
    @getNearTerrain()
    for terrain in @near
      grid.terrain[terrain.y][terrain.x].highlight(light)


class Path
  @open: []
  @closed: []
  @path: []
  @pathFound: false

  @started: null
  @ended: null

  constructor: ->

  isInOpen: (x, y) ->
    _is = false
    for e in @open
      _is = true if e.x is x and e.y is y

    return _is

  #orderOpen: ->
  getLowestOpen: ->
    if @open.length
      lowestValue = 9999999
      lowestTerrain = null
      for e in @open
        if grid.terrain[e.y][e.x].pathValue < lowestValue
        #if grid.terrain[e.y][e.x].movement < lowestValue
          lowestTerrain = {x: e.x, y: e.y }
          lowestValue = grid.terrain[e.y][e.x].pathValue

      return lowestTerrain

  isInClosed: (x, y) ->
    _is = false
    for e in @closed
      _is = true if e.x is x and e.y is y

    return _is

  moveToClosed: (x, y) ->
    newOpen = []
    for e in @open
      if not (e.x is x and e.y is y)
        newOpen.push e
    @open = newOpen
    @closed.push {x: x, y: y}

  drawThisPath: ->
    x = grid.end.x
    y = grid.end.y
    while not (x == grid.start.x and y == grid.start.y)
      console.log "drawing #{x},#{y}"
      terrain = grid.terrain[y][x]
      terrain.colorPath()
      x = terrain.parent.x
      y = terrain.parent.y

  calc: ->
    if grid.start.x and grid.end.x and not @pathFound
      @started = new Date().getMilliseconds()
      @open = []
      @closed = []
      @path = []
      @pathFound = false
      @open.push {x: grid.start.x, y: grid.start.y}
      while @open.length > 0 and not @pathFound
        @step()

  calc2: ->
    if grid.start.x and grid.end.x and not @pathFound
      @open = []
      @closed = []
      @path = []
      @pathFound = false
      @open.push {x: grid.start.x, y: grid.start.y}

  step: ->
    if not @pathFound
      nowt = @getLowestOpen()
      terrain = grid.terrain[nowt.y][nowt.x]
      if terrain.parent?
        terrain.calculate grid.terrain[terrain.parent.y][terrain.parent.x].path
      else
        terrain.calculate 0
      @moveToClosed nowt.x, nowt.y
      if nowt.x is grid.end.x and nowt.y is grid.end.y
        @pathFound = true
        @drawThisPath()
        @ended = new Date().getMilliseconds()
        console.log "Execution time: " + (@ended-@started) + "ms"
        return true
      terrain.colorClosed()
      terrain.getNearTerrain()
      for t in terrain.near
        neart = grid.terrain[t.y][t.x]
        # Still looking for a path
        if @isInOpen t.x, t.y
          if neart.path > (terrain.path + neart.movement)
            neart.parent = {x: nowt.x, y: nowt.y}
            neart.calculate(terrain.path)
        else
          if not @isInClosed t.x, t.y
            @open.push {x: t.x, y: t.y}
            grid.terrain[t.y][t.x].colorOpen()
            neart.calculate(terrain.path)
            neart.parent = {x: terrain.x, y: terrain.y}


$$('body').ready ->
  drawing = false
  drawingWhat = null
  calculating = false
  calculatingWhat = null

  $$('button.drawSolidButton').on 'click', ->
    drawing = true
    calculating = false
    drawingWhat = 'solid'

  $$('button.drawWaterButton').on 'click', ->
    drawing = true
    calculating = false
    drawingWhat = 'water'

  $$('button.drawAirButton').on 'click', ->
    drawing = true
    calculating = false
    drawingWhat = 'air'

  $$('button.drawStartPoint').on 'click', ->
    drawing = true
    calculating = false
    drawingWhat = 'start'

  $$('button.drawEndPoint').on 'click', ->
    drawing = true
    calculating = false
    drawingWhat = 'end'

  $$('button.calcNearButton').on 'click', ->
    drawing = false
    calculating = true
    calculatingWhat = 'near'

  $$('button.hoverNearButton').on 'click', ->
    drawing = false
    calculating = true
    calculatingWhat = 'hoverNear'

  $$('button.calcRouteButton').on 'click', ->
    path.calc()

  $$('button.calc2RouteButton').on 'click', ->
    path.calc2()

  $$('button.calcStepButton').on 'click', ->
    path.step()

  $$('button.resetButton').on 'click', ->
    window.location.reload()

  $$('terrain').on 'click', ->
    x = parseInt $$(@).attr('x')
    y = parseInt $$(@).attr('y')
    console.log "Clicked: #{x}, #{y}"
    if drawing
      grid.terrain[y][x].set(drawingWhat)
      switch drawingWhat
        when 'start' then grid.setStart x, y
        when 'end' then grid.setEnd x, y

    if calculating
      switch calculatingWhat
        when 'near' then grid.terrain[y][x].getNearTerrain()
        #when 'hoverNear' then grid.terrain[y][x].highlightNear()

  $$('terrain').on 'mouseover', ->
    x = $$(@).attr('x')
    y = $$(@).attr('y')
    if calculating
      switch calculatingWhat
        when 'hoverNear' then grid.terrain[y][x].highlightNear()

  $$('terrain').on 'mouseout', ->
    x = $$(@).attr('x')
    y = $$(@).attr('y')
    if calculating
      switch calculatingWhat
        when 'hoverNear'
          grid.terrain[y][x].highlightNear(false)
          grid.terrain[y][x].calculateManhattan()
          for t in grid.terrain[y][x].near
            console.log "#{t.x},#{t.y}"

