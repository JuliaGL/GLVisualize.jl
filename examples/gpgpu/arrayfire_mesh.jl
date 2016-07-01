# Needs CXX, Julia-0.5
ENV["PATH"]="/usr/local/cuda-7.5/bin:"*ENV["PATH"]
ENV["LD_LIBRARY_PATH"]="/usr/local/cuda-7.5/lib64:/usr/local/cuda/nvvm/lib64:"*get(ENV,"LD_LIBRARY_PATH","")
ENV["AFMODE"] = "CUDA"  # this example works with CUDA
using ArrayFire, CUDArt, GLAbstraction, Cxx, ModernGL


type CUDAGLBuffer{T} <: GPUArray{T, 1}
    buffer::GLBuffer{T}
    graphics_resource::Ref{CUDArt.rt.cudaGraphicsResource_t}
    ismapped::Bool
end

function CUDAGLBuffer(buffer::GLBuffer, flag = 0)
    cuda_resource = Ref{CUDArt.rt.cudaGraphicsResource_t}(C_NULL)
    CUDArt.rt.cudaGraphicsGLRegisterBuffer(cuda_resource, buffer.id, flag)
    CUDAGLBuffer(buffer, cuda_resource, false)
end
function map_resource(buffer::CUDAGLBuffer)
    if !buffer.ismapped
        CUDArt.rt.cudaGraphicsMapResources(1, buffer.graphics_resource, C_NULL)
        buffer.ismapped = true;
    end
    nothing
end

function unmap_resource(buffer::CUDAGLBuffer)
    if buffer.ismapped
        CUDArt.rt.cudaGraphicsUnmapResources(1, buffer.graphics_resource, C_NULL)
        buffer.ismapped = false
    end
    nothing
end

function copy_from_device_pointer{T}(
        cuda_mem_ptr::Ptr{T},
        cuda_gl_buffer::CUDAGLBuffer,
    )
    map_resource(cuda_gl_buffer)
    buffersize = length(cuda_gl_buffer.buffer)*sizeof(eltype(cuda_gl_buffer.buffer))
    if cuda_gl_buffer.buffer.buffertype == GL_RENDERBUFFER
        array_ptr = Ref{CUDArt.rt.cudaArray_t}(C_NULL)
        CUDArt.rt.cudaGraphicsSubResourceGetMappedArray(array_ptr, cuda_gl_buffer.graphics_resource[], 0, 0)
        CUDArt.rt.cudaMemcpyToArray(array_ptr[], 0, 0, cuda_mem_ptr, buffersize, CUDArt.rt.cudaMemcpyDeviceToDevice)
    else
        opengl_ptr = Ref{Ptr{Void}}(C_NULL); size_ref = Ref{Csize_t}(buffersize)
        CUDArt.rt.cudaGraphicsResourceGetMappedPointer(opengl_ptr, size_ref, cuda_gl_buffer.graphics_resource[])
        CUDArt.rt.cudaMemcpy(opengl_ptr[], cuda_mem_ptr, buffersize, CUDArt.rt.cudaMemcpyDeviceToDevice)
    end
    unmap_resource(cuda_gl_buffer)
end

"""
 Gets the device pointer from the mapped resource
 Sets is_mapped to true
"""
function copy_to_device_pointer{T}(
        cuda_mem_ptr::Ptr{T},
        cuda_gl_buffer::CUDAGLBuffer,
    )
    map_resource(cuda_gl_buffer)
    is_mapped = true
    buffersize = length(cuda_gl_buffer.buffer)*sizeof(eltype(cuda_gl_buffer.buffer))
    if cuda_gl_buffer.buffer.buffertype == GL_RENDERBUFFER
        array_ptr = Ref{CUDArt.rt.cudaArray_t}(C_NULL);
        CUDArt.rt.cudaGraphicsSubResourceGetMappedArray(array_ptr, cuda_gl_buffer.graphics_resource[], 0, 0)
        CUDArt.rt.cudaMemcpyFromArray(cuda_mem_ptr, array_ptr[], 0, 0, buffersize, CUDArt.rt.cudaMemcpyDeviceToDevice)
    else
        opengl_ptr = Ref{Ptr{Void}}(C_NULL); size_ref = Ref{Csize_t}(buffersize)
        CUDArt.rt.cudaGraphicsResourceGetMappedPointer(opengl_ptr, size_ref, cuda_gl_buffer.graphics_resource[])
        CUDArt.rt.cudaMemcpy(cuda_mem_ptr, opengl_ptr, buffersize, CUDArt.rt.cudaMemcpyDeviceToDevice)
    end
    unmap_resource(cuda_gl_buffer)
end

# ArrayFire.AFArray
function Base.copy(source::ArrayFire.AFArray, target::CUDAGLBuffer)
    d_ptr = ArrayFire.af_device(source)
    copy_from_device_pointer(d_ptr, target)
end
function Base.copy(source::CUDAGLBuffer, target::ArrayFire.AFArray)
    d_ptr = ArrayFire.af_device(target)
    copy_to_device_pointer(d_ptr, target)
end




using GLVisualize, GeometryTypes, Colors
w=glscreen();@async renderloop(w)
cat = loadasset("cat.obj")
colors = RGBA{Float32}[RGBA{Float32}(rand(), rand(), rand(), 1) for i=1:length(vertices(cat))]
catmesh = GLNormalVertexcolorMesh(
    vertices=vertices(cat), faces=faces(cat), normals=normals(cat),
    color=colors
)
_view(visualize(catmesh))

vertsvec = reinterpret(Float32, vertices(cat), (3,length(vertices(cat))));
colorsvec = reinterpret(Float32, colors, (4,length(colors)));
af_vertices = AFArray(vertsvec)
af_colors = AFArray(colorsvec)

gl_verts = w.renderlist[1][1][:vertices]
gl_colors = w.renderlist[1][1][:color]

cu_gl_verts = CUDAGLBuffer(gl_verts)
cu_gl_colors = CUDAGLBuffer(gl_colors)
b = af_vertices .* 2f0
copy(b, cu_gl_verts)
