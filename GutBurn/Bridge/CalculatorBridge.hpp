#ifndef CalculatorBridge_hpp
#define CalculatorBridge_hpp

#include "UserProfile.hpp"
#include <string>

namespace gutburn {

struct BridgeResult {
    double bmr = 0.0;
    double tdee = 0.0;
    bool valid = false;
};

BridgeResult calculateFromInputs(
    bool useMetric,
    const std::string& weightStr,
    const std::string& heightCmOrFtStr,
    const std::string& heightInStr,
    const std::string& ageStr,
    bool isMale,
    int activityIndex
);

} // namespace gutburn

#endif /* CalculatorBridge_hpp */
