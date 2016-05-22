
lib_dir = gh_utils.get_scripting_libs_dir()
dofile(lib_dir .. "lua/gx_cam_lib_v1.lua")


winW, winH = gh_window.getsize(0)
camera = gx_camera.create_perspective(60, 1, 0, 0, winW, winH, 0.1, 1000)
gh_camera.set_position(camera, 5, 5, 5)
camera_lookat_x = 0
camera_lookat_y = 5
camera_lookat_z = 3
gx_camera.init_orientation(camera, camera_lookat_x, camera_lookat_y, camera_lookat_z, 20, 170)
gx_camera.set_mode_orbit()
orbit_mode = 1
keyboard_speed = 10.0
camera_fov = 60.0
gx_camera.set_orbit_lookat(camera, camera_lookat_x, camera_lookat_y, camera_lookat_z)
gx_camera.set_keyboard_speed(keyboard_speed)
gh_model.set_current_3d_obj_loader("ObjLoaderV2")
cube_size = 1
local demo_dir = gh_utils.get_scenegraph_dir()
local model_directory = demo_dir .. "Assets/"
model = gh_model.create_from_file_loader_obj("Lamppost.obj", model_directory, model_directory)
street = gh_model.create_from_file_loader_obj("road.obj", model_directory, model_directory)
sidewalk = gh_model.create_from_file_loader_obj("sidewalk.obj", model_directory, model_directory)
wall = gh_model.create_from_file_loader_obj("wall.obj", model_directory, model_directory)
box = gh_model.create_from_file_loader_obj("WoodenBoxOpen02.obj", model_directory, model_directory)
aircondition = gh_model.create_from_file_loader_obj("AIRCONDITION.obj", model_directory, model_directory)
if (model > 0) then
	gh_model.load_textures(model, model_directory)

	model_norm_tex = gh_texture.create_from_file_v2(model_directory .. "Metal_Normal.jpg", PF_U8_RGB, 1, 1)

	gh_object.set_materials_texture_unit_offset(model, 0)

	gh_object.set_position(model, 2.5, 0.2, 0)
	gh_object.set_euler_angles(model, 0, 0, 0)
	gh_object.set_scale(model, 1, 1, 1)

end  
if (street > 0) then
	gh_model.load_textures(street, model_directory)

	street_norm_tex = gh_texture.create_from_file_v2(model_directory .. "Roads0069_1_S_Normal.jpg", PF_U8_RGB, 1, 1)

	gh_object.set_materials_texture_unit_offset(street, 0)

	gh_object.set_position(street, -2, 0, 0)
	gh_object.set_euler_angles(street, 0, 0, 0)
	gh_object.set_scale(street, 1, 1, 1)

	gh_object.compute_faces_normal(street)
	gh_object.compute_vertices_normal(street)
end  
if (sidewalk > 0) then
	gh_model.load_textures(sidewalk, model_directory)
	gh_object.set_materials_texture_unit_offset(sidewalk, 0)

	sidewalk_norm_tex = gh_texture.create_from_file_v2(model_directory .. "FloorStreets_Normal.jpg", PF_U8_RGB, 1, 1)

	gh_object.set_position(sidewalk, 3.75, 0.15, 0)
	gh_object.set_euler_angles(sidewalk, 0, 0, 0)
	gh_object.set_scale(sidewalk, 1, 1, 1)

	gh_object.compute_faces_normal(sidewalk)
	gh_object.compute_vertices_normal(sidewalk)
end  
if (wall > 0) then
	gh_model.load_textures(wall, model_directory)

	wall_norm_tex = gh_texture.create_from_file_v2(model_directory .. "BrickSmallBrown0257_1_S_Normal.jpg", PF_U8_RGB, 1, 1)
	width, height, depth = gh_texture.get_size(wall_norm_tex)
	gh_utils.trace(width .. "," .. height .. "," .. depth)
	gh_object.set_materials_texture_unit_offset(wall, 0)

	gh_object.set_position(wall, 5.8, 2.09, 0)
	gh_object.set_euler_angles(wall, 0, 0, 0)
	gh_object.set_scale(wall, 1, 1, 1)

	gh_object.compute_faces_normal(wall)
	gh_object.compute_vertices_normal(wall)
end  
if (box > 0) then
	gh_model.load_textures(box, model_directory)

	box_norm_tex = gh_texture.create_from_file_v2(model_directory .. "WoodPlanks_Normal.jpg", PF_U8_RGB, 1, 1)

	gh_object.set_materials_texture_unit_offset(box, 0)

	gh_object.set_position(box, 4.5, 1.5, -5)
	gh_object.set_euler_angles(box, 180, 0, 0)
	gh_object.set_scale(box, 2.3, 2.3, 2.3)

end  
if (aircondition > 0) then
	gh_model.load_textures(aircondition, model_directory)

	aircondition_norm_tex = gh_texture.create_from_file_v2(model_directory .. "AIRCONDITIONED_Normal.jpg", PF_U8_RGB, 1, 1)

	gh_object.set_materials_texture_unit_offset(aircondition, 0)

	gh_object.set_position(aircondition, 5.5, 6, 4)
	gh_object.set_euler_angles(aircondition, 0, 0, 0)
	gh_object.set_scale(aircondition, 1, 1, 1)

end  
  
	
shader_prog = gh_gpu_program.create_from_file("shader.glsl", 0)
gh_node.set_name(shader_prog, "shader_prog")

shader_shadowMap = gh_gpu_program.create_from_file("shader_shadowMap.glsl", 0)
gh_node.set_name(shader_shadowMap, "shader_shadowMap")

gh_renderer.set_vsync(1)
shadowMap_w = 4096
shadowMap_h = 4096
shadowMap = gh_render_target.create(shadowMap_w, shadowMap_h)

lightDegree = math.pi / 2 * 3
lightSource = { - 10, 10, 0 }
lightLookAt = { 0, 0, 0 }

camera_light = gx_camera.create_perspective(90, 1, 0, 0, shadowMap_w, shadowMap_h, 0.1, 1000)
gx_camera.init_orientation(camera_light, lightLookAt[1], lightLookAt[2], lightLookAt[3], 20, 170)

last_time = gh_utils.get_elapsed_time()

camera_ortho = gh_camera.create_ortho(- winW / 2, winW / 2, - winH / 2, winH / 2, 1.0, 10.0)
gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)
gh_camera.set_position(camera_ortho, 0, 0, 2)

shadowmap_viewer_prog = gh_gpu_program.create_from_file("shadowmap_viewer.glsl", 0)
gh_node.set_name(shadowmap_viewer_prog, "shadowmap_viewer_prog") -- useful for the live coding manager. 

fullscreen_quad = gh_mesh.create_quad(800, 600)
