module gravel

import arrays
import strings

type Values = []int | int | map[string]int

pub struct HorizontalBarChart {
	values Values
mut:
	bars []string
}

pub fn (mut h HorizontalBarChart) render() {
	match h.values {
		int { h.as_int() }
		[]int { h.as_array_values() }
		map[string]int { h.as_map() }
	}
}

fn (mut h HorizontalBarChart) as_map() {
	mut arr_labels := []string{}
	maps := h.values as map[string]int

	labels := maps.keys()
	values := maps.values()
	max := arrays.max(values) or { 100 }

	for i, val in values {
		color := order_barcolors[i % order_barcolors.len]
		mut horizontal_bar := HorizontalBar{
			value: val
			min: 0
			max: max
			blocks: [`▏`, `▎`, `▍`, `▌`, `▋`, `▊`, `▉`, `█`]
			color: color
			empty_block: ` `
			width: 75
		}
		horizontal_bar.render()

		label := horizontal_bar.dye_text('█')
		arr_labels << '${label} ${labels[i]}'
		h.bars << horizontal_bar.str() + '${val}'
	}

	h.bars << arr_labels.join(' ')
}

fn (mut h HorizontalBarChart) as_int() {
	mut horizontal_bar := HorizontalBar{
		value: h.values as int
		min: 0
		max: 100
		blocks: [`▏`, `▎`, `▍`, `▌`, `▋`, `▊`, `▉`, `█`]
		color: BarColor.def
		empty_block: ` `
		width: 75
	}
	horizontal_bar.render()
	h.bars << horizontal_bar.str() + horizontal_bar.value.str()
}

fn (mut h HorizontalBarChart) as_array_values() {
	values := h.values as []int
	max := arrays.max(values) or { 100 }


	for i, val in values {
		color := order_barcolors[i % order_barcolors.len]
		mut horizontal_bar := HorizontalBar{
			value: val
			min: 0
			max: max
			blocks: [`▏`, `▎`, `▍`, `▌`, `▋`, `▊`, `▉`, `█`]
			color: color
			empty_block: ` `
			width: 75
		}
		horizontal_bar.render()
		h.bars << horizontal_bar.str()
	}
}

fn (h HorizontalBarChart) str() string {
	mut builder := strings.new_builder(0)
	for i in h.bars {
		builder.writeln(i)
	}
	return builder.str()
}
