class Grid
  terrain: []

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
    @element.style.width = "#{gridSize}px";
    @log @element.style.width

  makeGrid: (_x, _y, _terrain) ->
    element = document.createElement 'terrain'
    element.setAttribute 'x', _x
    element.setAttribute 'y', _y
    element.style.background = _terrain.color
    @element.appendChild element
    @terrain[_y][_x]?.element = $$("terrain[x='#{_x}'][y='#{_y}']").get(0)

  makeSolid: (_x, _y) ->
    @terrain[_y][_x].setType()

  error: (msg) ->
    console.error msg

  log: (msg) ->
    console.log msg


class Terrain
  # types: air, liquid, solid
  type: 'air'
  color: 'white'
  element: null

  isSolid: ->
    @type is not 'air'

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