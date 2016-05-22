
winW, winH = gh_window.getsize(0)

aspect = 1.333
if (winH > 0) then
	aspect = winW / winH
end  
gh_camera.update_persp(camera, 60, aspect, 0.1, 1000.0)
gh_camera.set_viewport(camera, 0, 0, winW, winH)

gh_camera.update_ortho(camera_ortho, - winW / 2, winW / 2, - winH / 2, winH / 2, 1.0, 10.0)
gh_camera.set_viewport(camera_ortho, 0, 0, winW, winH)

gh_utils.font_set_viewport_info(font_a, 0, 0, winW, winH)