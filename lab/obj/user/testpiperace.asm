
obj/user/testpiperace.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 b3 01 00 00       	call   8001e4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 1c             	sub    $0x1c,%esp
	int p[2], r, pid, i, max;
	void *va;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for dup race...\n");
  80003b:	68 40 27 80 00       	push   $0x802740
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e3 20 00 00       	call   802133 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 59 27 80 00       	push   $0x802759
  80005d:	6a 0d                	push   $0xd
  80005f:	68 62 27 80 00       	push   $0x802762
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 a4 0f 00 00       	call   801012 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 76 27 80 00       	push   $0x802776
  80007a:	6a 10                	push   $0x10
  80007c:	68 62 27 80 00       	push   $0x802762
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 c8 13 00 00       	call   80145d <close>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	bb c8 00 00 00       	mov    $0xc8,%ebx
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
			if(pipeisclosed(p[0])){
  80009d:	83 ec 0c             	sub    $0xc,%esp
  8000a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8000a3:	e8 de 21 00 00       	call   802286 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 7f 27 80 00       	push   $0x80277f
  8000b7:	e8 61 02 00 00       	call   80031d <cprintf>
				exit();
  8000bc:	e8 69 01 00 00       	call   80022a <exit>
  8000c1:	83 c4 10             	add    $0x10,%esp
			}
			sys_yield();
  8000c4:	e8 bd 0b 00 00       	call   800c86 <sys_yield>
		//
		// If a clock interrupt catches dup between mapping the
		// fd and mapping the pipe structure, we'll have the same
		// ref counts, still a no-no.
		//
		for (i=0; i<max; i++) {
  8000c9:	83 eb 01             	sub    $0x1,%ebx
  8000cc:	75 cf                	jne    80009d <umain+0x6a>
				exit();
			}
			sys_yield();
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	6a 00                	push   $0x0
  8000d3:	6a 00                	push   $0x0
  8000d5:	6a 00                	push   $0x0
  8000d7:	e8 ed 10 00 00       	call   8011c9 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 9a 27 80 00       	push   $0x80279a
  8000e8:	e8 30 02 00 00       	call   80031d <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  8000ed:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  8000f3:	83 c4 08             	add    $0x8,%esp
  8000f6:	6b c6 7c             	imul   $0x7c,%esi,%eax
  8000f9:	c1 f8 02             	sar    $0x2,%eax
  8000fc:	69 c0 df 7b ef bd    	imul   $0xbdef7bdf,%eax,%eax
  800102:	50                   	push   %eax
  800103:	68 a5 27 80 00       	push   $0x8027a5
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 93 13 00 00       	call   8014ad <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 78 13 00 00       	call   8014ad <dup>
  800135:	83 c4 10             	add    $0x10,%esp
	cprintf("pid is %d\n", pid);
	va = 0;
	kid = &envs[ENVX(pid)];
	cprintf("kid is %d\n", kid-envs);
	dup(p[0], 10);
	while (kid->env_status == ENV_RUNNABLE)
  800138:	8b 53 54             	mov    0x54(%ebx),%edx
  80013b:	83 fa 02             	cmp    $0x2,%edx
  80013e:	74 e8                	je     800128 <umain+0xf5>
		dup(p[0], 10);

	cprintf("child done with loop\n");
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	68 b0 27 80 00       	push   $0x8027b0
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 2e 21 00 00       	call   802286 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 0c 28 80 00       	push   $0x80280c
  800167:	6a 3a                	push   $0x3a
  800169:	68 62 27 80 00       	push   $0x802762
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 b1 11 00 00       	call   801333 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 c6 27 80 00       	push   $0x8027c6
  80018f:	6a 3c                	push   $0x3c
  800191:	68 62 27 80 00       	push   $0x802762
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 27 11 00 00       	call   8012cd <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 0d 19 00 00       	call   801abb <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 de 27 80 00       	push   $0x8027de
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 f4 27 80 00       	push   $0x8027f4
  8001d5:	e8 43 01 00 00       	call   80031d <cprintf>
  8001da:	83 c4 10             	add    $0x10,%esp
}
  8001dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e0:	5b                   	pop    %ebx
  8001e1:	5e                   	pop    %esi
  8001e2:	5d                   	pop    %ebp
  8001e3:	c3                   	ret    

008001e4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e4:	55                   	push   %ebp
  8001e5:	89 e5                	mov    %esp,%ebp
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001ec:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ef:	e8 73 0a 00 00       	call   800c67 <sys_getenvid>
  8001f4:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800201:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800206:	85 db                	test   %ebx,%ebx
  800208:	7e 07                	jle    800211 <libmain+0x2d>
		binaryname = argv[0];
  80020a:	8b 06                	mov    (%esi),%eax
  80020c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800211:	83 ec 08             	sub    $0x8,%esp
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	e8 18 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80021b:	e8 0a 00 00 00       	call   80022a <exit>
}
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800226:	5b                   	pop    %ebx
  800227:	5e                   	pop    %esi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800230:	e8 53 12 00 00       	call   801488 <close_all>
	sys_env_destroy(0);
  800235:	83 ec 0c             	sub    $0xc,%esp
  800238:	6a 00                	push   $0x0
  80023a:	e8 e7 09 00 00       	call   800c26 <sys_env_destroy>
}
  80023f:	83 c4 10             	add    $0x10,%esp
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800244:	55                   	push   %ebp
  800245:	89 e5                	mov    %esp,%ebp
  800247:	56                   	push   %esi
  800248:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800249:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80024c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800252:	e8 10 0a 00 00       	call   800c67 <sys_getenvid>
  800257:	83 ec 0c             	sub    $0xc,%esp
  80025a:	ff 75 0c             	pushl  0xc(%ebp)
  80025d:	ff 75 08             	pushl  0x8(%ebp)
  800260:	56                   	push   %esi
  800261:	50                   	push   %eax
  800262:	68 40 28 80 00       	push   $0x802840
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 57 27 80 00 	movl   $0x802757,(%esp)
  80027f:	e8 99 00 00 00       	call   80031d <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800287:	cc                   	int3   
  800288:	eb fd                	jmp    800287 <_panic+0x43>

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 04             	sub    $0x4,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 13                	mov    (%ebx),%edx
  800296:	8d 42 01             	lea    0x1(%edx),%eax
  800299:	89 03                	mov    %eax,(%ebx)
  80029b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 1a                	jne    8002c3 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a9:	83 ec 08             	sub    $0x8,%esp
  8002ac:	68 ff 00 00 00       	push   $0xff
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	50                   	push   %eax
  8002b5:	e8 2f 09 00 00       	call   800be9 <sys_cputs>
		b->idx = 0;
  8002ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002c0:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002c3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002ca:	c9                   	leave  
  8002cb:	c3                   	ret    

008002cc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002dc:	00 00 00 
	b.cnt = 0;
  8002df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	ff 75 08             	pushl  0x8(%ebp)
  8002ef:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002f5:	50                   	push   %eax
  8002f6:	68 8a 02 80 00       	push   $0x80028a
  8002fb:	e8 54 01 00 00       	call   800454 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800300:	83 c4 08             	add    $0x8,%esp
  800303:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800309:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80030f:	50                   	push   %eax
  800310:	e8 d4 08 00 00       	call   800be9 <sys_cputs>

	return b.cnt;
}
  800315:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80031b:	c9                   	leave  
  80031c:	c3                   	ret    

0080031d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800323:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800326:	50                   	push   %eax
  800327:	ff 75 08             	pushl  0x8(%ebp)
  80032a:	e8 9d ff ff ff       	call   8002cc <vcprintf>
	va_end(ap);

	return cnt;
}
  80032f:	c9                   	leave  
  800330:	c3                   	ret    

00800331 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 1c             	sub    $0x1c,%esp
  80033a:	89 c7                	mov    %eax,%edi
  80033c:	89 d6                	mov    %edx,%esi
  80033e:	8b 45 08             	mov    0x8(%ebp),%eax
  800341:	8b 55 0c             	mov    0xc(%ebp),%edx
  800344:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800347:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80034a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80034d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800352:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800355:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800358:	39 d3                	cmp    %edx,%ebx
  80035a:	72 05                	jb     800361 <printnum+0x30>
  80035c:	39 45 10             	cmp    %eax,0x10(%ebp)
  80035f:	77 45                	ja     8003a6 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800361:	83 ec 0c             	sub    $0xc,%esp
  800364:	ff 75 18             	pushl  0x18(%ebp)
  800367:	8b 45 14             	mov    0x14(%ebp),%eax
  80036a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80036d:	53                   	push   %ebx
  80036e:	ff 75 10             	pushl  0x10(%ebp)
  800371:	83 ec 08             	sub    $0x8,%esp
  800374:	ff 75 e4             	pushl  -0x1c(%ebp)
  800377:	ff 75 e0             	pushl  -0x20(%ebp)
  80037a:	ff 75 dc             	pushl  -0x24(%ebp)
  80037d:	ff 75 d8             	pushl  -0x28(%ebp)
  800380:	e8 2b 21 00 00       	call   8024b0 <__udivdi3>
  800385:	83 c4 18             	add    $0x18,%esp
  800388:	52                   	push   %edx
  800389:	50                   	push   %eax
  80038a:	89 f2                	mov    %esi,%edx
  80038c:	89 f8                	mov    %edi,%eax
  80038e:	e8 9e ff ff ff       	call   800331 <printnum>
  800393:	83 c4 20             	add    $0x20,%esp
  800396:	eb 18                	jmp    8003b0 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800398:	83 ec 08             	sub    $0x8,%esp
  80039b:	56                   	push   %esi
  80039c:	ff 75 18             	pushl  0x18(%ebp)
  80039f:	ff d7                	call   *%edi
  8003a1:	83 c4 10             	add    $0x10,%esp
  8003a4:	eb 03                	jmp    8003a9 <printnum+0x78>
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a9:	83 eb 01             	sub    $0x1,%ebx
  8003ac:	85 db                	test   %ebx,%ebx
  8003ae:	7f e8                	jg     800398 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003b0:	83 ec 08             	sub    $0x8,%esp
  8003b3:	56                   	push   %esi
  8003b4:	83 ec 04             	sub    $0x4,%esp
  8003b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8003bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8003c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8003c3:	e8 18 22 00 00       	call   8025e0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 63 28 80 00 	movsbl 0x802863(%eax),%eax
  8003d2:	50                   	push   %eax
  8003d3:	ff d7                	call   *%edi
}
  8003d5:	83 c4 10             	add    $0x10,%esp
  8003d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003db:	5b                   	pop    %ebx
  8003dc:	5e                   	pop    %esi
  8003dd:	5f                   	pop    %edi
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003e3:	83 fa 01             	cmp    $0x1,%edx
  8003e6:	7e 0e                	jle    8003f6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	8b 52 04             	mov    0x4(%edx),%edx
  8003f4:	eb 22                	jmp    800418 <getuint+0x38>
	else if (lflag)
  8003f6:	85 d2                	test   %edx,%edx
  8003f8:	74 10                	je     80040a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ff:	89 08                	mov    %ecx,(%eax)
  800401:	8b 02                	mov    (%edx),%eax
  800403:	ba 00 00 00 00       	mov    $0x0,%edx
  800408:	eb 0e                	jmp    800418 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80040f:	89 08                	mov    %ecx,(%eax)
  800411:	8b 02                	mov    (%edx),%eax
  800413:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800420:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800424:	8b 10                	mov    (%eax),%edx
  800426:	3b 50 04             	cmp    0x4(%eax),%edx
  800429:	73 0a                	jae    800435 <sprintputch+0x1b>
		*b->buf++ = ch;
  80042b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80042e:	89 08                	mov    %ecx,(%eax)
  800430:	8b 45 08             	mov    0x8(%ebp),%eax
  800433:	88 02                	mov    %al,(%edx)
}
  800435:	5d                   	pop    %ebp
  800436:	c3                   	ret    

00800437 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800437:	55                   	push   %ebp
  800438:	89 e5                	mov    %esp,%ebp
  80043a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80043d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800440:	50                   	push   %eax
  800441:	ff 75 10             	pushl  0x10(%ebp)
  800444:	ff 75 0c             	pushl  0xc(%ebp)
  800447:	ff 75 08             	pushl  0x8(%ebp)
  80044a:	e8 05 00 00 00       	call   800454 <vprintfmt>
	va_end(ap);
}
  80044f:	83 c4 10             	add    $0x10,%esp
  800452:	c9                   	leave  
  800453:	c3                   	ret    

