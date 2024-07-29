package voxel
import rl "../raylib"
Cube :: struct {
    x : i16,
    y : i16, 
    z : i16
}
Rect :: struct {
    x : f32,
    y : f32,
}
Entity :: struct {
    x : f32,
    y : f32,
    z : f32,
    type : u16,
    yVelocity : f32,
    alive : bool
}
Faces :: struct { 
    front : bool,
    back : bool,
    top : bool,
    bottom : bool,
    left : bool,
    right : bool
}
StructureData :: struct {
    poses : [dynamic]Cube,
    types : [dynamic]u16
}
Player :: struct {
    cam : rl.Camera3D,
    y_velocity : f32,
    playerChoosenBlock : int,
    openedConsole : bool,
    consoleText : string,
    amounts : [dynamic]i32,
    types : [dynamic]string
}
Game :: struct #packed {
    player : Player,
    aliveCubes : [1024][257][1024]u16,
    meshes : [64][64]rl.Mesh,
    material : rl.Material,
    renderDistance : i16,
    items : [dynamic]Entity,
    structures : map[string]StructureData,
    tick : int,
    modelTypes : [dynamic]string,
    cords : map[u16]Rect, //for chunk meshes
	colors : map[u16]rl.Color, //for items
}
ChunkModel :: struct {
    vertex_count : int,
    text_count : int
}
WorldStructure :: struct {
	x : i16,
	y : i16,
	z : i16,
	kind : u16
}
SpawnBoundingBox :: proc(position : rl.Vector3, size : rl.Vector3) -> rl.BoundingBox{
    halfSize : rl.Vector3 = size/2
    return rl.BoundingBox{position-halfSize,position+halfSize}
}