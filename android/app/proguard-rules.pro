# CPMK 6: aturan ProGuard/R8 supaya obfuscation tidak merusak library
# yang pakai reflection (Supabase/Hive/Provider aman tanpa rules khusus,
# tapi beberapa plugin native butuh pengecualian eksplisit).

# Flutter Play Store Split (deferred components) — default Flutter
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Hive — pakai reflection untuk TypeAdapter kalau nanti pakai @HiveType
-keep class * extends com.hive.** { *; }
-keepclassmembers class * {
    @hive.HiveField <fields>;
}

# flutter_secure_storage & connectivity_plus — plugin platform channel standar,
# aman tanpa rules tambahan, tapi baris ini mencegah R8 menghapus native binding.
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Supabase (gotrue/postgrest) pakai model serialization — jaga nama field.
-keepattributes Signature
-keepattributes *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Hilangkan log debug di build release (opsional tapi bagus untuk audit keamanan)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
