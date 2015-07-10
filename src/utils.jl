function include_all(folder::String)
    for file in readdir(folder)
        if endswith(file, ".jl")
            include(joinpath(folder, file))
        end
    end
end

# Splits a dictionary in two dicts, via a condition
function Base.split(condition::Function, associative::Associative)
    A = similar(associative)
    B = similar(associative)
    for (key, value) in associative
        if condition(key, value)
            A[key] = value
        else
            B[key] = value
        end
    end
    A, B
end

#creates methods to accept signals, which then gets transfert to an OpenGL target type
macro visualize_gen(input, target, S)
    esc(quote 
        visualize(value::$input, s::$S, customizations=visualize_default(value, s)) = 
            visualize($target(value), s, customizations)

        function visualize(signal::Signal{$input}, s::$S, customizations=visualize_default(signal.value, s))
            tex = $target(signal.value)
            lift(update!, Input(tex), signal)
            visualize(tex, s, customizations)
        end
    end)
end


# scalars can be uploaded directly to gpu, but not arrays
texture_or_scalar(x) = x
texture_or_scalar(x::Array) = Texture(x)
function texture_or_scalar{A <: Array}(x::Signal{A})
    tex = Texture(x.value)
    lift(update!, tex, x)
    tex
end

isnotempty(x) = !isempty(x)
AND(a,b) = a&&b

GeometryTypes.AABB(a::GPUArray) = AABB(gpu_data(a))

function GLVisualizeShader(shaders...; attributes...)
    shaders = map(shader -> File(shaderdir, shader), shaders)
    TemplateProgram(shaders...;
        attributes...,  fragdatalocation=[(0, "fragment_color"), (1, "fragment_groupid")]
    )
end

function assemble_std(main, dict, shaders...; boundingbox=Input(AABB{Float32}(AABB(main))), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    std_renderobject(dict, program, boundingbox, primitive)
end

function assemble_instanced(main, dict, shaders...; boundingbox=Input(AABB{Float32}(AABB(main))), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    instanced_renderobject(dict, length(main), program, boundingbox, primitive)
end

function assemble_instanced(main::GPUVector, dict, shaders...; boundingbox=Input(AABB{Float32}(AABB(main))), primitive=GL_TRIANGLES)
    program = GLVisualizeShader(shaders..., attributes=dict)
    instanced_renderobject(dict, main, program, boundingbox, primitive)
end