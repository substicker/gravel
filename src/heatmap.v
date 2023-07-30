module gravel

import strings
import term

const block_color = [
	' ',
	term.blue('░'),
	term.blue('▒'),
	term.blue('▓'),
	term.blue('█'),
	term.bg_blue(' '),
	term.bg_blue(term.green('░')),
	term.bg_blue(term.green('▒')),
	term.bg_blue(term.green('▓')),
	term.bg_green(' '),
	term.bg_green(term.yellow('░')),
	term.bg_green(term.yellow('▒')),
	term.bg_green(term.yellow('▓')),
	term.bg_yellow(' '),
	term.bg_yellow(term.red('░')),
	term.bg_yellow(term.red('▒')),
	term.bg_yellow(term.red('▓')),
	term.red('█'),
]

pub struct Heatmap {
	width  int
	height int
	values [][]int
mut:
	x_min int
	x_max int
	y_min int
	y_max int

	matrix  [][]int
	heatmap [][]string
}

pub fn (mut h Heatmap) render() {
	h.init()
	h.make_matrix()
	h.make_heatmap()
}

fn (mut h Heatmap) init() {
	for point in h.values {
		if point[0] <= h.x_min {
			h.x_min = point[0]
		} else if point[0] >= h.x_max {
			h.x_max = point[0]
		}

		if point[1] <= h.y_min {
			h.y_min = point[1]
		} else if point[1] >= h.y_max {
			h.y_max = point[1]
		}
	}
}

fn (mut h Heatmap) make_matrix() {
	h.matrix = [][]int{len: h.height, init: []int{len: h.width}}
	h.heatmap = [][]string{len: h.height, init: []string{len: h.width}}

	for point in h.values {
		mut x := scale(point[0], h.x_min, h.x_max, 0, h.width - 1)
		mut y := scale(point[1], h.y_min, h.y_max, 0, h.height - 1)
		h.matrix[y][x] += 1
	}
	h.matrix = h.matrix.reverse()
}

fn (mut h Heatmap) make_heatmap() {
	for index, row in h.matrix {
		h.heatmap[index] = row.map(get_block(it))
	}
}

pub fn (h Heatmap) str() string {
	mut builder := strings.new_builder(0)

	for index, row in h.heatmap {
		e := h.width - index - 1
		builder.writeln(row.join(''))
		//builder.writeln('${e:2}|' + row.join(''))
	}
	//builder.writeln('   ' + strings.repeat_string('-', h.width))

	return builder.str()
}

fn get_block(val int) string {
	if val >= block_color.len {
		return block_color[block_color.len - 1]
	}
	return block_color[val]
}
