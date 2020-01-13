// Spectrum, by Skitty (and Even)
// Customize system colors!

#import "Tweak.h"

static NSMutableDictionary *settings;
static bool global = YES;
//static bool useIconColor = NO;
static bool enabled;

static bool customDarkColors;

static UIColor *tint;
static UIColor *highlight;

static UIColor *darkPrimaryColor;
static UIColor *darkSecondaryColor;
static UIColor *darkSeparatorColor;
static UIColor *darkLabelColor;
//static UIColor *iconTint;

UIColor *appTintColorFromWindow(UIWindow *window) {
	if (!window || !window.tintColor) {
		UIView *view = [[UIView alloc] init];
		return [view _normalInheritedTintColor];
	}
	if (!window.tintColor) {
		if (window.rootViewController) {
			//return window.rootViewController.view.tintColor;
		}
	}
	return window.tintColor;
}

UIColor *iconTintColorForCurrentApp() {
	NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
	if ([bundleid isEqualToString:@"com.apple.springboard"]) {
		return [UIColor systemBlueColor];
	}

	UIImage *icon = [UIImage _applicationIconImageForBundleIdentifier:bundleid format:2 scale:[UIScreen mainScreen].scale];

	CGSize size = {1, 1};
	UIGraphicsBeginImageContext(size);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetInterpolationQuality(ctx, kCGInterpolationMedium);

	[icon drawInRect:(CGRect){.size = size} blendMode:kCGBlendModeCopy alpha:1];
	uint8_t *data = (uint8_t *)CGBitmapContextGetData(ctx);

	UIColor *color = [UIColor colorWithRed:data[2] / 255.0f green:data[1] / 255.0f blue:data[0] / 255.0f alpha:1];

	UIGraphicsEndImageContext();

	return color;
}

// Color from hex function
UIColor *colorFromHexStringWithAlpha(NSString *hexString, double alpha) {
	unsigned rgbValue = 0;
	NSScanner *scanner = [NSScanner scannerWithString:hexString];
	[scanner setScanLocation:0];
	[scanner scanHexInt:&rgbValue];
	return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

// Preference Updates
static void refreshPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("xyz.skitty.spectrum"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/xyz.skitty.spectrum.plist"];
	}

	enabled = [([settings objectForKey:@"enabled"] ?: @(YES)) boolValue];
	customDarkColors = [([settings objectForKey:@"customDarkColors"] ?: @(NO)) boolValue];

	NSString  *tintHex = [settings objectForKey:@"tintColor"] ?: @"F22F6C";
	tint = colorFromHexStringWithAlpha(tintHex, 1.0);
	highlight = colorFromHexStringWithAlpha(tintHex, 0.2);
	darkPrimaryColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkPrimaryColor"] ?: @"000000", 1.0);
	darkSecondaryColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSecondaryColor"] ?: @"000000", 1.0);
	darkSeparatorColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkSeparatorColor"] ?: @"000000", 1.0);
	darkLabelColor = colorFromHexStringWithAlpha([settings objectForKey:@"darkLabelColor"] ?: @"FFFFFF", 1.0);
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	refreshPrefs();
}

// Create a Dynamic color
static UIColor *dynamicColor(UIColor *defaultColor, UIColor *darkColor) {
	if (@available(iOS 13.0, *)) {
		return [UIColor colorWithDynamicProvider:^UIColor *_Nonnull(UITraitCollection *_Nonnull traitCollection) {
			if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
				return darkColor;
			} else {
				return defaultColor;
			}
		}];
	}
	return defaultColor;
}

// Global Tint Color
%group UIColor

%hook UIColor
+ (id)colorWithRed:(double)red green:(double)green blue:(double)blue alpha:(double)alpha {
	if (red == 0.0 && green == 122.0/255.0 && blue == 1.0) {
		return tint;
	}
	return %orig;
}
// Default tint
+ (id)systemBlueColor {
	return tint;
}
// Selection point
+ (id)insertionPointColor {
	return tint;
}
// Selection highlight
+ (id)selectionHighlightColor {
	return highlight;
}
// Selection grabbers
+ (id)selectionGrabberColor {
	return tint;
}

// iOS 13 System Colors
+ (id)systemBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkPrimaryColor) : %orig;
}
+ (id)secondarySystemBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSecondaryColor) : %orig;
}

+ (id)systemGroupedBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkPrimaryColor) : %orig;
}
+ (id)secondarySystemGroupedBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSecondaryColor) : %orig;
}

+ (id)groupTableViewBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkPrimaryColor) : %orig;
}
+ (id)tableCellGroupedBackgroundColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSecondaryColor) : %orig;
}

+ (id)separatorColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSeparatorColor) : %orig;
}
+ (id)opaqueSeparatorColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSeparatorColor) : %orig;
}
+ (id)tableSeparatorColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkSeparatorColor) : %orig;
}

