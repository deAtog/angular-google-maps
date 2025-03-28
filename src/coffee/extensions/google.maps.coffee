#boot strap angular and extend google maps
angular.module('uiGmapgoogle-maps.extensions')
.service('uiGmapExtendGWin', ->
  init: _.once ->
    return unless google or google?.maps or google.maps.InfoWindow?
    #Taken from : http://stackoverflow.com/questions/12410062/check-if-infowindow-is-opened-google-maps-v3
    #
    #
    # modify the prototype for google.maps.Infowindow so that it is capable of tracking
    # the opened state of the window.  we track the state via boolean which is set when
    # open() or close() are called.  in addition to these, the closeclick event is
    # monitored so that the value of _openedState can be set when the close button is
    # clicked (see code at bottom of this file).
    #
    if !(google.maps.InfoWindow::hasOwnProperty('isOpen'))
      google.maps.InfoWindow::_open = google.maps.InfoWindow::open
      google.maps.InfoWindow::_close = google.maps.InfoWindow::close
      google.maps.InfoWindow::_isOpen = false

      google.maps.InfoWindow::open = (map, anchor, recurse) ->
        return if recurse?
        @_isOpen = true
        @_open map, anchor, true
        return

      google.maps.InfoWindow::close = (recurse) ->
        return if recurse?
        @_isOpen = false
        @_close(true)
        return

      google.maps.InfoWindow::isOpen = (val = undefined) ->
        unless val?
          return @_isOpen
        else
          @_isOpen = val

    ###
    Do the same for InfoBox
    TODO: Clean this up so the logic is defined once, wait until develop becomes master as this will be easier
    ###
    if window.InfoBox
      window.InfoBox::_open = window.InfoBox::open
      window.InfoBox::_close = window.InfoBox::close
      window.InfoBox::_isOpen = false

      window.InfoBox::open = (map, anchor) ->
        @_isOpen = true
        @_open map, anchor
        return

      window.InfoBox::close = ->
        @_isOpen = false
        @_close()
        return

      window.InfoBox::isOpen = (val = undefined) ->
        unless val?
          return @_isOpen
        else
          @_isOpen = val

      #coffeelint:disable=camel_case_classes
      class uiGmapInfoBox extends window.InfoBox
      #coffeelint:disable=camel_case_classes
        constructor: (opts) ->
          box = new window.InfoBox(opts)
          _.extend @, box
          @closeBoxDiv_ = opts.closeBoxDiv if opts.closeBoxDiv?

        getCloseBoxDiv_: =>
          @closeBoxDiv_
        #overriding with fetching div or image block
        getCloseBoxImg_: ->
          #custom div has pref
          div = @getCloseBoxDiv_()
          img = @getOrigCloseBoxImg_()
          div or img

        #default lame behavior, why grab an image when a template is possibly better!
        getOrigCloseBoxImg_: =>
          img = ""
          if @closeBoxURL_ isnt ""
            img = "<img"
            img += " src='" + @closeBoxURL_ + "'"
            img += " align=right" # Do this because Opera chokes on style='float: right;'
            img += " style='"
            img += " position: relative;" # Required by MSIE
            img += " cursor: pointer;"
            img += " margin: " + @closeBoxMargin_ + ";"
            img += "'>"
          img


      window.uiGmapInfoBox = uiGmapInfoBox


    if window.MarkerLabel_

      window.MarkerLabel_::setContent = ->
        content = @marker_.get('labelContent')
        #uigmap patches checking for undefined content and different
        return if !content or _.isEqual @oldContent, content
        if typeof content?.nodeType is 'undefined'
          @labelDiv_.innerHTML = content
          @eventDiv_.innerHTML = @labelDiv_.innerHTML
          @oldContent = content
        else
          @labelDiv_.innerHTML = '' # Remove current content
          @labelDiv_.appendChild content
          content = content.cloneNode(true)
          @labelDiv_.innerHTML = '' # Remove current content
          @eventDiv_.appendChild content
          @oldContent = content
        return
  )
