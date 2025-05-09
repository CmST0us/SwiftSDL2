import Foundation
import SDL2

// 定义显示表面协议
protocol DisplaySurface {
    var width: Int { get }
    var height: Int { get }
    func setPixel(x: Int, y: Int, color: UInt32)
    func getPixel(x: Int, y: Int) -> UInt32
    func clear()
}

// SDL显示表面实现
class SDLDisplaySurface: DisplaySurface {
    private var screen: UnsafeMutablePointer<SDL_Surface>?
    let width: Int
    let height: Int
    
    init(screen: UnsafeMutablePointer<SDL_Surface>?, width: Int, height: Int) {
        self.screen = screen
        self.width = width
        self.height = height
    }
    
    func setPixel(x: Int, y: Int, color: UInt32) {
        guard let screen = screen,
              x >= 0 && x < width && y >= 0 && y < height else { return }
        
        let pixel = screen.pointee.pixels.advanced(by: y * Int(screen.pointee.pitch) + x * Int(screen.pointee.format.pointee.BytesPerPixel))
        pixel.storeBytes(of: color, as: UInt32.self)
    }
    
    func getPixel(x: Int, y: Int) -> UInt32 {
        guard let screen = screen,
              x >= 0 && x < width && y >= 0 && y < height else { return 0 }
        
        let pixel = screen.pointee.pixels.advanced(by: y * Int(screen.pointee.pitch) + x * Int(screen.pointee.format.pointee.BytesPerPixel))
        return pixel.load(as: UInt32.self)
    }
    
    func clear() {
        guard let screen = screen,
              let pixel = screen.pointee.pixels else { return }
        for y in 0..<height {
            for x in 0..<width {
                let offset = y * Int(screen.pointee.pitch) + x * Int(screen.pointee.format.pointee.BytesPerPixel)
                pixel.advanced(by: offset).storeBytes(of: 0, as: UInt32.self)
            }
        }
    }
}

// 单色图形库
class MonoGraphics {
    private let surface: DisplaySurface
    private var drawColor: UInt32
    
    init(surface: DisplaySurface) {
        self.surface = surface
        self.drawColor = 0xFFFFFFFF  // 默认白色
    }
    
    // 设置绘制颜色
    func setDrawColor(_ color: UInt32) {
        self.drawColor = color
    }
    
    // 绘制单个像素
    func drawPixel(x: Int, y: Int) {
        surface.setPixel(x: x, y: y, color: drawColor)
    }
    
    // 绘制直线
    func drawLine(x0: Int, y0: Int, x1: Int, y1: Int) {
        let dx = abs(x1 - x0)
        let dy = abs(y1 - y0)
        let sx = x0 < x1 ? 1 : -1
        let sy = y0 < y1 ? 1 : -1
        var err = dx - dy
        
        var x = x0
        var y = y0
        
        while true {
            drawPixel(x: x, y: y)
            
            if x == x1 && y == y1 { break }
            let e2 = 2 * err
            if e2 > -dy {
                err -= dy
                x += sx
            }
            if e2 < dx {
                err += dx
                y += sy
            }
        }
    }
    
    // 绘制矩形框
    func drawFrame(x: Int, y: Int, w: Int, h: Int) {
        drawLine(x0: x, y0: y, x1: x + w, y1: y)      // 上边
        drawLine(x0: x, y0: y, x1: x, y1: y + h)      // 左边
        drawLine(x0: x + w, y0: y, x1: x + w, y1: y + h)  // 右边
        drawLine(x0: x, y0: y + h, x1: x + w, y1: y + h)  // 下边
    }
    
    // 绘制实心矩形
    func drawBox(x: Int, y: Int, w: Int, h: Int) {
        for py in y..<(y + h) {
            for px in x..<(x + w) {
                drawPixel(x: px, y: py)
            }
        }
    }
    
    // 绘制圆形
    func drawCircle(x: Int, y: Int, radius: Int) {
        var f = 1 - radius
        var ddF_x = 1
        var ddF_y = -2 * radius
        var x1 = 0
        var y1 = radius
        
        drawPixel(x: x, y: y + radius)
        drawPixel(x: x, y: y - radius)
        drawPixel(x: x + radius, y: y)
        drawPixel(x: x - radius, y: y)
        
        while x1 < y1 {
            if f >= 0 {
                y1 -= 1
                ddF_y += 2
                f += ddF_y
            }
            x1 += 1
            ddF_x += 2
            f += ddF_x
            
            drawPixel(x: x + x1, y: y + y1)
            drawPixel(x: x - x1, y: y + y1)
            drawPixel(x: x + x1, y: y - y1)
            drawPixel(x: x - x1, y: y - y1)
            drawPixel(x: x + y1, y: y + x1)
            drawPixel(x: x - y1, y: y + x1)
            drawPixel(x: x + y1, y: y - x1)
            drawPixel(x: x - y1, y: y - x1)
        }
    }
    
    // 绘制实心圆
    func drawDisc(x: Int, y: Int, radius: Int) {
        var f = 1 - radius
        var ddF_x = 1
        var ddF_y = -2 * radius
        var x1 = 0
        var y1 = radius
        
        // 绘制水平线
        drawLine(x0: x - radius, y0: y, x1: x + radius, y1: y)
        
        while x1 < y1 {
            if f >= 0 {
                y1 -= 1
                ddF_y += 2
                f += ddF_y
            }
            x1 += 1
            ddF_x += 2
            f += ddF_x
            
            // 绘制水平线
            drawLine(x0: x - x1, y0: y + y1, x1: x + x1, y1: y + y1)
            drawLine(x0: x - x1, y0: y - y1, x1: x + x1, y1: y - y1)
            drawLine(x0: x - y1, y0: y + x1, x1: x + y1, y1: y + x1)
            drawLine(x0: x - y1, y0: y - x1, x1: x + y1, y1: y - x1)
        }
    }
    
    // 绘制三角形
    func drawTriangle(x0: Int, y0: Int, x1: Int, y1: Int, x2: Int, y2: Int) {
        drawLine(x0: x0, y0: y0, x1: x1, y1: y1)
        drawLine(x0: x1, y0: y1, x1: x2, y1: y2)
        drawLine(x0: x2, y0: y2, x1: x0, y1: y0)
    }
    
    // 清除缓冲区
    func clearBuffer() {
        surface.clear()
    }
} 