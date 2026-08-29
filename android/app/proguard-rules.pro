# Razorpay
-keep class com.razorpay.** { *; }
-keep class proguard.annotation.Keep { *; }
-keep class proguard.annotation.KeepClassMembers { *; }
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
