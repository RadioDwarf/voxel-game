package voxel
import rl "../raylib"
import "core:math"
import "core:fmt"
import "core:unicode/utf8"
// Vector structure for 3D coordinates

// Normalizes a vector

COLLOFSSET :: #config(COLLOFSSET, 0.068)
COLLSIZE :: #config(COLLSIZE,0.5)
// Checks if a voxel exists at the given position in the game's voxel array
get_voxel_id :: proc(x: f32, y: f32, z: f32, game: ^Game) -> bool {
    ix, iy, iz := int(x), int(y), int(z)
    if ix >= 0 && ix < 1024 && iy >= 0 && iy < 256 && iz >= 0 && iz < 1024 {
        return game.aliveCubes[ix][iy][iz] != 255
    }
    return false
}
// Calculates the ray and checks for voxel hits
calcRay :: proc(pos: Cube, endPos: Cube, speed: f32, game: ^Game, mode : bool) -> Cube {
    direction := rl.Vector3Normalize(rl.Vector3{f32(endPos.x - pos.x), f32(endPos.y - pos.y), f32(endPos.z - pos.z)})
    direction = rl.Vector3{f32(direction.x / 24.0), f32(direction.y / 24.0), f32(direction.z / 24.0)}
    
    position := rl.Vector3{f32(pos.x), f32(pos.y) + 0.72, f32(pos.z)}
    max_distance := 6

    for i : int = 0; i < 8*50; i+=1 {
        oldPos := position
        position = rl.Vector3{position.x + direction.x, position.y + direction.y, position.z + direction.z}
        //fmt.println(position)
        if get_voxel_id(position.x, position.y, position.z, game) {
            if mode {
                return Cube{
                    x = i16(position.x),
                    y = i16(position.y),
                    z = i16(position.z)
                }
            }
            else {
                return Cube{
                    x = i16(oldPos.x),
                    y = i16(oldPos.y),
                    z = i16(oldPos.z),
                }
            }
            
        }
    }

    // No hit
    return pos
}
buildNDestroy :: proc(player : ^Player,game : ^Game) {
    targetPos := player.cam.target-player.cam.position
    targetPos+= player.cam.position
    targetPosCubified := Cube{i16(math.round(targetPos.x)),i16(math.round(targetPos.y)),i16(math.round(targetPos.z))}
    currentPos : Cube = {i16(math.round(player.cam.position.x)),i16(math.round(player.cam.position.y)),i16(math.round(player.cam.position.z))}
    newPos := calcRay(currentPos,targetPosCubified,12,game,false)
        
    if (rl.IsMouseButtonPressed(.RIGHT)) {
        if newPos != currentPos {
            changeBlock(game,newPos,u16(player.playerChoosenBlock))
        }
    }
    if (rl.IsMouseButtonPressed(.LEFT)) {
        newPos = calcRay(currentPos,targetPosCubified,12,game,true)
        if newPos != currentPos {
            changeBlock(game,newPos,255)
        
        }
        
    }
    if newPos!= currentPos {
        rl.DrawCube({f32(newPos.x),f32(newPos.y),f32(newPos.z)},1,1,1,rl.WHITE)
    
    }
     
    //rl.DrawCube({f32(newPos.x),f32(newPos.y),f32(newPos.z)},1,1,1,rl.WHITE)
    //rl.DrawCube({f32(currentPos.x),f32(currentPos.y),f32(currentPos.z)},1,1,1,rl.WHITE)

    
}
collisions :: proc(player : ^Player, game : ^Game) {
    
    x : int = int(math.round(player.cam.position.x))
    y : int = int(math.round(player.cam.position.y))
    z : int = int(math.round(player.cam.position.z))
    
    if game.aliveCubes[int(math.round(player.cam.position.x-COLLSIZE))][y-1][z]!=255 || game.aliveCubes[int(math.round(player.cam.position.x-COLLSIZE))][y][z]!=255 {
        player.cam.position.x = f32(x) + COLLOFSSET;
        player.cam.target.x += COLLOFSSET;
    }
    if game.aliveCubes[int(math.round(player.cam.position.x+COLLSIZE))][y-1][z]!=255 || game.aliveCubes[int(math.round(player.cam.position.x+COLLSIZE))][y][z]!=255 {
        player.cam.position.x = f32(x) -COLLOFSSET;
        player.cam.target.x -= COLLOFSSET;
    }
    if game.aliveCubes[x][y-1][int(math.round(player.cam.position.z-COLLSIZE))]!=255 || game.aliveCubes[x][y][int(math.round(player.cam.position.z-COLLSIZE))]!=255 {
        player.cam.position.z = f32(z) + COLLOFSSET;
        player.cam.target.z += COLLOFSSET;
    }
    if game.aliveCubes[x][y-1][int(math.round(player.cam.position.z+COLLSIZE))]!=255 || game.aliveCubes[x][y][int(math.round(player.cam.position.z+COLLSIZE))]!=255 {
        player.cam.position.z = f32(z) - COLLOFSSET;
        player.cam.target.z -= COLLOFSSET;
    }
    colldFromTop : bool = false;
    if (y>-1 && y<256) {
        if (game.aliveCubes[x][y][z]!=255) {
            player.y_velocity *= -0.5;
            colldFromTop = true;
        }
    }
    if (y-2<256 && y-2>-1) {
        if (game.aliveCubes[x][y-2][z]==255) {
            player.y_velocity += 0.01
        }
        else {
            player.y_velocity = 0
            if rl.IsKeyDown(.SPACE) && !colldFromTop {
                player.y_velocity -= 0.2
            }
        }
    }
    else {
        player.y_velocity += 0.01
    }
    player.cam.position.y -= player.y_velocity
    player.cam.target.y -= player.y_velocity
    
}
godMode :: proc(player : ^Player, game : ^Game) {
    if rl.IsKeyPressed(.SLASH) {
        player.openedConsole = !player.openedConsole
        fmt.println("\n")
        player.consoleText = ""
    }
    if rl.IsKeyPressed(.ONE) {
        player.playerChoosenBlock += 1;
    }
    if rl.IsKeyPressed(.TWO) {
        player.playerChoosenBlock -= 1;
    }
    if player.playerChoosenBlock == 9 {
        player.playerChoosenBlock = 7;
    }
    if player.playerChoosenBlock == -1 {
        player.playerChoosenBlock = 0;
    }
    //if rl.IsKeyPressed(.C) {
    //    saveWorld(game^,"data/worlds/world1.json")
    //}
}
updatePlayer :: proc(player : ^Player,game : ^Game) {
    if !player.openedConsole {
        rl.UpdateCamera(&player.cam,.FIRST_PERSON)
    }
    collisions(player,game);
    godMode(player,game);
    buildNDestroy(player,game);
    rl.EndMode3D()
    for x : i32 = 0; x < 9; x+=1 {
        rl.DrawRectangle(x*65+275,600,64,64,rl.LIGHTGRAY)
    }
    rl.BeginMode3D(player.cam)
    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
}
