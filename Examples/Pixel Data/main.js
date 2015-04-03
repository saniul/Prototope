var layer = new Layer()
var pusheen = new Image({name:"pusheen"})

var dimension = (400*400);

var start = new Date()
pusheen.loadPixels()
var end = new Date()
console.log("Load done! Took:"+ (end-start));

start = new Date()
for (var i=0; i < dimension; i++) { 
	var pixel = pusheen.pixels[i]
	pixel[0] = 255 - pixel[0]
	pixel[1] = 255 - pixel[1]
	pixel[2] = 255 - pixel[2]
	pusheen.pixels[i] = pixel
}
end = new Date() 
console.log("Modifications done! Took:"+ (end-start));

start = new Date()
pusheen.updatePixels()
end = new Date() 
console.log("Update done! Took:"+ (end-start));

layer.image = pusheen
layer.position = new Point({ x: Layer.root.width * 0.5, y: Layer.root.height * 0.5 })

//var pixels = pusheen.toPixels()
//var start = new Date()
//
//var t = function(pixel) { 
////	var color = pixel.color
////	pixel.red = 1.0 - pixel.red
////	pixel.green = 1.0 - pixel.green
////	pixel.blue = 1.0 - pixel.blue
//	return pixel 
//} 
//pixels = pixels.map({ transform: t})
//
//
//
//var end = new Date()
//console.log("Done! Took:"+ (end-start));
//pusheen = pixels.toImage()
//
//layer.image = pusheen
//
//layer.position = new Point({ x: Layer.root.width * 0.5, y: Layer.root.height * 0.5 })