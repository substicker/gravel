module gravel

fn scale[T](x T, in_min T, in_max T, out_min T, out_max T) T {
	return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
}

fn calc_progress[T](value T, min T, max T, width int) (f64, f64) {
	if value <= min {
		return 0.0, 0
	} else if value >= max {
		return 100.0, width
	}
	mut progress := 0.0
	progress = scale(value, min, max, 0, 100)
	width_progress := scale(progress, 0, 100, 0, width)
	return progress, width_progress
}