using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes
using Meshes, MeshIO, FileIO, WavefrontObj, GLFW

global const T = Float32
function fold_pivot(v0, v1)
	xt, yt, zt, xtr, ytr, ztr = v1

	xrot = Quaternions.qrotation(v0.xaxis, xt)
	yrot = Quaternions.qrotation(v0.yaxis, yt)
	zrot = Quaternions.qrotation(v0.zaxis, zt)

	v1rot = zrot*xrot*yrot

	Pivot(v0.origin, v0.xaxis, v0.yaxis, v0.zaxis, v1rot, Vec3(xtr, ytr, ztr), v0.scale)
end

function getmodel(xtheta, ytheta, ztheta, xtrans, ytrans, ztrans)
	origin 			= Vec3(0)
	xaxis 			= Vec3(1,0,0)
	yaxis 			= Vec3(0,1,0)
	zaxis 			= Vec3(0,0,1)
	translate 		= Vector3{T}(0,0,0)
	p0 				= Pivot(origin, xaxis, yaxis, zaxis, Quaternions.Quaternion(1f0,0f0,0f0,0f0), translate, Vector3{T}(1))
	pivot 			= foldl(fold_pivot, p0, lift(tuple, xtheta, ytheta, ztheta, xtrans, ytrans, ztrans))

	modelmatrix 	= lift(transformationmatrix, pivot)
end

inputs = GLVisualize.ROOT_SCREEN.inputs


function mousedragg_fold(t0, mouse_down1, mouseposition1)
	mouse_down0, draggstart, mouseposition0 = t0
	if !mouse_down0 && mouse_down1
		return (mouse_down1, mouseposition1, mouseposition1)
	elseif mouse_down0 && mouse_down1
		return (mouse_down1, draggstart, mouseposition1)
	end
	(false, Vec2(0), Vec2(0))
end
isnotempty(x) = !isempty(x)
function diff_mouse(mouse_down_draggstart_mouseposition)
	mouse_down, draggstart, mouseposition = mouse_down_draggstart_mouseposition
	draggstart - mouseposition
end
function get_diff(inputs)
	@materialize mousebuttonspressed, mousereleased, mouseposition = inputs
	mousedown = lift(isnotempty, mousebuttonspressed)
	mousedraggdiff = lift(diff_mouse, 
						foldl(mousedragg_fold, (false, Vec2(0), Vec2(0)), mousedown, mouseposition))
	return keepwhen(mousedown, Vec2(0), mousedraggdiff)
end
t = lift(first, get_diff(inputs))


leftdown_ctrldown_lift(mousebuttons, keyboardkeys) = length(mousebuttons) == 1 && first(mousebuttons) == 0 && length(keyboardkeys) == 1 && first(keyboardkeys) == GLFW.KEY_LEFT_CONTROL
leftdown_ctrldown = lift(leftdown_ctrldown_lift, inputs[:mousebuttonspressed], inputs[:buttonspressed])
t = keepwhen(leftdown_ctrldown, 0f0, t)
lift(println, t)
iscat(x) = x[1] == 2
mouse_hover = lift(first,GLVisualize.SELECTION[:mouse_hover])
is_cat 	= lift(iscat, mouse_hover)
t_trans = keepwhen(is_cat, 0f0, t)

model 	= getmodel(Input(0f0), Input(0f0), Input(0f0), lift(/,t_trans, 10f0), Input(0f0), Input(0f0))

msh 	= GLNormalMesh(file"cat.obj")
robj 	= visualize(msh, model=model)
push!(GLVisualize.ROOT_SCREEN.renderlist, robj)

renderloop()