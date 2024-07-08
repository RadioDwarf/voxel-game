package voxel
import rl "../raylib"
import "core:math"
import "core:fmt"

// Vector structure for 3D coordinates

// Normalizes a vector

COLLOFSSET :: #config(COLLOFSSET, 0.05)
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
buildNDestroy :: proc(game : ^Game) {
    targetPos := game.cam.target-game.cam.position
    targetPos+= game.cam.position
    targetPosCubified := Cube{i16(math.round(targetPos.x)),i16(math.round(targetPos.y)),i16(math.round(targetPos.z))}
    currentPos : Cube = {i16(math.round(game.cam.position.x)),i16(math.round(game.cam.position.y)),i16(math.round(game.cam.position.z))}
    newPos := calcRay(currentPos,targetPosCubified,12,game,false)
        
    if (rl.IsMouseButtonDown(.RIGHT)) {
        if newPos != currentPos {
            changeBlock(game,newPos,u8(game.playerChoosenBlock))
        }
    }
    if (rl.IsMouseButtonDown(.LEFT)) {
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
updatePlayer :: proc(game : ^Game) {
    rl.UpdateCamera(&game.cam,.FIRST_PERSON)
    
    if rl.IsKeyDown(.G) {
        rl.rlEnableWireMode()
    }
    if rl.IsKeyDown(.H) {
        rl.rlDisableWireMode();
    }
    if rl.IsKeyDown(.ONE) {
        game.playerChoosenBlock = 0;
    }
    if rl.IsKeyDown(.TWO) {
        game.playerChoosenBlock = 2;
    }
    if rl.IsKeyDown(.THREE) {
        game.playerChoosenBlock = 4;
    }
    if rl.IsKeyDown(.FOUR) {
        game.playerChoosenBlock = 6;
    }
    x : int = int(math.round(game.cam.position.x))
    y : int = int(math.round(game.cam.position.y))
    z : int = int(math.round(game.cam.position.z))
    
    if game.aliveCubes[int(math.round(game.cam.position.x-COLLSIZE))][y-1][z]!=255 || game.aliveCubes[int(math.round(game.cam.position.x-COLLSIZE))][y][z]!=255 {
        game.cam.position.x = f32(x) + COLLOFSSET;
        game.cam.target.x += COLLOFSSET;
    }
    if game.aliveCubes[int(math.round(game.cam.position.x+COLLSIZE))][y-1][z]!=255 || game.aliveCubes[int(math.round(game.cam.position.x+COLLSIZE))][y][z]!=255 {
        game.cam.position.x = f32(x) -COLLOFSSET;
        game.cam.target.x -= COLLOFSSET;
    }
    if game.aliveCubes[x][y-1][int(math.round(game.cam.position.z-COLLSIZE))]!=255 || game.aliveCubes[x][y][int(math.round(game.cam.position.z-COLLSIZE))]!=255 {
        game.cam.position.z = f32(z) + COLLOFSSET;
        game.cam.target.z += COLLOFSSET;
    }
    if game.aliveCubes[x][y-1][int(math.round(game.cam.position.z+COLLSIZE))]!=255 || game.aliveCubes[x][y][int(math.round(game.cam.position.z+COLLSIZE))]!=255 {
        game.cam.position.z = f32(z) - COLLOFSSET;
        game.cam.target.z -= COLLOFSSET;
    }
    colldFromTop : bool = false;
    if (y>-1 && y<256) {
        if (game.aliveCubes[x][y][z]!=255) {
            game.y_velocity *= -0.5;
            colldFromTop = true;
        }
    }
    if (y-2<256 && y-2>-1) {
        if (game.aliveCubes[x][y-2][z]==255) {
            game.y_velocity += 0.01
        }
        else {
            game.y_velocity = 0
            if rl.IsKeyDown(.SPACE) && !colldFromTop {
                game.y_velocity -= 0.2
            }
        }
    }
    else {
        game.y_velocity += 0.01
    }
    
    game.cam.position.y -= game.y_velocity
    game.cam.target.y -= game.y_velocity
    buildNDestroy(game);
    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
}