00800454 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	57                   	push   %edi
  800458:	56                   	push   %esi
  800459:	53                   	push   %ebx
  80045a:	83 ec 2c             	sub    $0x2c,%esp
  80045d:	8b 75 08             	mov    0x8(%ebp),%esi
  800460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800463:	8b 7d 10             	mov    0x10(%ebp),%edi
  800466:	eb 12                	jmp    80047a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800468:	85 c0                	test   %eax,%eax
  80046a:	0f 84 89 03 00 00    	je     8007f9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800470:	83 ec 08             	sub    $0x8,%esp
  800473:	53                   	push   %ebx
  800474:	50                   	push   %eax
  800475:	ff d6                	call   *%esi
  800477:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80047a:	83 c7 01             	add    $0x1,%edi
  80047d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800481:	83 f8 25             	cmp    $0x25,%eax
  800484:	75 e2                	jne    800468 <vprintfmt+0x14>
  800486:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80048a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800491:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800498:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80049f:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a4:	eb 07                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8004a9:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ad:	8d 47 01             	lea    0x1(%edi),%eax
  8004b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004b3:	0f b6 07             	movzbl (%edi),%eax
  8004b6:	0f b6 c8             	movzbl %al,%ecx
  8004b9:	83 e8 23             	sub    $0x23,%eax
  8004bc:	3c 55                	cmp    $0x55,%al
  8004be:	0f 87 1a 03 00 00    	ja     8007de <vprintfmt+0x38a>
  8004c4:	0f b6 c0             	movzbl %al,%eax
  8004c7:	ff 24 85 a0 29 80 00 	jmp    *0x8029a0(,%eax,4)
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004d1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004d5:	eb d6                	jmp    8004ad <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004e5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004e9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004ec:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004ef:	83 fa 09             	cmp    $0x9,%edx
  8004f2:	77 39                	ja     80052d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f7:	eb e9                	jmp    8004e2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 48 04             	lea    0x4(%eax),%ecx
  8004ff:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800502:	8b 00                	mov    (%eax),%eax
  800504:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050a:	eb 27                	jmp    800533 <vprintfmt+0xdf>
  80050c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	b9 00 00 00 00       	mov    $0x0,%ecx
  800516:	0f 49 c8             	cmovns %eax,%ecx
  800519:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80051f:	eb 8c                	jmp    8004ad <vprintfmt+0x59>
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800524:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80052b:	eb 80                	jmp    8004ad <vprintfmt+0x59>
  80052d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800530:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800533:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800537:	0f 89 70 ff ff ff    	jns    8004ad <vprintfmt+0x59>
				width = precision, precision = -1;
  80053d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800540:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800543:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80054a:	e9 5e ff ff ff       	jmp    8004ad <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80054f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800555:	e9 53 ff ff ff       	jmp    8004ad <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 50 04             	lea    0x4(%eax),%edx
  800560:	89 55 14             	mov    %edx,0x14(%ebp)
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	53                   	push   %ebx
  800567:	ff 30                	pushl  (%eax)
  800569:	ff d6                	call   *%esi
			break;
  80056b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800571:	e9 04 ff ff ff       	jmp    80047a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 50 04             	lea    0x4(%eax),%edx
  80057c:	89 55 14             	mov    %edx,0x14(%ebp)
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	99                   	cltd   
  800582:	31 d0                	xor    %edx,%eax
  800584:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800586:	83 f8 0f             	cmp    $0xf,%eax
  800589:	7f 0b                	jg     800596 <vprintfmt+0x142>
  80058b:	8b 14 85 00 2b 80 00 	mov    0x802b00(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 7b 28 80 00       	push   $0x80287b
  80059c:	53                   	push   %ebx
  80059d:	56                   	push   %esi
  80059e:	e8 94 fe ff ff       	call   800437 <printfmt>
  8005a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8005a9:	e9 cc fe ff ff       	jmp    80047a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005ae:	52                   	push   %edx
  8005af:	68 05 2d 80 00       	push   $0x802d05
  8005b4:	53                   	push   %ebx
  8005b5:	56                   	push   %esi
  8005b6:	e8 7c fe ff ff       	call   800437 <printfmt>
  8005bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005c1:	e9 b4 fe ff ff       	jmp    80047a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 50 04             	lea    0x4(%eax),%edx
  8005cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005d1:	85 ff                	test   %edi,%edi
  8005d3:	b8 74 28 80 00       	mov    $0x802874,%eax
  8005d8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005db:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005df:	0f 8e 94 00 00 00    	jle    800679 <vprintfmt+0x225>
  8005e5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005e9:	0f 84 98 00 00 00    	je     800687 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	ff 75 d0             	pushl  -0x30(%ebp)
  8005f5:	57                   	push   %edi
  8005f6:	e8 86 02 00 00       	call   800881 <strnlen>
  8005fb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fe:	29 c1                	sub    %eax,%ecx
  800600:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800603:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800606:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80060a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800610:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800612:	eb 0f                	jmp    800623 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800614:	83 ec 08             	sub    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	ff 75 e0             	pushl  -0x20(%ebp)
  80061b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80061d:	83 ef 01             	sub    $0x1,%edi
  800620:	83 c4 10             	add    $0x10,%esp
  800623:	85 ff                	test   %edi,%edi
  800625:	7f ed                	jg     800614 <vprintfmt+0x1c0>
  800627:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80062a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	b8 00 00 00 00       	mov    $0x0,%eax
  800634:	0f 49 c1             	cmovns %ecx,%eax
  800637:	29 c1                	sub    %eax,%ecx
  800639:	89 75 08             	mov    %esi,0x8(%ebp)
  80063c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80063f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800642:	89 cb                	mov    %ecx,%ebx
  800644:	eb 4d                	jmp    800693 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800646:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80064a:	74 1b                	je     800667 <vprintfmt+0x213>
  80064c:	0f be c0             	movsbl %al,%eax
  80064f:	83 e8 20             	sub    $0x20,%eax
  800652:	83 f8 5e             	cmp    $0x5e,%eax
  800655:	76 10                	jbe    800667 <vprintfmt+0x213>
					putch('?', putdat);
  800657:	83 ec 08             	sub    $0x8,%esp
  80065a:	ff 75 0c             	pushl  0xc(%ebp)
  80065d:	6a 3f                	push   $0x3f
  80065f:	ff 55 08             	call   *0x8(%ebp)
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	eb 0d                	jmp    800674 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	ff 75 0c             	pushl  0xc(%ebp)
  80066d:	52                   	push   %edx
  80066e:	ff 55 08             	call   *0x8(%ebp)
  800671:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800674:	83 eb 01             	sub    $0x1,%ebx
  800677:	eb 1a                	jmp    800693 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	eb 0c                	jmp    800693 <vprintfmt+0x23f>
  800687:	89 75 08             	mov    %esi,0x8(%ebp)
  80068a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80068d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800690:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800693:	83 c7 01             	add    $0x1,%edi
  800696:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80069a:	0f be d0             	movsbl %al,%edx
  80069d:	85 d2                	test   %edx,%edx
  80069f:	74 23                	je     8006c4 <vprintfmt+0x270>
  8006a1:	85 f6                	test   %esi,%esi
  8006a3:	78 a1                	js     800646 <vprintfmt+0x1f2>
  8006a5:	83 ee 01             	sub    $0x1,%esi
  8006a8:	79 9c                	jns    800646 <vprintfmt+0x1f2>
  8006aa:	89 df                	mov    %ebx,%edi
  8006ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8006af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006b2:	eb 18                	jmp    8006cc <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	6a 20                	push   $0x20
  8006ba:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006bc:	83 ef 01             	sub    $0x1,%edi
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	eb 08                	jmp    8006cc <vprintfmt+0x278>
  8006c4:	89 df                	mov    %ebx,%edi
  8006c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8006c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006cc:	85 ff                	test   %edi,%edi
  8006ce:	7f e4                	jg     8006b4 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d3:	e9 a2 fd ff ff       	jmp    80047a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d8:	83 fa 01             	cmp    $0x1,%edx
  8006db:	7e 16                	jle    8006f3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 50 08             	lea    0x8(%eax),%edx
  8006e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e6:	8b 50 04             	mov    0x4(%eax),%edx
  8006e9:	8b 00                	mov    (%eax),%eax
  8006eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f1:	eb 32                	jmp    800725 <vprintfmt+0x2d1>
	else if (lflag)
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	74 18                	je     80070f <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fa:	8d 50 04             	lea    0x4(%eax),%edx
  8006fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800700:	8b 00                	mov    (%eax),%eax
  800702:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800705:	89 c1                	mov    %eax,%ecx
  800707:	c1 f9 1f             	sar    $0x1f,%ecx
  80070a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80070d:	eb 16                	jmp    800725 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  80070f:	8b 45 14             	mov    0x14(%ebp),%eax
  800712:	8d 50 04             	lea    0x4(%eax),%edx
  800715:	89 55 14             	mov    %edx,0x14(%ebp)
  800718:	8b 00                	mov    (%eax),%eax
  80071a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80071d:	89 c1                	mov    %eax,%ecx
  80071f:	c1 f9 1f             	sar    $0x1f,%ecx
  800722:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800725:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800728:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80072b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800730:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800734:	79 74                	jns    8007aa <vprintfmt+0x356>
				putch('-', putdat);
  800736:	83 ec 08             	sub    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 2d                	push   $0x2d
  80073c:	ff d6                	call   *%esi
				num = -(long long) num;
  80073e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800741:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800744:	f7 d8                	neg    %eax
  800746:	83 d2 00             	adc    $0x0,%edx
  800749:	f7 da                	neg    %edx
  80074b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80074e:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800753:	eb 55                	jmp    8007aa <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800755:	8d 45 14             	lea    0x14(%ebp),%eax
  800758:	e8 83 fc ff ff       	call   8003e0 <getuint>
			base = 10;
  80075d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800762:	eb 46                	jmp    8007aa <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800764:	8d 45 14             	lea    0x14(%ebp),%eax
  800767:	e8 74 fc ff ff       	call   8003e0 <getuint>
			base = 8;
  80076c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800771:	eb 37                	jmp    8007aa <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 30                	push   $0x30
  800779:	ff d6                	call   *%esi
			putch('x', putdat);
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	53                   	push   %ebx
  80077f:	6a 78                	push   $0x78
  800781:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 50 04             	lea    0x4(%eax),%edx
  800789:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800793:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800796:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80079b:	eb 0d                	jmp    8007aa <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80079d:	8d 45 14             	lea    0x14(%ebp),%eax
  8007a0:	e8 3b fc ff ff       	call   8003e0 <getuint>
			base = 16;
  8007a5:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007aa:	83 ec 0c             	sub    $0xc,%esp
  8007ad:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007b1:	57                   	push   %edi
  8007b2:	ff 75 e0             	pushl  -0x20(%ebp)
  8007b5:	51                   	push   %ecx
  8007b6:	52                   	push   %edx
  8007b7:	50                   	push   %eax
  8007b8:	89 da                	mov    %ebx,%edx
  8007ba:	89 f0                	mov    %esi,%eax
  8007bc:	e8 70 fb ff ff       	call   800331 <printnum>
			break;
  8007c1:	83 c4 20             	add    $0x20,%esp
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007c7:	e9 ae fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	51                   	push   %ecx
  8007d1:	ff d6                	call   *%esi
			break;
  8007d3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d9:	e9 9c fc ff ff       	jmp    80047a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	53                   	push   %ebx
  8007e2:	6a 25                	push   $0x25
  8007e4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	eb 03                	jmp    8007ee <vprintfmt+0x39a>
  8007eb:	83 ef 01             	sub    $0x1,%edi
  8007ee:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007f2:	75 f7                	jne    8007eb <vprintfmt+0x397>
  8007f4:	e9 81 fc ff ff       	jmp    80047a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007fc:	5b                   	pop    %ebx
  8007fd:	5e                   	pop    %esi
  8007fe:	5f                   	pop    %edi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 45 08             	mov    0x8(%ebp),%eax
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800810:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800814:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800817:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081e:	85 c0                	test   %eax,%eax
  800820:	74 26                	je     800848 <vsnprintf+0x47>
  800822:	85 d2                	test   %edx,%edx
  800824:	7e 22                	jle    800848 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800826:	ff 75 14             	pushl  0x14(%ebp)
  800829:	ff 75 10             	pushl  0x10(%ebp)
  80082c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082f:	50                   	push   %eax
  800830:	68 1a 04 80 00       	push   $0x80041a
  800835:	e8 1a fc ff ff       	call   800454 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800840:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 05                	jmp    80084d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800855:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800858:	50                   	push   %eax
  800859:	ff 75 10             	pushl  0x10(%ebp)
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	ff 75 08             	pushl  0x8(%ebp)
  800862:	e8 9a ff ff ff       	call   800801 <vsnprintf>
	va_end(ap);

	return rc;
}
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
  800874:	eb 03                	jmp    800879 <strlen+0x10>
		n++;
  800876:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800879:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80087d:	75 f7                	jne    800876 <strlen+0xd>
		n++;
	return n;
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800881:	55                   	push   %ebp
  800882:	89 e5                	mov    %esp,%ebp
  800884:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800887:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80088a:	ba 00 00 00 00       	mov    $0x0,%edx
  80088f:	eb 03                	jmp    800894 <strnlen+0x13>
		n++;
  800891:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800894:	39 c2                	cmp    %eax,%edx
  800896:	74 08                	je     8008a0 <strnlen+0x1f>
  800898:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80089c:	75 f3                	jne    800891 <strnlen+0x10>
  80089e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008a0:	5d                   	pop    %ebp
  8008a1:	c3                   	ret    

008008a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	53                   	push   %ebx
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ac:	89 c2                	mov    %eax,%edx
  8008ae:	83 c2 01             	add    $0x1,%edx
  8008b1:	83 c1 01             	add    $0x1,%ecx
  8008b4:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008b8:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	75 ef                	jne    8008ae <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    

008008c2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008c2:	55                   	push   %ebp
  8008c3:	89 e5                	mov    %esp,%ebp
  8008c5:	53                   	push   %ebx
  8008c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c9:	53                   	push   %ebx
  8008ca:	e8 9a ff ff ff       	call   800869 <strlen>
  8008cf:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	01 d8                	add    %ebx,%eax
  8008d7:	50                   	push   %eax
  8008d8:	e8 c5 ff ff ff       	call   8008a2 <strcpy>
	return dst;
}
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ef:	89 f3                	mov    %esi,%ebx
  8008f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	89 f2                	mov    %esi,%edx
  8008f6:	eb 0f                	jmp    800907 <strncpy+0x23>
		*dst++ = *src;
  8008f8:	83 c2 01             	add    $0x1,%edx
  8008fb:	0f b6 01             	movzbl (%ecx),%eax
  8008fe:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800901:	80 39 01             	cmpb   $0x1,(%ecx)
  800904:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	39 da                	cmp    %ebx,%edx
  800909:	75 ed                	jne    8008f8 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80090b:	89 f0                	mov    %esi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5d                   	pop    %ebp
  800910:	c3                   	ret    

00800911 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80091c:	8b 55 10             	mov    0x10(%ebp),%edx
  80091f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800921:	85 d2                	test   %edx,%edx
  800923:	74 21                	je     800946 <strlcpy+0x35>
  800925:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800929:	89 f2                	mov    %esi,%edx
  80092b:	eb 09                	jmp    800936 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80092d:	83 c2 01             	add    $0x1,%edx
  800930:	83 c1 01             	add    $0x1,%ecx
  800933:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800936:	39 c2                	cmp    %eax,%edx
  800938:	74 09                	je     800943 <strlcpy+0x32>
  80093a:	0f b6 19             	movzbl (%ecx),%ebx
  80093d:	84 db                	test   %bl,%bl
  80093f:	75 ec                	jne    80092d <strlcpy+0x1c>
  800941:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800943:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800946:	29 f0                	sub    %esi,%eax
}
  800948:	5b                   	pop    %ebx
  800949:	5e                   	pop    %esi
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800952:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800955:	eb 06                	jmp    80095d <strcmp+0x11>
		p++, q++;
  800957:	83 c1 01             	add    $0x1,%ecx
  80095a:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80095d:	0f b6 01             	movzbl (%ecx),%eax
  800960:	84 c0                	test   %al,%al
  800962:	74 04                	je     800968 <strcmp+0x1c>
  800964:	3a 02                	cmp    (%edx),%al
  800966:	74 ef                	je     800957 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800968:	0f b6 c0             	movzbl %al,%eax
  80096b:	0f b6 12             	movzbl (%edx),%edx
  80096e:	29 d0                	sub    %edx,%eax
}
  800970:	5d                   	pop    %ebp
  800971:	c3                   	ret    

00800972 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c3                	mov    %eax,%ebx
  80097e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800981:	eb 06                	jmp    800989 <strncmp+0x17>
		n--, p++, q++;
  800983:	83 c0 01             	add    $0x1,%eax
  800986:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800989:	39 d8                	cmp    %ebx,%eax
  80098b:	74 15                	je     8009a2 <strncmp+0x30>
  80098d:	0f b6 08             	movzbl (%eax),%ecx
  800990:	84 c9                	test   %cl,%cl
  800992:	74 04                	je     800998 <strncmp+0x26>
  800994:	3a 0a                	cmp    (%edx),%cl
  800996:	74 eb                	je     800983 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800998:	0f b6 00             	movzbl (%eax),%eax
  80099b:	0f b6 12             	movzbl (%edx),%edx
  80099e:	29 d0                	sub    %edx,%eax
  8009a0:	eb 05                	jmp    8009a7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a7:	5b                   	pop    %ebx
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b4:	eb 07                	jmp    8009bd <strchr+0x13>
		if (*s == c)
  8009b6:	38 ca                	cmp    %cl,%dl
  8009b8:	74 0f                	je     8009c9 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 f2                	jne    8009b6 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	eb 03                	jmp    8009da <strfind+0xf>
  8009d7:	83 c0 01             	add    $0x1,%eax
  8009da:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 04                	je     8009e5 <strfind+0x1a>
  8009e1:	84 d2                	test   %dl,%dl
  8009e3:	75 f2                	jne    8009d7 <strfind+0xc>
			break;
	return (char *) s;
}
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f3:	85 c9                	test   %ecx,%ecx
  8009f5:	74 36                	je     800a2d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f7:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fd:	75 28                	jne    800a27 <memset+0x40>
  8009ff:	f6 c1 03             	test   $0x3,%cl
  800a02:	75 23                	jne    800a27 <memset+0x40>
		c &= 0xFF;
  800a04:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a08:	89 d3                	mov    %edx,%ebx
  800a0a:	c1 e3 08             	shl    $0x8,%ebx
  800a0d:	89 d6                	mov    %edx,%esi
  800a0f:	c1 e6 18             	shl    $0x18,%esi
  800a12:	89 d0                	mov    %edx,%eax
  800a14:	c1 e0 10             	shl    $0x10,%eax
  800a17:	09 f0                	or     %esi,%eax
  800a19:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a1b:	89 d8                	mov    %ebx,%eax
  800a1d:	09 d0                	or     %edx,%eax
  800a1f:	c1 e9 02             	shr    $0x2,%ecx
  800a22:	fc                   	cld    
  800a23:	f3 ab                	rep stos %eax,%es:(%edi)
  800a25:	eb 06                	jmp    800a2d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 35                	jae    800a7b <memmove+0x47>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2e                	jae    800a7b <memmove+0x47>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	89 d6                	mov    %edx,%esi
  800a52:	09 fe                	or     %edi,%esi
  800a54:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5a:	75 13                	jne    800a6f <memmove+0x3b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 0e                	jne    800a6f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a61:	83 ef 04             	sub    $0x4,%edi
  800a64:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a67:	c1 e9 02             	shr    $0x2,%ecx
  800a6a:	fd                   	std    
  800a6b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6d:	eb 09                	jmp    800a78 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6f:	83 ef 01             	sub    $0x1,%edi
  800a72:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a75:	fd                   	std    
  800a76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a78:	fc                   	cld    
  800a79:	eb 1d                	jmp    800a98 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 f2                	mov    %esi,%edx
  800a7d:	09 c2                	or     %eax,%edx
  800a7f:	f6 c2 03             	test   $0x3,%dl
  800a82:	75 0f                	jne    800a93 <memmove+0x5f>
  800a84:	f6 c1 03             	test   $0x3,%cl
  800a87:	75 0a                	jne    800a93 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	89 c7                	mov    %eax,%edi
  800a8e:	fc                   	cld    
  800a8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a91:	eb 05                	jmp    800a98 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a93:	89 c7                	mov    %eax,%edi
  800a95:	fc                   	cld    
  800a96:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a9f:	ff 75 10             	pushl  0x10(%ebp)
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	ff 75 08             	pushl  0x8(%ebp)
  800aa8:	e8 87 ff ff ff       	call   800a34 <memmove>
}
  800aad:	c9                   	leave  
  800aae:	c3                   	ret    

