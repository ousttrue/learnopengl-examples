// (fp)FirstPerson camera

// typedef struct lopgl_fp_cam_desc {
//     HMM_Vec3 position;
//     HMM_Vec3 world_up;
//     float yaw;
//     float pitch;
//     float zoom;
//     // limits
//     float min_pitch;
// 	float max_pitch;
// 	float min_zoom;
// 	float max_zoom;
//     // control options
//     float movement_speed;
//     float aim_speed;
//     float zoom_speed;
// } lopgl_fp_cam_desc_t;

// struct fp_cam {
//     // camera attributes
//     HMM_Vec3 position;
//     HMM_Vec3 world_up;
//     float yaw;
//     float pitch;
//     float zoom;
//     // limits
//     float min_pitch;
// 	float max_pitch;
// 	float min_zoom;
// 	float max_zoom;
//     // control options
//     float movement_speed;
//     float aim_speed;
//     float zoom_speed;
//     // control state
//     bool enable_aim;
//     bool move_forward;
//     bool move_backward;
//     bool move_left;
//     bool move_right;
//     // internal state
//     HMM_Vec3 front;
//     HMM_Vec3 up;
//     HMM_Vec3 right;
// }

// lopgl_fp_cam_desc_t lopgl_get_fp_cam_desc() {
//     return (lopgl_fp_cam_desc_t) {
//         .position = _lopgl.fp_cam.position,
//         .world_up = _lopgl.fp_cam.world_up,
//         .yaw = _lopgl.fp_cam.yaw,
//         .pitch = _lopgl.fp_cam.pitch,
//         .zoom = _lopgl.fp_cam.zoom,
//         .movement_speed = _lopgl.fp_cam.movement_speed,
//         .aim_speed = _lopgl.fp_cam.aim_speed,
//         .zoom_speed = _lopgl.fp_cam.zoom_speed,
//         .min_pitch = _lopgl.fp_cam.min_pitch,
//         .max_pitch = _lopgl.fp_cam.max_pitch,
//         .min_zoom = _lopgl.fp_cam.min_zoom,
//         .max_zoom = _lopgl.fp_cam.max_zoom
//     };
// }

