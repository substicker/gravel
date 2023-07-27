module gravel

import term
import strings

pub enum StyleProgressBar {
	classic
	apt
}

type Label = map[int]string | string

pub struct ProgressBar {
	style       StyleProgressBar = .classic
	auto_update bool
	label       Label
	width       int = 75
	color       Color
	goal        int = 100
mut:
	progress_bar string
pub mut:
	value    int
	progress f64
}

pub fn (mut p ProgressBar) render() {
	match p.style {
		.classic { p.style_classic() }
		.apt { p.style_apt() }
	}
}

fn (p ProgressBar) get_label() string {
	mut label := ''
	match p.label {
		string {
			label = p.label as string
		}
		map[int]string {
			labels_map := p.label as map[int]string
			label_keys := labels_map.keys()
			labels := label_keys.filter(it <= p.progress)
			label = labels_map[labels[labels.len - 1]]
		}
	}
	return label
}

pub fn (mut p ProgressBar) style_classic() {
	mut builder := strings.new_builder(0)
	mut horizontal_bar := HorizontalBar{
		value: p.value
		min: 0
		max: p.goal
		blocks: [` `, `▏`, `▎`, `▍`, `▌`, `▋`, `▊`, `▉`, `█`]
		color: p.color
		empty_block: ` `
		width: p.width
	}
	horizontal_bar.render()
	p.progress = horizontal_bar.progress
	mut label := p.get_label()

	builder.write_string('${label:2} ${p.progress:3}%')
	builder.write_rune(`[`)
	builder.write_string(horizontal_bar.str())
	builder.write_rune(`]`)

	p.progress_bar = builder.str()
}

pub fn (mut p ProgressBar) update(value int) {
	p.value = value

	if p.auto_update {
		p.render()
	}
}

pub fn (mut p ProgressBar) style_apt() {
	mut builder := strings.new_builder(0)
	mut horizontal_bar := HorizontalBar{
		value: p.value
		min: 0
		max: p.goal
		blocks: [`#`]
		empty_block: `.`
		width: p.width
	}
	horizontal_bar.render()

	builder.write_string(term.bg_green('Progress: [${horizontal_bar.progress:3}%]'))
	builder.write_rune(`[`)
	builder.write_string(horizontal_bar.str())
	builder.write_rune(`]`)

	p.progress_bar = builder.str()
}

pub fn (mut p ProgressBar) str() string {
	return p.progress_bar
}