00800aaf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	56                   	push   %esi
  800ab3:	53                   	push   %ebx
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aba:	89 c6                	mov    %eax,%esi
  800abc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800abf:	eb 1a                	jmp    800adb <memcmp+0x2c>
		if (*s1 != *s2)
  800ac1:	0f b6 08             	movzbl (%eax),%ecx
  800ac4:	0f b6 1a             	movzbl (%edx),%ebx
  800ac7:	38 d9                	cmp    %bl,%cl
  800ac9:	74 0a                	je     800ad5 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800acb:	0f b6 c1             	movzbl %cl,%eax
  800ace:	0f b6 db             	movzbl %bl,%ebx
  800ad1:	29 d8                	sub    %ebx,%eax
  800ad3:	eb 0f                	jmp    800ae4 <memcmp+0x35>
		s1++, s2++;
  800ad5:	83 c0 01             	add    $0x1,%eax
  800ad8:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adb:	39 f0                	cmp    %esi,%eax
  800add:	75 e2                	jne    800ac1 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5b                   	pop    %ebx
  800ae5:	5e                   	pop    %esi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	53                   	push   %ebx
  800aec:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aef:	89 c1                	mov    %eax,%ecx
  800af1:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af8:	eb 0a                	jmp    800b04 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800afa:	0f b6 10             	movzbl (%eax),%edx
  800afd:	39 da                	cmp    %ebx,%edx
  800aff:	74 07                	je     800b08 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b01:	83 c0 01             	add    $0x1,%eax
  800b04:	39 c8                	cmp    %ecx,%eax
  800b06:	72 f2                	jb     800afa <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b08:	5b                   	pop    %ebx
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b17:	eb 03                	jmp    800b1c <strtol+0x11>
		s++;
  800b19:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1c:	0f b6 01             	movzbl (%ecx),%eax
  800b1f:	3c 20                	cmp    $0x20,%al
  800b21:	74 f6                	je     800b19 <strtol+0xe>
  800b23:	3c 09                	cmp    $0x9,%al
  800b25:	74 f2                	je     800b19 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b27:	3c 2b                	cmp    $0x2b,%al
  800b29:	75 0a                	jne    800b35 <strtol+0x2a>
		s++;
  800b2b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b33:	eb 11                	jmp    800b46 <strtol+0x3b>
  800b35:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b3a:	3c 2d                	cmp    $0x2d,%al
  800b3c:	75 08                	jne    800b46 <strtol+0x3b>
		s++, neg = 1;
  800b3e:	83 c1 01             	add    $0x1,%ecx
  800b41:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b46:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b4c:	75 15                	jne    800b63 <strtol+0x58>
  800b4e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b51:	75 10                	jne    800b63 <strtol+0x58>
  800b53:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b57:	75 7c                	jne    800bd5 <strtol+0xca>
		s += 2, base = 16;
  800b59:	83 c1 02             	add    $0x2,%ecx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 16                	jmp    800b79 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 12                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b6c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b6f:	75 08                	jne    800b79 <strtol+0x6e>
		s++, base = 8;
  800b71:	83 c1 01             	add    $0x1,%ecx
  800b74:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b79:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b81:	0f b6 11             	movzbl (%ecx),%edx
  800b84:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b87:	89 f3                	mov    %esi,%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x8b>
			dig = *s - '0';
  800b8e:	0f be d2             	movsbl %dl,%edx
  800b91:	83 ea 30             	sub    $0x30,%edx
  800b94:	eb 22                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b99:	89 f3                	mov    %esi,%ebx
  800b9b:	80 fb 19             	cmp    $0x19,%bl
  800b9e:	77 08                	ja     800ba8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ba0:	0f be d2             	movsbl %dl,%edx
  800ba3:	83 ea 57             	sub    $0x57,%edx
  800ba6:	eb 10                	jmp    800bb8 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ba8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bab:	89 f3                	mov    %esi,%ebx
  800bad:	80 fb 19             	cmp    $0x19,%bl
  800bb0:	77 16                	ja     800bc8 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bb2:	0f be d2             	movsbl %dl,%edx
  800bb5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bb8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bbb:	7d 0b                	jge    800bc8 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bbd:	83 c1 01             	add    $0x1,%ecx
  800bc0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bc4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bc6:	eb b9                	jmp    800b81 <strtol+0x76>

	if (endptr)
  800bc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bcc:	74 0d                	je     800bdb <strtol+0xd0>
		*endptr = (char *) s;
  800bce:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bd1:	89 0e                	mov    %ecx,(%esi)
  800bd3:	eb 06                	jmp    800bdb <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd5:	85 db                	test   %ebx,%ebx
  800bd7:	74 98                	je     800b71 <strtol+0x66>
  800bd9:	eb 9e                	jmp    800b79 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	f7 da                	neg    %edx
  800bdf:	85 ff                	test   %edi,%edi
  800be1:	0f 45 c2             	cmovne %edx,%eax
}
  800be4:	5b                   	pop    %ebx
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	89 c3                	mov    %eax,%ebx
  800bfc:	89 c7                	mov    %eax,%edi
  800bfe:	89 c6                	mov    %eax,%esi
  800c00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5f                   	pop    %edi
  800c05:	5d                   	pop    %ebp
  800c06:	c3                   	ret    

00800c07 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	57                   	push   %edi
  800c0b:	56                   	push   %esi
  800c0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c12:	b8 01 00 00 00       	mov    $0x1,%eax
  800c17:	89 d1                	mov    %edx,%ecx
  800c19:	89 d3                	mov    %edx,%ebx
  800c1b:	89 d7                	mov    %edx,%edi
  800c1d:	89 d6                	mov    %edx,%esi
  800c1f:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c34:	b8 03 00 00 00       	mov    $0x3,%eax
  800c39:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3c:	89 cb                	mov    %ecx,%ebx
  800c3e:	89 cf                	mov    %ecx,%edi
  800c40:	89 ce                	mov    %ecx,%esi
  800c42:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c44:	85 c0                	test   %eax,%eax
  800c46:	7e 17                	jle    800c5f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c48:	83 ec 0c             	sub    $0xc,%esp
  800c4b:	50                   	push   %eax
  800c4c:	6a 03                	push   $0x3
  800c4e:	68 5f 2b 80 00       	push   $0x802b5f
  800c53:	6a 23                	push   $0x23
  800c55:	68 7c 2b 80 00       	push   $0x802b7c
  800c5a:	e8 e5 f5 ff ff       	call   800244 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 17                	jle    800ce0 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	83 ec 0c             	sub    $0xc,%esp
  800ccc:	50                   	push   %eax
  800ccd:	6a 04                	push   $0x4
  800ccf:	68 5f 2b 80 00       	push   $0x802b5f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 7c 2b 80 00       	push   $0x802b7c
  800cdb:	e8 64 f5 ff ff       	call   800244 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ce0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce3:	5b                   	pop    %ebx
  800ce4:	5e                   	pop    %esi
  800ce5:	5f                   	pop    %edi
  800ce6:	5d                   	pop    %ebp
  800ce7:	c3                   	ret    

00800ce8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf1:	b8 05 00 00 00       	mov    $0x5,%eax
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d02:	8b 75 18             	mov    0x18(%ebp),%esi
  800d05:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7e 17                	jle    800d22 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0b:	83 ec 0c             	sub    $0xc,%esp
  800d0e:	50                   	push   %eax
  800d0f:	6a 05                	push   $0x5
  800d11:	68 5f 2b 80 00       	push   $0x802b5f
  800d16:	6a 23                	push   $0x23
  800d18:	68 7c 2b 80 00       	push   $0x802b7c
  800d1d:	e8 22 f5 ff ff       	call   800244 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	b8 06 00 00 00       	mov    $0x6,%eax
  800d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d40:	8b 55 08             	mov    0x8(%ebp),%edx
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7e 17                	jle    800d64 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	50                   	push   %eax
  800d51:	6a 06                	push   $0x6
  800d53:	68 5f 2b 80 00       	push   $0x802b5f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 7c 2b 80 00       	push   $0x802b7c
  800d5f:	e8 e0 f4 ff ff       	call   800244 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d67:	5b                   	pop    %ebx
  800d68:	5e                   	pop    %esi
  800d69:	5f                   	pop    %edi
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
  800d72:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 17                	jle    800da6 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	83 ec 0c             	sub    $0xc,%esp
  800d92:	50                   	push   %eax
  800d93:	6a 08                	push   $0x8
  800d95:	68 5f 2b 80 00       	push   $0x802b5f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 7c 2b 80 00       	push   $0x802b7c
  800da1:	e8 9e f4 ff ff       	call   800244 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da9:	5b                   	pop    %ebx
  800daa:	5e                   	pop    %esi
  800dab:	5f                   	pop    %edi
  800dac:	5d                   	pop    %ebp
  800dad:	c3                   	ret    

00800dae <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	57                   	push   %edi
  800db2:	56                   	push   %esi
  800db3:	53                   	push   %ebx
  800db4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dbc:	b8 09 00 00 00       	mov    $0x9,%eax
  800dc1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc7:	89 df                	mov    %ebx,%edi
  800dc9:	89 de                	mov    %ebx,%esi
  800dcb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dcd:	85 c0                	test   %eax,%eax
  800dcf:	7e 17                	jle    800de8 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	50                   	push   %eax
  800dd5:	6a 09                	push   $0x9
  800dd7:	68 5f 2b 80 00       	push   $0x802b5f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 7c 2b 80 00       	push   $0x802b7c
  800de3:	e8 5c f4 ff ff       	call   800244 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800de8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800deb:	5b                   	pop    %ebx
  800dec:	5e                   	pop    %esi
  800ded:	5f                   	pop    %edi
  800dee:	5d                   	pop    %ebp
  800def:	c3                   	ret    

00800df0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	57                   	push   %edi
  800df4:	56                   	push   %esi
  800df5:	53                   	push   %ebx
  800df6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfe:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e06:	8b 55 08             	mov    0x8(%ebp),%edx
  800e09:	89 df                	mov    %ebx,%edi
  800e0b:	89 de                	mov    %ebx,%esi
  800e0d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	7e 17                	jle    800e2a <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	50                   	push   %eax
  800e17:	6a 0a                	push   $0xa
  800e19:	68 5f 2b 80 00       	push   $0x802b5f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 7c 2b 80 00       	push   $0x802b7c
  800e25:	e8 1a f4 ff ff       	call   800244 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e2d:	5b                   	pop    %ebx
  800e2e:	5e                   	pop    %esi
  800e2f:	5f                   	pop    %edi
  800e30:	5d                   	pop    %ebp
  800e31:	c3                   	ret    

00800e32 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e32:	55                   	push   %ebp
  800e33:	89 e5                	mov    %esp,%ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e38:	be 00 00 00 00       	mov    $0x0,%esi
  800e3d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e45:	8b 55 08             	mov    0x8(%ebp),%edx
  800e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4e:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	57                   	push   %edi
  800e59:	56                   	push   %esi
  800e5a:	53                   	push   %ebx
  800e5b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e63:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e68:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6b:	89 cb                	mov    %ecx,%ebx
  800e6d:	89 cf                	mov    %ecx,%edi
  800e6f:	89 ce                	mov    %ecx,%esi
  800e71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 0d                	push   $0xd
  800e7d:	68 5f 2b 80 00       	push   $0x802b5f
  800e82:	6a 23                	push   $0x23
  800e84:	68 7c 2b 80 00       	push   $0x802b7c
  800e89:	e8 b6 f3 ff ff       	call   800244 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea1:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ea6:	89 d1                	mov    %edx,%ecx
  800ea8:	89 d3                	mov    %edx,%ebx
  800eaa:	89 d7                	mov    %edx,%edi
  800eac:	89 d6                	mov    %edx,%esi
  800eae:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eb0:	5b                   	pop    %ebx
  800eb1:	5e                   	pop    %esi
  800eb2:	5f                   	pop    %edi
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	57                   	push   %edi
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec3:	b8 0f 00 00 00       	mov    $0xf,%eax
  800ec8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ece:	89 df                	mov    %ebx,%edi
  800ed0:	89 de                	mov    %ebx,%esi
  800ed2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 17                	jle    800eef <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	50                   	push   %eax
  800edc:	6a 0f                	push   $0xf
  800ede:	68 5f 2b 80 00       	push   $0x802b5f
  800ee3:	6a 23                	push   $0x23
  800ee5:	68 7c 2b 80 00       	push   $0x802b7c
  800eea:	e8 55 f3 ff ff       	call   800244 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800eef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	53                   	push   %ebx
  800efd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f05:	b8 10 00 00 00       	mov    $0x10,%eax
  800f0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f10:	89 df                	mov    %ebx,%edi
  800f12:	89 de                	mov    %ebx,%esi
  800f14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7e 17                	jle    800f31 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	50                   	push   %eax
  800f1e:	6a 10                	push   $0x10
  800f20:	68 5f 2b 80 00       	push   $0x802b5f
  800f25:	6a 23                	push   $0x23
  800f27:	68 7c 2b 80 00       	push   $0x802b7c
  800f2c:	e8 13 f3 ff ff       	call   800244 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	56                   	push   %esi
  800f3d:	53                   	push   %ebx
  800f3e:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f41:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f43:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f47:	75 25                	jne    800f6e <pgfault+0x35>
  800f49:	89 d8                	mov    %ebx,%eax
  800f4b:	c1 e8 0c             	shr    $0xc,%eax
  800f4e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f55:	f6 c4 08             	test   $0x8,%ah
  800f58:	75 14                	jne    800f6e <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f5a:	83 ec 04             	sub    $0x4,%esp
  800f5d:	68 8c 2b 80 00       	push   $0x802b8c
  800f62:	6a 1e                	push   $0x1e
  800f64:	68 20 2c 80 00       	push   $0x802c20
  800f69:	e8 d6 f2 ff ff       	call   800244 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f6e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f74:	e8 ee fc ff ff       	call   800c67 <sys_getenvid>
  800f79:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f7b:	83 ec 04             	sub    $0x4,%esp
  800f7e:	6a 07                	push   $0x7
  800f80:	68 00 f0 7f 00       	push   $0x7ff000
  800f85:	50                   	push   %eax
  800f86:	e8 1a fd ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	79 12                	jns    800fa4 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f92:	50                   	push   %eax
  800f93:	68 b8 2b 80 00       	push   $0x802bb8
  800f98:	6a 33                	push   $0x33
  800f9a:	68 20 2c 80 00       	push   $0x802c20
  800f9f:	e8 a0 f2 ff ff       	call   800244 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	68 00 10 00 00       	push   $0x1000
  800fac:	53                   	push   %ebx
  800fad:	68 00 f0 7f 00       	push   $0x7ff000
  800fb2:	e8 e5 fa ff ff       	call   800a9c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800fb7:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fbe:	53                   	push   %ebx
  800fbf:	56                   	push   %esi
  800fc0:	68 00 f0 7f 00       	push   $0x7ff000
  800fc5:	56                   	push   %esi
  800fc6:	e8 1d fd ff ff       	call   800ce8 <sys_page_map>
	if (r < 0)
  800fcb:	83 c4 20             	add    $0x20,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	79 12                	jns    800fe4 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fd2:	50                   	push   %eax
  800fd3:	68 dc 2b 80 00       	push   $0x802bdc
  800fd8:	6a 3b                	push   $0x3b
  800fda:	68 20 2c 80 00       	push   $0x802c20
  800fdf:	e8 60 f2 ff ff       	call   800244 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fe4:	83 ec 08             	sub    $0x8,%esp
  800fe7:	68 00 f0 7f 00       	push   $0x7ff000
  800fec:	56                   	push   %esi
  800fed:	e8 38 fd ff ff       	call   800d2a <sys_page_unmap>
	if (r < 0)
  800ff2:	83 c4 10             	add    $0x10,%esp
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	79 12                	jns    80100b <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800ff9:	50                   	push   %eax
  800ffa:	68 00 2c 80 00       	push   $0x802c00
  800fff:	6a 40                	push   $0x40
  801001:	68 20 2c 80 00       	push   $0x802c20
  801006:	e8 39 f2 ff ff       	call   800244 <_panic>
}
  80100b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80100e:	5b                   	pop    %ebx
  80100f:	5e                   	pop    %esi
  801010:	5d                   	pop    %ebp
  801011:	c3                   	ret    

