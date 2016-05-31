
-- Calc elapsed time
local elapsed_time = gh_utils.get_elapsed_time()
local dt = elapsed_time - last_time
last_time = elapsed_time

-- +++++++++++++++ Handle input +++++++++++++++
local KC_LEFT = 203
local KC_RIGHT = 205
local KC_1 =  2
local KC_2 =  3
local KC_3 =  4
local KC_4 =  5
local KC_5 =  6
local KC_6 =  7
local KC_7 =  8
local KC_N =  49
local KC_M =  50
local KC_SPACE = 57

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
-- Set graphicsMode
if (gh_input.keyboard_is_key_down(KC_1) == 1) then
	graphicsMode = 1
end
if (gh_input.keyboard_is_key_down(KC_2) == 1) then
	graphicsMode = 2
end
if (gh_input.keyboard_is_key_down(KC_3) == 1) then
	graphicsMode = 3
end
if (gh_input.keyboard_is_key_down(KC_4) == 1) then
	graphicsMode = 4
end
if (gh_input.keyboard_is_key_down(KC_5) == 1) then
	graphicsMode = 5
end
if (gh_input.keyboard_is_key_down(KC_6) == 1) then
	graphicsMode = 6
end
if (gh_input.keyboard_is_key_down(KC_7) == 1) then
	graphicsMode = 7
end
-- Show shadowMap?
if (gh_input.keyboard_is_key_down(KC_M) == 1) then
	showShadowMap = true
end
if (gh_input.keyboard_is_key_down(KC_N) == 1) then
	showShadowMap = false
end
if (gh_input.keyboard_is_key_down(KC_SPACE) == 1 and not pausedPressed) then
	paused = not paused
	pausedPressed = true
else
	pausedPressed = false
end


-- Set light camera from light position
gh_camera.set_position(camera_light, lightSource[1], lightSource[2], lightSource[3])
gh_camera.set_lookat(camera_light, lightLookAt[1], lightLookAt[2], lightLookAt[3], 1)

if not paused then

-- +++++++++++++++ Render shadow map +++++++++++++++
-- Render to a texture
gh_render_target.bind(shadowMap)
gh_camera.bind(camera_light)
gh_gpu_program.bind(shaderShadowMap)
gh_renderer.set_blending_state(0)

-- Clear
gh_renderer.clear_color_depth_buffers(0.2, 0.2, 0.2, 1.0, 1.0)
gh_renderer.set_depth_test_state(1)

-- Render models
gh_object.render(lamppost)
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

-- AlphaBlending
gh_renderer.set_blending_factors(1, 5)
gh_renderer.set_blending_state(1)

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
-- Set graphicsMode
gh_gpu_program.uniform1i(shaderMain, "graphicsMode", graphicsMode)

-- Bind shadow map
gh_texture.rt_color_bind(shadowMap, 2)
   
-- Render models with normal maps
gh_gpu_program.uniform1f(shaderMain, "materialShininess", 20)
gh_gpu_program.uniform1f(shaderMain, "materialSpecular", 0.3)
gh_texture.bind(lamppost_norm_tex, 1)
gh_object.render(lamppost)
gh_texture.bind(lamppostGlas_tex, 1)
gh_gpu_program.uniform1i(shaderMain, "graphicsMode", math.min(3, graphicsMode))
gh_object.render(lamppostGlas)
gh_gpu_program.uniform1i(shaderMain, "graphicsMode", graphicsMode)
gh_gpu_program.uniform1f(shaderMain, "materialSpecular", 0.6)
gh_texture.bind(aircondition_norm_tex, 1)
gh_object.render(aircondition)
gh_gpu_program.uniform1f(shaderMain, "materialShininess", 4)
gh_gpu_program.uniform1f(shaderMain, "materialSpecular", 0.08)
gh_texture.bind(street_norm_tex, 1)
gh_object.render(street)
gh_texture.bind(sidewalk_norm_tex, 1)
gh_object.render(sidewalk)
gh_texture.bind(wall_norm_tex, 1)
gh_object.render(wall)
gh_texture.bind(box_norm_tex, 1)
gh_object.render(box)


if (showShadowMap) then
	-- +++++++++++++++ Render shadow map to screen +++++++++++++++
	gh_renderer.set_depth_test_state(0)
    gh_renderer.set_blending_state(0)

	-- Bindings
	gh_gpu_program.bind(shaderShadowMapViewer)
	gh_camera.bind(camera_ortho)

	-- Set shadow map
	gh_gpu_program.uniform1i(shaderShadowMapViewer, "tex0", 0)
	gh_texture.rt_color_bind(shadowMap, 0)

	-- Render fullscreen squad into the upper right corner
	gh_object.set_position(fullscreen_quad, winW / 2 - 400 - 10, winH / 2 - 300 - 60, 0)
	gh_object.render(fullscreen_quad)
end

end