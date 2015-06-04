using GLVisualize, AbstractGPUArray, GLAbstraction, GeometryTypes, Reactive, ColorTypes
using Meshes, MeshIO, FileIO, WavefrontObj, GLFW

global const T = Float32
function fold_pivot(v0, v1)
	xt, yt, zt, translation = v1

	xrot = Quaternions.qrotation(v0.xaxis, xt)
	yrot = Quaternions.qrotation(v0.yaxis, yt)
	zrot = Quaternions.qrotation(v0.zaxis, zt)

	v1rot = zrot*xrot*yrot

	Pivot(v0.origin, v0.xaxis, v0.yaxis, v0.zaxis, v1rot, translation, v0.scale)
end

function getmodel(xtheta, ytheta, ztheta, translation)
	origin 			= Vec3(0)
	xaxis 			= Vec3(1,0,0)
	yaxis 			= Vec3(0,1,0)
	zaxis 			= Vec3(0,0,1)
	translate 		= Vector3{T}(0,0,0)
	p0 				= Pivot(origin, xaxis, yaxis, zaxis, Quaternions.Quaternion(1f0,0f0,0f0,0f0), translate, Vector3{T}(1))
	pivot 			= foldl(fold_pivot, p0, lift(tuple, xtheta, ytheta, ztheta, translation))

	modelmatrix 	= lift(transformationmatrix, pivot)
end

const inputs = GLVisualize.ROOT_SCREEN.inputs

const mouse_hover = lift(first,GLVisualize.SELECTION[:mouse_hover])

function mousedragg_fold(t0, mouse_down1, mouseposition1, objectid)
	mouse_down0, draggstart, objectidstart, mouseposition0 = t0
	if !mouse_down0 && mouse_down1
		return (mouse_down1, mouseposition1, objectid, mouseposition1)
	elseif mouse_down0 && mouse_down1
		return (mouse_down1, draggstart, objectidstart, mouseposition1)
	end
	(false, Vec2(0), Vector2(0), Vec2(0))
end
isnotempty(x) = !isempty(x)
function diff_mouse(mouse_down_draggstart_mouseposition)
	mouse_down, draggstart, objectidstart, mouseposition = mouse_down_draggstart_mouseposition
	(draggstart - mouseposition, objectidstart)
end
function get_drag_diff(inputs)
	@materialize mousebuttonspressed, mousereleased, mouseposition = inputs
	mousedown = lift(isnotempty, mousebuttonspressed)
	mousedraggdiff = lift(diff_mouse, 
						foldl(mousedragg_fold, (false, Vec2(0), Vector2(0), Vec2(0)), mousedown, mouseposition, mouse_hover))
	return keepwhen(mousedown, (Vec2(0), Vector2(0)), mousedraggdiff)
end

AND(a,b) = a&&b
leftmousedown_lift(mousebuttons) = length(mousebuttons) == 1 && first(mousebuttons)
ctrldown_lift(keyboardkeys) 	 = length(keyboardkeys) == 1 && first(keyboardkeys) == GLFW.KEY_LEFT_CONTROL
leftdown = lift(leftmousedown_lift, inputs[:mousebuttonspressed])
ctrldown = lift(ctrldown_lift, inputs[:buttonspressed])
leftdown_ctrldown = lift(AND, leftdown, ctrldown)

iscat(x) = x[1] == 3

is_cat 	= lift(iscat, mouse_hover)



function cat_gizmo_fold(gizmo_started, iscat, ctrdown)
	(gizmo_started && !ctrdown) && return false
	gizmo_started && return true
	(!gizmo_started && ctrdown && iscat) && return true
	false
end
cat_gizmo = foldl(cat_gizmo_fold, false,  is_cat, ctrldown)





dirlen 	= 1f0
const baselen = Vec3(0.04f0)
const gizmo_directions = [
	Vec3(1,0,0), Vec3(0,1,0), Vec3(0,0,1),
	Vec3(-1,0,0), Vec3(0,-1,0), Vec3(0,0,-1),
]
gizmo_mesh = map(gizmo_directions) do dir
	inverted  = dir .!= Vec3(1)
	cube_size = dir + (baselen.*inverted)
	GLNormalMesh((Cube(baselen, cube_size), RGBA(abs(dir)..., 1f0)))
end


gizmo_mesh = merge(gizmo_mesh)


const gizmo = visualize(gizmo_mesh, visible=cat_gizmo)

function gizmodir_lift(draggdiff_id)
	(dragg, (id, index)) = draggdiff_id
	if id == gizmo.alluniforms[:objectid]
		return gizmo_directions[index+1]*dragg.x
	end
	Vec3(0)
end
const dragdiff_id = get_drag_diff(inputs)
gizmo_dir = lift(/, lift(gizmodir_lift, dragdiff_id), 10f0)

model 	= getmodel(Input(0f0), Input(0f0), Input(0f0), gizmo_dir)


msh 	= GLNormalMesh(file"cat.obj")

robj 	= visualize(msh, model=model)
gizmo[:model] = model

push!(GLVisualize.ROOT_SCREEN.renderlist, robj)
push!(GLVisualize.ROOT_SCREEN.renderlist, gizmo)

renderloop()