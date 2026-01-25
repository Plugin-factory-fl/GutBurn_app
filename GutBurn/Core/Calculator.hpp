#ifndef Calculator_hpp
#define Calculator_hpp

#include "UserProfile.hpp"

namespace gutburn {

double computeBMR(const UserProfile& p);
double computeTDEE(double bmr, ActivityLevel level);
double getActivityMultiplier(ActivityLevel level);

} // namespace gutburn

#endif /* Calculator_hpp */
