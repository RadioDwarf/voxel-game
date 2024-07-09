package voxel
import rl "../raylib"

genCam :: proc() -> rl.Camera3D { //setup up the camera will be moved into the player controller file once one is created and needed
    cam : rl.Camera3D
    cam.position = {5,105,5};
    cam.target = {0,100,0}
    cam.up = {0,1,0}
    cam.fovy = 45
    
    cam.projection = .PERSPECTIVE
    return cam
}

setVertex :: proc(model : ^ChunkModel,mesh : ^rl.Mesh,x : f32, y : f32, z : f32, tx1 : f32,  tx2 : f32) {
    //quick and dirt solution, good enuf
    mesh.vertices[model.vertex_count] = x
    model.vertex_count+=1;
    mesh.vertices[model.vertex_count] = y
    model.vertex_count+=1;
    mesh.vertices[model.vertex_count] = z
    model.vertex_count+=1;
    mesh.texcoords[model.text_count] = tx1
    model.text_count+=1
    mesh.texcoords[model.text_count] = tx2
    model.text_count+=1
}
b2f32 :: proc(boolean : bool) -> f32 {
    //a quick fix because odin's system doesn't allow i for some reason
    if (boolean) {
        return 1;
    }
    return 0;
}
addCube :: proc(model : ^ChunkModel, mesh : ^rl.Mesh, x : f32, y : f32, z : f32, width : f32, height : f32, length : f32, tx1 : f32, tx2 : f32, face : Faces, ambients : Faces) {
    //I hate this
    //Gonna add a file that defines all the faces
    //front face
    tx_step : f32 = 0.51;
    if (!face.front) {
        ft := tx_step + b2f32(ambients.front)
        setVertex(model, mesh, x, y, z, tx1,ft);                      // Bottom-left
        setVertex(model, mesh, x + length, y, z, tx1 , ft);             // Bottom-right
        setVertex(model, mesh, x + length, y + height, z, tx1, ft);    // Top-right
        setVertex(model, mesh, x, y, z, tx1 , tx2 + ft);                      // Bottom-left
        setVertex(model, mesh, x + length, y + height, z, tx1, ft);    // Top-right
        setVertex(model, mesh, x, y + height, z, tx1 , ft);             // Top-left        
    }

    // Back face
    if (!face.back) {
        bk := tx_step + b2f32(ambients.back)
        setVertex(model, mesh, x, y, z + width, tx1 , bk);                  // Bottom-left
        setVertex(model, mesh, x + length, y, z + width, tx1 , bk);         // Bottom-right
        setVertex(model, mesh, x + length, y + height, z + width, tx1 , bk);// Top-right
        setVertex(model, mesh, x, y, z + width, tx1 ,bk);                  // Bottom-left
        setVertex(model, mesh, x + length, y + height, z + width, tx1 , bk);// Top-right
        setVertex(model, mesh, x, y + height, z + width, tx1 , bk);         // Top-left    
    }

    // Left face
    if (!face.left) {
        lt := tx_step + b2f32(ambients.left)
        setVertex(model, mesh, x, y, z, tx1 , lt);                      // Bottom-left
        setVertex(model, mesh, x, y + height, z, tx1 , lt);             // Top-left
        setVertex(model, mesh, x, y + height, z + width, tx1 , lt);     // Top-right
        setVertex(model, mesh, x, y, z, tx1 , tx2 + lt);                      // Bottom-left
        setVertex(model, mesh, x, y + height, z + width, tx1 , lt);     // Top-right
        setVertex(model, mesh, x, y, z + width, tx1 , lt);              // Bottom-right    
    }

    // Right face
    if (!face.right) {
        rt := tx_step + b2f32(ambients.right)
        setVertex(model, mesh, x + length, y, z, tx1 , rt);                 // Bottom-left
        setVertex(model, mesh, x + length, y + height, z, tx1 ,  rt);        // Top-left
        setVertex(model, mesh, x + length, y + height, z + width, tx1 , rt);// Top-right
        setVertex(model, mesh, x + length, y, z, tx1, rt);                 // Bottom-left
        setVertex(model, mesh, x + length, y + height, z + width, tx1 , rt);// Top-right
        setVertex(model, mesh, x + length, y, z + width, tx1 , rt );         // Bottom-right    
    }

    // Top face
    if (!face.top) {
        setVertex(model,mesh, x, y + height, z, tx1, tx2);            // Bottom-left
        setVertex(model,mesh, x + length, y + height, z, tx1, tx2);   // Bottom-right
        setVertex(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setVertex(model,mesh, x, y + height, z, tx1, tx2);            // Bottom-left
        setVertex(model,mesh, x + length, y + height, z + width, tx1, tx2); // Top-right
        setVertex(model,mesh, x, y + height, z + width, tx1, tx2);    // Top-left
            
    }
    
    // Bottom face
    if (!face.bottom) {
        setVertex(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setVertex(model,mesh, x + length, y, z, tx1, tx2);   // Bottom-right
        setVertex(model,mesh, x + length, y, z + width, tx1, tx2); // Top-right
        setVertex(model,mesh, x, y, z, tx1, tx2);            // Bottom-left
        setVertex(model,mesh, x + length, y, z + width, tx1, tx2); // Top-right
        setVertex(model,mesh, x, y, z + width, tx1, tx2);    // Top-left
    }
    
}

genMesh :: proc(_blocks : [dynamic]Cube, _faces : [dynamic]Faces, _types : [dynamic]u8, _ambients : [dynamic]Faces, game : ^Game) -> rl.Mesh {
    mesh : rl.Mesh
    trang_count : i32 = 0
    //count the trang count
    for face in _faces {
        if (!face.front) {trang_count += 2;}
        if (!face.back) {trang_count += 2;}
        if (!face.top) {trang_count += 2;}
        if (!face.bottom) {trang_count += 2;}
        if (!face.right) {trang_count += 2;}
        if (!face.left) {trang_count += 2;}
    }
    mesh.triangleCount = trang_count
    mesh.vertexCount = mesh.triangleCount*3;
    mesh.vertices = cast(^f32)rl.MemAlloc(cast(u32)mesh.vertexCount*3*size_of(f32))
    mesh.texcoords = cast(^f32)rl.MemAlloc(cast(u32)mesh.vertexCount*2*size_of(f32))
    model := ChunkModel{0,0}
    //go through blocks and add the data to the mesh
    index : int = 0
    for block in _blocks {
        addCube(&model, &mesh, cast(f32)block.x,cast(f32)block.y,cast(f32)block.z,1,1,1,game.cords[_types[index]].x,game.cords[_types[index]].y, _faces[index], _ambients[index])

        index+=1
    }
    rl.UploadMesh(&mesh,false)
    return mesh
}
checkObscures :: proc(game : ^Game, x : i16, y : i16, z : i16) -> Faces {
    faces : Faces = {false, false, false, false, false, false}
    if (z+1 < 1024) { if (game.aliveCubes[x][y][z+1]!=255) { faces.back = true } } // back
    if (z-1> -1) { if (game.aliveCubes[x][y][z-1]!=255) { faces.front = true } } // front
    if (y+1 < 256) { if (game.aliveCubes[x][y+1][z]!=255) { faces.top = true } } // top
    if (y-1 > -1) { if (game.aliveCubes[x][y-1][z]!=255) { faces.bottom = true } } // bottom
    if (x-1 > -1) { if (game.aliveCubes[x-1][y][z]!=255) { faces.left = true } } // left
    if (x+1 < 1024) { if (game.aliveCubes[x+1][y][z]!=255) { faces.right = true } } // right

    return faces
}
checkAmbience :: proc(game : ^Game, x : i16, y : i16, z : i16) -> Faces {
    faces : Faces = {false, false, false, false, false, false} //I reuse the data type for simplicity sake 
    if (y+1<256) {
        if (z+1 < 1024) { if (game.aliveCubes[x][y+1][z+1]!=255) { faces.back = true } } // back
        if (z-1 > 0) { if (game.aliveCubes[x][y+1][z-1]!=255) { faces.front = true } } // front
        if (x > 0) { if (game.aliveCubes[x-1][y+1][z]!=255) { faces.left = true } } // left
        if (x+1 < 1024) { if (game.aliveCubes[x+1][y+1][z]!=255) { faces.right = true } } // right
    }
    
    return faces
}
genChunkModel :: proc(game : ^Game, x : i16, y : i16, z : i16) {
	//setup data
    blocks : [dynamic]Cube
    faces : [dynamic]Faces
    types : [dynamic]u8
    ambients : [dynamic]Faces
    //go through the chunk size
    for chunkx : i16 = 0; chunkx < 16; chunkx+=1 {
        for chunkz : i16 = 0; chunkz < 16; chunkz+=1 {
            for chunky : i16 = 0; chunky < 256; chunky+=1 { 
				//don't change the 0s to 1s, doesn't change anything gameplay wise and helps with the performance quite a bit 
                if(chunkx+x*16>0 && chunky+y*16 > 0 && chunkz+z*16>0 && chunkx+x*16<1024 && chunky+y*16 <256 && chunkz+z*16<1024) {
                    if (game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]!=255) {
                        append(&blocks,Cube{chunkx+x*16,chunky+y*16,chunkz+z*16}) //add cube poses
                        append(&faces,checkObscures(game,chunkx+x*16,chunky+y*16,chunkz+z*16)) //add visible faces
                        append(&ambients,checkAmbience(game,chunkx+x*16,chunky+y*16,chunkz+z*16)) //add the checks for lights
                        append(&types,game.aliveCubes[chunkx+x*16][chunky+y*16][chunkz+z*16]) //add the block types
                    }
                }
                
            }
        }
    }
    game.meshes[x][z] = genMesh(blocks,faces,types,ambients,game)
}

