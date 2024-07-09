package voxel
import rl "../raylib"
import noise "../noise"
import "core:fmt"

import "core:os"
import "core:strings"
import "core:strconv"
loadStructure :: proc(filepath : string, type : string,game : ^Game) {
    data, ok := os.read_entire_file(filepath,context.allocator)
    if !ok {
        fmt.println("unable to load the structure")
        return
    }
    defer delete(data,context.allocator)

    it := string(data)
    cubes : [dynamic]Cube
	types : [dynamic]u8
	for line in strings.split_lines_iterator(&it) {
        elements := strings.split(line," ",context.temp_allocator)
        cube := Cube{i16(strconv.atoi(elements[0])),i16(strconv.atoi(elements[1])),i16(strconv.atoi(elements[2]))}
		type : u8 = u8(strconv.atoi(elements[3]))
		append(&cubes,cube)
		append(&types,type)
    }
	game.structures[type] = {
		cubes,types
	}
	//fmt.println(game.structures[type])
}
genStructure :: proc(type : string, game : ^Game, x : i16, y : i16, z : i16) {
	currentBlock : int = 0
	for value in game.structures[type].poses {
		if (value.x+x>0 && value.x+x<1024 && value.y+y>-1 && value.y+y<256 && value.z+z>0 && value.z+z<1024) {
			game.aliveCubes[value.x+x][value.y+y][value.z+z] = game.structures[type].types[currentBlock]
		}
		currentBlock+=1
	}
	//game.aliveCubes[x][y][z] 
}

