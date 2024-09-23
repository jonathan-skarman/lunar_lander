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
		@air_res = 0.995
		@rotation = 0.0
		@rotation_speed = 1.80
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

		@y_vel += @g

		if Gosu.button_down?(Gosu::KB_UP)
			@x_vel += @thrust * (Math.cos(@rotation * (Math::PI/180)))
			@y_vel -= @thrust * (Math.sin(@rotation * (Math::PI/180)))
		end

		@x_vel *= @air_res
		@y_vel *= @air_res

		@x += @x_vel
		@y += @y_vel

	end

	def draw
		@image.draw_rot(@x, @y, 0, (90 - @rotation))
	end

end

class Ground

	def initialize
		@x = [0, 10000]
		@y = 900
	end

	def draw
		Gosu::draw_line(@x[0], @y, Gosu::Color.argb(0xff_ffffff), @x[1], @y, Gosu::Color.argb(0xff_ffffff), 0, mode = :default)
	end
end

class Game < Gosu::Window
	#konstruktor
	def initialize
		super(1920 , 1080, true)
		self.caption = "Lunar Lander"
		@lander = Lander.new
		@ground = Ground.new
	end

	def update
		@lander.update_movement

		# if Gosu.button_down?(Gosu::KB_F)
		# 	self.fullscreen = !self.fullscreen
		# end
	end

	def draw
		@lander.draw
		@ground.draw
	end
end

game = Game.new
game.show
