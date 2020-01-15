// SkittyColorAlphaView.m

#import "SkittyColorAlphaView.h"
#import "ColorPicker.h"

@implementation SkittyColorAlphaView

- (id)init {
	self = [super init];

	if (self) {
	}

	return self;
}

- (void)updateContent {
	if (!self.imageView) {
		self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		[self addSubview:self.imageView];
	}

	CGSize size = self.imageView.bounds.size;
	CAGradientLayer *layer = [CAGradientLayer layer];
	layer.frame = CGRectMake(0, 0, size.width, size.height);
	layer.colors = @[(__bridge id)[UIColor whiteColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];

	layer.startPoint = CGPointMake(0.0, 0.5);
    layer.endPoint = CGPointMake(1.0, 0.5);

	UIGraphicsBeginImageContext(size);

	[layer renderInContext:UIGraphicsGetCurrentContext()];
	self.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	/*CGImageRef imageRef = createContentImage();
	self.imageView.image = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);*/
}

- (void)layoutSubviews {
	if (!self.alphaValue) {
		self.alphaValue = 1;
	}
	if (!self.indicator) {
		self.indicator = [[SkittyColorIndicatorView alloc] initWithFrame:CGRectMake(116, 116, 24, 24)];
		[self addSubview:self.indicator];
	}
	if (!self.gesture) {
		self.gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanSwipe:)];
		[self addGestureRecognizer:self.gesture];
	}

	CGFloat indicatorX =  self.alphaValue * self.bounds.size.width;
	CGFloat indicatorY = self.bounds.size.height / 2;

	self.indicator.center = CGPointMake(indicatorX, indicatorY);

	self.indicator.color = [UIColor colorWithWhite:0 alpha:self.alphaValue];
}

- (void)setAlphaValue:(float)value {
	if (value != _alphaValue || self.imageView.image == nil) {
		_alphaValue = value;
		
		if (self.delegate)
			[self.delegate updateAlpha:value];
		
		[self updateContent];
		[self setNeedsLayout];
	}
}

- (void)handlePanSwipe:(UIPanGestureRecognizer*)recognizer {
	CGPoint t = [recognizer locationInView:recognizer.view];

	self.alphaValue = pin(0.0f, t.x / self.bounds.size.width, 1.0f);
}

@end
