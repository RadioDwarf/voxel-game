package voxel
import rl "../raylib"
import "core:math"
import "core:fmt"
updateItem :: proc(game : ^Game, entity : ^Entity) {
    sinOutput := math.sin_f32(f32(game.tick/2))/1.2
    cubePos := Cube{i16(entity.x),i16(entity.y),i16(entity.z)}
    if game.aliveCubes[cubePos.x][cubePos.y][cubePos.z] == 255 {
        entity.yVelocity -= 0.02;
    }
    else {
        entity.yVelocity = 0;
        entity.y = f32(cubePos.y)+0.5;
    }
    entity.y+= entity.yVelocity;
    rl.DrawCube({entity.x,entity.y,entity.z},0.3+0.1*sinOutput,0.3+0.1*sinOutput,0.3+0.1*sinOutput,game.colors[u16(entity.type)])

    if i32(math.round_f32(game.player.cam.position.x)) == i32(math.round_f32(entity.x)) && i32(math.round_f32(game.player.cam.position.y))-1 == i32(math.round_f32(entity.y)) && i32(math.round_f32(game.player.cam.position.z)) == i32(math.round_f32(entity.z)) {
        fmt.println("a")
        entity.alive = false;
    }
    
}
spawnItem :: proc(game : ^Game, x : f32, y : f32, z : f32, type : u16) {
    append(&game.items,Entity{x,y,z,type,0,true});
}