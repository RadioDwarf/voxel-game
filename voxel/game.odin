package voxel
import rl "../raylib"
import perlin "../noise"
import "core:fmt"
setupGame :: proc(game : ^Game, width : i32, height : i32) {
	//reset vars
	game.cam = genCam();
    game.meshes = {};
    game.aliveCubes = {};
	game.renderDistance = 16;
    game.y_velocity = 0;
    game.items = {};
    game.playerChoosenBlock = 0;
    for i : i32 = 0; i < 24; i += 1 {
        game.cords[u8(i)] = {f32(i) / 128.0+0.0000001, 0.0};
    }
    
	//setup raylib stuff
	rl.InitWindow(width,height,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
    //load structures
    loadStructure("data/structures/house.struct","house",game);
    loadStructure("data/structures/tree.struct","tree",game);
    texture := rl.LoadImage("textures/texture_pack3.png");
    for x : i32 = 0; x < 16; x+=1 {
        game.colors[u8(x)] = rl.GetImageColor(texture,x,0)
        fmt.println(game.colors[u8(x)])
    }
    rl.UnloadImage(texture);
}

runGame :: proc(game : ^Game, width : i32, height : i32) {
	setupGame(game,width,height)
    genWorld(game);
    
    game.material = rl.LoadMaterialDefault();

    game.material.maps[0].texture = rl.LoadTexture("textures/texture_pack3.png");
    //colors : []rl.Color = {rl.GREEN,rl.BROWN,rl.YELLOW,rl.BLUE,rl.LIME,rl.RED,rl.GRAY,rl.SKYBLUE,rl.WHITE,rl.PINK}
    tickChange : int = 0;
    for !rl.WindowShouldClose() {
        rl.BeginDrawing();
        defer rl.EndDrawing();
        rl.ClearBackground(rl.SKYBLUE);
        tickChange+=1;
        if (tickChange==3) {
            game.tick+=1;
            tickChange = 0;
        }
        if game.tick >= 20 {
            game.tick = 0;
        }
        rl.BeginMode3D(game.cam);
		updateWorld(game);
        rl.EndMode3D();
        rl.DrawRectangle(600-64/2,700,64,64,game.colors[u8(game.playerChoosenBlock*2)])
        rl.DrawFPS(0,0);
    }
}