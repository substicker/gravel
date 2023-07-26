module gravel

import term
import strings
import arrays

pub struct RGB {
	r u8
	g u8
	b u8
}

pub type Color = RGB | bool | map[int]RGB

// HorizontalBar struct for making the horizontalbar
pub struct HorizontalBar[T] {
	min         T      [required]
	max         T      [required]
	width       int    [required]
	blocks      []rune [required]
	empty_block rune   [required]
	color       Color
mut:
	last_block  string
	used_space  string
	empty_space string
pub mut:
	progress f64
	value    T   [required]
}

pub fn (mut b HorizontalBar[T]) render() {
	b.val() or {
		eprintln(err)
		return
	}
	b.make()
}

// validation
fn (b HorizontalBar[T]) val() ! {
	match true {
		b.min > b.max { return error('invalid range (${b.min} to ${b.max})') }
		b.width <= 0 { return error('invalid width (${b.width})') }
		b.blocks.len < 1 { return error('not enough blocks') }
		else {}
	}
}

fn (mut b HorizontalBar[T]) make() {
	percentage, width_progress := calc_progress(b.value, b.min, b.max, b.width)

	block := b.blocks[b.blocks.len - 1].str()
	unit := int(width_progress)
	decimal := int(width_progress * 100) % 100

	mut empty := b.width - unit - 1
	if empty == -1 {
		empty = 0
	}

	b.progress = percentage
	b.empty_space = strings.repeat_string(b.empty_block.str(), empty)
	b.used_space = strings.repeat_string(block, unit)

	if b.progress != 100 {
		b.last_block = b.blocks[scale(decimal, 0, 100, 0, b.blocks.len - 1)].str()
	}

	b.dye()
}

fn (mut b HorizontalBar[T]) dye_rgb() {
	color := b.color as RGB

	b.used_space = term.rgb(color.r, color.g, color.b, b.used_space)
	b.last_block = term.rgb(color.r, color.g, color.b, b.last_block)
}

// it's messy but it works just fine! (for now)
fn (mut b HorizontalBar[T]) dye_map_int_rgb() {
	color := b.color as map[int]RGB
	keys := color.keys()
	before_keys := keys.filter(it <= b.progress)
	after_keys := keys.filter(it >= b.progress)

	if before_keys.len == 0 {
		return
	}

	key := arrays.max(before_keys) or { 0 }
	selected := color[key]
	step := b.progress - key

	if step == 0 {
		b.used_space = term.rgb(selected.r, selected.g, selected.b, b.used_space)
		b.last_block = term.rgb(selected.r, selected.g, selected.b, b.last_block)
	} else {
		next_key := arrays.min(after_keys) or { 0 }
		next := color[next_key]
		steps := next_key - key

		red := selected.r + int(((next.r - selected.r) / steps) * step)
		green := selected.g + int(((next.g - selected.g) / steps) * step)
		blue := selected.b + int(((next.b - selected.b) / steps) * step)

		b.used_space = term.rgb(red, green, blue, b.used_space)
		b.last_block = term.rgb(red, green, blue, b.last_block)
	}
}

fn (mut b HorizontalBar[T]) dye() {
	if !term.can_show_color_on_stdout() {
		return
	}
	match b.color {
		bool { return }
		RGB { b.dye_rgb() }
		map[int]RGB { b.dye_map_int_rgb() }
	}
}

pub fn (b HorizontalBar[T]) str() string {
	mut builder := strings.new_builder(0)
	builder.write_string(b.used_space)
	builder.write_string(b.last_block)
	builder.write_string(b.empty_space)
	return builder.str()
}
