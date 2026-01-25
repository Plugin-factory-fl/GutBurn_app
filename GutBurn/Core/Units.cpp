#include "Units.hpp"

namespace gutburn {

double lbToKg(double lb) {
    return lb * 0.453592;
}

double ftInToCm(int ft, int in) {
    return (ft * 30.48) + (in * 2.54);
}

} // namespace gutburn
