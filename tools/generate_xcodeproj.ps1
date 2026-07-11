$root = 'C:\Users\Baks\Projects\Cashflare'
$projDir = Join-Path $root 'Cashflare.xcodeproj'
New-Item -ItemType Directory -Force -Path $projDir | Out-Null

function New-Id {
    -join ((1..24) | ForEach-Object { '{0:X}' -f (Get-Random -Max 16) })
}

$ids = @{}
@(
  'Project','Target','Sources','Resources','Frameworks','Product',
  'GroupRoot','GroupApp','GroupGame','GroupProducts',
  'AppSwift','ContentSwift','CurrencySwift','GameStateSwift','BillFactorySwift','GameSceneSwift','Assets',
  'BF_App','BF_Content','BF_Currency','BF_GameState','BF_BillFactory','BF_GameScene','BF_Assets',
  'ProjectConfigList','TargetConfigList','ProjectDebug','ProjectRelease','TargetDebug','TargetRelease'
) | ForEach-Object { $ids[$_] = New-Id }

$pbx = @"
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {

/* Begin PBXBuildFile section */
		$($ids.BF_App) /* CashflareApp.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.AppSwift) /* CashflareApp.swift */; };
		$($ids.BF_Content) /* ContentView.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.ContentSwift) /* ContentView.swift */; };
		$($ids.BF_Currency) /* Currency.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.CurrencySwift) /* Currency.swift */; };
		$($ids.BF_GameState) /* GameState.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.GameStateSwift) /* GameState.swift */; };
		$($ids.BF_BillFactory) /* BillFactory.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.BillFactorySwift) /* BillFactory.swift */; };
		$($ids.BF_GameScene) /* GameScene.swift in Sources */ = {isa = PBXBuildFile; fileRef = $($ids.GameSceneSwift) /* GameScene.swift */; };
		$($ids.BF_Assets) /* Assets.xcassets in Resources */ = {isa = PBXBuildFile; fileRef = $($ids.Assets) /* Assets.xcassets */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		$($ids.Product) /* Cashflare.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Cashflare.app; sourceTree = BUILT_PRODUCTS_DIR; };
		$($ids.AppSwift) /* CashflareApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = CashflareApp.swift; sourceTree = "<group>"; };
		$($ids.ContentSwift) /* ContentView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = ContentView.swift; sourceTree = "<group>"; };
		$($ids.CurrencySwift) /* Currency.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = Currency.swift; sourceTree = "<group>"; };
		$($ids.GameStateSwift) /* GameState.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GameState.swift; sourceTree = "<group>"; };
		$($ids.BillFactorySwift) /* BillFactory.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = BillFactory.swift; sourceTree = "<group>"; };
		$($ids.GameSceneSwift) /* GameScene.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = GameScene.swift; sourceTree = "<group>"; };
		$($ids.Assets) /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		$($ids.Frameworks) /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		$($ids.GroupRoot) = {
			isa = PBXGroup;
			children = (
				$($ids.GroupApp) /* Cashflare */,
				$($ids.GroupProducts) /* Products */,
			);
			sourceTree = "<group>";
		};
		$($ids.GroupProducts) /* Products */ = {
			isa = PBXGroup;
			children = (
				$($ids.Product) /* Cashflare.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
		$($ids.GroupApp) /* Cashflare */ = {
			isa = PBXGroup;
			children = (
				$($ids.AppSwift) /* CashflareApp.swift */,
				$($ids.ContentSwift) /* ContentView.swift */,
				$($ids.GroupGame) /* Game */,
				$($ids.Assets) /* Assets.xcassets */,
			);
			path = Cashflare;
			sourceTree = "<group>";
		};
		$($ids.GroupGame) /* Game */ = {
			isa = PBXGroup;
			children = (
				$($ids.CurrencySwift) /* Currency.swift */,
				$($ids.GameStateSwift) /* GameState.swift */,
				$($ids.BillFactorySwift) /* BillFactory.swift */,
				$($ids.GameSceneSwift) /* GameScene.swift */,
			);
			path = Game;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		$($ids.Target) /* Cashflare */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = $($ids.TargetConfigList) /* Build configuration list for PBXNativeTarget "Cashflare" */;
			buildPhases = (
				$($ids.Sources) /* Sources */,
				$($ids.Frameworks) /* Frameworks */,
				$($ids.Resources) /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = Cashflare;
			productName = Cashflare;
			productReference = $($ids.Product) /* Cashflare.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		$($ids.Project) /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
			};
			buildConfigurationList = $($ids.ProjectConfigList) /* Build configuration list for PBXProject "Cashflare" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = $($ids.GroupRoot);
			productRefGroup = $($ids.GroupProducts) /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				$($ids.Target) /* Cashflare */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		$($ids.Resources) /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				$($ids.BF_Assets) /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		$($ids.Sources) /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				$($ids.BF_App) /* CashflareApp.swift in Sources */,
				$($ids.BF_Content) /* ContentView.swift in Sources */,
				$($ids.BF_Currency) /* Currency.swift in Sources */,
				$($ids.BF_GameState) /* GameState.swift in Sources */,
				$($ids.BF_BillFactory) /* BillFactory.swift in Sources */,
				$($ids.BF_GameScene) /* GameScene.swift in Sources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		$($ids.ProjectDebug) /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		$($ids.ProjectRelease) /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 5.0;
				VALIDATE_PRODUCT = YES;
			};
			name = Release;
		};
		$($ids.TargetDebug) /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = Cashflare;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.krayd.cashflare;
				PRODUCT_NAME = Cashflare;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Debug;
		};
		$($ids.TargetRelease) /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_TEAM = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = Cashflare;
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations = UIInterfaceOrientationPortrait;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.krayd.cashflare;
				PRODUCT_NAME = Cashflare;
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		$($ids.ProjectConfigList) /* Build configuration list for PBXProject "Cashflare" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$($ids.ProjectDebug) /* Debug */,
				$($ids.ProjectRelease) /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		$($ids.TargetConfigList) /* Build configuration list for PBXNativeTarget "Cashflare" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				$($ids.TargetDebug) /* Debug */,
				$($ids.TargetRelease) /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = $($ids.Project) /* Project object */;
}
"@

Set-Content -Path (Join-Path $projDir 'project.pbxproj') -Value $pbx -Encoding UTF8
Write-Host 'OK'
Get-ChildItem -Recurse $root | Select-Object FullName
