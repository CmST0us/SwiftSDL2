import SDL2
import GLEW

func sdldie(_ msg: String) {
    print("\(msg): \(String(cString: SDL_GetError()))")
    SDL_Quit()
    exit(1)
}

func checkSDLError(line: Int = -1) {
    if let error = String(validatingUTF8: SDL_GetError()), !error.isEmpty {
        print("SDL Error: \(error)")
        if line != -1 {
            print(" + line: \(line)")
        }
        SDL_ClearError()
    }
}

let PROGRAM_NAME = "OpenGL Triangle"

var mainwindow: OpaquePointer?
var maincontext: SDL_GLContext?

if SDL_Init(SDL_INIT_VIDEO) < 0 {
    sdldie("Unable to initialize SDL")
}

SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3)
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2)
SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24)

mainwindow = SDL_CreateWindow(PROGRAM_NAME, Int32(SDL_WINDOWPOS_CENTERED_MASK), Int32(SDL_WINDOWPOS_CENTERED_MASK),
                              512, 512, SDL_WINDOW_OPENGL.rawValue | SDL_WINDOW_SHOWN.rawValue)

var wmInfo: SDL_SysWMinfo = SDL_SysWMinfo()
wmInfo.version.major = UInt8(SDL_MAJOR_VERSION)
wmInfo.version.minor = UInt8(SDL_MINOR_VERSION)
wmInfo.version.patch = UInt8(SDL_PATCHLEVEL)

let result = SDL_GetWindowWMInfo(mainwindow, &wmInfo)
print("Get Window WM Info result: \(result)")

if wmInfo.subsystem == SDL_SYSWM_WAYLAND {
    print("Run on wayland")
} else if wmInfo.subsystem == SDL_SYSWM_X11 {
    print("Run on x11")
}


if mainwindow == nil {
    sdldie("Unable to create window")
}

checkSDLError(line: #line)

maincontext = SDL_GL_CreateContext(mainwindow)
checkSDLError(line: #line)

glewExperimental = GLboolean(GL_TRUE);
if (glewInit() != GLEW_OK) {
    print("Failed to initialize GLEW")
}

SDL_GL_MakeCurrent(mainwindow, maincontext)

glEnable(GLenum(GL_BLEND))
glBlendFunc(GLenum(GL_SRC_ALPHA), GLenum(GL_ONE_MINUS_SRC_ALPHA))

// Vertex shader source
let vertexSource = """
#version 150 core
in vec2 position;
void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
}
"""

// Fragment shader source
let fragmentSource = """
#version 150 core
out vec4 outColor;
void main()
{
    outColor = vec4(0.0, 1.0, 0.0, 1.0);
}
"""

// Compile vertex shader
let vertexShader = glCreateShader(GLenum(GL_VERTEX_SHADER))
vertexSource.withCString { source in
    var src: UnsafePointer<GLchar>? = source
    glShaderSource(vertexShader, 1, &src, nil)
}
glCompileShader(vertexShader)

// Compile fragment shader
let fragmentShader = glCreateShader(GLenum(GL_FRAGMENT_SHADER))
fragmentSource.withCString { source in
    var src: UnsafePointer<GLchar>? = source
    glShaderSource(fragmentShader, 1, &src, nil)
}
glCompileShader(fragmentShader)


// Link shaders into a program
let shaderProgram = glCreateProgram()
glAttachShader(shaderProgram, vertexShader)
glAttachShader(shaderProgram, fragmentShader)
glLinkProgram(shaderProgram)
glUseProgram(shaderProgram)

// Vertex data for a triangle
let vertices: [GLfloat] = [
    0.0,  0.5,
   -0.5, -0.5,
    0.5, -0.5
]

// Create a vertex buffer object (VBO)
var vbo: GLuint = 0
glGenBuffers(1, &vbo)
glBindBuffer(GLenum(GL_ARRAY_BUFFER), vbo)
glBufferData(GLenum(GL_ARRAY_BUFFER), vertices.count * MemoryLayout<GLfloat>.size, vertices, GLenum(GL_STATIC_DRAW))

// Create a vertex array object (VAO)
var vao: GLuint = 0
glGenVertexArrays(1, &vao)
glBindVertexArray(vao)

// Specify the layout of the vertex data
let posAttrib = GLuint(glGetAttribLocation(shaderProgram, "position"))
glEnableVertexAttribArray(posAttrib)
glVertexAttribPointer(posAttrib, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), 2 * GLsizei(MemoryLayout<GLfloat>.size), nil)

var running = true
while running {
    var event = SDL_Event()
    while SDL_PollEvent(&event) != 0 {
        if event.type == SDL_QUIT.rawValue {
            running = false
        }
    }

    // Clear the screen
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glClear(GLenum(GL_COLOR_BUFFER_BIT))

    // Draw the triangle
    glDrawArrays(GLenum(GL_TRIANGLES), 0, 3)

    // Swap buffers
    SDL_GL_SwapWindow(mainwindow)
}

// Clean up
glDeleteProgram(shaderProgram)
glDeleteShader(vertexShader)
glDeleteShader(fragmentShader)
glDeleteBuffers(1, &vbo)
glDeleteVertexArrays(1, &vao)

SDL_GL_DeleteContext(maincontext)
SDL_DestroyWindow(mainwindow)
SDL_Quit()
