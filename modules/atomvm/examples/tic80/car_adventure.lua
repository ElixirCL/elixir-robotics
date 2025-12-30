-- title: Car Adventure
-- author: GaboChip
-- desc: A mini-game of dont crush your car
-- script: lua
Mode = "intro"
intro_t = 0
Colors  = {}
Defeat_Colors = {}

for i = 0,15,1 do
Colors[i] = {}
Defeat_Colors[i] = {}
	for j = 0,2,1 do
	Colors[i][j] = peek(0x03FC0+(j)+(i*3))
	Defeat_Colors[i][j] = Colors[i][j]
	end

end


game_t = 1--Time in game
reset_t = 0--Time to reset
player = {
x = 112,
y = 112,
time_to_pass = 5,
speed = 0,
cf = 112,
BDY_X1,BDY_X2,BDY_Y1,BDY_Y2,
IsCracked = false,
score = 1,
IsA_PNTS = false,
ref_enemy = 1,
SCR_Mult = 1

}
Max_Pnts = 0
----------------
COLRscore_1 = 9
COLRscore_2 = 8
i = 0
----------------

_500 = {
x = 112,
y = 120,
sprite = 320,
visible = false,
tim = 0
}

Back_Map = {
offset_y = 0,
speed = 120,
shake_x = 0,
shake_y = 0
}
--Init the enemy array
Cars = {}
for i = 1,5 do
	Car_Enemy = {
	x = 114,
	y = -16,
	sprite = 258,
	avaliable = false,
	speed = 64,
	test = "hello",
	BDY_X1,BDY_X2,BDY_Y1,BDY_Y2
	}

	Cars[i]=Car_Enemy

--------
Levels = {2,3,4}
Actual_Level = 1

--------

end

time_oneEnemy = 0
timeLimit_Enemy = 16


c1,c2,c3 = 96,112,128
xe = 0
stop = false--Line 78, break the loop
Exp_stop = false
shake_stop = 0

--Explosion
Explosion = {
	sprites = {266,268,270,288,290,292,294,296},
	sprite = 1,
	tim = 7,
	b = 1

}

function TIC()
for i = 0,15,1 do

 for j = 0,2,1 do
		poke(0x03FC0+(j)+(i*3),Colors[i][j])
	end

