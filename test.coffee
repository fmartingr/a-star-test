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
      @terrain.push (new Terrain for x in [0..@x])

  showTerrain: ->
    yy = 0
    xx = 0
    for y in [1..@y]
      if yy < @y then yy++ else yy = 1
      for x in [1..@x]
        if xx < @x then xx++ else xx = 1
        #@log "#{xx} #{yy}"
        @makeGrid xx, yy, x

    element = document.getElementsByTagName('terrain')[0]
    gridSize = (parseInt element.scrollHeight * @x)
    @element.style.width = "#{gridSize}px"
    @log @element.style.width

  makeGrid: (_x, _y, _terrain) ->
    element = document.createElement 'terrain'
    element.setAttribute 'x', _x
    element.setAttribute 'y', _y
    element.textContent = "#{_x},#{_y}"
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
  element: null
  start: false
  end: false

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
    @updateElement()

  setWater: ->
    @unsetPoints()
    @setType 'liquid'
    @color = 'blue'
    @updateElement()

  setAir: ->
    @unsetPoints()
    @setType 'air'
    @color = 'lightblue'
    @updateElement()

  setStart: ->
    grid.cleanStart()
    @unsetPoints()
    @start = true
    @color = 'green'
    @setType 'air'
    @updateElement()

  setEnd: ->
    grid.cleanEnd()
    @unsetPoints()
    @end = true
    @color = 'red'
    @setType 'air'
    @updateElement()

  updateElement: ->
    if @element
      @element.style.backgroundColor = @color

  setType: (_type = "solid") ->
    @type = _type

###
class Air extends Terrain


class Water extends Terrain
  type: 'liquid'
  color: 'blue'

class Rock extends Terrain
  type: 'solid'
  color: 'brown'
###

grid = new Grid

$$('body').ready ->
  drawing = false
  drawingWhat = null

  $$('button.drawSolidButton').on 'click', ->
    drawing = true
    drawingWhat = 'solid'

  $$('button.drawWaterButton').on 'click', ->
    drawing = true
    drawingWhat = 'water'

  $$('button.drawAirButton').on 'click', ->
    drawing = true
    drawingWhat = 'air'

  $$('button.drawStartPoint').on 'click', ->
    drawing = true
    drawingWhat = 'start'

  $$('button.drawEndPoint').on 'click', ->
    drawing = true
    drawingWhat = 'end'


  $$('terrain').on 'click', ->
    if drawing
      x = $$(@).attr('x')
      y = $$(@).attr('y')
      grid.terrain[y][x].set(drawingWhat)
      switch drawingWhat
        when 'start' then grid.setStart x, y
        when 'end' then grid.setEnd x, y