00801012 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	57                   	push   %edi
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
  801018:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  80101b:	68 39 0f 80 00       	push   $0x800f39
  801020:	e8 17 14 00 00       	call   80243c <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801025:	b8 07 00 00 00       	mov    $0x7,%eax
  80102a:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	0f 88 64 01 00 00    	js     80119b <fork+0x189>
  801037:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80103c:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801041:	85 c0                	test   %eax,%eax
  801043:	75 21                	jne    801066 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801045:	e8 1d fc ff ff       	call   800c67 <sys_getenvid>
  80104a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801057:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80105c:	ba 00 00 00 00       	mov    $0x0,%edx
  801061:	e9 3f 01 00 00       	jmp    8011a5 <fork+0x193>
  801066:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801069:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80106b:	89 d8                	mov    %ebx,%eax
  80106d:	c1 e8 16             	shr    $0x16,%eax
  801070:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801077:	a8 01                	test   $0x1,%al
  801079:	0f 84 bd 00 00 00    	je     80113c <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80107f:	89 d8                	mov    %ebx,%eax
  801081:	c1 e8 0c             	shr    $0xc,%eax
  801084:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108b:	f6 c2 01             	test   $0x1,%dl
  80108e:	0f 84 a8 00 00 00    	je     80113c <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	a8 04                	test   $0x4,%al
  80109d:	0f 84 99 00 00 00    	je     80113c <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  8010a3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010aa:	f6 c4 04             	test   $0x4,%ah
  8010ad:	74 17                	je     8010c6 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8010af:	83 ec 0c             	sub    $0xc,%esp
  8010b2:	68 07 0e 00 00       	push   $0xe07
  8010b7:	53                   	push   %ebx
  8010b8:	57                   	push   %edi
  8010b9:	53                   	push   %ebx
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 27 fc ff ff       	call   800ce8 <sys_page_map>
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	eb 76                	jmp    80113c <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010c6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010cd:	a8 02                	test   $0x2,%al
  8010cf:	75 0c                	jne    8010dd <fork+0xcb>
  8010d1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d8:	f6 c4 08             	test   $0x8,%ah
  8010db:	74 3f                	je     80111c <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010dd:	83 ec 0c             	sub    $0xc,%esp
  8010e0:	68 05 08 00 00       	push   $0x805
  8010e5:	53                   	push   %ebx
  8010e6:	57                   	push   %edi
  8010e7:	53                   	push   %ebx
  8010e8:	6a 00                	push   $0x0
  8010ea:	e8 f9 fb ff ff       	call   800ce8 <sys_page_map>
		if (r < 0)
  8010ef:	83 c4 20             	add    $0x20,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	0f 88 a5 00 00 00    	js     80119f <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010fa:	83 ec 0c             	sub    $0xc,%esp
  8010fd:	68 05 08 00 00       	push   $0x805
  801102:	53                   	push   %ebx
  801103:	6a 00                	push   $0x0
  801105:	53                   	push   %ebx
  801106:	6a 00                	push   $0x0
  801108:	e8 db fb ff ff       	call   800ce8 <sys_page_map>
  80110d:	83 c4 20             	add    $0x20,%esp
  801110:	85 c0                	test   %eax,%eax
  801112:	b9 00 00 00 00       	mov    $0x0,%ecx
  801117:	0f 4f c1             	cmovg  %ecx,%eax
  80111a:	eb 1c                	jmp    801138 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80111c:	83 ec 0c             	sub    $0xc,%esp
  80111f:	6a 05                	push   $0x5
  801121:	53                   	push   %ebx
  801122:	57                   	push   %edi
  801123:	53                   	push   %ebx
  801124:	6a 00                	push   $0x0
  801126:	e8 bd fb ff ff       	call   800ce8 <sys_page_map>
  80112b:	83 c4 20             	add    $0x20,%esp
  80112e:	85 c0                	test   %eax,%eax
  801130:	b9 00 00 00 00       	mov    $0x0,%ecx
  801135:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 67                	js     8011a3 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80113c:	83 c6 01             	add    $0x1,%esi
  80113f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801145:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80114b:	0f 85 1a ff ff ff    	jne    80106b <fork+0x59>
  801151:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	6a 07                	push   $0x7
  801159:	68 00 f0 bf ee       	push   $0xeebff000
  80115e:	57                   	push   %edi
  80115f:	e8 41 fb ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  801164:	83 c4 10             	add    $0x10,%esp
		return r;
  801167:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801169:	85 c0                	test   %eax,%eax
  80116b:	78 38                	js     8011a5 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80116d:	83 ec 08             	sub    $0x8,%esp
  801170:	68 83 24 80 00       	push   $0x802483
  801175:	57                   	push   %edi
  801176:	e8 75 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80117b:	83 c4 10             	add    $0x10,%esp
		return r;
  80117e:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801180:	85 c0                	test   %eax,%eax
  801182:	78 21                	js     8011a5 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801184:	83 ec 08             	sub    $0x8,%esp
  801187:	6a 02                	push   $0x2
  801189:	57                   	push   %edi
  80118a:	e8 dd fb ff ff       	call   800d6c <sys_env_set_status>
	if (r < 0)
  80118f:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801192:	85 c0                	test   %eax,%eax
  801194:	0f 48 f8             	cmovs  %eax,%edi
  801197:	89 fa                	mov    %edi,%edx
  801199:	eb 0a                	jmp    8011a5 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80119b:	89 c2                	mov    %eax,%edx
  80119d:	eb 06                	jmp    8011a5 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80119f:	89 c2                	mov    %eax,%edx
  8011a1:	eb 02                	jmp    8011a5 <fork+0x193>
  8011a3:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  8011a5:	89 d0                	mov    %edx,%eax
  8011a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011aa:	5b                   	pop    %ebx
  8011ab:	5e                   	pop    %esi
  8011ac:	5f                   	pop    %edi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <sfork>:

// Challenge!
int
sfork(void)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011b5:	68 2b 2c 80 00       	push   $0x802c2b
  8011ba:	68 c9 00 00 00       	push   $0xc9
  8011bf:	68 20 2c 80 00       	push   $0x802c20
  8011c4:	e8 7b f0 ff ff       	call   800244 <_panic>

008011c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011c9:	55                   	push   %ebp
  8011ca:	89 e5                	mov    %esp,%ebp
  8011cc:	56                   	push   %esi
  8011cd:	53                   	push   %ebx
  8011ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8011d7:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  8011d9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011de:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	50                   	push   %eax
  8011e5:	e8 6b fc ff ff       	call   800e55 <sys_ipc_recv>

	if (from_env_store != NULL)
  8011ea:	83 c4 10             	add    $0x10,%esp
  8011ed:	85 f6                	test   %esi,%esi
  8011ef:	74 14                	je     801205 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	78 09                	js     801203 <ipc_recv+0x3a>
  8011fa:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801200:	8b 52 74             	mov    0x74(%edx),%edx
  801203:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801205:	85 db                	test   %ebx,%ebx
  801207:	74 14                	je     80121d <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801209:	ba 00 00 00 00       	mov    $0x0,%edx
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 09                	js     80121b <ipc_recv+0x52>
  801212:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801218:	8b 52 78             	mov    0x78(%edx),%edx
  80121b:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  80121d:	85 c0                	test   %eax,%eax
  80121f:	78 08                	js     801229 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
  801226:	8b 40 70             	mov    0x70(%eax),%eax
}
  801229:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80122c:	5b                   	pop    %ebx
  80122d:	5e                   	pop    %esi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	57                   	push   %edi
  801234:	56                   	push   %esi
  801235:	53                   	push   %ebx
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80123f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801242:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801244:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801249:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80124c:	ff 75 14             	pushl  0x14(%ebp)
  80124f:	53                   	push   %ebx
  801250:	56                   	push   %esi
  801251:	57                   	push   %edi
  801252:	e8 db fb ff ff       	call   800e32 <sys_ipc_try_send>

		if (err < 0) {
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	79 1e                	jns    80127c <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80125e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801261:	75 07                	jne    80126a <ipc_send+0x3a>
				sys_yield();
  801263:	e8 1e fa ff ff       	call   800c86 <sys_yield>
  801268:	eb e2                	jmp    80124c <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80126a:	50                   	push   %eax
  80126b:	68 41 2c 80 00       	push   $0x802c41
  801270:	6a 49                	push   $0x49
  801272:	68 4e 2c 80 00       	push   $0x802c4e
  801277:	e8 c8 ef ff ff       	call   800244 <_panic>
		}

	} while (err < 0);

}
  80127c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127f:	5b                   	pop    %ebx
  801280:	5e                   	pop    %esi
  801281:	5f                   	pop    %edi
  801282:	5d                   	pop    %ebp
  801283:	c3                   	ret    

00801284 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801284:	55                   	push   %ebp
  801285:	89 e5                	mov    %esp,%ebp
  801287:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80128f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801292:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801298:	8b 52 50             	mov    0x50(%edx),%edx
  80129b:	39 ca                	cmp    %ecx,%edx
  80129d:	75 0d                	jne    8012ac <ipc_find_env+0x28>
			return envs[i].env_id;
  80129f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012a2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012a7:	8b 40 48             	mov    0x48(%eax),%eax
  8012aa:	eb 0f                	jmp    8012bb <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8012ac:	83 c0 01             	add    $0x1,%eax
  8012af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012b4:	75 d9                	jne    80128f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8012b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c8:	c1 e8 0c             	shr    $0xc,%eax
}
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    

008012cd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012cd:	55                   	push   %ebp
  8012ce:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8012d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012d3:	05 00 00 00 30       	add    $0x30000000,%eax
  8012d8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012dd:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012e2:	5d                   	pop    %ebp
  8012e3:	c3                   	ret    

008012e4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ea:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ef:	89 c2                	mov    %eax,%edx
  8012f1:	c1 ea 16             	shr    $0x16,%edx
  8012f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012fb:	f6 c2 01             	test   $0x1,%dl
  8012fe:	74 11                	je     801311 <fd_alloc+0x2d>
  801300:	89 c2                	mov    %eax,%edx
  801302:	c1 ea 0c             	shr    $0xc,%edx
  801305:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80130c:	f6 c2 01             	test   $0x1,%dl
  80130f:	75 09                	jne    80131a <fd_alloc+0x36>
			*fd_store = fd;
  801311:	89 01                	mov    %eax,(%ecx)
			return 0;
  801313:	b8 00 00 00 00       	mov    $0x0,%eax
  801318:	eb 17                	jmp    801331 <fd_alloc+0x4d>
  80131a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80131f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801324:	75 c9                	jne    8012ef <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801326:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80132c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801339:	83 f8 1f             	cmp    $0x1f,%eax
  80133c:	77 36                	ja     801374 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133e:	c1 e0 0c             	shl    $0xc,%eax
  801341:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801346:	89 c2                	mov    %eax,%edx
  801348:	c1 ea 16             	shr    $0x16,%edx
  80134b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801352:	f6 c2 01             	test   $0x1,%dl
  801355:	74 24                	je     80137b <fd_lookup+0x48>
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 0c             	shr    $0xc,%edx
  80135c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 1a                	je     801382 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	89 02                	mov    %eax,(%edx)
	return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	eb 13                	jmp    801387 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb 0c                	jmp    801387 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801380:	eb 05                	jmp    801387 <fd_lookup+0x54>
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 08             	sub    $0x8,%esp
  80138f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801392:	ba d8 2c 80 00       	mov    $0x802cd8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801397:	eb 13                	jmp    8013ac <dev_lookup+0x23>
  801399:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80139c:	39 08                	cmp    %ecx,(%eax)
  80139e:	75 0c                	jne    8013ac <dev_lookup+0x23>
			*dev = devtab[i];
  8013a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8013aa:	eb 2e                	jmp    8013da <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ac:	8b 02                	mov    (%edx),%eax
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	75 e7                	jne    801399 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b7:	8b 40 48             	mov    0x48(%eax),%eax
  8013ba:	83 ec 04             	sub    $0x4,%esp
  8013bd:	51                   	push   %ecx
  8013be:	50                   	push   %eax
  8013bf:	68 58 2c 80 00       	push   $0x802c58
  8013c4:	e8 54 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  8013c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013cc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013da:	c9                   	leave  
  8013db:	c3                   	ret    

008013dc <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 10             	sub    $0x10,%esp
  8013e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	50                   	push   %eax
  8013ee:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013f4:	c1 e8 0c             	shr    $0xc,%eax
  8013f7:	50                   	push   %eax
  8013f8:	e8 36 ff ff ff       	call   801333 <fd_lookup>
  8013fd:	83 c4 08             	add    $0x8,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 05                	js     801409 <fd_close+0x2d>
	    || fd != fd2)
  801404:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801407:	74 0c                	je     801415 <fd_close+0x39>
		return (must_exist ? r : 0);
  801409:	84 db                	test   %bl,%bl
  80140b:	ba 00 00 00 00       	mov    $0x0,%edx
  801410:	0f 44 c2             	cmove  %edx,%eax
  801413:	eb 41                	jmp    801456 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	ff 36                	pushl  (%esi)
  80141e:	e8 66 ff ff ff       	call   801389 <dev_lookup>
  801423:	89 c3                	mov    %eax,%ebx
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 1a                	js     801446 <fd_close+0x6a>
		if (dev->dev_close)
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801432:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801437:	85 c0                	test   %eax,%eax
  801439:	74 0b                	je     801446 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80143b:	83 ec 0c             	sub    $0xc,%esp
  80143e:	56                   	push   %esi
  80143f:	ff d0                	call   *%eax
  801441:	89 c3                	mov    %eax,%ebx
  801443:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	56                   	push   %esi
  80144a:	6a 00                	push   $0x0
  80144c:	e8 d9 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	89 d8                	mov    %ebx,%eax
}
  801456:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801459:	5b                   	pop    %ebx
  80145a:	5e                   	pop    %esi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    

0080145d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	ff 75 08             	pushl  0x8(%ebp)
  80146a:	e8 c4 fe ff ff       	call   801333 <fd_lookup>
  80146f:	83 c4 08             	add    $0x8,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 10                	js     801486 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	6a 01                	push   $0x1
  80147b:	ff 75 f4             	pushl  -0xc(%ebp)
  80147e:	e8 59 ff ff ff       	call   8013dc <fd_close>
  801483:	83 c4 10             	add    $0x10,%esp
}
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <close_all>:

void
close_all(void)
{
  801488:	55                   	push   %ebp
  801489:	89 e5                	mov    %esp,%ebp
  80148b:	53                   	push   %ebx
  80148c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	53                   	push   %ebx
  801498:	e8 c0 ff ff ff       	call   80145d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80149d:	83 c3 01             	add    $0x1,%ebx
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	83 fb 20             	cmp    $0x20,%ebx
  8014a6:	75 ec                	jne    801494 <close_all+0xc>
		close(i);
}
  8014a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	57                   	push   %edi
  8014b1:	56                   	push   %esi
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 2c             	sub    $0x2c,%esp
  8014b6:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	ff 75 08             	pushl  0x8(%ebp)
  8014c0:	e8 6e fe ff ff       	call   801333 <fd_lookup>
  8014c5:	83 c4 08             	add    $0x8,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	0f 88 c1 00 00 00    	js     801591 <dup+0xe4>
		return r;
	close(newfdnum);
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	56                   	push   %esi
  8014d4:	e8 84 ff ff ff       	call   80145d <close>

	newfd = INDEX2FD(newfdnum);
  8014d9:	89 f3                	mov    %esi,%ebx
  8014db:	c1 e3 0c             	shl    $0xc,%ebx
  8014de:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014e4:	83 c4 04             	add    $0x4,%esp
  8014e7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014ea:	e8 de fd ff ff       	call   8012cd <fd2data>
  8014ef:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014f1:	89 1c 24             	mov    %ebx,(%esp)
  8014f4:	e8 d4 fd ff ff       	call   8012cd <fd2data>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ff:	89 f8                	mov    %edi,%eax
  801501:	c1 e8 16             	shr    $0x16,%eax
  801504:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80150b:	a8 01                	test   $0x1,%al
  80150d:	74 37                	je     801546 <dup+0x99>
  80150f:	89 f8                	mov    %edi,%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80151b:	f6 c2 01             	test   $0x1,%dl
  80151e:	74 26                	je     801546 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801520:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801527:	83 ec 0c             	sub    $0xc,%esp
  80152a:	25 07 0e 00 00       	and    $0xe07,%eax
  80152f:	50                   	push   %eax
  801530:	ff 75 d4             	pushl  -0x2c(%ebp)
  801533:	6a 00                	push   $0x0
  801535:	57                   	push   %edi
  801536:	6a 00                	push   $0x0
  801538:	e8 ab f7 ff ff       	call   800ce8 <sys_page_map>
  80153d:	89 c7                	mov    %eax,%edi
  80153f:	83 c4 20             	add    $0x20,%esp
  801542:	85 c0                	test   %eax,%eax
  801544:	78 2e                	js     801574 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801546:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801549:	89 d0                	mov    %edx,%eax
  80154b:	c1 e8 0c             	shr    $0xc,%eax
  80154e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801555:	83 ec 0c             	sub    $0xc,%esp
  801558:	25 07 0e 00 00       	and    $0xe07,%eax
  80155d:	50                   	push   %eax
  80155e:	53                   	push   %ebx
  80155f:	6a 00                	push   $0x0
  801561:	52                   	push   %edx
  801562:	6a 00                	push   $0x0
  801564:	e8 7f f7 ff ff       	call   800ce8 <sys_page_map>
  801569:	89 c7                	mov    %eax,%edi
  80156b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80156e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801570:	85 ff                	test   %edi,%edi
  801572:	79 1d                	jns    801591 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	53                   	push   %ebx
  801578:	6a 00                	push   $0x0
  80157a:	e8 ab f7 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80157f:	83 c4 08             	add    $0x8,%esp
  801582:	ff 75 d4             	pushl  -0x2c(%ebp)
  801585:	6a 00                	push   $0x0
  801587:	e8 9e f7 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	89 f8                	mov    %edi,%eax
}
  801591:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5f                   	pop    %edi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    