end
if Mode == "game" then
cls(10)
	--GameControl
	GameControl()
	--GameControl

	----------
	Max_Pnts = peek(0x14e04)+(peek(0x14e05)*256)+(peek(0x14e06)*65536)
	----------


	--Player
	player:Update()
	--Player

	--BackGround
	Back_Map:Update()
	--BackGround


	--Map
	map((Actual_Level-1)*30,-math.abs(Back_Map.offset_y//8+1),30,18,0+Back_Map.shake_x,(Back_Map.offset_y-8*((Back_Map.offset_y//8)+1))+Back_Map.shake_y,-1,1)
	--Map

	--Enemy
	Enemy()
	--Enemy

	--Sprite:Enemy
	if player.IsCracked == false then
		for i = 1,5,1 do
		spr(Cars[i].sprite,Cars[i].x,Cars[i].y,0,1,0,0,2,2)
		end
	end
	--Sprite:Enemy

	--Sprite:Player
	if player.IsCracked == false then
		spr(256,player.x,player.y,0,1,0,0,2,2)
	end
	--Sprite:Player

	--Explosion
	if player.IsCracked == true then
	spr(Explosion.sprites[Explosion.sprite],player.x,player.y,0,1,0,0,2,2)
	end
	--Explosion

	--Score
	if player.score >= Max_Pnts and Max_Pnts ~= 0 then
		if game_t%8 == 0 then
			if COLRscore_1 == 9 and COLRscore_2 == 8 then
			COLRscore_1 = 12  COLRscore_2 = 14
			elseif COLRscore_1 == 12 and COLRscore_2 == 14 then
			COLRscore_1 = 9  COLRscore_2 = 8
			end
			end
	end

	print("Score:"..math.ceil(player.score),4,128,COLRscore_2,true)
	print("Score:"..math.ceil(player.score),5,128,COLRscore_2,true)
	print("Score:"..math.ceil(player.score),4,127,COLRscore_1,true)
	trace("score:"..math.ceil(player.score))
	--Score


	if player.score % 2500 <= 15	then
		trace("event:score_milestone")
	end

	--Best Score
	print("Best: "..Max_Pnts,4,120,2,true)
	print("Best: "..Max_Pnts,5,120,2,true)
	print("Best: "..Max_Pnts,4,119,3,true)
	--Time

	--_500
	if game_t%4 == 0 then
		if _500.sprite == 320 then _500.sprite = 322
		elseif _500.sprite == 322 then _500.sprite = 320 end
	end
	if _500.visible == true then
		spr(_500.sprite,_500.x,116,0,1,0,0,2,1)
		_500.tim = _500.tim +1
	end
	if _500.tim >=30 then _500.visible = false _500.tim = 0 end


elseif Mode == "intro" then
spr(324,82,56,0,1,0,0,10,3)
cls(0)
	Intro_()

end

end
--PLAYER UPDATE
function player:Update()

player.x = (player.x + player.speed)

if(player.x == player.cf)then
player.speed = 0
else
player.speed = (player.cf - player.x)/1.8
end

if(math.abs(player.x-player.cf)<0.8) then
player.x = player.cf
end

if player.IsCracked == false then
	if player.x == c2 and btnp(3) then player.cf = c3  end
	if player.x == c2 and btnp(2) then player.cf = c1 end
	if player.x == c3 and btnp(2) then player.cf = c2 end
	if player.x == c1 and btnp(3) then player.cf = c2 end
end
--Update the player body
	player.BDY_X1 = player.x + 4
	player.BDY_X2 = player.x + 11
	player.BDY_Y1 = player.y + 2
	player.BDY_Y2 = player.y + 13

--If the player crack...
if player.IsCracked == true then
	PlayExplode()--Explosion!!!
	trace("event:explode")
		if Exp_stop == false then
		sfx(63,"C-4",30,3,15,7)--...And sound
		Exp_stop = true
		end
	end

if player.IsCracked == false then
player.score = player.score+(1*player.SCR_Mult)
end
end
--MAP:UPDATE
function Back_Map:Update()

Back_Map.offset_y = Back_Map.offset_y + Back_Map.speed/60
if game_t%120 == 0 then
Back_Map.speed = Back_Map.speed + 1
end

if player.IsCracked == true then--If player crack,stop camera
	Back_Map.speed = 0
	if shake_stop < 10 then--This is for shake camera effect
		Back_Map.shake_x = math.random(-2,2)
		Back_Map.shake_y = math.random(-2,2)
		shake_stop = shake_stop + 1
		else Back_Map.shake_x = 0 Back_Map.shake_y = 0 end
end
end
--ENEMY:UPDATE
function Enemy()
stop = false

time_oneEnemy = time_oneEnemy + 1

--if pass the time, the first object avaliable wont be it
if time_oneEnemy >= timeLimit_Enemy then
	for enemies = 1,5 do
		if Cars[enemies].avaliable == false and stop == false then
		Cars[enemies].avaliable = true
		Set_PosX(enemies)--Set the X postion to object avaliable
		Set_sprite(enemies)--Set a random sprite enemy to object avaliable
			stop = true
			else
			enemies = enemies + 1  end
	end
	time_oneEnemy = 0
	player.SCR_Mult = player.SCR_Mult + 0.2

end


for enemies = 1,5,1 do
	if Cars[enemies].avaliable == true then --Check the avaliable objects and move them
	Cars[enemies].y = Cars[enemies].y - (Cars[enemies].speed/60) + (Back_Map.speed/60)
	end

	if Cars[enemies].y > 136 then --Check if the object is out of the screen
	Cars[enemies].avaliable = false
	Cars[enemies].y = -16

	end

	--Update the enemies body
	Cars[enemies].BDY_X1 = Cars[enemies].x + 3
	Cars[enemies].BDY_X2 = Cars[enemies].x + 12
	Cars[enemies].BDY_Y1 = Cars[enemies].y + 1
	Cars[enemies].BDY_Y2 = Cars[enemies].y + 14

	--Check collision
		if player.BDY_X1 <= Cars[enemies].BDY_X2 and
					player.BDY_X2 >= Cars[enemies].BDY_X1 and
					player.BDY_Y1 <= Cars[enemies].BDY_Y2 and
					player.BDY_Y2 >= Cars[enemies].BDY_Y1
					then
					player.IsCracked = true
		end

end

for enemies = 1,5,1 do-- Check points collision

	if  player.BDY_X1 <= Cars[enemies].BDY_X2 and
					player.BDY_X2 >= Cars[enemies].BDY_X1 and
					player.BDY_Y1 <= Cars[enemies].BDY_Y2+6 and
					player.BDY_Y2 >= Cars[enemies].BDY_Y1+6
					then
					player.IsA_PNTS = true _500.x = player.x player.ref_enemy = enemies break end
end
if player.IsA_PNTS == true and player.IsCracked == false then--Check when player is out of ref_enemy
	if   player.BDY_X1 <= Cars[player.ref_enemy].BDY_X2 and
					player.BDY_X2 >= Cars[player.ref_enemy].BDY_X1 and
					player.BDY_Y1 <= Cars[player.ref_enemy].BDY_Y2+6 and
					player.BDY_Y2 >= Cars[player.ref_enemy].BDY_Y1+6
					then
	else _500.visible = true player.IsA_PNTS = false
	player.score = player.score + 100 sfx(59,"F-4",-1,2,15,4)end
end

if player.IsCracked == false then--Update the rate enemy making
	timeLimit_Enemy = 3840//Back_Map.speed+10
end


end

function Set_PosX(number)--Set a random X position
local p = 0--Randomly number
local RNDNum = math.random(90)+p--Random number
if RNDNum <30 then Cars[number].x = c1  p=30
elseif RNDNum >= 30 and RNDNum < 60 then Cars[number].x = c2
p=math.random(60)-30
elseif(RNDNum >= 60 and RNDNum <= 90) then Cars[number].x = c3  p=-40
else  return

end


end
function PlayExplode()
stop = false

if Explosion.sprite < #Explosion.sprites then
Explosion.b = Explosion.b + 1
end
	if Explosion.b >= Explosion.tim  then
	Explosion.sprite = Explosion.sprite + 1
	Explosion.b = 1
	end

end

function Set_sprite(number)--Set a random enemy sprite
local RNDNumber = math.random(129,132)
Cars[number].sprite = RNDNumber*2

end

function GameControl()--Control all the game
lenght = #(Levels)--Update the lenght of the bag levels

if lenght == 0 then
Levels = {1,2,3,4}
end

if player.IsCracked == false then
	game_t = game_t + 1
else reset_t = reset_t + 1 end

if reset_t >= 150 then
--Set a non-repeated level
local RandomLevel = math.random(1,lenght)
Actual_Level = Levels[RandomLevel]
table.remove(Levels,RandomLevel)

 --Set the Max Score
	if player.score > Max_Pnts  then
	poke(0x14e06,math.ceil(player.score)//65536)
	poke(0x14e05,math.ceil(player.score)//256)
	poke(0x14e04,math.ceil(player.score)-(peek(0x14e04)*256)-(peek(0x14e06)*65536))
	end
--Reser all values
player.IsCracked = false
Back_Map.speed = 120
reset_t = 0
Explosion.sprite = 1
Exp_stop = false
player.score = 0
player.IsA_PNTS = false
time_oneEnemy = 0
shake_stop = 0
player.x = 112
game_t = 1
player.SCR_Mult = 1
COLRscore_1 = 9
COLRscore_2 = 8
for enemies = 1,5,1 do
Cars[enemies].avaliable = false
Cars[enemies].y = -16
end
end
end
function Intro_()

cls()

	intro_t = intro_t + 1
	if intro_t > 10 then
	spr(324,82,56,0,1,0,0,10,3)
	end

	if intro_t >= 60 and intro_t < 80 then

	for i = 0,15,1 do
			for j = 0,2,1 do
				 Colors[i][j] = Colors[i][j] + ((Defeat_Colors[i][j]-Colors[i][j])/(15))
			end
	end
	elseif intro_t < 60 then
	for i = 0,15,1 do
			for j = 0,2,1 do
			  Colors[i][j] = Colors[0][j]
			end
	end
	elseif intro_t < 150 and intro_t == 80 then
	music(1,0,0,false)


	elseif intro_t >= 150 and intro_t < 200then
	for i = 0,15,1 do
			for j = 0,2,1 do
				 Colors[i][j] = Colors[i][j] + ((Colors[0][j]-Colors[i][j])/(9))
			end
	end


	elseif intro_t >= 200  then
	for i = 0,15,1 do
			for j = 0,2,1 do
				 Colors[i][j] = Defeat_Colors[i][j]
			end
	end
	 Mode = "game"
	end

end
