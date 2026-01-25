#ifndef UserProfile_hpp
#define UserProfile_hpp

namespace gutburn {

enum class ActivityLevel {
    Sedentary,
    LightlyActive,
    ModeratelyActive,
    VeryActive,
    ExtremelyActive
};

struct UserProfile {
    int age = 0;
    bool isMale = true;
    double weightKg = 0.0;
    double heightCm = 0.0;
    ActivityLevel activityLevel = ActivityLevel::Sedentary;
};

} // namespace gutburn

#endif /* UserProfile_hpp */