00801599 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	53                   	push   %ebx
  80159d:	83 ec 14             	sub    $0x14,%esp
  8015a0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a6:	50                   	push   %eax
  8015a7:	53                   	push   %ebx
  8015a8:	e8 86 fd ff ff       	call   801333 <fd_lookup>
  8015ad:	83 c4 08             	add    $0x8,%esp
  8015b0:	89 c2                	mov    %eax,%edx
  8015b2:	85 c0                	test   %eax,%eax
  8015b4:	78 6d                	js     801623 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bc:	50                   	push   %eax
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	ff 30                	pushl  (%eax)
  8015c2:	e8 c2 fd ff ff       	call   801389 <dev_lookup>
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 4c                	js     80161a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015d1:	8b 42 08             	mov    0x8(%edx),%eax
  8015d4:	83 e0 03             	and    $0x3,%eax
  8015d7:	83 f8 01             	cmp    $0x1,%eax
  8015da:	75 21                	jne    8015fd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e1:	8b 40 48             	mov    0x48(%eax),%eax
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	50                   	push   %eax
  8015e9:	68 9c 2c 80 00       	push   $0x802c9c
  8015ee:	e8 2a ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015fb:	eb 26                	jmp    801623 <read+0x8a>
	}
	if (!dev->dev_read)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	8b 40 08             	mov    0x8(%eax),%eax
  801603:	85 c0                	test   %eax,%eax
  801605:	74 17                	je     80161e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	52                   	push   %edx
  801611:	ff d0                	call   *%eax
  801613:	89 c2                	mov    %eax,%edx
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	eb 09                	jmp    801623 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	eb 05                	jmp    801623 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80161e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801623:	89 d0                	mov    %edx,%eax
  801625:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801628:	c9                   	leave  
  801629:	c3                   	ret    

0080162a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80162a:	55                   	push   %ebp
  80162b:	89 e5                	mov    %esp,%ebp
  80162d:	57                   	push   %edi
  80162e:	56                   	push   %esi
  80162f:	53                   	push   %ebx
  801630:	83 ec 0c             	sub    $0xc,%esp
  801633:	8b 7d 08             	mov    0x8(%ebp),%edi
  801636:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
  80163e:	eb 21                	jmp    801661 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801640:	83 ec 04             	sub    $0x4,%esp
  801643:	89 f0                	mov    %esi,%eax
  801645:	29 d8                	sub    %ebx,%eax
  801647:	50                   	push   %eax
  801648:	89 d8                	mov    %ebx,%eax
  80164a:	03 45 0c             	add    0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	57                   	push   %edi
  80164f:	e8 45 ff ff ff       	call   801599 <read>
		if (m < 0)
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 10                	js     80166b <readn+0x41>
			return m;
		if (m == 0)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 0a                	je     801669 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80165f:	01 c3                	add    %eax,%ebx
  801661:	39 f3                	cmp    %esi,%ebx
  801663:	72 db                	jb     801640 <readn+0x16>
  801665:	89 d8                	mov    %ebx,%eax
  801667:	eb 02                	jmp    80166b <readn+0x41>
  801669:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	53                   	push   %ebx
  801677:	83 ec 14             	sub    $0x14,%esp
  80167a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	53                   	push   %ebx
  801682:	e8 ac fc ff ff       	call   801333 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 68                	js     8016f8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 e8 fc ff ff       	call   801389 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 47                	js     8016ef <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ab:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016af:	75 21                	jne    8016d2 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8016b6:	8b 40 48             	mov    0x48(%eax),%eax
  8016b9:	83 ec 04             	sub    $0x4,%esp
  8016bc:	53                   	push   %ebx
  8016bd:	50                   	push   %eax
  8016be:	68 b8 2c 80 00       	push   $0x802cb8
  8016c3:	e8 55 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8016c8:	83 c4 10             	add    $0x10,%esp
  8016cb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016d0:	eb 26                	jmp    8016f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d8:	85 d2                	test   %edx,%edx
  8016da:	74 17                	je     8016f3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	50                   	push   %eax
  8016e6:	ff d2                	call   *%edx
  8016e8:	89 c2                	mov    %eax,%edx
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb 09                	jmp    8016f8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ef:	89 c2                	mov    %eax,%edx
  8016f1:	eb 05                	jmp    8016f8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016f3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016f8:	89 d0                	mov    %edx,%eax
  8016fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <seek>:

int
seek(int fdnum, off_t offset)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801705:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801708:	50                   	push   %eax
  801709:	ff 75 08             	pushl  0x8(%ebp)
  80170c:	e8 22 fc ff ff       	call   801333 <fd_lookup>
  801711:	83 c4 08             	add    $0x8,%esp
  801714:	85 c0                	test   %eax,%eax
  801716:	78 0e                	js     801726 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801718:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801721:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 14             	sub    $0x14,%esp
  80172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801735:	50                   	push   %eax
  801736:	53                   	push   %ebx
  801737:	e8 f7 fb ff ff       	call   801333 <fd_lookup>
  80173c:	83 c4 08             	add    $0x8,%esp
  80173f:	89 c2                	mov    %eax,%edx
  801741:	85 c0                	test   %eax,%eax
  801743:	78 65                	js     8017aa <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174b:	50                   	push   %eax
  80174c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174f:	ff 30                	pushl  (%eax)
  801751:	e8 33 fc ff ff       	call   801389 <dev_lookup>
  801756:	83 c4 10             	add    $0x10,%esp
  801759:	85 c0                	test   %eax,%eax
  80175b:	78 44                	js     8017a1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80175d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801764:	75 21                	jne    801787 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801766:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80176b:	8b 40 48             	mov    0x48(%eax),%eax
  80176e:	83 ec 04             	sub    $0x4,%esp
  801771:	53                   	push   %ebx
  801772:	50                   	push   %eax
  801773:	68 78 2c 80 00       	push   $0x802c78
  801778:	e8 a0 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80177d:	83 c4 10             	add    $0x10,%esp
  801780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801785:	eb 23                	jmp    8017aa <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80178a:	8b 52 18             	mov    0x18(%edx),%edx
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 14                	je     8017a5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	ff 75 0c             	pushl  0xc(%ebp)
  801797:	50                   	push   %eax
  801798:	ff d2                	call   *%edx
  80179a:	89 c2                	mov    %eax,%edx
  80179c:	83 c4 10             	add    $0x10,%esp
  80179f:	eb 09                	jmp    8017aa <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	eb 05                	jmp    8017aa <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017aa:	89 d0                	mov    %edx,%eax
  8017ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017af:	c9                   	leave  
  8017b0:	c3                   	ret    

008017b1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	53                   	push   %ebx
  8017b5:	83 ec 14             	sub    $0x14,%esp
  8017b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017be:	50                   	push   %eax
  8017bf:	ff 75 08             	pushl  0x8(%ebp)
  8017c2:	e8 6c fb ff ff       	call   801333 <fd_lookup>
  8017c7:	83 c4 08             	add    $0x8,%esp
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 58                	js     801828 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d6:	50                   	push   %eax
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017da:	ff 30                	pushl  (%eax)
  8017dc:	e8 a8 fb ff ff       	call   801389 <dev_lookup>
  8017e1:	83 c4 10             	add    $0x10,%esp
  8017e4:	85 c0                	test   %eax,%eax
  8017e6:	78 37                	js     80181f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017eb:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ef:	74 32                	je     801823 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017fb:	00 00 00 
	stat->st_isdir = 0;
  8017fe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801805:	00 00 00 
	stat->st_dev = dev;
  801808:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	53                   	push   %ebx
  801812:	ff 75 f0             	pushl  -0x10(%ebp)
  801815:	ff 50 14             	call   *0x14(%eax)
  801818:	89 c2                	mov    %eax,%edx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	eb 09                	jmp    801828 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181f:	89 c2                	mov    %eax,%edx
  801821:	eb 05                	jmp    801828 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801823:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801828:	89 d0                	mov    %edx,%eax
  80182a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182d:	c9                   	leave  
  80182e:	c3                   	ret    

0080182f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	6a 00                	push   $0x0
  801839:	ff 75 08             	pushl  0x8(%ebp)
  80183c:	e8 d6 01 00 00       	call   801a17 <open>
  801841:	89 c3                	mov    %eax,%ebx
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	85 c0                	test   %eax,%eax
  801848:	78 1b                	js     801865 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	ff 75 0c             	pushl  0xc(%ebp)
  801850:	50                   	push   %eax
  801851:	e8 5b ff ff ff       	call   8017b1 <fstat>
  801856:	89 c6                	mov    %eax,%esi
	close(fd);
  801858:	89 1c 24             	mov    %ebx,(%esp)
  80185b:	e8 fd fb ff ff       	call   80145d <close>
	return r;
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	89 f0                	mov    %esi,%eax
}
  801865:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801868:	5b                   	pop    %ebx
  801869:	5e                   	pop    %esi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	56                   	push   %esi
  801870:	53                   	push   %ebx
  801871:	89 c6                	mov    %eax,%esi
  801873:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801875:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80187c:	75 12                	jne    801890 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	6a 01                	push   $0x1
  801883:	e8 fc f9 ff ff       	call   801284 <ipc_find_env>
  801888:	a3 00 40 80 00       	mov    %eax,0x804000
  80188d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801890:	6a 07                	push   $0x7
  801892:	68 00 50 80 00       	push   $0x805000
  801897:	56                   	push   %esi
  801898:	ff 35 00 40 80 00    	pushl  0x804000
  80189e:	e8 8d f9 ff ff       	call   801230 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a3:	83 c4 0c             	add    $0xc,%esp
  8018a6:	6a 00                	push   $0x0
  8018a8:	53                   	push   %ebx
  8018a9:	6a 00                	push   $0x0
  8018ab:	e8 19 f9 ff ff       	call   8011c9 <ipc_recv>
}
  8018b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b3:	5b                   	pop    %ebx
  8018b4:	5e                   	pop    %esi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018da:	e8 8d ff ff ff       	call   80186c <fsipc>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018fc:	e8 6b ff ff ff       	call   80186c <fsipc>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 40 0c             	mov    0xc(%eax),%eax
  801913:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 05 00 00 00       	mov    $0x5,%eax
  801922:	e8 45 ff ff ff       	call   80186c <fsipc>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 2c                	js     801957 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	68 00 50 80 00       	push   $0x805000
  801933:	53                   	push   %ebx
  801934:	e8 69 ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801939:	a1 80 50 80 00       	mov    0x805080,%eax
  80193e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801944:	a1 84 50 80 00       	mov    0x805084,%eax
  801949:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801965:	8b 55 08             	mov    0x8(%ebp),%edx
  801968:	8b 52 0c             	mov    0xc(%edx),%edx
  80196b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801971:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801976:	50                   	push   %eax
  801977:	ff 75 0c             	pushl  0xc(%ebp)
  80197a:	68 08 50 80 00       	push   $0x805008
  80197f:	e8 b0 f0 ff ff       	call   800a34 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801984:	ba 00 00 00 00       	mov    $0x0,%edx
  801989:	b8 04 00 00 00       	mov    $0x4,%eax
  80198e:	e8 d9 fe ff ff       	call   80186c <fsipc>

}
  801993:	c9                   	leave  
  801994:	c3                   	ret    

00801995 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801995:	55                   	push   %ebp
  801996:	89 e5                	mov    %esp,%ebp
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80199d:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8019a3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019a8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b3:	b8 03 00 00 00       	mov    $0x3,%eax
  8019b8:	e8 af fe ff ff       	call   80186c <fsipc>
  8019bd:	89 c3                	mov    %eax,%ebx
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 4b                	js     801a0e <devfile_read+0x79>
		return r;
	assert(r <= n);
  8019c3:	39 c6                	cmp    %eax,%esi
  8019c5:	73 16                	jae    8019dd <devfile_read+0x48>
  8019c7:	68 ec 2c 80 00       	push   $0x802cec
  8019cc:	68 f3 2c 80 00       	push   $0x802cf3
  8019d1:	6a 7c                	push   $0x7c
  8019d3:	68 08 2d 80 00       	push   $0x802d08
  8019d8:	e8 67 e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  8019dd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019e2:	7e 16                	jle    8019fa <devfile_read+0x65>
  8019e4:	68 13 2d 80 00       	push   $0x802d13
  8019e9:	68 f3 2c 80 00       	push   $0x802cf3
  8019ee:	6a 7d                	push   $0x7d
  8019f0:	68 08 2d 80 00       	push   $0x802d08
  8019f5:	e8 4a e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019fa:	83 ec 04             	sub    $0x4,%esp
  8019fd:	50                   	push   %eax
  8019fe:	68 00 50 80 00       	push   $0x805000
  801a03:	ff 75 0c             	pushl  0xc(%ebp)
  801a06:	e8 29 f0 ff ff       	call   800a34 <memmove>
	return r;
  801a0b:	83 c4 10             	add    $0x10,%esp
}
  801a0e:	89 d8                	mov    %ebx,%eax
  801a10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a13:	5b                   	pop    %ebx
  801a14:	5e                   	pop    %esi
  801a15:	5d                   	pop    %ebp
  801a16:	c3                   	ret    

00801a17 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 20             	sub    $0x20,%esp
  801a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a21:	53                   	push   %ebx
  801a22:	e8 42 ee ff ff       	call   800869 <strlen>
  801a27:	83 c4 10             	add    $0x10,%esp
  801a2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a2f:	7f 67                	jg     801a98 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a37:	50                   	push   %eax
  801a38:	e8 a7 f8 ff ff       	call   8012e4 <fd_alloc>
  801a3d:	83 c4 10             	add    $0x10,%esp
		return r;
  801a40:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a42:	85 c0                	test   %eax,%eax
  801a44:	78 57                	js     801a9d <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a46:	83 ec 08             	sub    $0x8,%esp
  801a49:	53                   	push   %ebx
  801a4a:	68 00 50 80 00       	push   $0x805000
  801a4f:	e8 4e ee ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a57:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a5f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a64:	e8 03 fe ff ff       	call   80186c <fsipc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	79 14                	jns    801a86 <open+0x6f>
		fd_close(fd, 0);
  801a72:	83 ec 08             	sub    $0x8,%esp
  801a75:	6a 00                	push   $0x0
  801a77:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7a:	e8 5d f9 ff ff       	call   8013dc <fd_close>
		return r;
  801a7f:	83 c4 10             	add    $0x10,%esp
  801a82:	89 da                	mov    %ebx,%edx
  801a84:	eb 17                	jmp    801a9d <open+0x86>
	}

	return fd2num(fd);
  801a86:	83 ec 0c             	sub    $0xc,%esp
  801a89:	ff 75 f4             	pushl  -0xc(%ebp)
  801a8c:	e8 2c f8 ff ff       	call   8012bd <fd2num>
  801a91:	89 c2                	mov    %eax,%edx
  801a93:	83 c4 10             	add    $0x10,%esp
  801a96:	eb 05                	jmp    801a9d <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a98:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a9d:	89 d0                	mov    %edx,%eax
  801a9f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    

