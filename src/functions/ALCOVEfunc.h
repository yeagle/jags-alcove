#ifndef ALCOVEFUNC_H_
#define ALCOVEFUNC_H_

#include <function/ArrayFunction.h>

namespace jags {
namespace alcove {

class AlcoveFunc : public ArrayFunction 
{
  public:
    AlcoveFunc();

    void evaluate(double *value, std::vector<double const *> 
        const &args, std::vector<std::vector<unsigned int> > const &dims) const;
    std::vector<unsigned int> dim(std::vector<std::vector<unsigned int> > const &dims,
        std::vector <double const *> const &values) const;
    bool checkParameterDim(std::vector<std::vector<unsigned int> > const &dims) const;
    bool checkParameterValue(std::vector<double const *> const &args, 
        std::vector<std::vector<unsigned int> > const &dims) const;
};

} // namespace alcove
} // namespace jags

#endif /* ALCOVEFUNC_H_ */