+ (id)labelColor {
	return customDarkColors ? dynamicColor([%orig resolvedColorWithTraitCollection:[UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight]], darkLabelColor) : %orig;
}

+ (id)linkColor {
	return tint;
}
%end

%end

// Per App Tint Color
%group App

%hook UIView
- (UIColor *)tintColor {
	if (![self isKindOfClass:%c(UIWindow)] && [self _normalInheritedTintColor] == appTintColorFromWindow([self window])) {
		return tint;
	}
	return %orig;
}
%end

%end

// Message bubbles POC
/*%group Messages

%hook CKUITheme
- (id)blue_balloonColors {
	UIColor *topColor = [UIColor blueColor];
	UIColor *bottomColor = [UIColor redColor];
	return @[topColor, bottomColor]
}
// - (id)green_balloonColors
%end

%end*/

static void getAppList(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		return;
	}
	//NSLog(@"[SPEC] getAppList2");

	NSArray *ids = @[@"com.apple.AppSSOUIService", @"com.apple.AuthKitUIService", @"com.apple.BusinessChatViewService", @"com.apple.CTNotifyUIService", @"com.apple.CarPlaySplashScreen", @"com.apple.FTMInternal", @"com.apple.appleseed.FeedbackAssistant", @"com.apple.FontInstallViewService", @"com.apple.BarcodeScanner", @"com.apple.icloud.spnfcurl", @"com.apple.ScreenTimeUnlock", @"com.apple.CarPlaySettings", @"com.apple.SharedWebCredentialViewService", @"com.apple.sidecar", @"com.apple.Spotlight", @"com.apple.iMessageAppsViewService", @"com.apple.AXUIViewService", @"com.apple.AccountAuthenticationDialog", @"com.apple.AdPlatformsDiagnostics", @"com.apple.CTCarrierSpaceAuth", @"com.apple.CheckerBoard", @"com.apple.CloudKit.ShareBear", @"com.apple.AskPermissionUI", @"com.apple.CompassCalibrationViewService", @"com.apple.sidecar.camera", @"com.apple.datadetectors.DDActionsService", @"com.apple.DataActivation", @"com.apple.DemoApp", @"com.apple.Diagnostics", @"com.apple.DiagnosticsService", @"com.apple.carkit.DNDBuddy", @"com.apple.family", @"com.apple.fieldtest", @"com.apple.gamecenter.GameCenterUIService", @"com.apple.HealthPrivacyService", @"com.apple.Home.HomeUIService", @"com.apple.InCallService", @"com.apple.MailCompositionService", @"com.apple.mobilesms.compose", @"com.apple.MobileReplayer", @"com.apple.MusicUIService", @"com.apple.PhotosViewService", @"com.apple.PreBoard", @"com.apple.PrintKit.Print-Center", @"com.apple.social.SLYahooAuth", @"com.apple.SafariViewService", @"org.coolstar.SafeMode", @"com.apple.ScreenshotServicesSharing", @"com.apple.ScreenshotServicesService", @"com.apple.ScreenSharingViewService", @"com.apple.SIMSetupUIService", @"com.apple.Magnifier", @"com.apple.purplebuddy", @"com.apple.SharedWebCredentialsViewService", @"com.apple.SharingViewService", @"com.apple.SiriViewService", @"com.apple.susuiservice", @"com.apple.StoreDemoViewService", @"com.apple.TVAccessViewService", @"com.apple.TVRemoteUIService", @"com.apple.TrustMe", @"com.apple.CoreAuthUI", @"com.apple.VSViewService", @"com.apple.PassbookStub", @"com.apple.PassbookUIService", @"com.apple.WebContentFilter.remoteUI.WebContentAnalysisUI", @"com.apple.WebSheet", @"com.apple.iad.iAdOptOut", @"com.apple.ios.StoreKitUIService", @"com.apple.webapp", @"com.apple.webapp1"];

	NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
	for (SBApplication *app in [[NSClassFromString(@"SBApplicationController") sharedInstance] allApplications]) {
		bool add = YES;
		NSString *name = app.displayName ?: @"Error";
		for (NSString *id in ids) {
			if ([app.bundleIdentifier isEqual:id]) {
				add = NO;
			}
		}
		if (add) {
			[mutableDict setObject:name forKey:app.bundleIdentifier];
		}
	}

	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("xyz.skitty.spectrum.setapps"), nil, (__bridge CFDictionaryRef)mutableDict, true);
}

%ctor {
	//iconTint = iconTintColorForCurrentApp();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("xyz.skitty.spectrum.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, getAppList, CFSTR("xyz.skitty.spectrum.getapps"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	refreshPrefs();

	if (enabled) {
		%init(App);
		if (global) {
			%init(UIColor);
		}
	}
}