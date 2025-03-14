# Keep TensorFlow Lite classes
-keep class org.tensorflow.** { *; }
-keep class com.google.android.odml.image.** { *; }

# Keep GPU delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }

# Keep all native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Prevent obfuscation of classes used in reflection
-keepattributes *Annotation*

# Ensure TFLite dependencies are not removed
-dontwarn org.tensorflow.lite.**
-dontwarn com.google.android.odml.image.**
