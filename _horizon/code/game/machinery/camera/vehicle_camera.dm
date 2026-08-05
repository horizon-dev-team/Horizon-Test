// Vehicle camera subtype for multitile vehicles.
// TG uses /obj/machinery/camera (without /structure/ prefix); CM13 uses /obj/structure/machinery/camera/vehicle.
// This file declares the TG-compatible subtype.

/obj/machinery/camera/vehicle
	name = "vehicle camera"
	network = list("vehicle")
	c_tag = "vehicle"
	// Vehicle cameras are always inside their vehicle and don't need station AI to view them
	internal_light = FALSE

/// Toggle camera status on/off (CM13 compat shim)
/obj/machinery/camera/vehicle/proc/toggle_cam_status(status)
	if(status == null)
		status = !camera_enabled
	set_camera_status(status)

/obj/machinery/camera/vehicle/proc/set_camera_status(status)
	if(status)
		camera_enabled = TRUE
	else
		camera_enabled = FALSE
	update_icon()
