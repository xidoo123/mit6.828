#include "types.h"
#include "user.h"
#include "date.h"

int
main(int argc, char *argv[])
{
  struct rtcdate r;

  if (date(&r)) {
    printf(2, "date failed\n");
    exit();
  }

  // your code to print the time in any format you like...

    // struct rtcdate {
    //     uint second;
    //     uint minute;
    //     uint hour;
    //     uint day;
    //     uint month;
    //     uint year;
    // };

  printf(1, "%d.%d.%d, %d:%d:%d\n", r.year, r.month, r.day, r.hour, r.minute, r.second);

  exit();
}