// Tweak.h

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);

@interface UIColor (Spectrum)
+ (id)systemBlueColor;
@end

@interface UIImage (Spectrum)
+ (id)_applicationIconImageForBundleIdentifier:(id)arg1 format:(int)arg2 scale:(double)arg3;
@end

@interface UIView (Spectrum)
- (id)_normalInheritedTintColor;
@end

@interface UINavigationBar (Spectrum)
@property (nonatomic, retain) UIColor *storedBarColor;
@end

@interface UIToolbar (Spectrum)
@property (nonatomic, retain) UIColor *storedBarColor;
@end

@interface UITabBar (Spectrum)
@property (nonatomic, retain) UIColor *storedBarColor;
@end

@interface SBApplication : NSObject
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSString *bundleIdentifier;
@end

@interface SBApplicationController : NSObject
+ (id)sharedInstance;
- (id)allApplications;
- (id)allBundleIdentifiers;
- (id)runningApplications;
@end

@interface SBIconView : UIView
@end

@interface SBIconBadgeView : UIView
- (void)updateColor;
@end
