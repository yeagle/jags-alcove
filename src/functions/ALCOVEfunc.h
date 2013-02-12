#ifndef ALCOVEFUNC_H_
#define ALCOVEFUNC_H_

#include <function/ArrayFunction.h>

namespace alcove {

class AlcoveFunc : public ArrayFunction 
{
  public:
    AlcoveFunc();

    void evaluate(double *value, std::vector<double const *> 
        const &args, std::vector<std::vector<unsigned int> > const &dims) const;
    std::vector<unsigned int> dim(std::vector<std::vector<unsigned int> > const &dims) const;
    bool checkParameterDim(std::vector<std::vector<unsigned int> > const &dims) const;
    };

}

#endif /* ALCOVEFUNC_H_ */
