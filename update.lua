
local elapsed_time = gh_utils.get_elapsed_time()
local dt = elapsed_time - last_time
last_time = elapsed_time

local KC_LEFT = 203
local KC_RIGHT = 205
local is_down = gh_input.keyboard_is_key_down(KC_RIGHT)
if (is_down == 1) then
	lightDegree = lightDegree + dt * 0.6
end
if (gh_input.keyboard_is_key_down(KC_LEFT) == 1) then
	lightDegree = lightDegree - dt * 0.6
	gh_utils.trace("L " .. lightSource[1] .. "," .. lightSource[3])
end
lightSource[1] = math.sin(lightDegree) * 10
lightSource[3] = math.cos(lightDegree) * 10

gh_camera.set_position(camera_light, lightSource[1], lightSource[2], lightSource[3])
gh_camera.set_lookat(camera_light, lightLookAt[1], lightLookAt[2], lightLookAt[3], 1)
gx_camera.update(camera, dt)


gh_render_target.bind(shadowMap)
gh_camera.bind(camera_light)

gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
gh_renderer.set_depth_test_state(1)

gh_gpu_program.bind(shader_shadowMap)
gh_object.render(model)
gh_object.render(street)
gh_object.render(sidewalk)
gh_object.render(wall)
gh_object.render(box)
gh_object.render(aircondition)
gh_gpu_program.bind(0)

gh_render_target.unbind(shadowMap)


gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
gh_renderer.set_depth_test_state(1)

gh_camera.bind(camera)
gh_gpu_program.bind(shader_prog)
gh_gpu_program.uniform4f(shader_prog, "lightDir", lightLookAt[1] - lightSource[1], lightLookAt[2] - lightSource[2], lightLookAt[3] - lightSource[3], 0)
gh_gpu_program.uniform4f(shader_prog, "lightPos", lightSource[1], lightSource[2], lightSource[3], 0)
gh_gpu_program.uniform1f(shader_prog, "lightPower", 1.2)
gh_gpu_program.uniform4f(shader_prog, "camera", gh_camera.get_view(camera))
gh_gpu_program.uniform_camera_matrices(shader_prog, camera_light, "lightViewMatrix", "lightProjectionMatrix")
gh_gpu_program.uniform1i(shader_prog, "tex0", 0)
gh_gpu_program.uniform1i(shader_prog, "tex1", 1)
gh_gpu_program.uniform1i(shader_prog, "shadowMap", 2)
gh_texture.rt_color_bind(shadowMap, 2)
   
-- Render the triangle and the grid
--
gh_texture.bind(model_norm_tex, 1)
gh_object.render(model)
gh_texture.bind(street_norm_tex, 1)
gh_object.render(street)
gh_texture.bind(sidewalk_norm_tex, 1)
gh_object.render(sidewalk)
gh_texture.bind(wall_norm_tex, 1)
gh_object.render(wall)
gh_texture.bind(box_norm_tex, 1)
gh_object.render(box)
gh_texture.bind(aircondition_norm_tex, 1)
gh_object.render(aircondition)


gh_renderer.set_depth_test_state(0)
gh_gpu_program.bind(shadowmap_viewer_prog)
gh_gpu_program.uniform1i(shader_prog, "tex0", 0)
gh_texture.rt_color_bind(shadowMap, 0)
gh_camera.bind(camera_ortho)
gh_object.set_position(fullscreen_quad, winW / 2 - 400 - 10, winH / 2 - 300 - 60, 0)
gh_object.render(fullscreen_quad)
