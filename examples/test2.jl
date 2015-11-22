using Test

using GLFW, GLWindow
const GL_TRUE = convert(Cuint, 1)
GLFW.Init()
windowhints=[(GLFW.SAMPLES, 4)]

for elem in windowhints
    GLFW.WindowHint(elem...)
end
w,h,name = 10,10,"lol"
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MAJOR, 3)
GLFW.WindowHint(GLFW.CONTEXT_VERSION_MINOR, 3)
GLFW.WindowHint(GLFW.OPENGL_FORWARD_COMPAT, GL_TRUE)
GLFW.WindowHint(GLFW.OPENGL_PROFILE, GLFW.OPENGL_CORE_PROFILE)
window = GLFW.CreateWindow(w, h, name)
GLFW.MakeContextCurrent(window)
GLFW.ShowWindow(window)

a = GLuint[1]
fb = glGenFramebuffers(1, a)
glBindFramebuffer(GL_FRAMEBUFFER, a[])