flatLands :: proc(game : ^Game, x : i16, z : i16, structures : ^[dynamic] WorldStructure, p : []int) {
	height := noise.perlin(cast(f32)x/20,0,cast(f32)z/20,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
	highest_point : i16
	for y : i16 = 1; y < 256; y+=1 { 
		if  ((y<80 && height<0) || (y<81 && height>=0)) {
			game.aliveCubes[x][y][z] = 5
			highest_point = y
		}
		else {
			game.aliveCubes[x][y][z] = 255
		}
	}
	if (rl.GetRandomValue(0,200)==1) {
		treetype : u8 = 0
		if (rl.GetRandomValue(0,5)==1) {
			treetype = 1
		}
		append(structures,WorldStructure{x,highest_point+1,z,treetype})			
	}
}
highLands :: proc(game : ^Game, x : i16, z : i16, structures : ^[dynamic] WorldStructure, p : []int) { //finished, only need o add structure generation. Overall I am very happy with the result ;)
	height2 := noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
	height := noise.perlin(cast(f32)x/80,0,cast(f32)z/80,p)  + noise.perlin(cast(f32)x/80,0,cast(f32)z/80,p);
	mountain_height := height* 60;
	for y : i16 = 1; y < 256; y+=1 { 
		game.aliveCubes[x][y][z] = 255
		if  ((y<80 && height2<0) || (y<81 && height2>=0)) {
			game.aliveCubes[x][y][z] = 1
			if ((y==79 && height2<0) || (y==80 && height2>=0)) {
				game.aliveCubes[x][y][z] = 0
				game.aliveCubes[x][y-1][z] = 4
				
				if rl.GetRandomValue(0,200)==1 {
					append(structures,WorldStructure{x,y,z,0})	
				}
				
			}
			
		}
		else if  (y<=cast(i16)mountain_height+80 && y>79) {
			game.aliveCubes[x][y][z] = 1
			
			if (y==cast(i16)mountain_height+80) {
				game.aliveCubes[x][y][z] = 0
				game.aliveCubes[x][y-1][z] = 4
				
				if rl.GetRandomValue(0,200)==1 {
					append(structures,WorldStructure{x,y,z,0})	
				}
				
			}
			
		}
		
	}
}
desert :: proc(game : ^Game, x : i16, z : i16, structures : ^[dynamic]WorldStructure, p : []int) {
	height := noise.perlin(cast(f32)x/20,0,cast(f32)z/20,p)  + noise.perlin(cast(f32)x/10,0,cast(f32)z/10,p) 
	highest_point : i16
	for y : i16 = 1; y < 256; y+=1 { 
		if  ((y<80 && height<0) || (y<81 && height>=0)) {
			game.aliveCubes[x][y][z] = 4
			highest_point = y
			if (y==79 && height < 0) {
				if height < -0.7 {
					game.aliveCubes[x][y][z] = 12
				}
				else if height < -0.6 {
					game.aliveCubes[x][y][z] = 0
					if (rl.GetRandomValue(0,100)==1) {
						treetype : u8 = 0
						if (rl.GetRandomValue(0,5)==1) {
							treetype = 1
						}
						append(structures,WorldStructure{x,highest_point+1,z,treetype})			
					}
				}

			}
		}
		else {
			game.aliveCubes[x][y][z] = 255
		}
	}
	
}
genBiomeTypes :: proc(width : f32, height : f32) -> [64][64]i16 {
    biomeTypes : [64][64]i16
    p := noise.init_permutation()
    for x : int = 0; x < 64; x+=1 {
        for y : int = 0; y < 64; y+=1 {
            biome : i16 = 0
			height := noise.perlin(f32(x/100),0,f32(y/100),p)
			
            biomeTypes[x][y] = biome
        }
    }
    return biomeTypes
} 
genWorld :: proc(game : ^Game) {
    p := noise.init_permutation()
    structures : [dynamic] WorldStructure
    biomeTypes := genBiomeTypes(28,6)
	for x : i16 = 1; x < 1024; x+=1 {
        for z : i16 = 1; z < 1024; z+=1 {
			chunkX : int = int(x)/16
			chunkZ : int = int(z)/16
			switch(biomeTypes[chunkX][chunkZ]) {
				case 0:
				highLands(game,x,z,&structures,p);
        
				break;
				case 1:
				flatLands(game,x,z,&structures,p);
				break;
				case 2:
				desert(game,x,z,&structures,p);
				break;
            }
		}
    }
	
    for structure in structures { //temporary, will be made into a hashmap
		switch structure.kind {
			case 0:
				genStructure("tree",game,structure.x,structure.y,structure.z)
				//genTree(game,structure.x,structure.y,structure.z);
			break;
			case 1:
				genStructure("house",game,structure.x,structure.y,structure.z)
			break;
		}
    }
    for x : i16 = 0; x < 32; x+=1 {
        for y : i16 = 0; y < 32; y+=1 {
            genChunkModel(game,x,0,y)
            
        }    
    }
}
changeBlock :: proc(game : ^Game, pos : Cube, type : u8) {

    if (pos.x>-1 && pos.z > -1 && pos.y > -1) {
		//check whether the block is air and needs to be replaced
		//check whether the block is solid and is gonna be destroyed
        if (game.aliveCubes[pos.x][pos.y][pos.z] == 255 && type != 255) || (game.aliveCubes[pos.x][pos.y][pos.z] != 255 && type == 255) { 
            chunkPos := Cube{i16(int(pos.x/16)),0,i16(int(pos.z/16))}
            if (type==255) {
				fmt.println("a");
				spawnItem(game,f32(pos.x),f32(pos.y),f32(pos.z), game.aliveCubes[pos.x][pos.y][pos.z])
			}
			game.aliveCubes[pos.x][pos.y][pos.z] = type
            
			rl.UnloadMesh(game.meshes[chunkPos.x][chunkPos.z]) //there needs to be some thinking done here because it seems not everything is working correctly
            game.meshes[chunkPos.x][chunkPos.z].vertices = nil
            game.meshes[chunkPos.x][chunkPos.z].texcoords = nil
            genChunkModel(game,chunkPos.x,0,chunkPos.z) 
        
        }
    }
}

updateWorld :: proc(game :^Game) {
	chunkCamX := cast(i16)game.cam.position.x/16
    chunkCamZ := cast(i16)game.cam.position.z/16
    for x : i16 = chunkCamX-game.renderDistance; x < game.renderDistance+chunkCamX; x+=1 {
		for z : i16 = chunkCamZ-game.renderDistance; z < game.renderDistance+chunkCamZ; z+=1 {
			if (x>-1 && x < 64 && z > -1 && z < 64) {
				rl.DrawMesh(game.meshes[x][z],game.material,rl.MatrixTranslate(-0.5,-0.5,-0.5))
				
				
			}
                
        }
    }
	updatePlayer(game);
	leftItems : [dynamic]Entity
	for val, index in game.items {
		updateItem(game,&game.items[index])
		if val.alive {
			append(&leftItems, val)
		}
	}
	game.items = leftItems
}

setupWorld :: proc(game : ^Game) {
	
}
