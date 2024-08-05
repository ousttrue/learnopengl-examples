#include <string>

extern "C" int str_len(const char *p) {
  if (p) {
    std::string src(p);
    return src.size();
  } else {
    return 0;
  }
}