// void lopgl_set_fp_cam(lopgl_fp_cam_desc_t* desc) {
//     // camera attributes
//     _lopgl.fp_cam.position = desc->position;
//     _lopgl.fp_cam.world_up = desc->world_up;
//     _lopgl.fp_cam.yaw = desc->yaw;
//     _lopgl.fp_cam.pitch = desc->pitch;
//     _lopgl.fp_cam.zoom = desc->zoom;
//     // limits
//     _lopgl.fp_cam.min_pitch = desc->min_pitch;
// 	_lopgl.fp_cam.max_pitch = desc->max_pitch;
// 	_lopgl.fp_cam.min_zoom = desc->min_zoom;
// 	_lopgl.fp_cam.max_zoom = desc->max_zoom;
//     // control options
//     _lopgl.fp_cam.movement_speed = desc->movement_speed;
//     _lopgl.fp_cam.aim_speed = desc->aim_speed;
//     _lopgl.fp_cam.zoom_speed = desc->zoom_speed;
//     // control state
//     _lopgl.fp_cam.enable_aim = false;
//     _lopgl.fp_cam.move_forward = false;
//     _lopgl.fp_cam.move_backward = false;
//     _lopgl.fp_cam.move_left = false;
//     _lopgl.fp_cam.move_right = false;
//
//     update_fp_cam_vectors(&_lopgl.fp_cam);
// }
//
// /*=== FP CAM IMPLEMENTATION =======================================================*/
//
// // Defines several possible options for camera movement. Used as abstraction to stay away from window-system specific input methods
// enum camera_movement {
//     CAM_MOV_FORWARD,
//     CAM_MOV_BACKWARD,
//     CAM_MOV_LEFT,
//     CAM_MOV_RIGHT
// };
//
// static void update_fp_cam_vectors(struct fp_cam* camera) {
//     // Calculate the new Front vector
//     HMM_Vec3 front;
//     front.X = cosf(HMM_ToRad(camera.yaw)) * cosf(HMM_ToRad(camera.pitch));
//     front.Y = sinf(HMM_ToRad(camera.pitch));
//     front.Z = sinf(HMM_ToRad(camera.yaw)) * cosf(HMM_ToRad(camera.pitch));
//     camera.front = HMM_NormV3(front);
//     // Also re-calculate the Right and Up vector
//     // Normalize the vectors, because their length gets closer to 0 the more you look up or down which results in slower movement.
//     camera.right = HMM_NormV3(HMM_Cross(camera.front, camera.world_up));
//     camera.up    = HMM_NormV3(HMM_Cross(camera.right, camera.front));
// }
//
// HMM_Mat4 view_matrix_fp(struct fp_cam* camera) {
//     HMM_Vec3 target = HMM_AddV3(camera.position, camera.front);
//     return HMM_LookAt_RH(camera.position, target, camera.up);
// }
//
// void update_fp_camera(struct fp_cam* camera, float delta_time) {
//     float velocity = camera.movement_speed * delta_time;
//     if (camera.move_forward) {
//         HMM_Vec3 offset = HMM_MulV3F(camera.front, velocity);
//         camera.position = HMM_AddV3(camera.position, offset);
//     }
//     if (camera.move_backward) {
//         HMM_Vec3 offset = HMM_MulV3F(camera.front, velocity);
//         camera.position = HMM_SubV3(camera.position, offset);
//     }
//     if (camera.move_left) {
//         HMM_Vec3 offset = HMM_MulV3F(camera.right, velocity);
//         camera.position = HMM_SubV3(camera.position, offset);
//     }
//     if (camera.move_right) {
//         HMM_Vec3 offset = HMM_MulV3F(camera.right, velocity);
//         camera.position = HMM_AddV3(camera.position, offset);
//     }
// }
//
// static void aim_fp_camera(struct fp_cam* camera, HMM_Vec2 mouse_offset) {
//     camera.yaw   += mouse_offset.X * camera.aim_speed;
//     camera.pitch += mouse_offset.Y * camera.aim_speed;
//
//     camera.pitch = HMM_Clamp(camera.min_pitch, camera.pitch, camera.max_pitch);
//
//     update_fp_cam_vectors(camera);
// }
//
// static void zoom_fp_camera(struct fp_cam* camera, float yoffset) {
//     camera.zoom -= yoffset * camera.zoom_speed;
//     camera.zoom = HMM_Clamp(camera.min_zoom, camera.zoom, camera.max_zoom);
// }
//
// void handle_input_fp(struct fp_cam* camera, const sapp_event* e, HMM_Vec2 mouse_offset) {
//     if (e.type == SAPP_EVENTTYPE_KEY_DOWN) {
//         if (e.key_code == SAPP_KEYCODE_W || e.key_code == SAPP_KEYCODE_UP) {
//             camera.move_forward = true;
//         }
//         else if (e.key_code == SAPP_KEYCODE_S || e.key_code == SAPP_KEYCODE_DOWN) {
//             camera.move_backward = true;
//         }
//         else if (e.key_code == SAPP_KEYCODE_A || e.key_code == SAPP_KEYCODE_LEFT) {
//             camera.move_left = true;
//         }
//         else if (e.key_code == SAPP_KEYCODE_D || e.key_code == SAPP_KEYCODE_RIGHT) {
//             camera.move_right = true;
//         }
//     }
//     else if (e.type == SAPP_EVENTTYPE_KEY_UP) {
//         if (e.key_code == SAPP_KEYCODE_W || e.key_code == SAPP_KEYCODE_UP) {
//             camera.move_forward = false;
//         }
//         else if (e.key_code == SAPP_KEYCODE_S || e.key_code == SAPP_KEYCODE_DOWN) {
//             camera.move_backward = false;
//         }
//         else if (e.key_code == SAPP_KEYCODE_A || e.key_code == SAPP_KEYCODE_LEFT) {
//             camera.move_left = false;
//         }
//         else if (e.key_code == SAPP_KEYCODE_D || e.key_code == SAPP_KEYCODE_RIGHT) {
//             camera.move_right = false;
//         }
//     }
//     else if (e.type == SAPP_EVENTTYPE_MOUSE_DOWN) {
// 		if (e.mouse_button == SAPP_MOUSEBUTTON_LEFT) {
// 			camera.enable_aim = true;
// 		}
// 	}
// 	else if (e.type == SAPP_EVENTTYPE_MOUSE_UP) {
// 		if (e.mouse_button == SAPP_MOUSEBUTTON_LEFT) {
// 			camera.enable_aim = false;
// 		}
// 	}
//     else if (e.type == SAPP_EVENTTYPE_MOUSE_MOVE) {
//         if (camera.enable_aim) {
//             aim_fp_camera(camera, mouse_offset);
//         }
//     }
//     else if (e.type == SAPP_EVENTTYPE_MOUSE_SCROLL) {
//         zoom_fp_camera(camera, e.scroll_y);
//     }
// }
//
// const char* help_fp() {
//     return  "Forward:\t'W' '\xf0'\n"
//             "Left:\t\t'A' '\xf2\'\n"
//             "Back:\t\t'S' '\xf1\'\n"
//             "Right:\t\t'D' '\xf3\'\n"
//             "Look:\t\tleft-mouse-btn\n"
//             "Zoom:\t\tmouse-scroll\n";
// }
//
// #endif /*LOPGL_APP_IMPL*/
