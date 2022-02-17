Slideshow = {}

function Slideshow:new(slides)
	local t = {
		slides = slides,
		index = 1
	}
	setmetatable(t, self)
	self.__index = self
	return t
end

function Slideshow:next()
	print("next!")
	self.index = (self.index) % #self.slides + 1
end

function Slideshow:prev()
	print("back")
	self.index = (self.index - 2) % #self.slides + 1
end

function Slideshow:display()
	putString("Slide", self.slides[self.index])
end