00801aa4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aa4:	55                   	push   %ebp
  801aa5:	89 e5                	mov    %esp,%ebp
  801aa7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801aaa:	ba 00 00 00 00       	mov    $0x0,%edx
  801aaf:	b8 08 00 00 00       	mov    $0x8,%eax
  801ab4:	e8 b3 fd ff ff       	call   80186c <fsipc>
}
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ac1:	89 d0                	mov    %edx,%eax
  801ac3:	c1 e8 16             	shr    $0x16,%eax
  801ac6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad2:	f6 c1 01             	test   $0x1,%cl
  801ad5:	74 1d                	je     801af4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ad7:	c1 ea 0c             	shr    $0xc,%edx
  801ada:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ae1:	f6 c2 01             	test   $0x1,%dl
  801ae4:	74 0e                	je     801af4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ae6:	c1 ea 0c             	shr    $0xc,%edx
  801ae9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801af0:	ef 
  801af1:	0f b7 c0             	movzwl %ax,%eax
}
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801afc:	68 1f 2d 80 00       	push   $0x802d1f
  801b01:	ff 75 0c             	pushl  0xc(%ebp)
  801b04:	e8 99 ed ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	53                   	push   %ebx
  801b14:	83 ec 10             	sub    $0x10,%esp
  801b17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b1a:	53                   	push   %ebx
  801b1b:	e8 9b ff ff ff       	call   801abb <pageref>
  801b20:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801b23:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801b28:	83 f8 01             	cmp    $0x1,%eax
  801b2b:	75 10                	jne    801b3d <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801b2d:	83 ec 0c             	sub    $0xc,%esp
  801b30:	ff 73 0c             	pushl  0xc(%ebx)
  801b33:	e8 c0 02 00 00       	call   801df8 <nsipc_close>
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801b3d:	89 d0                	mov    %edx,%eax
  801b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b4a:	6a 00                	push   $0x0
  801b4c:	ff 75 10             	pushl  0x10(%ebp)
  801b4f:	ff 75 0c             	pushl  0xc(%ebp)
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	ff 70 0c             	pushl  0xc(%eax)
  801b58:	e8 78 03 00 00       	call   801ed5 <nsipc_send>
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b65:	6a 00                	push   $0x0
  801b67:	ff 75 10             	pushl  0x10(%ebp)
  801b6a:	ff 75 0c             	pushl  0xc(%ebp)
  801b6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b70:	ff 70 0c             	pushl  0xc(%eax)
  801b73:	e8 f1 02 00 00       	call   801e69 <nsipc_recv>
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b80:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b83:	52                   	push   %edx
  801b84:	50                   	push   %eax
  801b85:	e8 a9 f7 ff ff       	call   801333 <fd_lookup>
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	78 17                	js     801ba8 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b9a:	39 08                	cmp    %ecx,(%eax)
  801b9c:	75 05                	jne    801ba3 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b9e:	8b 40 0c             	mov    0xc(%eax),%eax
  801ba1:	eb 05                	jmp    801ba8 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801ba3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801ba8:	c9                   	leave  
  801ba9:	c3                   	ret    

00801baa <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801baa:	55                   	push   %ebp
  801bab:	89 e5                	mov    %esp,%ebp
  801bad:	56                   	push   %esi
  801bae:	53                   	push   %ebx
  801baf:	83 ec 1c             	sub    $0x1c,%esp
  801bb2:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 27 f7 ff ff       	call   8012e4 <fd_alloc>
  801bbd:	89 c3                	mov    %eax,%ebx
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 1b                	js     801be1 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bc6:	83 ec 04             	sub    $0x4,%esp
  801bc9:	68 07 04 00 00       	push   $0x407
  801bce:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 cd f0 ff ff       	call   800ca5 <sys_page_alloc>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	79 10                	jns    801bf1 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801be1:	83 ec 0c             	sub    $0xc,%esp
  801be4:	56                   	push   %esi
  801be5:	e8 0e 02 00 00       	call   801df8 <nsipc_close>
		return r;
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	89 d8                	mov    %ebx,%eax
  801bef:	eb 24                	jmp    801c15 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfa:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bfc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bff:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c06:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c09:	83 ec 0c             	sub    $0xc,%esp
  801c0c:	50                   	push   %eax
  801c0d:	e8 ab f6 ff ff       	call   8012bd <fd2num>
  801c12:	83 c4 10             	add    $0x10,%esp
}
  801c15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c18:	5b                   	pop    %ebx
  801c19:	5e                   	pop    %esi
  801c1a:	5d                   	pop    %ebp
  801c1b:	c3                   	ret    

00801c1c <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c1c:	55                   	push   %ebp
  801c1d:	89 e5                	mov    %esp,%ebp
  801c1f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
  801c25:	e8 50 ff ff ff       	call   801b7a <fd2sockid>
		return r;
  801c2a:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 1f                	js     801c4f <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c30:	83 ec 04             	sub    $0x4,%esp
  801c33:	ff 75 10             	pushl  0x10(%ebp)
  801c36:	ff 75 0c             	pushl  0xc(%ebp)
  801c39:	50                   	push   %eax
  801c3a:	e8 12 01 00 00       	call   801d51 <nsipc_accept>
  801c3f:	83 c4 10             	add    $0x10,%esp
		return r;
  801c42:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c44:	85 c0                	test   %eax,%eax
  801c46:	78 07                	js     801c4f <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c48:	e8 5d ff ff ff       	call   801baa <alloc_sockfd>
  801c4d:	89 c1                	mov    %eax,%ecx
}
  801c4f:	89 c8                	mov    %ecx,%eax
  801c51:	c9                   	leave  
  801c52:	c3                   	ret    

00801c53 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c53:	55                   	push   %ebp
  801c54:	89 e5                	mov    %esp,%ebp
  801c56:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c59:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5c:	e8 19 ff ff ff       	call   801b7a <fd2sockid>
  801c61:	85 c0                	test   %eax,%eax
  801c63:	78 12                	js     801c77 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c65:	83 ec 04             	sub    $0x4,%esp
  801c68:	ff 75 10             	pushl  0x10(%ebp)
  801c6b:	ff 75 0c             	pushl  0xc(%ebp)
  801c6e:	50                   	push   %eax
  801c6f:	e8 2d 01 00 00       	call   801da1 <nsipc_bind>
  801c74:	83 c4 10             	add    $0x10,%esp
}
  801c77:	c9                   	leave  
  801c78:	c3                   	ret    

00801c79 <shutdown>:

int
shutdown(int s, int how)
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	e8 f3 fe ff ff       	call   801b7a <fd2sockid>
  801c87:	85 c0                	test   %eax,%eax
  801c89:	78 0f                	js     801c9a <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c8b:	83 ec 08             	sub    $0x8,%esp
  801c8e:	ff 75 0c             	pushl  0xc(%ebp)
  801c91:	50                   	push   %eax
  801c92:	e8 3f 01 00 00       	call   801dd6 <nsipc_shutdown>
  801c97:	83 c4 10             	add    $0x10,%esp
}
  801c9a:	c9                   	leave  
  801c9b:	c3                   	ret    

00801c9c <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca5:	e8 d0 fe ff ff       	call   801b7a <fd2sockid>
  801caa:	85 c0                	test   %eax,%eax
  801cac:	78 12                	js     801cc0 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801cae:	83 ec 04             	sub    $0x4,%esp
  801cb1:	ff 75 10             	pushl  0x10(%ebp)
  801cb4:	ff 75 0c             	pushl  0xc(%ebp)
  801cb7:	50                   	push   %eax
  801cb8:	e8 55 01 00 00       	call   801e12 <nsipc_connect>
  801cbd:	83 c4 10             	add    $0x10,%esp
}
  801cc0:	c9                   	leave  
  801cc1:	c3                   	ret    

00801cc2 <listen>:

int
listen(int s, int backlog)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	e8 aa fe ff ff       	call   801b7a <fd2sockid>
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	78 0f                	js     801ce3 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801cd4:	83 ec 08             	sub    $0x8,%esp
  801cd7:	ff 75 0c             	pushl  0xc(%ebp)
  801cda:	50                   	push   %eax
  801cdb:	e8 67 01 00 00       	call   801e47 <nsipc_listen>
  801ce0:	83 c4 10             	add    $0x10,%esp
}
  801ce3:	c9                   	leave  
  801ce4:	c3                   	ret    

00801ce5 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ceb:	ff 75 10             	pushl  0x10(%ebp)
  801cee:	ff 75 0c             	pushl  0xc(%ebp)
  801cf1:	ff 75 08             	pushl  0x8(%ebp)
  801cf4:	e8 3a 02 00 00       	call   801f33 <nsipc_socket>
  801cf9:	83 c4 10             	add    $0x10,%esp
  801cfc:	85 c0                	test   %eax,%eax
  801cfe:	78 05                	js     801d05 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d00:	e8 a5 fe ff ff       	call   801baa <alloc_sockfd>
}
  801d05:	c9                   	leave  
  801d06:	c3                   	ret    

00801d07 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d07:	55                   	push   %ebp
  801d08:	89 e5                	mov    %esp,%ebp
  801d0a:	53                   	push   %ebx
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d10:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d17:	75 12                	jne    801d2b <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	6a 02                	push   $0x2
  801d1e:	e8 61 f5 ff ff       	call   801284 <ipc_find_env>
  801d23:	a3 04 40 80 00       	mov    %eax,0x804004
  801d28:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d2b:	6a 07                	push   $0x7
  801d2d:	68 00 60 80 00       	push   $0x806000
  801d32:	53                   	push   %ebx
  801d33:	ff 35 04 40 80 00    	pushl  0x804004
  801d39:	e8 f2 f4 ff ff       	call   801230 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d3e:	83 c4 0c             	add    $0xc,%esp
  801d41:	6a 00                	push   $0x0
  801d43:	6a 00                	push   $0x0
  801d45:	6a 00                	push   $0x0
  801d47:	e8 7d f4 ff ff       	call   8011c9 <ipc_recv>
}
  801d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4f:	c9                   	leave  
  801d50:	c3                   	ret    

00801d51 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d59:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d61:	8b 06                	mov    (%esi),%eax
  801d63:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d68:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6d:	e8 95 ff ff ff       	call   801d07 <nsipc>
  801d72:	89 c3                	mov    %eax,%ebx
  801d74:	85 c0                	test   %eax,%eax
  801d76:	78 20                	js     801d98 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d78:	83 ec 04             	sub    $0x4,%esp
  801d7b:	ff 35 10 60 80 00    	pushl  0x806010
  801d81:	68 00 60 80 00       	push   $0x806000
  801d86:	ff 75 0c             	pushl  0xc(%ebp)
  801d89:	e8 a6 ec ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801d8e:	a1 10 60 80 00       	mov    0x806010,%eax
  801d93:	89 06                	mov    %eax,(%esi)
  801d95:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5d                   	pop    %ebp
  801da0:	c3                   	ret    

00801da1 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	53                   	push   %ebx
  801da5:	83 ec 08             	sub    $0x8,%esp
  801da8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dab:	8b 45 08             	mov    0x8(%ebp),%eax
  801dae:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801db3:	53                   	push   %ebx
  801db4:	ff 75 0c             	pushl  0xc(%ebp)
  801db7:	68 04 60 80 00       	push   $0x806004
  801dbc:	e8 73 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dc1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dc7:	b8 02 00 00 00       	mov    $0x2,%eax
  801dcc:	e8 36 ff ff ff       	call   801d07 <nsipc>
}
  801dd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dd4:	c9                   	leave  
  801dd5:	c3                   	ret    

00801dd6 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801dd6:	55                   	push   %ebp
  801dd7:	89 e5                	mov    %esp,%ebp
  801dd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801de4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801dec:	b8 03 00 00 00       	mov    $0x3,%eax
  801df1:	e8 11 ff ff ff       	call   801d07 <nsipc>
}
  801df6:	c9                   	leave  
  801df7:	c3                   	ret    

00801df8 <nsipc_close>:

int
nsipc_close(int s)
{
  801df8:	55                   	push   %ebp
  801df9:	89 e5                	mov    %esp,%ebp
  801dfb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801e01:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e06:	b8 04 00 00 00       	mov    $0x4,%eax
  801e0b:	e8 f7 fe ff ff       	call   801d07 <nsipc>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	53                   	push   %ebx
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1f:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e24:	53                   	push   %ebx
  801e25:	ff 75 0c             	pushl  0xc(%ebp)
  801e28:	68 04 60 80 00       	push   $0x806004
  801e2d:	e8 02 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e32:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e38:	b8 05 00 00 00       	mov    $0x5,%eax
  801e3d:	e8 c5 fe ff ff       	call   801d07 <nsipc>
}
  801e42:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e45:	c9                   	leave  
  801e46:	c3                   	ret    

00801e47 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e4d:	8b 45 08             	mov    0x8(%ebp),%eax
  801e50:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e58:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e5d:	b8 06 00 00 00       	mov    $0x6,%eax
  801e62:	e8 a0 fe ff ff       	call   801d07 <nsipc>
}
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e71:	8b 45 08             	mov    0x8(%ebp),%eax
  801e74:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e79:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e82:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e87:	b8 07 00 00 00       	mov    $0x7,%eax
  801e8c:	e8 76 fe ff ff       	call   801d07 <nsipc>
  801e91:	89 c3                	mov    %eax,%ebx
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 35                	js     801ecc <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e97:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e9c:	7f 04                	jg     801ea2 <nsipc_recv+0x39>
  801e9e:	39 c6                	cmp    %eax,%esi
  801ea0:	7d 16                	jge    801eb8 <nsipc_recv+0x4f>
  801ea2:	68 2b 2d 80 00       	push   $0x802d2b
  801ea7:	68 f3 2c 80 00       	push   $0x802cf3
  801eac:	6a 62                	push   $0x62
  801eae:	68 40 2d 80 00       	push   $0x802d40
  801eb3:	e8 8c e3 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801eb8:	83 ec 04             	sub    $0x4,%esp
  801ebb:	50                   	push   %eax
  801ebc:	68 00 60 80 00       	push   $0x806000
  801ec1:	ff 75 0c             	pushl  0xc(%ebp)
  801ec4:	e8 6b eb ff ff       	call   800a34 <memmove>
  801ec9:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ecc:	89 d8                	mov    %ebx,%eax
  801ece:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5d                   	pop    %ebp
  801ed4:	c3                   	ret    

00801ed5 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ed5:	55                   	push   %ebp
  801ed6:	89 e5                	mov    %esp,%ebp
  801ed8:	53                   	push   %ebx
  801ed9:	83 ec 04             	sub    $0x4,%esp
  801edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ee7:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eed:	7e 16                	jle    801f05 <nsipc_send+0x30>
  801eef:	68 4c 2d 80 00       	push   $0x802d4c
  801ef4:	68 f3 2c 80 00       	push   $0x802cf3
  801ef9:	6a 6d                	push   $0x6d
  801efb:	68 40 2d 80 00       	push   $0x802d40
  801f00:	e8 3f e3 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801f05:	83 ec 04             	sub    $0x4,%esp
  801f08:	53                   	push   %ebx
  801f09:	ff 75 0c             	pushl  0xc(%ebp)
  801f0c:	68 0c 60 80 00       	push   $0x80600c
  801f11:	e8 1e eb ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  801f16:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801f24:	b8 08 00 00 00       	mov    $0x8,%eax
  801f29:	e8 d9 fd ff ff       	call   801d07 <nsipc>
}
  801f2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801f41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f44:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f49:	8b 45 10             	mov    0x10(%ebp),%eax
  801f4c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f51:	b8 09 00 00 00       	mov    $0x9,%eax
  801f56:	e8 ac fd ff ff       	call   801d07 <nsipc>
}
  801f5b:	c9                   	leave  
  801f5c:	c3                   	ret    

00801f5d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f5d:	55                   	push   %ebp
  801f5e:	89 e5                	mov    %esp,%ebp
  801f60:	56                   	push   %esi
  801f61:	53                   	push   %ebx
  801f62:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	ff 75 08             	pushl  0x8(%ebp)
  801f6b:	e8 5d f3 ff ff       	call   8012cd <fd2data>
  801f70:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f72:	83 c4 08             	add    $0x8,%esp
  801f75:	68 58 2d 80 00       	push   $0x802d58
  801f7a:	53                   	push   %ebx
  801f7b:	e8 22 e9 ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f80:	8b 46 04             	mov    0x4(%esi),%eax
  801f83:	2b 06                	sub    (%esi),%eax
  801f85:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f8b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f92:	00 00 00 
	stat->st_dev = &devpipe;
  801f95:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f9c:	30 80 00 
	return 0;
}
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fa7:	5b                   	pop    %ebx
  801fa8:	5e                   	pop    %esi
  801fa9:	5d                   	pop    %ebp
  801faa:	c3                   	ret    

