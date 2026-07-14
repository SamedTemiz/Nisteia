# Keep rules for release (R8) builds. Flutter's own Gradle plugin enables
# minification/resource shrinking by default for the `release` build type
# even though this project's build.gradle.kts never set isMinifyEnabled
# explicitly — discovered 2026-07-14 via a real-device crash (WorkManager's
# Room database failed to initialize under R8; root-caused to an unused
# transitive dependency, since removed — see pubspec.yaml).
#
# These rules are defensive: keep the plugins we actually ship so a future
# addition doesn't silently break the same way in a release-only build that
# debug testing can never catch.

# flutter_local_notifications
-keep class com.dexterous.** { *; }

# Google Play Billing (in_app_purchase_android)
-keep class com.android.billingclient.** { *; }
-keep class com.google.android.gms.** { *; }

# AndroidX WorkManager — Room-generated DB/DAO classes must survive R8.
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep public class * extends androidx.startup.Initializer

# AndroidX Room (WorkManager's WorkDatabase uses it internally).
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *
-dontwarn androidx.room.paging.**
