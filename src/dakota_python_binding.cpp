#include <iostream>
#include "dakface.hpp"
#include <boost/python.hpp>
namespace bp = boost::python;

#if BOOST_VERSION < 106500
namespace bpn = boost::python::numeric;
#endif



#define MAKE_ARGV \
  char *argv[10]; \
  int argc = 0; \
  argv[argc++] = const_cast<char*>("dakota"); \
  argv[argc++] = const_cast<char*>("-i"); \
  argv[argc++] = infile; \
  if (outfile && strlen(outfile)) { \
    argv[argc++] = const_cast<char*>("-o"); \
    argv[argc++] = outfile; \
  } \
  if (errfile && strlen(errfile)) { \
    argv[argc++] = const_cast<char*>("-e"); \
    argv[argc++] = errfile; \
  }

int run_dakota(char *infile, char *outfile, char *errfile, bp::object exc, int restart, bool throw_on_error)
{

  MAKE_ARGV
  if (restart==1){
    argv[argc++] = const_cast<char*>("-r"); \
    argv[argc++] = const_cast<char*>("dakota.rst");
  }

  void *tmp_exc = NULL;
  if (exc)
    tmp_exc = &exc;

  return all_but_actual_main(argc, argv, tmp_exc, throw_on_error);
}

void translator(const int& exc)
{
  if (!PyErr_Occurred()) {
    // No exception recorded yet.
    //     PyErr_SetString(PyExc_RuntimeError, "DAKOTA run failed");
  }
}


#include <boost/python.hpp>
#include <numpy/arrayobject.h>
using namespace boost::python;
BOOST_PYTHON_MODULE(carolina)
{

#if BOOST_VERSION < 106500
  using namespace bpn;
#endif

#if PY_MAJOR_VERSION >= 3
  import_array1();
#else
  import_array();
#endif

#if BOOST_VERSION < 106500
  array::set_module_and_type("numpy", "ndarray");
#endif

  register_exception_translator<int>(&translator);

  def("run_dakota", run_dakota, "run dakota");
}


/*
 * Local Variables:
 * mode: C++
 * End:
 */
