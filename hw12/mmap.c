#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <signal.h>
#include <stdint.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <math.h>

#include <sys/types.h>

static size_t page_size;

// align_down - rounds a value down to an alignment
// @x: the value
// @a: the alignment (must be power of 2)
//
// Returns an aligned value.
#define align_down(x, a) ((x) & ~((typeof(x))(a) - 1))

#define AS_LIMIT	(1 << 25) // Maximum limit on virtual memory bytes
#define MAX_SQRTS	(1 << 27) // Maximum limit on sqrt table entries
static double *sqrts;

// Use this helper function as an oracle for square root values.
static void
calculate_sqrts(double *sqrt_pos, int start, int nr)
{
  int i;

  for (i = 0; i < nr; i++)
    sqrt_pos[i] = sqrt((double)(start + i));
}

int segv_cnt = 0;
static void *prev_mapped = NULL;

static void
handle_sigsegv(int sig, siginfo_t *si, void *ctx)
{
  // Your code here.

  // replace these three lines with your implementation
//   uintptr_t fault_addr = (uintptr_t)si->si_addr;
//   exit(EXIT_FAILURE);

  uintptr_t fault_addr = (uintptr_t)si->si_addr;
  uintptr_t aligned = align_down(fault_addr, page_size);
  uintptr_t start_index = (aligned - (uintptr_t)sqrts) / sizeof(double);
  void *mapped = NULL;

  segv_cnt++;
  printf("oops got SIGSEGV %d at 0x%lx\n", segv_cnt, aligned);

  // check if mmaped
  int r = msync((void *)aligned, page_size, 0);

  printf("%d\n", r);

  if (prev_mapped) {
    if (munmap(prev_mapped, page_size) < 0) {
      printf("munmap fails\n");
      exit(EXIT_FAILURE);
    }
  }

  if ((mapped = mmap((void *)aligned, page_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0)) < 0) {
    printf("mmap fails\n");
    exit(EXIT_FAILURE);
  }

  prev_mapped = mapped;

//   if (r <= 0) {
//     // already mmaped, first munmap
//     if (errno != ENOMEM) {
//         printf("munmap 0x%lx\n", aligned);

//         if (munmap((void *)aligned, page_size) < 0) {
//             printf("munmap fails\n");
//             exit(EXIT_FAILURE);
//         }
//     }
//     mapped = mmap((void *)aligned, page_size, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
//     if ((uintptr_t)mapped == -1) {
//         printf("mmap fails: %s\n", strerror(errno));
//         exit(EXIT_FAILURE);
//     }
//   }

  printf("Calculating at %p\n", mapped);
  calculate_sqrts(mapped, start_index, page_size / sizeof(double));
}

static void
setup_sqrt_region(void)
{
  struct rlimit lim = {AS_LIMIT, AS_LIMIT};
  struct sigaction act;

  // Only mapping to find a safe location for the table.
  sqrts = mmap(NULL, MAX_SQRTS * sizeof(double) + AS_LIMIT, PROT_NONE,
	       MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  if (sqrts == MAP_FAILED) {
    fprintf(stderr, "Couldn't mmap() region for sqrt table; %s\n",
	    strerror(errno));
    exit(EXIT_FAILURE);
  }

  // Now release the virtual memory to remain under the rlimit.
  if (munmap(sqrts, MAX_SQRTS * sizeof(double) + AS_LIMIT) == -1) {
    fprintf(stderr, "Couldn't munmap() region for sqrt table; %s\n",
            strerror(errno));
    exit(EXIT_FAILURE);
  }

  // Set a soft rlimit on virtual address-space bytes.
  if (setrlimit(RLIMIT_AS, &lim) == -1) {
    fprintf(stderr, "Couldn't set rlimit on RLIMIT_AS; %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }

  // Register a signal handler to capture SIGSEGV.
  act.sa_sigaction = handle_sigsegv;
  act.sa_flags = SA_SIGINFO;
  sigemptyset(&act.sa_mask);
  if (sigaction(SIGSEGV, &act, NULL) == -1) {
    fprintf(stderr, "Couldn't set up SIGSEGV handler;, %s\n", strerror(errno));
    exit(EXIT_FAILURE);
  }
}

static void
test_sqrt_region(void)
{
  int i, pos = rand() % (MAX_SQRTS - 1);
  double correct_sqrt;

  printf("Validating square root table contents...\n");
  srand(0xDEADBEEF);

  for (i = 0; i < 500000; i++) {
    if (i % 2 == 0)
      pos = rand() % (MAX_SQRTS - 1);
    else
      pos += 1;
    printf("Try to calculate at %p\n", &correct_sqrt);
    calculate_sqrts(&correct_sqrt, pos, 1);
    if (sqrts[pos] != correct_sqrt) {
      fprintf(stderr, "Square root is incorrect. Expected %f, got %f.\n",
              correct_sqrt, sqrts[pos]);
      exit(EXIT_FAILURE);
    }
  }

  printf("All tests passed!\n");
}

int
main(int argc, char *argv[])
{
  page_size = sysconf(_SC_PAGESIZE);
  printf("page_size is %ld\n", page_size);
  setup_sqrt_region();
  test_sqrt_region();
  return 0;
}