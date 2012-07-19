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
  movement: 10
  element: null
  start: false
  end: false
  parent: null
  near: []

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
    @movement = 15
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

  updateElement: ->
    if @element
      @element.style.backgroundColor = @color
      @element.style.backgroundImage = "url('img/#{@image}.png')"

  setType: (_type = "solid") ->
    @type = _type

  walkable: ->
    @movement

  getNearTerrain: ->
    if not @near.length
      @near = []
      for x in [@x-1..@x+1]
        for y in [@y-1..@y+1]
          if not (@x == x and @y == y) and y != 0 and x != 0
            if @x == x or @y == y # Avoid diagonals!
              if grid.terrain[y]?[x]?
                @near.push {'x': x, 'y': y}

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



grid = new Grid

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

  $$('terrain').on 'click', ->
    x = $$(@).attr('x')
    y = $$(@).attr('y')
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
          for t in grid.terrain[y][x].near
            console.log "#{t.x},#{t.y}"

