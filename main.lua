push = require 'push'
Class = require 'class'
require 'Paddle'
require  'Ball'

window_width = 1280; window_height = 720
virtual_width = 432; virtual_height = 243

paddle_speed = 200



function love.load()
	love.graphics.setDefaultFilter('nearest',nearest)
	background=love.graphics.newImage('ppong.png')

	love.window.setTitle('Pong')

	math.randomseed( os.time())

	sounds = {
		['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
		['winner']= love.audio.newSource('sounds/winner.wav','static')
	}

	smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)
    	
	push:setupScreen(virtual_width, virtual_height, window_width, window_height, {
		fullscreen = false,
		resizable= false,
		vsync=true,
	})

	player1 = Paddle(10,30,5,50)
	player2 = Paddle(virtual_width-10, virtual_height-30, 5,50)

	ball = Ball(virtual_width/2-4, virtual_height/2-4, 8, 8)

	player1Score = 0
    player2Score = 0

	servingPlayer = 1
	winningPlayer=0

	gameState = 'start'

end

function love.resize(w, h)
    push:resize(w, h)
end


function love.update(dt)
	if gameState == 'serve' then
    	ball.dy = math.random(-50, 50)
    	if servingPlayer == 1 then
        	ball.dx = math.random(140, 250)
     	else
            ball.dx = -math.random(140, 250)
        end


	elseif gameState == 'play' then
		if ball:collides(player1) then
        	ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 200)
            else
                ball.dy = math.random(10, 200)
            end

			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 8

            if ball.dy < 0 then
                ball.dy = -math.random(10, 200)
            else
                ball.dy = math.random(10, 200)
            end

            sounds['paddle_hit']:play()
        end




		if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= virtual_height - 8 then
            ball.y = virtual_height - 8
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end




		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1
			sounds['score']:play()

			if player2Score == 3 then
				sounds['winner']:play()
				winningPlayer = 2
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end
		if ball.x > virtual_width then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()


            if player1Score == 3 then
				sounds['winner']:play()
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
	end



    if love.keyboard.isDown('w') then
        player1.dy = -paddle_speed
    elseif love.keyboard.isDown('s') then
        player1.dy = paddle_speed
    else
        player1.dy = 0
    end


    if love.keyboard.isDown('up') then
        player2.dy = -paddle_speed
    elseif love.keyboard.isDown('down') then
        player2.dy = paddle_speed
    else
        player2.dy = 0
    end



	if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()

    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'

        elseif gameState == 'serve' then
            gameState = 'play'

        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            player1Score = 0
            player2Score = 0

            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end
    end
end


function love.draw()
	push:apply('start')

	love.graphics.setColor(0,255,1,27)
	love.graphics.draw(background, 0, 0)

	if gameState=='start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!',0,10, virtual_width, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, virtual_width, 'center')
	elseif gameState== 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player '..tostring(servingPlayer)..'s serve!', 0, 10, virtual_width, 'center')
		love.graphics.printf('Please Enter to serve!', 0, 20, virtual_width, 'center')
	elseif gameState== 'play' then
	elseif gameState=='done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player '..tostring(winningPlayer)..' wins!', 0, 10, virtual_width, 'center')
		love.graphics.printf('Press Enter to restart the game!', 0, 30, virtual_width,'center')
	end

	displayScore()

    player1:render()
    player2:render()
    ball:render()

    push:apply('end')
end


function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), virtual_width/ 2 - 50,virtual_height / 3)
    love.graphics.print(tostring(player2Score), virtual_width / 2 + 30,virtual_height / 3)
end
