00801fab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fab:	55                   	push   %ebp
  801fac:	89 e5                	mov    %esp,%ebp
  801fae:	53                   	push   %ebx
  801faf:	83 ec 0c             	sub    $0xc,%esp
  801fb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fb5:	53                   	push   %ebx
  801fb6:	6a 00                	push   $0x0
  801fb8:	e8 6d ed ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fbd:	89 1c 24             	mov    %ebx,(%esp)
  801fc0:	e8 08 f3 ff ff       	call   8012cd <fd2data>
  801fc5:	83 c4 08             	add    $0x8,%esp
  801fc8:	50                   	push   %eax
  801fc9:	6a 00                	push   $0x0
  801fcb:	e8 5a ed ff ff       	call   800d2a <sys_page_unmap>
}
  801fd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd3:	c9                   	leave  
  801fd4:	c3                   	ret    

00801fd5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801fd5:	55                   	push   %ebp
  801fd6:	89 e5                	mov    %esp,%ebp
  801fd8:	57                   	push   %edi
  801fd9:	56                   	push   %esi
  801fda:	53                   	push   %ebx
  801fdb:	83 ec 1c             	sub    $0x1c,%esp
  801fde:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801fe1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fe3:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801feb:	83 ec 0c             	sub    $0xc,%esp
  801fee:	ff 75 e0             	pushl  -0x20(%ebp)
  801ff1:	e8 c5 fa ff ff       	call   801abb <pageref>
  801ff6:	89 c3                	mov    %eax,%ebx
  801ff8:	89 3c 24             	mov    %edi,(%esp)
  801ffb:	e8 bb fa ff ff       	call   801abb <pageref>
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	39 c3                	cmp    %eax,%ebx
  802005:	0f 94 c1             	sete   %cl
  802008:	0f b6 c9             	movzbl %cl,%ecx
  80200b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80200e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  802014:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802017:	39 ce                	cmp    %ecx,%esi
  802019:	74 1b                	je     802036 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80201b:	39 c3                	cmp    %eax,%ebx
  80201d:	75 c4                	jne    801fe3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80201f:	8b 42 58             	mov    0x58(%edx),%eax
  802022:	ff 75 e4             	pushl  -0x1c(%ebp)
  802025:	50                   	push   %eax
  802026:	56                   	push   %esi
  802027:	68 5f 2d 80 00       	push   $0x802d5f
  80202c:	e8 ec e2 ff ff       	call   80031d <cprintf>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	eb ad                	jmp    801fe3 <_pipeisclosed+0xe>
	}
}
  802036:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802039:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80203c:	5b                   	pop    %ebx
  80203d:	5e                   	pop    %esi
  80203e:	5f                   	pop    %edi
  80203f:	5d                   	pop    %ebp
  802040:	c3                   	ret    

00802041 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802041:	55                   	push   %ebp
  802042:	89 e5                	mov    %esp,%ebp
  802044:	57                   	push   %edi
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	83 ec 28             	sub    $0x28,%esp
  80204a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80204d:	56                   	push   %esi
  80204e:	e8 7a f2 ff ff       	call   8012cd <fd2data>
  802053:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	bf 00 00 00 00       	mov    $0x0,%edi
  80205d:	eb 4b                	jmp    8020aa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80205f:	89 da                	mov    %ebx,%edx
  802061:	89 f0                	mov    %esi,%eax
  802063:	e8 6d ff ff ff       	call   801fd5 <_pipeisclosed>
  802068:	85 c0                	test   %eax,%eax
  80206a:	75 48                	jne    8020b4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80206c:	e8 15 ec ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802071:	8b 43 04             	mov    0x4(%ebx),%eax
  802074:	8b 0b                	mov    (%ebx),%ecx
  802076:	8d 51 20             	lea    0x20(%ecx),%edx
  802079:	39 d0                	cmp    %edx,%eax
  80207b:	73 e2                	jae    80205f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80207d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802080:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802084:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802087:	89 c2                	mov    %eax,%edx
  802089:	c1 fa 1f             	sar    $0x1f,%edx
  80208c:	89 d1                	mov    %edx,%ecx
  80208e:	c1 e9 1b             	shr    $0x1b,%ecx
  802091:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802094:	83 e2 1f             	and    $0x1f,%edx
  802097:	29 ca                	sub    %ecx,%edx
  802099:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80209d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020a1:	83 c0 01             	add    $0x1,%eax
  8020a4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020a7:	83 c7 01             	add    $0x1,%edi
  8020aa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020ad:	75 c2                	jne    802071 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020af:	8b 45 10             	mov    0x10(%ebp),%eax
  8020b2:	eb 05                	jmp    8020b9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020b4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020bc:	5b                   	pop    %ebx
  8020bd:	5e                   	pop    %esi
  8020be:	5f                   	pop    %edi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    

008020c1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	57                   	push   %edi
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
  8020c7:	83 ec 18             	sub    $0x18,%esp
  8020ca:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8020cd:	57                   	push   %edi
  8020ce:	e8 fa f1 ff ff       	call   8012cd <fd2data>
  8020d3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020dd:	eb 3d                	jmp    80211c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8020df:	85 db                	test   %ebx,%ebx
  8020e1:	74 04                	je     8020e7 <devpipe_read+0x26>
				return i;
  8020e3:	89 d8                	mov    %ebx,%eax
  8020e5:	eb 44                	jmp    80212b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020e7:	89 f2                	mov    %esi,%edx
  8020e9:	89 f8                	mov    %edi,%eax
  8020eb:	e8 e5 fe ff ff       	call   801fd5 <_pipeisclosed>
  8020f0:	85 c0                	test   %eax,%eax
  8020f2:	75 32                	jne    802126 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020f4:	e8 8d eb ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020f9:	8b 06                	mov    (%esi),%eax
  8020fb:	3b 46 04             	cmp    0x4(%esi),%eax
  8020fe:	74 df                	je     8020df <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802100:	99                   	cltd   
  802101:	c1 ea 1b             	shr    $0x1b,%edx
  802104:	01 d0                	add    %edx,%eax
  802106:	83 e0 1f             	and    $0x1f,%eax
  802109:	29 d0                	sub    %edx,%eax
  80210b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802113:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802116:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802119:	83 c3 01             	add    $0x1,%ebx
  80211c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80211f:	75 d8                	jne    8020f9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802121:	8b 45 10             	mov    0x10(%ebp),%eax
  802124:	eb 05                	jmp    80212b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802126:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80212b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212e:	5b                   	pop    %ebx
  80212f:	5e                   	pop    %esi
  802130:	5f                   	pop    %edi
  802131:	5d                   	pop    %ebp
  802132:	c3                   	ret    

00802133 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802133:	55                   	push   %ebp
  802134:	89 e5                	mov    %esp,%ebp
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80213b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213e:	50                   	push   %eax
  80213f:	e8 a0 f1 ff ff       	call   8012e4 <fd_alloc>
  802144:	83 c4 10             	add    $0x10,%esp
  802147:	89 c2                	mov    %eax,%edx
  802149:	85 c0                	test   %eax,%eax
  80214b:	0f 88 2c 01 00 00    	js     80227d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802151:	83 ec 04             	sub    $0x4,%esp
  802154:	68 07 04 00 00       	push   $0x407
  802159:	ff 75 f4             	pushl  -0xc(%ebp)
  80215c:	6a 00                	push   $0x0
  80215e:	e8 42 eb ff ff       	call   800ca5 <sys_page_alloc>
  802163:	83 c4 10             	add    $0x10,%esp
  802166:	89 c2                	mov    %eax,%edx
  802168:	85 c0                	test   %eax,%eax
  80216a:	0f 88 0d 01 00 00    	js     80227d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802170:	83 ec 0c             	sub    $0xc,%esp
  802173:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	e8 68 f1 ff ff       	call   8012e4 <fd_alloc>
  80217c:	89 c3                	mov    %eax,%ebx
  80217e:	83 c4 10             	add    $0x10,%esp
  802181:	85 c0                	test   %eax,%eax
  802183:	0f 88 e2 00 00 00    	js     80226b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802189:	83 ec 04             	sub    $0x4,%esp
  80218c:	68 07 04 00 00       	push   $0x407
  802191:	ff 75 f0             	pushl  -0x10(%ebp)
  802194:	6a 00                	push   $0x0
  802196:	e8 0a eb ff ff       	call   800ca5 <sys_page_alloc>
  80219b:	89 c3                	mov    %eax,%ebx
  80219d:	83 c4 10             	add    $0x10,%esp
  8021a0:	85 c0                	test   %eax,%eax
  8021a2:	0f 88 c3 00 00 00    	js     80226b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021a8:	83 ec 0c             	sub    $0xc,%esp
  8021ab:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ae:	e8 1a f1 ff ff       	call   8012cd <fd2data>
  8021b3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b5:	83 c4 0c             	add    $0xc,%esp
  8021b8:	68 07 04 00 00       	push   $0x407
  8021bd:	50                   	push   %eax
  8021be:	6a 00                	push   $0x0
  8021c0:	e8 e0 ea ff ff       	call   800ca5 <sys_page_alloc>
  8021c5:	89 c3                	mov    %eax,%ebx
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	0f 88 89 00 00 00    	js     80225b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d2:	83 ec 0c             	sub    $0xc,%esp
  8021d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8021d8:	e8 f0 f0 ff ff       	call   8012cd <fd2data>
  8021dd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e4:	50                   	push   %eax
  8021e5:	6a 00                	push   $0x0
  8021e7:	56                   	push   %esi
  8021e8:	6a 00                	push   $0x0
  8021ea:	e8 f9 ea ff ff       	call   800ce8 <sys_page_map>
  8021ef:	89 c3                	mov    %eax,%ebx
  8021f1:	83 c4 20             	add    $0x20,%esp
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	78 55                	js     80224d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021f8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802201:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802203:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802206:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80220d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802213:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802216:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80221b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802222:	83 ec 0c             	sub    $0xc,%esp
  802225:	ff 75 f4             	pushl  -0xc(%ebp)
  802228:	e8 90 f0 ff ff       	call   8012bd <fd2num>
  80222d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802230:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802232:	83 c4 04             	add    $0x4,%esp
  802235:	ff 75 f0             	pushl  -0x10(%ebp)
  802238:	e8 80 f0 ff ff       	call   8012bd <fd2num>
  80223d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802240:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802243:	83 c4 10             	add    $0x10,%esp
  802246:	ba 00 00 00 00       	mov    $0x0,%edx
  80224b:	eb 30                	jmp    80227d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80224d:	83 ec 08             	sub    $0x8,%esp
  802250:	56                   	push   %esi
  802251:	6a 00                	push   $0x0
  802253:	e8 d2 ea ff ff       	call   800d2a <sys_page_unmap>
  802258:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80225b:	83 ec 08             	sub    $0x8,%esp
  80225e:	ff 75 f0             	pushl  -0x10(%ebp)
  802261:	6a 00                	push   $0x0
  802263:	e8 c2 ea ff ff       	call   800d2a <sys_page_unmap>
  802268:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80226b:	83 ec 08             	sub    $0x8,%esp
  80226e:	ff 75 f4             	pushl  -0xc(%ebp)
  802271:	6a 00                	push   $0x0
  802273:	e8 b2 ea ff ff       	call   800d2a <sys_page_unmap>
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80227d:	89 d0                	mov    %edx,%eax
  80227f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802282:	5b                   	pop    %ebx
  802283:	5e                   	pop    %esi
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    

00802286 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80228c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228f:	50                   	push   %eax
  802290:	ff 75 08             	pushl  0x8(%ebp)
  802293:	e8 9b f0 ff ff       	call   801333 <fd_lookup>
  802298:	83 c4 10             	add    $0x10,%esp
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 18                	js     8022b7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80229f:	83 ec 0c             	sub    $0xc,%esp
  8022a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a5:	e8 23 f0 ff ff       	call   8012cd <fd2data>
	return _pipeisclosed(fd, p);
  8022aa:	89 c2                	mov    %eax,%edx
  8022ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022af:	e8 21 fd ff ff       	call   801fd5 <_pipeisclosed>
  8022b4:	83 c4 10             	add    $0x10,%esp
}
  8022b7:	c9                   	leave  
  8022b8:	c3                   	ret    

008022b9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8022bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    

008022c3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022c9:	68 77 2d 80 00       	push   $0x802d77
  8022ce:	ff 75 0c             	pushl  0xc(%ebp)
  8022d1:	e8 cc e5 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  8022d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022db:	c9                   	leave  
  8022dc:	c3                   	ret    

008022dd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8022dd:	55                   	push   %ebp
  8022de:	89 e5                	mov    %esp,%ebp
  8022e0:	57                   	push   %edi
  8022e1:	56                   	push   %esi
  8022e2:	53                   	push   %ebx
  8022e3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022e9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022ee:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022f4:	eb 2d                	jmp    802323 <devcons_write+0x46>
		m = n - tot;
  8022f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022f9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022fb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022fe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802303:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802306:	83 ec 04             	sub    $0x4,%esp
  802309:	53                   	push   %ebx
  80230a:	03 45 0c             	add    0xc(%ebp),%eax
  80230d:	50                   	push   %eax
  80230e:	57                   	push   %edi
  80230f:	e8 20 e7 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  802314:	83 c4 08             	add    $0x8,%esp
  802317:	53                   	push   %ebx
  802318:	57                   	push   %edi
  802319:	e8 cb e8 ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80231e:	01 de                	add    %ebx,%esi
  802320:	83 c4 10             	add    $0x10,%esp
  802323:	89 f0                	mov    %esi,%eax
  802325:	3b 75 10             	cmp    0x10(%ebp),%esi
  802328:	72 cc                	jb     8022f6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80232a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80232d:	5b                   	pop    %ebx
  80232e:	5e                   	pop    %esi
  80232f:	5f                   	pop    %edi
  802330:	5d                   	pop    %ebp
  802331:	c3                   	ret    

00802332 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 08             	sub    $0x8,%esp
  802338:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80233d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802341:	74 2a                	je     80236d <devcons_read+0x3b>
  802343:	eb 05                	jmp    80234a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802345:	e8 3c e9 ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80234a:	e8 b8 e8 ff ff       	call   800c07 <sys_cgetc>
  80234f:	85 c0                	test   %eax,%eax
  802351:	74 f2                	je     802345 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802353:	85 c0                	test   %eax,%eax
  802355:	78 16                	js     80236d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802357:	83 f8 04             	cmp    $0x4,%eax
  80235a:	74 0c                	je     802368 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80235c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80235f:	88 02                	mov    %al,(%edx)
	return 1;
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	eb 05                	jmp    80236d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802368:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80236d:	c9                   	leave  
  80236e:	c3                   	ret    

0080236f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80236f:	55                   	push   %ebp
  802370:	89 e5                	mov    %esp,%ebp
  802372:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802375:	8b 45 08             	mov    0x8(%ebp),%eax
  802378:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80237b:	6a 01                	push   $0x1
  80237d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802380:	50                   	push   %eax
  802381:	e8 63 e8 ff ff       	call   800be9 <sys_cputs>
}
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	c9                   	leave  
  80238a:	c3                   	ret    

0080238b <getchar>:

int
getchar(void)
{
  80238b:	55                   	push   %ebp
  80238c:	89 e5                	mov    %esp,%ebp
  80238e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802391:	6a 01                	push   $0x1
  802393:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802396:	50                   	push   %eax
  802397:	6a 00                	push   $0x0
  802399:	e8 fb f1 ff ff       	call   801599 <read>
	if (r < 0)
  80239e:	83 c4 10             	add    $0x10,%esp
  8023a1:	85 c0                	test   %eax,%eax
  8023a3:	78 0f                	js     8023b4 <getchar+0x29>
		return r;
	if (r < 1)
  8023a5:	85 c0                	test   %eax,%eax
  8023a7:	7e 06                	jle    8023af <getchar+0x24>
		return -E_EOF;
	return c;
  8023a9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8023ad:	eb 05                	jmp    8023b4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8023af:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8023b4:	c9                   	leave  
  8023b5:	c3                   	ret    

008023b6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8023b6:	55                   	push   %ebp
  8023b7:	89 e5                	mov    %esp,%ebp
  8023b9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023bf:	50                   	push   %eax
  8023c0:	ff 75 08             	pushl  0x8(%ebp)
  8023c3:	e8 6b ef ff ff       	call   801333 <fd_lookup>
  8023c8:	83 c4 10             	add    $0x10,%esp
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	78 11                	js     8023e0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8023cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023d2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023d8:	39 10                	cmp    %edx,(%eax)
  8023da:	0f 94 c0             	sete   %al
  8023dd:	0f b6 c0             	movzbl %al,%eax
}
  8023e0:	c9                   	leave  
  8023e1:	c3                   	ret    

