# This is the main script, this is where the magic happens
# First we requre the gosu library which we need for this project
require 'gosu'
# Then we requre the other scripts reletive to this script so we can access them later
require_relative 'player.rb'
require_relative 'star.rb'
require_relative 'button.rb'
require_relative 'asteroid.rb'

module ZOrder# ZOrder is the depth of how graphics will be placed, the higest number will always be ontop
  Background, Elements, Player, UI, Mouse = *0..4
end

class GameWindow < Gosu::Window# The game window class, this is controlling what you see on the screen
  def initialize(fullscreen)
    super(640, 480, fullscreen)
    self.caption = "Space Game 101"
    @sound_switch = Gosu::Sample.new(self, "media/switch.wav")
    @sound_alarm = Gosu::Sample.new(self, "media/alarm.wav")
    @song = Gosu::Song.new(self, "media/song.ogg")
    @song2 = Gosu::Song.new(self, "media/song2.ogg")
	@fullscreen = fullscreen

    @cursor = Gosu::Image.new(self, "media/cursor.png", false)
    
    @background_image = Gosu::Image.new(self, "media/bg_space.png", true)
    @background_image_menu = Gosu::Image.new(self, "media/bg_spacemenu.png", true)
    @background_image_menu_upgrade = Gosu::Image.new(self, "media/bg_spaceupgrademenu.png", true)
    
    @player = Player.new(self)
    @player.warp(320, 240)
    @alive = true
    
    @star_anim = Gosu::Image::load_tiles(self, "media/star2.png", 32, 32, false)
	@asteroids = []
    @stars = []
    @buttons = []
    @upgradebuttons = []
    
    @maxroids = 1
	
    @upgrademenu = false
    @menu = true
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    
    @song.play(true)
    @mute = 1
    
    @buttons.push(Button.new(self, 10, 120, 1, 0.25, "Start Game", 20, 5))
    @buttons.push(Button.new(self, 10, 160, 1, 0.25, "Quit Game", 20, 5))
    if !@fullscreen
	  @buttons.push(Button.new(self, 150, 120, 1, 0.25, "Fullscreen", 20, 5))
	else
      @buttons.push(Button.new(self, 150, 120, 1, 0.25, "Windowed", 20, 5))
	end
    @buttons.push(Button.new(self, 10, 200, 1, 0.25, "Mute Game", 20, 5))
    @upgradebuttons.push(Upgradebutton.new(self, 10, 145, 1, 0.25, "Speed Upgrade", 2, 5))
    @upgradebuttons.push(Upgradebutton.new(self, 10, 185, 1, 0.25, "More lives", 20, 5))
	
	@mouse_debug = false
	@debug = false
  end

  def update
    if @menu
      if mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 120 && mouse_y < 120 + 30 || mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 160 && mouse_y < 160 + 30 || mouse_x > 150 && mouse_x < 150 + 130 && mouse_y > 120 && mouse_y < 120 + 30
	    @mouse_debug = true
	  else
	    @mouse_debug = false
	  end
	end
	if @upgrademenu
	  if mouse_x > 10 && mouse_x < 10 + 130 && mouse_y > 145 && mouse_y < 145 + 30
	    @mouse_debug = true
      else
	    @mouse_debug = false
	  end
	end
	
    if button_down? Gosu::KbLeft or button_down? Gosu::GpLeft then
      if !@menu && !@upgrademenu && @alive
        @player.turn_left
      end
    end
    
    if button_down? Gosu::KbRight or button_down? Gosu::GpRight then
      if !@menu && !@upgrademenu && @alive
        @player.turn_right
      end
    end
    
    if button_down? Gosu::KbUp or button_down? Gosu::GpButton0 then
      if !@menu && !@upgrademenu && @alive
        @player.accelerate
      end
    end
    
    if !@menu && !@upgrademenu && @alive
      @asteroids.each { |asteroid| asteroid.move }
      @player.move
      @player.collect_stars(@stars)
      @player.hit_asteroid(@asteroids)
    end

    if rand(100) < 4 && @stars.size < 25 then
      if !@menu && !@upgrademenu && @alive
      @stars.push(Star.new(@star_anim))
      end
    end
    if rand(100) < 4 && @asteroids.size < @maxroids then
      if !@menu && !@upgrademenu && @alive
      @asteroids.push(Asteroid.new(self))
      end
    end	
  end

  def add_roid
    @maxroids += 1
  end
  
  def mute
    @mute
  end
  
  def draw
    if !@menu && !@upgrademenu
      @background_image.draw(0, 0, ZOrder::Background)
      if @debug
        @font.draw("Max roids: #{@maxroids}", 10, 50, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
      if @alive
        @player.draw
        @stars.each { |star| star.draw }
        @asteroids.each { |asteroid| asteroid.draw }
        @font.draw("Score: #{@player.score} Lives: #{@player.lives}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        @font.draw("Press X to go to the upgrade menu, Press ESC to go back to the main menu.", 10, 30, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        else
        @font.draw("You lost the game, you are dead.", 175, 190, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        @font.draw("Press ESC to quit.", 230, 230, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        @font.draw("Thanks for playing!", 225, 270, ZOrder::UI, 1.0, 1.0, 0xffffff00)
        @font.draw("This game is made by Matias Jensen, using the Ruby programming language.", 10, 450, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
    end
    
    if @menu
	  if @debug
        @font.draw("Debug: Mouse x: #{mouse_x}, Mouse y: #{mouse_y} OK?: #{@mouse_debug}", 5, 5, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
      @font.draw("Build 5", 540, 440, ZOrder::UI, 1.0, 1.0, 0xffffff00)
	  @buttons.each { |button| button.draw }
      @cursor.draw(mouse_x, mouse_y, ZOrder::Mouse)
      @background_image_menu.draw(0, 0, ZOrder::Background)
    end
    
    if @upgrademenu
	  if @debug
        @font.draw("Debug: Mouse x: #{mouse_x}, Mouse y: #{mouse_y} OK?: #{@mouse_debug}", 5, 5, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      end
	  @upgradebuttons.each { |button| button.draw }
      @cursor.draw(mouse_x, mouse_y, ZOrder::Mouse)
      @background_image_menu_upgrade.draw(0, 0, ZOrder::Background)
      @font.draw("costs #{@player.speedprice} score. Level: #{@player.speedlevel}/#{@player.maxspeedlevel}", 150, 150, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      @font.draw("Score: #{@player.score}.", 10, 120, ZOrder::UI, 1.0, 1.0, 0xffffff00)
      @font.draw("costs 500 score.", 150, 190, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    end
  end

  def loose
    @alive = false
  end
  
  def button_down(id)# This functon detects which buttons are pressed.
    if id == Gosu::KbEscape# Kb*button* for keyboard buttons and Ms*button* for mouse buttons
      if @menu
        @sound_switch.play(@mute)
        close
      end
      if !@menu && !@upgrademenu
        @sound_switch.play(@mute)
        @menu = true
      end
      if @upgrademenu
        @sound_switch.play(@mute)
        @upgrademenu = false
      end
      if !@alive
        close
      end
    end
    if id == Gosu::MsLeft
	  if @menu
	    if @buttons[0].pressed(mouse_x, mouse_y)# Start game
          @sound_alarm.play(@mute)
          @menu = false
		end
	    if @buttons[1].pressed(mouse_x, mouse_y)# Quit game
		  close
		end
		if @buttons[2].pressed(mouse_x, mouse_y)# Screen res
		  if @fullscreen
	        @sound_switch.play(@mute)
            close
            gamewindow = GameWindow.new(false).show
		  else
		    @sound_switch.play(@mute)
            close
            gamewindow = GameWindow.new(true).show
		  end
		end
        if @buttons[3].pressed(mouse_x, mouse_y)# Mute
		  if @mute == 1
            @mute = 0
            @song.stop
          else
            @mute = 1
            @song.play
          end
		end
      end
	  if @upgrademenu
	    if @upgradebuttons[0].pressed(mouse_x, mouse_y)# Speed upgrade
		  @player.speedboost
		end
        if @upgradebuttons[1].pressed(mouse_x, mouse_y)# Lives
		  @player.liveboost
		end
	  end
    end
    if id == Gosu::KbX
      if !@menu && !@upgrademenu && @alive
        @sound_switch.play(@mute)
        @upgrademenu = true
      end
	end
	if id == Gosu::KbZ
	  if @debug
		@debug = false
      else
		@debug = true
	  end
    end
    if id == Gosu::KbT
        @player.cheats(1)
    end
    if id == Gosu::KbY
        @player.cheats(2)
    end
    if id == Gosu::KbU
        @player.cheats(3)
    end
  end
end
gamewindow = GameWindow.new(false).show# This triggers the GameWindow class to start the game