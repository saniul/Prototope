var layer = new Layer()
var pusheen = new Image({name:"pusheen"})

var pixels = pusheen.toPixels()
var start = new Date()

var t = function(pixel) { 
//	var color = pixel.color
//	pixel.red = 1.0 - pixel.red
//	pixel.green = 1.0 - pixel.green
//	pixel.blue = 1.0 - pixel.blue
	return pixel 
} 
pixels = pixels.map({ transform: t})



var end = new Date()
console.log("Done! Took:"+ (end-start));
pusheen = pixels.toImage()

layer.image = pusheen

layer.position = new Point({ x: Layer.root.width * 0.5, y: Layer.root.height * 0.5 })