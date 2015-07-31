for m in [
        :FixedSizeArrays, :Quaternions,
        :VideoIO, :GLFW, :Reactive, :AbstractGPUArray,
        :FreeTypeAbstraction,:ImageIO
        ]
    Base.compile(m)
end
