#import <Foundation/Foundation.h>
#include "CalculatorBridge.hpp"
#include "Calculator.hpp"
#include "Units.hpp"
#include <cstdlib>
#include <cstring>

namespace gutburn {

static double parseDouble(const std::string& s) {
    if (s.empty()) return -1.0;
    char* end = nullptr;
    double v = std::strtod(s.c_str(), &end);
    return (end && *end == '\0') ? v : -1.0;
}

static int parseInt(const std::string& s) {
    if (s.empty()) return -1;
    char* end = nullptr;
    long v = std::strtol(s.c_str(), &end, 10);
    return (end && *end == '\0' && v >= 0 && v <= 150) ? static_cast<int>(v) : -1;
}

BridgeResult calculateFromInputs(
    bool useMetric,
    const std::string& weightStr,
    const std::string& heightCmOrFtStr,
    const std::string& heightInStr,
    const std::string& ageStr,
    bool isMale,
    int activityIndex
) {
    BridgeResult out;
    double weightKg;
    double heightCm;

    if (useMetric) {
        weightKg = parseDouble(weightStr);
        heightCm = parseDouble(heightCmOrFtStr);
        if (weightKg <= 0 || heightCm <= 0) return out;
    } else {
        double weightLb = parseDouble(weightStr);
        int ft = parseInt(heightCmOrFtStr);
        int in = heightInStr.empty() ? 0 : parseInt(heightInStr);
        if (weightLb <= 0 || ft < 0 || in < 0) return out;
        weightKg = lbToKg(weightLb);
        heightCm = ftInToCm(ft, in);
        if (heightCm <= 0) return out;
    }

    int age = parseInt(ageStr);
    if (age <= 0) return out;

    ActivityLevel level = ActivityLevel::Sedentary;
    if (activityIndex == 0) level = ActivityLevel::Sedentary;       // 0-10 min
    else if (activityIndex == 1) level = ActivityLevel::LightlyActive;   // 10-30 min
    else if (activityIndex == 2) level = ActivityLevel::ModeratelyActive; // 1 hour
    else if (activityIndex == 3) level = ActivityLevel::VeryActive;      // 1.5 hours
    else if (activityIndex == 4) level = ActivityLevel::ExtremelyActive; // 2 hours

    UserProfile p;
    p.age = age;
    p.isMale = isMale;
    p.weightKg = weightKg;
    p.heightCm = heightCm;
    p.activityLevel = level;

    double bmr = computeBMR(p);
    double tdee = computeTDEE(bmr, level);

    out.bmr = bmr;
    out.tdee = tdee;
    out.valid = true;
    return out;
}

} // namespace gutburn
