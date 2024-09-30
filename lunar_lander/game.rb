require 'gosu'

class Lander

	def initialize
		@image = Gosu::Image.new("media/img/lander.png")
		@x = 100.0
		@y = 100.0
		@x_vel = 0.0
		@y_vel = 0.0
		@thrust = 0.035
		@g = 0.01625
		@air_res = 0.005 #number between 0 and 1
		@rotation = 0.0
		@rotation_speed = 1.80
		@landed = false
	end

	def update_movement
		if Gosu.button_down?(Gosu::KB_LEFT)
			@rotation += @rotation_speed
		elsif Gosu.button_down?(Gosu::KB_RIGHT)
			@rotation -= @rotation_speed
		end

		if @rotation > 180
			@rotation = 180
		elsif @rotation < 0
			@rotation = 0
		end

		#@y_vel += @g

		if Gosu.button_down?(Gosu::KB_UP)
			@x_vel += @thrust * (Math.cos(@rotation * (Math::PI/180)))
			@y_vel -= @thrust * (Math.sin(@rotation * (Math::PI/180)))
		end

		@x_vel *= (1 - @air_res)
		@y_vel *= (1 - @air_res)

		@x += @x_vel
		@y += @y_vel

	end

	def draw
		@image.draw_rot(@x, @y, 0, (90 - @rotation))
	end

	def x
		@x
	end

	def y
		@y
	end

	def total_speed
		total_speed = Math.sqrt((@x_vel**2) + (@y_vel**2))
	end

	def landed
		@landed
	end

	def rotation
		@rotation
	end

	def landing
		@air_res = 0
		@rotation_speed = 0
		@landed = true
	end
end

class Terrain

  def initialize
    @white = Gosu::Color.argb(0xff_ffffff)
    @terrain_size = 500
    @terrain_aggressiveness = (40..60)
    @terrain_height_soft = (100..200) # approximate
		@terrain_height_hard = (0..300)
    @terrain_res = 40
		@terrain_offset = 500

    @flat = Array.new(@terrain_size) {rand(3) == 1}
    @terrain = Array.new(@terrain_size)
    generate_world()
  end

  def generate_world
    modifier = 0.5
    up = rand > modifier
    last_up = up
    last_y = rand(@terrain_height_soft)
    i = 0

    while i < @flat.length

      if @flat[i]
        @terrain[i] = last_y

        if last_y < @terrain_height_soft.begin
          up = false
        elsif last_y > @terrain_height_soft.end
          up = true
        else
          up = rand > modifier
        end

      else
        change = rand(@terrain_aggressiveness)

        if up
					# if last_y
          last_y -= change
        else
          last_y += change
        end

				@terrain[i] = last_y
      end

      i += 1
    end
  end

	def y(x)
		@terrain[x/@terrain_res]+@terrain_offset
	end

	def is_flat(x)
		@flat[x/@terrain_res]
	end

  def draw
    i = 0
    while i < @terrain.length - 1
      Gosu::draw_line(i*@terrain_res, @terrain[i]+@terrain_offset, @white, (i+1)*@terrain_res, @terrain[i+1]+@terrain_offset, @white)
      i += 1
    end
  end
end

class Game < Gosu::Window

	def initialize
		super(600, 800, {fullscreen: true, resizable: true, borderless: false})
		self.caption = "Lunar Lander"
		self.reset
	end

	def reset
		@lander = Lander.new
		@terrain = Terrain.new
		@f_pressed = false
		@landing_rotation = (80..100)
	end

	def does_crash #make work
		@lander_range = (((@lander.y.to_i) -20)..((@lander.y.to_i) +20))
		if @lander_range.include?(@terrain.y(@lander.x))#if it hits ground
			if @lander.total_speed <= 0.7 && @landing_rotation.include?(@lander.rotation) && @terrain.is_flat(@lander.x)#if it lands
				p "landning " + @lander.total_speed.to_s
				@lander.landing
			else #or else crashes
				p "krash " + @lander.total_speed.to_s
				@lander.landing
			end
			sleep(1) #waits
			self.reset #then resets game
		end
	end

	def update
		@lander.update_movement

		if Gosu.button_down?(Gosu::KB_F) && !@f_pressed
			self.fullscreen = !self.fullscreen?
			@f_pressed = true
		elsif !Gosu.button_down?(Gosu::KB_F)
			@f_pressed = false
		end

		if !@lander.landed
			does_crash() #does it crash?
		end
	end

	def draw
		@lander.draw
		@terrain.draw
	end
end

game = Game.new
game.show
