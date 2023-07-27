module gravel

import term
import strings
import arrays

pub struct RGB {
	r u8
	g u8
	b u8
}

pub enum BarColor {
	def
	white
	black
	red
	blue
	green
	cyan
	magenta
	yellow
	gray
}

const order_barcolors = {
	1: BarColor.red,
	2: BarColor.green,
	3: BarColor.yellow,
	4: BarColor.blue,
	5: BarColor.cyan
	6: BarColor.white,
	7: BarColor.magenta,
	8: BarColor.gray,
}

const bar_color_to_term_color = {
	BarColor.def:     fn (s string) string {
		return s
	}
	BarColor.white:   term.white
	BarColor.black:   term.black
	BarColor.red:     term.red
	BarColor.blue:    term.blue
	BarColor.green:   term.green
	BarColor.magenta: term.magenta
	BarColor.yellow:  term.yellow
	BarColor.cyan:    term.cyan
	BarColor.gray:    term.gray
}

pub type Color = BarColor | RGB | fn (string) string | map[int]RGB

// HorizontalBar struct for making the horizontalbar
pub struct HorizontalBar[T] {
	min         T      [required]
	max         T      [required]
	width       int    [required]
	blocks      []rune [required]
	empty_block rune   [required]
	color       Color
mut:
	used_color  Color
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

fn (b HorizontalBar[T]) dye_text(s string) string {
	color := b.used_color
	if color is BarColor {
		return term.colorize(bar_color_to_term_color[color], s)
	} else if color is RGB {
		return term.rgb(color.r, color.g, color.b, s)
	} else if color is fn (string) string {
		return term.colorize(color, s)
	}
	return s
}

fn (mut b HorizontalBar[T]) dye_rgb() {
	color := b.color as RGB

	b.used_space = term.rgb(color.r, color.g, color.b, b.used_space)
	b.last_block = term.rgb(color.r, color.g, color.b, b.last_block)
	b.used_color = color
}

fn (mut b HorizontalBar[T]) dye_barcolor() {
	color := b.color as BarColor
	term_color := bar_color_to_term_color[color]

	b.used_space = term.colorize(term_color, b.used_space)
	b.last_block = term.colorize(term_color, b.last_block)
	b.used_color = term_color
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
		b.used_color = selected
	} else {
		next_key := arrays.min(after_keys) or { 0 }
		next := color[next_key]
		steps := next_key - key

		red := selected.r + u8(((next.r - selected.r) / steps) * step)
		green := selected.g + u8(((next.g - selected.g) / steps) * step)
		blue := selected.b + u8(((next.b - selected.b) / steps) * step)

		b.used_space = term.rgb(red, green, blue, b.used_space)
		b.last_block = term.rgb(red, green, blue, b.last_block)
		b.used_color = RGB{
			r: red
			g: green
			b: blue
		}
	}
}

fn (mut b HorizontalBar[T]) dye() {
	if !term.can_show_color_on_stdout() {
		return
	}
	match b.color {
		BarColor { b.dye_barcolor() }
		RGB { b.dye_rgb() }
		map[int]RGB { b.dye_map_int_rgb() }
		fn (string) string { return }
	}
}

pub fn (b HorizontalBar[T]) str() string {
	mut builder := strings.new_builder(0)
	builder.write_string(b.used_space)
	builder.write_string(b.last_block)
	builder.write_string(b.empty_space)
	return builder.str()
}
