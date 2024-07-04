package voxel
import rl "../raylib"
buildNDestroy :: proc(game : ^Game) {
    vec : Cube= {cast(i16)(game.cam.target.x-game.cam.position.x),cast(i16)(game.cam.target.y-game.cam.position.y),cast(i16)(game.cam.target.z-game.cam.position.z)}
    vec.x += i16(game.cam.target.x)
    vec.y += i16(game.cam.target.y)
    vec.z += i16(game.cam.target.z)
    vec = Cube{i16(int(vec.x)),i16(int(vec.y)),i16(int(vec.z))}
    //fmt.println(vec)
    
    if (rl.IsMouseButtonDown(.RIGHT)) {
        changeBlock(game,vec,u8(game.playerChoosenBlock))
    }
    if (rl.IsMouseButtonDown(.LEFT)) {
        changeBlock(game,vec,255)
    }
}
updatePlayer :: proc(game : ^Game) {
    rl.UpdateCamera(&game.cam,.FIRST_PERSON)
    if rl.IsKeyDown(.SPACE) {
        game.cam.target.y += 1
        game.cam.position.y += 1
    }
    if rl.IsKeyDown(.LEFT_CONTROL) {
        game.cam.target.y -= 1
        game.cam.position.y -= 1
    }
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
    //x : int = int(game.cam.position.x)
    //y : int = int(game.cam.position.y)
    //z : int = int(game.cam.position.z)
    //if (game.aliveCubes[x][y-1][z]==255) {
    //    game.y_velocity += 0.01
    //}
    //else {
    //    game.y_velocity = 0
    //}
    //game.cam.position.y -= game.y_velocity
    //game.cam.target.y -= game.y_velocity
    buildNDestroy(game);
    //rl.DrawCube({f32(vec.x),f32(vec.y),f32(vec.z)}, 1,1,1,rl.RED)
}