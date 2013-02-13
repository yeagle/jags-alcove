#include <Module.h>
#include <functions/ALCOVEfunc.h>

using std::vector;

namespace alcove {

class ALCOVEModule : public Module {
  public:
    ALCOVEModule();
    ~ALCOVEModule();
};

ALCOVEModule::ALCOVEModule() : Module("alcove")
{
  //Load functions
  insert(new AlcoveFunc());
}

ALCOVEModule::~ALCOVEModule() 
{
  vector<Function*> const &fvec = functions();
  for (unsigned int i = 0; i < fvec.size(); ++i) {
    delete fvec[i];
  }
}

} // namespace alcove

alcove::ALCOVEModule _alcove_module;
