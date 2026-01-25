#include "Calculator.hpp"

namespace gutburn {

double getActivityMultiplier(ActivityLevel level) {
    switch (level) {
        case ActivityLevel::Sedentary:        return 1.2;
        case ActivityLevel::LightlyActive:    return 1.375;
        case ActivityLevel::ModeratelyActive: return 1.55;
        case ActivityLevel::VeryActive:       return 1.725;
        case ActivityLevel::ExtremelyActive: return 1.9;
    }
    return 1.2;
}

double computeBMR(const UserProfile& p) {
    double bmr = (10.0 * p.weightKg) + (6.25 * p.heightCm) - (5.0 * p.age);
    return p.isMale ? bmr + 5.0 : bmr - 161.0;
}

double computeTDEE(double bmr, ActivityLevel level) {
    return bmr * getActivityMultiplier(level);
}

} // namespace gutburn