008023e2 <opencons>:

int
opencons(void)
{
  8023e2:	55                   	push   %ebp
  8023e3:	89 e5                	mov    %esp,%ebp
  8023e5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023eb:	50                   	push   %eax
  8023ec:	e8 f3 ee ff ff       	call   8012e4 <fd_alloc>
  8023f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8023f4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 3e                	js     802438 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023fa:	83 ec 04             	sub    $0x4,%esp
  8023fd:	68 07 04 00 00       	push   $0x407
  802402:	ff 75 f4             	pushl  -0xc(%ebp)
  802405:	6a 00                	push   $0x0
  802407:	e8 99 e8 ff ff       	call   800ca5 <sys_page_alloc>
  80240c:	83 c4 10             	add    $0x10,%esp
		return r;
  80240f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802411:	85 c0                	test   %eax,%eax
  802413:	78 23                	js     802438 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802415:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80241b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80241e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802423:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80242a:	83 ec 0c             	sub    $0xc,%esp
  80242d:	50                   	push   %eax
  80242e:	e8 8a ee ff ff       	call   8012bd <fd2num>
  802433:	89 c2                	mov    %eax,%edx
  802435:	83 c4 10             	add    $0x10,%esp
}
  802438:	89 d0                	mov    %edx,%eax
  80243a:	c9                   	leave  
  80243b:	c3                   	ret    

0080243c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80243c:	55                   	push   %ebp
  80243d:	89 e5                	mov    %esp,%ebp
  80243f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802442:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802449:	75 2e                	jne    802479 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80244b:	e8 17 e8 ff ff       	call   800c67 <sys_getenvid>
  802450:	83 ec 04             	sub    $0x4,%esp
  802453:	68 07 0e 00 00       	push   $0xe07
  802458:	68 00 f0 bf ee       	push   $0xeebff000
  80245d:	50                   	push   %eax
  80245e:	e8 42 e8 ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802463:	e8 ff e7 ff ff       	call   800c67 <sys_getenvid>
  802468:	83 c4 08             	add    $0x8,%esp
  80246b:	68 83 24 80 00       	push   $0x802483
  802470:	50                   	push   %eax
  802471:	e8 7a e9 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  802476:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802479:	8b 45 08             	mov    0x8(%ebp),%eax
  80247c:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802481:	c9                   	leave  
  802482:	c3                   	ret    

00802483 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802483:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802484:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802489:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80248b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80248e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802492:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802496:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802499:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80249c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80249d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  8024a0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  8024a1:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  8024a2:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  8024a6:	c3                   	ret    
  8024a7:	66 90                	xchg   %ax,%ax
  8024a9:	66 90                	xchg   %ax,%ax
  8024ab:	66 90                	xchg   %ax,%ax
  8024ad:	66 90                	xchg   %ax,%ax
  8024af:	90                   	nop

008024b0 <__udivdi3>:
  8024b0:	55                   	push   %ebp
  8024b1:	57                   	push   %edi
  8024b2:	56                   	push   %esi
  8024b3:	53                   	push   %ebx
  8024b4:	83 ec 1c             	sub    $0x1c,%esp
  8024b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024c7:	85 f6                	test   %esi,%esi
  8024c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024cd:	89 ca                	mov    %ecx,%edx
  8024cf:	89 f8                	mov    %edi,%eax
  8024d1:	75 3d                	jne    802510 <__udivdi3+0x60>
  8024d3:	39 cf                	cmp    %ecx,%edi
  8024d5:	0f 87 c5 00 00 00    	ja     8025a0 <__udivdi3+0xf0>
  8024db:	85 ff                	test   %edi,%edi
  8024dd:	89 fd                	mov    %edi,%ebp
  8024df:	75 0b                	jne    8024ec <__udivdi3+0x3c>
  8024e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024e6:	31 d2                	xor    %edx,%edx
  8024e8:	f7 f7                	div    %edi
  8024ea:	89 c5                	mov    %eax,%ebp
  8024ec:	89 c8                	mov    %ecx,%eax
  8024ee:	31 d2                	xor    %edx,%edx
  8024f0:	f7 f5                	div    %ebp
  8024f2:	89 c1                	mov    %eax,%ecx
  8024f4:	89 d8                	mov    %ebx,%eax
  8024f6:	89 cf                	mov    %ecx,%edi
  8024f8:	f7 f5                	div    %ebp
  8024fa:	89 c3                	mov    %eax,%ebx
  8024fc:	89 d8                	mov    %ebx,%eax
  8024fe:	89 fa                	mov    %edi,%edx
  802500:	83 c4 1c             	add    $0x1c,%esp
  802503:	5b                   	pop    %ebx
  802504:	5e                   	pop    %esi
  802505:	5f                   	pop    %edi
  802506:	5d                   	pop    %ebp
  802507:	c3                   	ret    
  802508:	90                   	nop
  802509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802510:	39 ce                	cmp    %ecx,%esi
  802512:	77 74                	ja     802588 <__udivdi3+0xd8>
  802514:	0f bd fe             	bsr    %esi,%edi
  802517:	83 f7 1f             	xor    $0x1f,%edi
  80251a:	0f 84 98 00 00 00    	je     8025b8 <__udivdi3+0x108>
  802520:	bb 20 00 00 00       	mov    $0x20,%ebx
  802525:	89 f9                	mov    %edi,%ecx
  802527:	89 c5                	mov    %eax,%ebp
  802529:	29 fb                	sub    %edi,%ebx
  80252b:	d3 e6                	shl    %cl,%esi
  80252d:	89 d9                	mov    %ebx,%ecx
  80252f:	d3 ed                	shr    %cl,%ebp
  802531:	89 f9                	mov    %edi,%ecx
  802533:	d3 e0                	shl    %cl,%eax
  802535:	09 ee                	or     %ebp,%esi
  802537:	89 d9                	mov    %ebx,%ecx
  802539:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80253d:	89 d5                	mov    %edx,%ebp
  80253f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802543:	d3 ed                	shr    %cl,%ebp
  802545:	89 f9                	mov    %edi,%ecx
  802547:	d3 e2                	shl    %cl,%edx
  802549:	89 d9                	mov    %ebx,%ecx
  80254b:	d3 e8                	shr    %cl,%eax
  80254d:	09 c2                	or     %eax,%edx
  80254f:	89 d0                	mov    %edx,%eax
  802551:	89 ea                	mov    %ebp,%edx
  802553:	f7 f6                	div    %esi
  802555:	89 d5                	mov    %edx,%ebp
  802557:	89 c3                	mov    %eax,%ebx
  802559:	f7 64 24 0c          	mull   0xc(%esp)
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	72 10                	jb     802571 <__udivdi3+0xc1>
  802561:	8b 74 24 08          	mov    0x8(%esp),%esi
  802565:	89 f9                	mov    %edi,%ecx
  802567:	d3 e6                	shl    %cl,%esi
  802569:	39 c6                	cmp    %eax,%esi
  80256b:	73 07                	jae    802574 <__udivdi3+0xc4>
  80256d:	39 d5                	cmp    %edx,%ebp
  80256f:	75 03                	jne    802574 <__udivdi3+0xc4>
  802571:	83 eb 01             	sub    $0x1,%ebx
  802574:	31 ff                	xor    %edi,%edi
  802576:	89 d8                	mov    %ebx,%eax
  802578:	89 fa                	mov    %edi,%edx
  80257a:	83 c4 1c             	add    $0x1c,%esp
  80257d:	5b                   	pop    %ebx
  80257e:	5e                   	pop    %esi
  80257f:	5f                   	pop    %edi
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
  802582:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802588:	31 ff                	xor    %edi,%edi
  80258a:	31 db                	xor    %ebx,%ebx
  80258c:	89 d8                	mov    %ebx,%eax
  80258e:	89 fa                	mov    %edi,%edx
  802590:	83 c4 1c             	add    $0x1c,%esp
  802593:	5b                   	pop    %ebx
  802594:	5e                   	pop    %esi
  802595:	5f                   	pop    %edi
  802596:	5d                   	pop    %ebp
  802597:	c3                   	ret    
  802598:	90                   	nop
  802599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025a0:	89 d8                	mov    %ebx,%eax
  8025a2:	f7 f7                	div    %edi
  8025a4:	31 ff                	xor    %edi,%edi
  8025a6:	89 c3                	mov    %eax,%ebx
  8025a8:	89 d8                	mov    %ebx,%eax
  8025aa:	89 fa                	mov    %edi,%edx
  8025ac:	83 c4 1c             	add    $0x1c,%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    
  8025b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	39 ce                	cmp    %ecx,%esi
  8025ba:	72 0c                	jb     8025c8 <__udivdi3+0x118>
  8025bc:	31 db                	xor    %ebx,%ebx
  8025be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025c2:	0f 87 34 ff ff ff    	ja     8024fc <__udivdi3+0x4c>
  8025c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025cd:	e9 2a ff ff ff       	jmp    8024fc <__udivdi3+0x4c>
  8025d2:	66 90                	xchg   %ax,%ax
  8025d4:	66 90                	xchg   %ax,%ax
  8025d6:	66 90                	xchg   %ax,%ax
  8025d8:	66 90                	xchg   %ax,%ax
  8025da:	66 90                	xchg   %ax,%ax
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__umoddi3>:
  8025e0:	55                   	push   %ebp
  8025e1:	57                   	push   %edi
  8025e2:	56                   	push   %esi
  8025e3:	53                   	push   %ebx
  8025e4:	83 ec 1c             	sub    $0x1c,%esp
  8025e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025f7:	85 d2                	test   %edx,%edx
  8025f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802601:	89 f3                	mov    %esi,%ebx
  802603:	89 3c 24             	mov    %edi,(%esp)
  802606:	89 74 24 04          	mov    %esi,0x4(%esp)
  80260a:	75 1c                	jne    802628 <__umoddi3+0x48>
  80260c:	39 f7                	cmp    %esi,%edi
  80260e:	76 50                	jbe    802660 <__umoddi3+0x80>
  802610:	89 c8                	mov    %ecx,%eax
  802612:	89 f2                	mov    %esi,%edx
  802614:	f7 f7                	div    %edi
  802616:	89 d0                	mov    %edx,%eax
  802618:	31 d2                	xor    %edx,%edx
  80261a:	83 c4 1c             	add    $0x1c,%esp
  80261d:	5b                   	pop    %ebx
  80261e:	5e                   	pop    %esi
  80261f:	5f                   	pop    %edi
  802620:	5d                   	pop    %ebp
  802621:	c3                   	ret    
  802622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802628:	39 f2                	cmp    %esi,%edx
  80262a:	89 d0                	mov    %edx,%eax
  80262c:	77 52                	ja     802680 <__umoddi3+0xa0>
  80262e:	0f bd ea             	bsr    %edx,%ebp
  802631:	83 f5 1f             	xor    $0x1f,%ebp
  802634:	75 5a                	jne    802690 <__umoddi3+0xb0>
  802636:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80263a:	0f 82 e0 00 00 00    	jb     802720 <__umoddi3+0x140>
  802640:	39 0c 24             	cmp    %ecx,(%esp)
  802643:	0f 86 d7 00 00 00    	jbe    802720 <__umoddi3+0x140>
  802649:	8b 44 24 08          	mov    0x8(%esp),%eax
  80264d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802651:	83 c4 1c             	add    $0x1c,%esp
  802654:	5b                   	pop    %ebx
  802655:	5e                   	pop    %esi
  802656:	5f                   	pop    %edi
  802657:	5d                   	pop    %ebp
  802658:	c3                   	ret    
  802659:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802660:	85 ff                	test   %edi,%edi
  802662:	89 fd                	mov    %edi,%ebp
  802664:	75 0b                	jne    802671 <__umoddi3+0x91>
  802666:	b8 01 00 00 00       	mov    $0x1,%eax
  80266b:	31 d2                	xor    %edx,%edx
  80266d:	f7 f7                	div    %edi
  80266f:	89 c5                	mov    %eax,%ebp
  802671:	89 f0                	mov    %esi,%eax
  802673:	31 d2                	xor    %edx,%edx
  802675:	f7 f5                	div    %ebp
  802677:	89 c8                	mov    %ecx,%eax
  802679:	f7 f5                	div    %ebp
  80267b:	89 d0                	mov    %edx,%eax
  80267d:	eb 99                	jmp    802618 <__umoddi3+0x38>
  80267f:	90                   	nop
  802680:	89 c8                	mov    %ecx,%eax
  802682:	89 f2                	mov    %esi,%edx
  802684:	83 c4 1c             	add    $0x1c,%esp
  802687:	5b                   	pop    %ebx
  802688:	5e                   	pop    %esi
  802689:	5f                   	pop    %edi
  80268a:	5d                   	pop    %ebp
  80268b:	c3                   	ret    
  80268c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802690:	8b 34 24             	mov    (%esp),%esi
  802693:	bf 20 00 00 00       	mov    $0x20,%edi
  802698:	89 e9                	mov    %ebp,%ecx
  80269a:	29 ef                	sub    %ebp,%edi
  80269c:	d3 e0                	shl    %cl,%eax
  80269e:	89 f9                	mov    %edi,%ecx
  8026a0:	89 f2                	mov    %esi,%edx
  8026a2:	d3 ea                	shr    %cl,%edx
  8026a4:	89 e9                	mov    %ebp,%ecx
  8026a6:	09 c2                	or     %eax,%edx
  8026a8:	89 d8                	mov    %ebx,%eax
  8026aa:	89 14 24             	mov    %edx,(%esp)
  8026ad:	89 f2                	mov    %esi,%edx
  8026af:	d3 e2                	shl    %cl,%edx
  8026b1:	89 f9                	mov    %edi,%ecx
  8026b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	89 e9                	mov    %ebp,%ecx
  8026bf:	89 c6                	mov    %eax,%esi
  8026c1:	d3 e3                	shl    %cl,%ebx
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 d0                	mov    %edx,%eax
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	09 d8                	or     %ebx,%eax
  8026cd:	89 d3                	mov    %edx,%ebx
  8026cf:	89 f2                	mov    %esi,%edx
  8026d1:	f7 34 24             	divl   (%esp)
  8026d4:	89 d6                	mov    %edx,%esi
  8026d6:	d3 e3                	shl    %cl,%ebx
  8026d8:	f7 64 24 04          	mull   0x4(%esp)
  8026dc:	39 d6                	cmp    %edx,%esi
  8026de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026e2:	89 d1                	mov    %edx,%ecx
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	72 08                	jb     8026f0 <__umoddi3+0x110>
  8026e8:	75 11                	jne    8026fb <__umoddi3+0x11b>
  8026ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ee:	73 0b                	jae    8026fb <__umoddi3+0x11b>
  8026f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026f4:	1b 14 24             	sbb    (%esp),%edx
  8026f7:	89 d1                	mov    %edx,%ecx
  8026f9:	89 c3                	mov    %eax,%ebx
  8026fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ff:	29 da                	sub    %ebx,%edx
  802701:	19 ce                	sbb    %ecx,%esi
  802703:	89 f9                	mov    %edi,%ecx
  802705:	89 f0                	mov    %esi,%eax
  802707:	d3 e0                	shl    %cl,%eax
  802709:	89 e9                	mov    %ebp,%ecx
  80270b:	d3 ea                	shr    %cl,%edx
  80270d:	89 e9                	mov    %ebp,%ecx
  80270f:	d3 ee                	shr    %cl,%esi
  802711:	09 d0                	or     %edx,%eax
  802713:	89 f2                	mov    %esi,%edx
  802715:	83 c4 1c             	add    $0x1c,%esp
  802718:	5b                   	pop    %ebx
  802719:	5e                   	pop    %esi
  80271a:	5f                   	pop    %edi
  80271b:	5d                   	pop    %ebp
  80271c:	c3                   	ret    
  80271d:	8d 76 00             	lea    0x0(%esi),%esi
  802720:	29 f9                	sub    %edi,%ecx
  802722:	19 d6                	sbb    %edx,%esi
  802724:	89 74 24 04          	mov    %esi,0x4(%esp)
  802728:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80272c:	e9 18 ff ff ff       	jmp    802649 <__umoddi3+0x69>
