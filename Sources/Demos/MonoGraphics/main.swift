import SDL2
import Foundation

let width = 128 * 3
let height = 64 * 3

// 全局变量
var window: OpaquePointer?
var screen: UnsafeMutablePointer<SDL_Surface>?
var colors: [UInt32] = [0, 0, 0, 0, 0]

// 16x16 ASCII字体数据 (只包含基本ASCII字符)
let font16x16: [[UInt16]] = [
    // 空格 (0x20)
    [0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
     0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000],
    // 数字 0-9
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000], // 0
    [0x0180, 0x0380, 0x0780, 0x0F80, 0x0180, 0x0180, 0x0180, 0x0180,
     0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0000], // 1
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x0038, 0x0070, 0x00E0, 0x01C0,
     0x0380, 0x0700, 0x0E00, 0x1C00, 0x1C00, 0x1FF8, 0x1FF8, 0x0000], // 2
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x0038, 0x0070, 0x01E0, 0x0070,
     0x0038, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // 3
    [0x0070, 0x00F0, 0x01F0, 0x03F0, 0x0770, 0x0E70, 0x1C70, 0x1C70,
     0x1FF8, 0x1FF8, 0x0070, 0x0070, 0x0070, 0x0070, 0x0000, 0x0000], // 4
    [0x1FF8, 0x1FF8, 0x1C00, 0x1C00, 0x1FE0, 0x1FF0, 0x0038, 0x0038,
     0x0038, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // 5
    [0x07E0, 0x0FF0, 0x1C38, 0x1C00, 0x1C00, 0x1FE0, 0x1FF0, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // 6
    [0x1FF8, 0x1FF8, 0x0038, 0x0070, 0x00E0, 0x01C0, 0x0380, 0x0700,
     0x0E00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x0000, 0x0000], // 7
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x0FF0, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // 8
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF8, 0x0078,
     0x0038, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // 9
    // 字母 A-Z
    [0x0180, 0x03C0, 0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x1FF8,
     0x1FF8, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // A
    [0x1FE0, 0x1FF0, 0x1C38, 0x1C38, 0x1C38, 0x1FF0, 0x1FF0, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1FF0, 0x1FE0, 0x0000, 0x0000], // B
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C00, 0x1C00, 0x1C00, 0x1C00,
     0x1C00, 0x1C00, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // C
    [0x1FE0, 0x1FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1FF0, 0x1FE0, 0x0000, 0x0000], // D
    [0x1FF8, 0x1FF8, 0x1C00, 0x1C00, 0x1C00, 0x1FF0, 0x1FF0, 0x1C00,
     0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1FF8, 0x1FF8, 0x0000, 0x0000], // E
    [0x1FF8, 0x1FF8, 0x1C00, 0x1C00, 0x1C00, 0x1FF0, 0x1FF0, 0x1C00,
     0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x0000, 0x0000], // F
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C00, 0x1C00, 0x1C00, 0x1C78,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // G
    [0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1FF8, 0x1FF8, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // H
    [0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180,
     0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0000, 0x0000], // I
    [0x0038, 0x0038, 0x0038, 0x0038, 0x0038, 0x0038, 0x0038, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // J
    [0x1C38, 0x1C70, 0x1CE0, 0x1DC0, 0x1F80, 0x1F00, 0x1F00, 0x1F80,
     0x1DC0, 0x1CE0, 0x1C70, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // K
    [0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00,
     0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1FF8, 0x1FF8, 0x0000, 0x0000], // L
    [0x1C38, 0x1E78, 0x1E78, 0x1FF8, 0x1FF8, 0x1DB8, 0x1DB8, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // M
    [0x1C38, 0x1E38, 0x1F38, 0x1F38, 0x1FB8, 0x1DB8, 0x1CF8, 0x1C78,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // N
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // O
    [0x1FE0, 0x1FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1FF0, 0x1FE0,
     0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x1C00, 0x0000, 0x0000], // P
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0038, 0x0000], // Q
    [0x1FE0, 0x1FF0, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1FF0, 0x1FE0,
     0x1C70, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // R
    [0x07E0, 0x0FF0, 0x1C38, 0x1C38, 0x1C00, 0x0FF0, 0x07E0, 0x0038,
     0x0038, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // S
    [0x1FF8, 0x1FF8, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180,
     0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0000, 0x0000], // T
    [0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0FF0, 0x07E0, 0x0000, 0x0000], // U
    [0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38,
     0x1C38, 0x0E70, 0x0E70, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x0000], // V
    [0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x1DB8, 0x1DB8,
     0x1FF8, 0x1FF8, 0x1E78, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // W
    [0x1C38, 0x1C38, 0x0E70, 0x0E70, 0x07E0, 0x03C0, 0x03C0, 0x07E0,
     0x0E70, 0x0E70, 0x1C38, 0x1C38, 0x1C38, 0x1C38, 0x0000, 0x0000], // X
    [0x1C38, 0x1C38, 0x0E70, 0x0E70, 0x07E0, 0x03C0, 0x0180, 0x0180,
     0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0000, 0x0000], // Y
    [0x1FF8, 0x1FF8, 0x0038, 0x0070, 0x00E0, 0x01C0, 0x0380, 0x0700,
     0x0E00, 0x1C00, 0x1C00, 0x1C00, 0x1FF8, 0x1FF8, 0x0000, 0x0000]  // Z
]

// 弹簧动画参数
struct SpringAnimation {
    var position: Double
    var velocity: Double = 0
    var target: Double
    
    // iOS 弹簧动画参数
    let mass: Double = 1.0
    let stiffness: Double = 200.0   // 增加刚度，提高速度
    let damping: Double = 25.0      // 适当增加阻尼，保持平滑
    let initialVelocity: Double = 0.0
    
    init(position: Double, target: Double) {
        self.position = position
        self.target = target
    }
    
    mutating func update() {
        // 计算弹簧力
        let displacement = target - position
        let springForce = displacement * stiffness
        
        // 计算阻尼力
        let dampingForce = velocity * damping
        
        // 计算加速度 (F = ma)
        let acceleration = (springForce - dampingForce) / mass
        
        // 更新速度和位置
        velocity += acceleration * (1.0/60.0)  // 假设60FPS
        position += velocity * (1.0/60.0)
    }
    
    mutating func setTarget(_ newTarget: Double) {
        target = newTarget
    }
}

// 辅助函数：旋转点
func rotatePoint(x: Double, y: Double, angle: Double) -> (x: Double, y: Double) {
    let cosA = cos(angle)
    let sinA = sin(angle)
    return (
        x: x * cosA - y * sinA,
        y: x * sinA + y * cosA
    )
}

// 辅助函数：检查点是否在三角形内
func isPointInTriangle(px: Double, py: Double, points: [(x: Double, y: Double)]) -> Bool {
    func sign(p1: (x: Double, y: Double), p2: (x: Double, y: Double), p3: (x: Double, y: Double)) -> Double {
        return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y)
    }
    
    let point = (x: px, y: py)
    let d1 = sign(p1: point, p2: points[0], p3: points[1])
    let d2 = sign(p1: point, p2: points[1], p3: points[2])
    let d3 = sign(p1: point, p2: points[2], p3: points[0])
    
    let hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0)
    let hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0)
    
    return !(hasNeg && hasPos)
}

// 辅助函数：绘制16x16字符
func drawChar16x16(graphics: MonoGraphics, x: Int, y: Int, char: Character, color: UInt32) {
    let ascii = Int(char.asciiValue ?? 0)
    if ascii < 0x20 || ascii > 0x7A { 
        print("字符ASCII值超出范围：\(ascii)")
        return 
    }
    
    let charIndex = ascii - 0x20
    if charIndex >= font16x16.count { 
        print("字符索引超出范围：\(charIndex)")
        return 
    }
    
    let charData = font16x16[charIndex]
    print("绘制字符：\(char), ASCII: \(ascii), Index: \(charIndex)")
    
    graphics.setDrawColor(color)
    for row in 0..<16 {
        let rowData = charData[row]
        for col in 0..<16 {
            let mask = UInt16(1 << (15 - col))
            if (rowData & mask) != 0 {
                let pixelX = x + col
                let pixelY = y + row
                if pixelX >= 0 && pixelX < width && pixelY >= 0 && pixelY < height {
                    graphics.drawPixel(x: pixelX, y: pixelY)
                }
            }
        }
    }
}

// 辅助函数：绘制文本
func drawText16x16(graphics: MonoGraphics, x: Int, y: Int, text: String, color: UInt32) {
    var currentX = x
    for char in text {
        drawChar16x16(graphics: graphics, x: currentX, y: y, char: char, color: color)
        currentX += 16
    }
}

func initSDL(width: Int, height: Int) {
    // 初始化SDL视频子系统
    guard SDL_Init(UInt32(SDL_INIT_VIDEO)) == 0 else {
        print("无法初始化SDL: \(String(cString: SDL_GetError()))")
        exit(1)
    }
    
    // 创建窗口
    window = SDL_CreateWindow(
        "MonoGraphics Demo",
        Int32(SDL_WINDOWPOS_CENTERED_MASK),
        Int32(SDL_WINDOWPOS_CENTERED_MASK),
        Int32(width),
        Int32(height),
        0
    )
    
    guard let window = window else {
        print("无法创建窗口: \(String(cString: SDL_GetError()))")
        exit(1)
    }
    
    // 获取窗口表面
    screen = SDL_GetWindowSurface(window)
    
    guard let screen = screen else {
        print("无法创建屏幕表面: \(String(cString: SDL_GetError()))")
        exit(1)
    }
    
    // 获取表面格式
    guard let format = screen.pointee.format else {
        print("无法获取表面格式")
        exit(1)
    }
    
    // 设置颜色
    colors[0] = SDL_MapRGB(format, 0, 0, 0)
    colors[1] = SDL_MapRGB(format, 0, 255, 0)
    colors[2] = SDL_MapRGB(format, 0, 0, 255)
    colors[3] = SDL_MapRGB(format, 255, 0, 0)
    colors[4] = SDL_MapRGB(format, 255, 255, 0)
    
    // 更新窗口表面
    SDL_UpdateWindowSurface(window)
    
    // 注册退出处理
    atexit {
        SDL_Quit()
    }
}

// 初始化SDL
initSDL(width: width, height: height)

// 创建显示表面和图形库实例
let sdlSurface = SDLDisplaySurface(screen: screen, width: width, height: height)
let graphics = MonoGraphics(surface: sdlSurface)

// 主循环
var angle: Double = 0
let centerX = width / 2
let centerY = height / 2
let triangleSize = Double(min(width, height)) * 0.3

// 创建X和Y轴的弹簧动画，设置初始位置
var springAnimationX = SpringAnimation(position: Double(width/2), target: Double(width/2))
var springAnimationY = SpringAnimation(position: Double(height/2), target: Double(height/2))

// 辅助函数：计算三角形的边界框
func getTriangleBoundingBox(points: [(x: Double, y: Double)]) -> (minX: Int, minY: Int, maxX: Int, maxY: Int) {
    let minX = Int(points.map { $0.x }.min()!)
    let maxX = Int(points.map { $0.x }.max()!)
    let minY = Int(points.map { $0.y }.min()!)
    let maxY = Int(points.map { $0.y }.max()!)
    return (minX, minY, maxX, maxY)
}

// 辅助函数：批量设置像素
func batchSetPixels(graphics: MonoGraphics, pixels: [(x: Int, y: Int)]) {
    for pixel in pixels {
        graphics.drawPixel(x: pixel.x, y: pixel.y)
    }
}

while true {
    // 处理事件
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
        switch event.type {
        case SDL_QUIT.rawValue:
            SDL_Quit()
            exit(0)
            
        case SDL_MOUSEBUTTONDOWN.rawValue:
            let mouseX = Int(event.button.x)
            let mouseY = Int(event.button.y)
            
            // 更新弹簧动画的目标位置
            let newTargetX = Double(mouseX - 20)
            let newTargetY = Double(mouseY - 20)
            springAnimationX.setTarget(newTargetX)
            springAnimationY.setTarget(newTargetY)
            
        default:
            break
        }
    }
    
    // 清除屏幕
    graphics.clearBuffer()
    
    // 更新弹簧动画
    springAnimationX.update()
    springAnimationY.update()
    
    // 绘制测试字符（放大版本）
    let testChar = "A"
    let testCharIndex = Int(testChar.first?.asciiValue ?? 0) - 0x20
    if testCharIndex >= 0 && testCharIndex < font16x16.count {
        let charData = font16x16[testCharIndex]
        graphics.setDrawColor(colors[4])
        for row in 0..<16 {
            let rowData = charData[row]
            for col in 0..<16 {
                let mask = UInt16(1 << (15 - col))
                if (rowData & mask) != 0 {
                    // 绘制2x2的像素块
                    let pixelX = 100 + col * 2
                    let pixelY = 100 + row * 2
                    graphics.drawPixel(x: pixelX, y: pixelY)
                    graphics.drawPixel(x: pixelX+1, y: pixelY)
                    graphics.drawPixel(x: pixelX, y: pixelY+1)
                    graphics.drawPixel(x: pixelX+1, y: pixelY+1)
                }
            }
        }
    }
    
    // 绘制普通文本
    drawText16x16(graphics: graphics, x: 10, y: 10, text: "ABCD", color: colors[4])
    drawText16x16(graphics: graphics, x: 10, y: 30, text: "1234", color: colors[4])
    
    // 计算三角形的顶点
    let trianglePoints = [
        rotatePoint(x: 0, y: -triangleSize, angle: angle),
        rotatePoint(x: triangleSize * cos(.pi/6), y: triangleSize * sin(.pi/6), angle: angle),
        rotatePoint(x: -triangleSize * cos(.pi/6), y: triangleSize * sin(.pi/6), angle: angle)
    ].map { (x: $0.x + Double(centerX), y: $0.y + Double(centerY)) }
    
    // 获取正方形位置
    let squareX = Int(springAnimationX.position)
    let squareY = Int(springAnimationY.position)
    
    // 计算三角形的边界框
    let bbox = getTriangleBoundingBox(points: trianglePoints)
    
    // 绘制三角形
    graphics.setDrawColor(colors[1])
    var trianglePixels: [(x: Int, y: Int)] = []
    for y in max(0, bbox.minY)..<min(height, bbox.maxY + 1) {
        for x in max(0, bbox.minX)..<min(width, bbox.maxX + 1) {
            if isPointInTriangle(px: Double(x), py: Double(y), points: trianglePoints) {
                trianglePixels.append((x: x, y: y))
            }
        }
    }
    batchSetPixels(graphics: graphics, pixels: trianglePixels)
    
    // 绘制正方形，处理相交区域
    let squarePixels = (squareY..<(squareY + 40)).flatMap { y in
        (squareX..<(squareX + 40)).map { x in
            (x: x, y: y)
        }
    }
    
    // 分离相交和非相交像素
    var intersectionPixels: [(x: Int, y: Int)] = []
    var nonIntersectionPixels: [(x: Int, y: Int)] = []
    
    for pixel in squarePixels {
        if isPointInTriangle(px: Double(pixel.x), py: Double(pixel.y), points: trianglePoints) {
            intersectionPixels.append(pixel)
        } else {
            nonIntersectionPixels.append(pixel)
        }
    }
    
    // 批量绘制相交像素
    graphics.setDrawColor(colors[3])
    batchSetPixels(graphics: graphics, pixels: intersectionPixels)
    
    // 批量绘制非相交像素
    graphics.setDrawColor(colors[2])
    batchSetPixels(graphics: graphics, pixels: nonIntersectionPixels)
    
    // 更新角度
    angle += 0.02
    
    // 更新显示
    SDL_UpdateWindowSurface(window)
    
    // 控制帧率
    SDL_Delay(16) // 约60FPS
}

// 清理
SDL_DestroyWindow(window)
SDL_Quit()


