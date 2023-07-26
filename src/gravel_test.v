module gravel

fn test_calc_progress() {
	mut x := 0.0
	mut y := 0.0
		
	x, y = calc_progress(0, 0, 100, 100)
	assert x == 0.0
	assert y == 0.0

	x, y = calc_progress(100, 0, 100, 50)
	assert x == 100
	assert y == 50

	x, y = calc_progress(10, 0, 20, 10)
	assert x == 50
	assert y == 5

	x, y = calc_progress(1, 0, 1, 1)
	assert x == 100
	assert y == 1
}

fn test_horizontalbar() {

	mut x := gravel.HorizontalBar{
		min: 0
		max: 100
		width: 10
		blocks: [`0`,`1`, `2`, `3`, `4`, `5`]
		empty_block: `-`
		value: 10
	}
	x.render()
	assert x.str() == '50--------'
	assert x.progress == 10.0
	
	x = gravel.HorizontalBar{
		min: 0
		max: 1
		width: 1
		blocks: [`0`,`1`, `2`, `3`, `4`, `5`]
		empty_block: `-`
		value: 1
	}
	x.render()
	assert x.str() == '5'
	assert x.progress == 100.0
		
	x = gravel.HorizontalBar{
		min: -10
		max: 10
		width: 50
		blocks: [`0`,`1`, `2`, `3`, `4`, `5`]
		empty_block: `-`
		value: 0
	}
	x.render()
	assert x.str() == '55555555555555555555555550------------------------'
	assert x.progress == 50
}