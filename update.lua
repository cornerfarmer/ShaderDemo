
-- Calc elapsed time
local elapsed_time = gh_utils.get_elapsed_time()
local dt = elapsed_time - last_time
last_time = elapsed_time

-- +++++++++++++++ Handle input +++++++++++++++
local KC_LEFT = 203
local KC_RIGHT = 205
-- Move light
if (gh_input.keyboard_is_key_down(KC_RIGHT) == 1) then
	lightDegree = lightDegree + dt * 0.6
end
if (gh_input.keyboard_is_key_down(KC_LEFT) == 1) then
	lightDegree = lightDegree - dt * 0.6
end
lightSource[1] = math.sin(lightDegree) * 10
lightSource[3] = math.cos(lightDegree) * 10
-- Update main camera
gx_camera.update(camera, dt)

-- Set light camera from light position
gh_camera.set_position(camera_light, lightSource[1], lightSource[2], lightSource[3])
gh_camera.set_lookat(camera_light, lightLookAt[1], lightLookAt[2], lightLookAt[3], 1)

-- +++++++++++++++ Render shadow map +++++++++++++++
-- Render to a texture
gh_render_target.bind(shadowMap)
gh_camera.bind(camera_light)
gh_gpu_program.bind(shaderShadowMap)

-- Clear
gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
gh_renderer.set_depth_test_state(1)

-- Render models
gh_object.render(model)
gh_object.render(street)
gh_object.render(sidewalk)
gh_object.render(wall)
gh_object.render(box)
gh_object.render(aircondition)

-- Unbind
gh_gpu_program.bind(0)
gh_render_target.unbind(shadowMap)

-- +++++++++++++++ Render shadowed scene +++++++++++++++
-- Clear
gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
gh_renderer.set_depth_test_state(1)

-- Bindings
gh_camera.bind(camera)
gh_gpu_program.bind(shaderMain)

-- Set parameters
-- Set light direction, position, power and view matrix
gh_gpu_program.uniform4f(shaderMain, "lightDir", lightLookAt[1] - lightSource[1], lightLookAt[2] - lightSource[2], lightLookAt[3] - lightSource[3], 0)
gh_gpu_program.uniform4f(shaderMain, "lightPos", lightSource[1], lightSource[2], lightSource[3], 0)
gh_gpu_program.uniform1f(shaderMain, "lightPower", 1.2)
gh_gpu_program.uniform_camera_matrices(shaderMain, camera_light, "lightViewMatrix", "lightProjectionMatrix")
-- Set camera vector
gh_gpu_program.uniform4f(shaderMain, "camera", gh_camera.get_view(camera))
-- Set texture indices
gh_gpu_program.uniform1i(shaderMain, "tex0", 0)
gh_gpu_program.uniform1i(shaderMain, "tex1", 1)
gh_gpu_program.uniform1i(shaderMain, "shadowMap", 2)

-- Bind shadow map
gh_texture.rt_color_bind(shadowMap, 2)
   
-- Render models with normal maps
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

-- +++++++++++++++ Render shadow map to screen +++++++++++++++
gh_renderer.set_depth_test_state(0)

-- Bindings
gh_gpu_program.bind(shaderShadowMapViewer)
gh_camera.bind(camera_ortho)

-- Set shadow map
gh_gpu_program.uniform1i(shaderShadowMapViewer, "tex0", 0)
gh_texture.rt_color_bind(shadowMap, 0)

-- Render fullscreen squad into the upper right corner
gh_object.set_position(fullscreen_quad, winW / 2 - 400 - 10, winH / 2 - 300 - 60, 0)
gh_object.render(fullscreen_quad)
