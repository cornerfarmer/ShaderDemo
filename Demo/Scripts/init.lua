
-- Load libs
lib_dir = gh_utils.get_scripting_libs_dir()
dofile(lib_dir .. "lua/gx_cam_lib_v1.lua")


-- +++++++++++++++ Load models +++++++++++++++
-- Build absolute paths
local demo_dir = gh_utils.get_scenegraph_dir()
local model_directory = demo_dir .. "Assets/"
-- Set loader to v2
gh_model.set_current_3d_obj_loader("ObjLoaderV2")

-- Load the lamppost
lamppost = gh_model.create_from_file_loader_obj("Lamppost.obj", model_directory, model_directory)
if (lamppost > 0) then
	-- Textures
	gh_model.load_textures(lamppost, model_directory)
	lamppost_norm_tex = gh_texture.create_from_file_v2(model_directory .. "Metal_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(lamppost, 2.5, 0.2, 0)
	gh_object.set_euler_angles(lamppost, 0, 0, 0)
	gh_object.set_scale(lamppost, 1, 1, 1)
end  

-- Load the lamppost glas
lamppostGlas = gh_model.create_from_file_loader_obj("LamppostGlas.obj", model_directory, model_directory)
if (lamppostGlas > 0) then
	-- Textures
	gh_model.load_textures(lamppostGlas, model_directory)
	lamppostGlas_tex = gh_texture.create_from_file_v2(model_directory .. "Glas.png", 3, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(lamppostGlas, 2.5, 0.2, 0)
	gh_object.set_euler_angles(lamppostGlas, 0, 0, 0)
	gh_object.set_scale(lamppostGlas, 1, 1, 1)
end  

-- Load the street
street = gh_model.create_from_file_loader_obj("road.obj", model_directory, model_directory)
if (street > 0) then
	-- Textures
	gh_model.load_textures(street, model_directory)
	street_norm_tex = gh_texture.create_from_file_v2(model_directory .. "Roads0069_1_S_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(street, -2, 0, 0)
	gh_object.set_euler_angles(street, 0, 0, 0)
	gh_object.set_scale(street, 1, 1, 1)
	-- Recompute normals for better lightning
	gh_object.compute_faces_normal(street)
	gh_object.compute_vertices_normal(street)
end  

-- Load the sidewalk
sidewalk = gh_model.create_from_file_loader_obj("sidewalk.obj", model_directory, model_directory)
if (sidewalk > 0) then
	-- Textures
	gh_model.load_textures(sidewalk, model_directory)
	sidewalk_norm_tex = gh_texture.create_from_file_v2(model_directory .. "FloorStreets_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(sidewalk, 3.75, 0.15, 0)
	gh_object.set_euler_angles(sidewalk, 0, 0, 0)
	gh_object.set_scale(sidewalk, 1, 1, 1)
	-- Recompute normals for better lightning
	gh_object.compute_faces_normal(sidewalk)
	gh_object.compute_vertices_normal(sidewalk)
end  

-- Load the wall
wall = gh_model.create_from_file_loader_obj("wall.obj", model_directory, model_directory)
if (wall > 0) then
	-- Textures
	gh_model.load_textures(wall, model_directory)
	wall_norm_tex = gh_texture.create_from_file_v2(model_directory .. "BrickSmallBrown0257_1_S_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(wall, 5.8, 2.09, 0)
	gh_object.set_euler_angles(wall, 0, 0, 0)
	gh_object.set_scale(wall, 1, 1, 1)
	-- Recompute normals for better lightning
	gh_object.compute_faces_normal(wall)
	gh_object.compute_vertices_normal(wall)
end  

-- Load the wooden box
box = gh_model.create_from_file_loader_obj("WoodenBoxOpen02.obj", model_directory, model_directory)
if (box > 0) then
	-- Textures
	gh_model.load_textures(box, model_directory)
	box_norm_tex = gh_texture.create_from_file_v2(model_directory .. "WoodPlanks_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(box, 4.5, 1.5, -5)
	gh_object.set_euler_angles(box, 180, 0, 0)
	gh_object.set_scale(box, 2.3, 2.3, 2.3)
end  

-- Load the aircondition
aircondition = gh_model.create_from_file_loader_obj("AIRCONDITION.obj", model_directory, model_directory)
if (aircondition > 0) then
	-- Textures
	gh_model.load_textures(aircondition, model_directory)
	aircondition_norm_tex = gh_texture.create_from_file_v2(model_directory .. "AIRCONDITIONED_Normal.jpg", PF_U8_RGB, 1, 1)
	-- Translate, rotate and scale
	gh_object.set_position(aircondition, 5.5, 6, 4)
	gh_object.set_euler_angles(aircondition, 0, 0, 0)
	gh_object.set_scale(aircondition, 1, 1, 1)
end  
-- Fullscreen quad
fullscreen_quad = gh_mesh.create_quad(800, 600)
  
-- +++++++++++++++ Load shaders +++++++++++++++
-- Main scene
shaderMain = gh_gpu_program.create_from_file("Shader/mainShader.glsl", 0)
gh_node.set_name(shaderMain, "shaderMain")
-- Shadow map
shaderShadowMap = gh_gpu_program.create_from_file("Shader/shaderShadowMap.glsl", 0)
gh_node.set_name(shaderShadowMap, "shaderShadowMap")
-- Shadow map viewer
shaderShadowMapViewer = gh_gpu_program.create_from_file("Shader/shaderShadowMapViewer.glsl", 0)
gh_node.set_name(shaderShadowMapViewer, "shaderShadowMapViewer")

-- +++++++++++++++ Create render target +++++++++++++++
shadowMap_w = 4096
shadowMap_h = 4096
shadowMap = gh_render_target.create(shadowMap_w, shadowMap_h)

-- +++++++++++++++ Init lights +++++++++++++++
lightDegree = math.pi / 2 * 3
lightSource = { - 10, 10, 0 }
lightLookAt = { 0, 0, 0 }

-- +++++++++++++++ Init cameras +++++++++++++++
winW, winH = gh_window.getsize(0)
-- Main camera
camera = gx_camera.create_perspective(60, 1, 0, 0, winW, winH, 0.1, 1000)
gh_camera.set_position(camera, 5, 5, 5)
camera_lookat_x = 0
camera_lookat_y = 5
camera_lookat_z = 3
gx_camera.init_orientation(camera, camera_lookat_x, camera_lookat_y, camera_lookat_z, 20, 170)
gx_camera.set_mode_orbit()
gx_camera.set_orbit_lookat(camera, camera_lookat_x, camera_lookat_y, camera_lookat_z)
gx_camera.set_keyboard_speed(10.0)
-- Light camera
camera_light = gx_camera.create_perspective(90, 1, 0, 0, shadowMap_w, shadowMap_h, 0.1, 1000)
gx_camera.init_orientation(camera_light, lightLookAt[1], lightLookAt[2], lightLookAt[3], 20, 170)
-- Ortho camera for 2d overlay rendering
camera_ortho = gh_camera.create_ortho(- winW / 2, winW / 2, - winH / 2, winH / 2, 1.0, 10.0)
gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)
gh_camera.set_position(camera_ortho, 0, 0, 2)

-- +++++++++++++++ Other render options +++++++++++++++
gh_renderer.set_vsync(1)
last_time = gh_utils.get_elapsed_time()
graphicsMode = 1
showShadowMap = false
paused = false
pausedPressed = false