package gui
import rl"rl/raylib"
import "core:fmt"
import "core:unicode/utf8"
import "core:strings"
GuiElements :: enum {
    BUTTON,
    DRAGABLE,
    LABEL,
}
Rect :: struct {
    x : i32,
    y : i32,
    width : i32,
    height : i32
}
TextData :: struct {
    content : string,
    size : i32,
    color : rl.Color
}
GuiElement :: struct {
    rect : Rect,
    textData : TextData,
    color : rl.Color,
    highlight : rl.Color,
    borderSize : i32,
    borderColor : rl.Color,
    type : GuiElements,
    picked : bool
}

updateBase :: proc(element : GuiElement) {
    rl.DrawRectangle(element.rect.x-element.borderSize/2,element.rect.y-element.borderSize/2,element.rect.width+element.borderSize,element.rect.height+element.borderSize,element.borderColor)
    rl.DrawRectangle(element.rect.x,element.rect.y,element.rect.width,element.rect.height,element.color)
}
updateText :: proc(element : GuiElement) {
    textLength := i32(len(element.textData.content))
    size : f32 = f32(element.textData.size)*0.64
    textLength = (element.rect.width-textLength*i32(size))/2
    rl.DrawText(rl.TextFormat("%s",element.textData.content), element.rect.x+textLength,element.rect.y+(element.rect.height-element.textData.size)/2, element.textData.size, element.textData.color)
}
updateButton :: proc(button : GuiElement) -> bool {
    updateBase(button)
    if rl.CheckCollisionRecs({f32(button.rect.x),f32(button.rect.y),f32(button.rect.width),f32(button.rect.height)},{f32(rl.GetMouseX()),f32(rl.GetMouseY()),1,1}) {
        rl.DrawRectangle(button.rect.x,button.rect.y,button.rect.width,button.rect.height,button.highlight)
        if rl.IsMouseButtonPressed(.LEFT) {
            return true;
        }
    }
    updateText(button)
    return false;
}
updateDragableObject :: proc(dragableObject : ^GuiElement) {
    updateBase(dragableObject^)
    if rl.IsMouseButtonDown(.LEFT) {
        if rl.CheckCollisionRecs({f32(dragableObject.rect.x),f32(dragableObject.rect.y),f32(dragableObject.rect.width),f32(dragableObject.rect.height)}, {f32(rl.GetMouseX()),f32(rl.GetMouseY()),1,1}) {
            dragableObject.picked = true;
        }        
    }
    else {
        dragableObject.picked = false;
    }
    
    if dragableObject.picked {
        dragableObject.rect.x = rl.GetMouseX()-dragableObject.rect.width/2
        dragableObject.rect.y = rl.GetMouseY()-dragableObject.rect.height/2
    }
    updateText(dragableObject^)
}
updateLabel :: proc(dragableObject : GuiElement) {
    updateBase(dragableObject)
    updateText(dragableObject)
}