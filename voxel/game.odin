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
    
    //needs to be moved into data.odin and made loaded from a file, this is a temporary solution
    game.cords[0] = {0.0,0} //grass
    game.cords[1] = {0.0626,0} //ambient grass
    game.cords[2] = {0.1251,0} //stone
    game.cords[3] = {0.1876,0} //ambient stone
    game.cords[4] = {0.2501,0} //sand 
    game.cords[5] = {0.3126,0} //ambient sand
    game.cords[6] = {0.3751,0} //wood
    game.cords[7] = {0.4376,0} //ambient wood
    game.cords[8] = {0.5001,0} //dirt
    game.cords[9] = {0.5626,0} //ambient dirt
    game.cords[10] = {0.6251,0} //leaf
    game.cords[11] = {0.6876,0} //ambient leaf
    game.cords[12] = {0.7501,0} //iron ore
    game.cords[13] = {0.8126,0} //ambient iron ore
    game.cords[14] = {0.8751,0} //gold ore
    game.cords[15] = {0.9376,0} //ambient gold ore
    
    
	//setup raylib stuff
	rl.InitWindow(width,height,"a");
    rl.SetTargetFPS(60);
    rl.rlDisableBackfaceCulling();
    rl.DisableCursor();
    //load structures
    loadStructure("data/structures/house.struct","house",game);
    loadStructure("data/structures/tree.struct","tree",game);
    texture := rl.LoadImage("textures/texture_pack.png");
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

    game.material.maps[0].texture = rl.LoadTexture("textures/texture_pack.png");
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
        
        rl.DrawFPS(0,0);
    }
}