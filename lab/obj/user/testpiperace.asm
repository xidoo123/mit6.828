
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
  80003b:	68 00 27 80 00       	push   $0x802700
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 a1 20 00 00       	call   8020f1 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 27 80 00       	push   $0x802719
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 27 80 00       	push   $0x802722
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 62 0f 00 00       	call   800fd0 <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 36 27 80 00       	push   $0x802736
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 27 80 00       	push   $0x802722
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 86 13 00 00       	call   80141b <close>
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
  8000a3:	e8 9c 21 00 00       	call   802244 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 3f 27 80 00       	push   $0x80273f
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
  8000d7:	e8 ab 10 00 00       	call   801187 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 5a 27 80 00       	push   $0x80275a
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
  800103:	68 65 27 80 00       	push   $0x802765
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 51 13 00 00       	call   80146b <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 36 13 00 00       	call   80146b <dup>
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
  800143:	68 70 27 80 00       	push   $0x802770
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 ec 20 00 00       	call   802244 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 cc 27 80 00       	push   $0x8027cc
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 27 80 00       	push   $0x802722
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 6f 11 00 00       	call   8012f1 <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 86 27 80 00       	push   $0x802786
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 27 80 00       	push   $0x802722
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 e5 10 00 00       	call   80128b <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 cb 18 00 00       	call   801a79 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 9e 27 80 00       	push   $0x80279e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 b4 27 80 00       	push   $0x8027b4
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
  800230:	e8 11 12 00 00       	call   801446 <close_all>
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
  800262:	68 00 28 80 00       	push   $0x802800
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 27 80 00 	movl   $0x802717,(%esp)
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
  800380:	e8 eb 20 00 00       	call   802470 <__udivdi3>
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
  8003c3:	e8 d8 21 00 00       	call   8025a0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 23 28 80 00 	movsbl 0x802823(%eax),%eax
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
  8004c7:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
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
  80058b:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 3b 28 80 00       	push   $0x80283b
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
  8005af:	68 c5 2c 80 00       	push   $0x802cc5
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
  8005d3:	b8 34 28 80 00       	mov    $0x802834,%eax
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
  800c4e:	68 1f 2b 80 00       	push   $0x802b1f
  800c53:	6a 23                	push   $0x23
  800c55:	68 3c 2b 80 00       	push   $0x802b3c
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
  800ccf:	68 1f 2b 80 00       	push   $0x802b1f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 2b 80 00       	push   $0x802b3c
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
  800d11:	68 1f 2b 80 00       	push   $0x802b1f
  800d16:	6a 23                	push   $0x23
  800d18:	68 3c 2b 80 00       	push   $0x802b3c
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
  800d53:	68 1f 2b 80 00       	push   $0x802b1f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 3c 2b 80 00       	push   $0x802b3c
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
  800d95:	68 1f 2b 80 00       	push   $0x802b1f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 3c 2b 80 00       	push   $0x802b3c
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
  800dd7:	68 1f 2b 80 00       	push   $0x802b1f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 3c 2b 80 00       	push   $0x802b3c
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
  800e19:	68 1f 2b 80 00       	push   $0x802b1f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 3c 2b 80 00       	push   $0x802b3c
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
  800e7d:	68 1f 2b 80 00       	push   $0x802b1f
  800e82:	6a 23                	push   $0x23
  800e84:	68 3c 2b 80 00       	push   $0x802b3c
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
  800ede:	68 1f 2b 80 00       	push   $0x802b1f
  800ee3:	6a 23                	push   $0x23
  800ee5:	68 3c 2b 80 00       	push   $0x802b3c
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

00800ef7 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800eff:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f01:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f05:	75 25                	jne    800f2c <pgfault+0x35>
  800f07:	89 d8                	mov    %ebx,%eax
  800f09:	c1 e8 0c             	shr    $0xc,%eax
  800f0c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f13:	f6 c4 08             	test   $0x8,%ah
  800f16:	75 14                	jne    800f2c <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f18:	83 ec 04             	sub    $0x4,%esp
  800f1b:	68 4c 2b 80 00       	push   $0x802b4c
  800f20:	6a 1e                	push   $0x1e
  800f22:	68 e0 2b 80 00       	push   $0x802be0
  800f27:	e8 18 f3 ff ff       	call   800244 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f2c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f32:	e8 30 fd ff ff       	call   800c67 <sys_getenvid>
  800f37:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	6a 07                	push   $0x7
  800f3e:	68 00 f0 7f 00       	push   $0x7ff000
  800f43:	50                   	push   %eax
  800f44:	e8 5c fd ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  800f49:	83 c4 10             	add    $0x10,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	79 12                	jns    800f62 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f50:	50                   	push   %eax
  800f51:	68 78 2b 80 00       	push   $0x802b78
  800f56:	6a 33                	push   $0x33
  800f58:	68 e0 2b 80 00       	push   $0x802be0
  800f5d:	e8 e2 f2 ff ff       	call   800244 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	68 00 10 00 00       	push   $0x1000
  800f6a:	53                   	push   %ebx
  800f6b:	68 00 f0 7f 00       	push   $0x7ff000
  800f70:	e8 27 fb ff ff       	call   800a9c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f75:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f7c:	53                   	push   %ebx
  800f7d:	56                   	push   %esi
  800f7e:	68 00 f0 7f 00       	push   $0x7ff000
  800f83:	56                   	push   %esi
  800f84:	e8 5f fd ff ff       	call   800ce8 <sys_page_map>
	if (r < 0)
  800f89:	83 c4 20             	add    $0x20,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	79 12                	jns    800fa2 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f90:	50                   	push   %eax
  800f91:	68 9c 2b 80 00       	push   $0x802b9c
  800f96:	6a 3b                	push   $0x3b
  800f98:	68 e0 2b 80 00       	push   $0x802be0
  800f9d:	e8 a2 f2 ff ff       	call   800244 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fa2:	83 ec 08             	sub    $0x8,%esp
  800fa5:	68 00 f0 7f 00       	push   $0x7ff000
  800faa:	56                   	push   %esi
  800fab:	e8 7a fd ff ff       	call   800d2a <sys_page_unmap>
	if (r < 0)
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	79 12                	jns    800fc9 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800fb7:	50                   	push   %eax
  800fb8:	68 c0 2b 80 00       	push   $0x802bc0
  800fbd:	6a 40                	push   $0x40
  800fbf:	68 e0 2b 80 00       	push   $0x802be0
  800fc4:	e8 7b f2 ff ff       	call   800244 <_panic>
}
  800fc9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcc:	5b                   	pop    %ebx
  800fcd:	5e                   	pop    %esi
  800fce:	5d                   	pop    %ebp
  800fcf:	c3                   	ret    

00800fd0 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	53                   	push   %ebx
  800fd6:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800fd9:	68 f7 0e 80 00       	push   $0x800ef7
  800fde:	e8 17 14 00 00       	call   8023fa <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe3:	b8 07 00 00 00       	mov    $0x7,%eax
  800fe8:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fea:	83 c4 10             	add    $0x10,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	0f 88 64 01 00 00    	js     801159 <fork+0x189>
  800ff5:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800ffa:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fff:	85 c0                	test   %eax,%eax
  801001:	75 21                	jne    801024 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801003:	e8 5f fc ff ff       	call   800c67 <sys_getenvid>
  801008:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801010:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801015:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	e9 3f 01 00 00       	jmp    801163 <fork+0x193>
  801024:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801027:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  801029:	89 d8                	mov    %ebx,%eax
  80102b:	c1 e8 16             	shr    $0x16,%eax
  80102e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801035:	a8 01                	test   $0x1,%al
  801037:	0f 84 bd 00 00 00    	je     8010fa <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	c1 e8 0c             	shr    $0xc,%eax
  801042:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	0f 84 a8 00 00 00    	je     8010fa <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801052:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801059:	a8 04                	test   $0x4,%al
  80105b:	0f 84 99 00 00 00    	je     8010fa <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801061:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801068:	f6 c4 04             	test   $0x4,%ah
  80106b:	74 17                	je     801084 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80106d:	83 ec 0c             	sub    $0xc,%esp
  801070:	68 07 0e 00 00       	push   $0xe07
  801075:	53                   	push   %ebx
  801076:	57                   	push   %edi
  801077:	53                   	push   %ebx
  801078:	6a 00                	push   $0x0
  80107a:	e8 69 fc ff ff       	call   800ce8 <sys_page_map>
  80107f:	83 c4 20             	add    $0x20,%esp
  801082:	eb 76                	jmp    8010fa <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801084:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80108b:	a8 02                	test   $0x2,%al
  80108d:	75 0c                	jne    80109b <fork+0xcb>
  80108f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801096:	f6 c4 08             	test   $0x8,%ah
  801099:	74 3f                	je     8010da <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	68 05 08 00 00       	push   $0x805
  8010a3:	53                   	push   %ebx
  8010a4:	57                   	push   %edi
  8010a5:	53                   	push   %ebx
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 3b fc ff ff       	call   800ce8 <sys_page_map>
		if (r < 0)
  8010ad:	83 c4 20             	add    $0x20,%esp
  8010b0:	85 c0                	test   %eax,%eax
  8010b2:	0f 88 a5 00 00 00    	js     80115d <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	68 05 08 00 00       	push   $0x805
  8010c0:	53                   	push   %ebx
  8010c1:	6a 00                	push   $0x0
  8010c3:	53                   	push   %ebx
  8010c4:	6a 00                	push   $0x0
  8010c6:	e8 1d fc ff ff       	call   800ce8 <sys_page_map>
  8010cb:	83 c4 20             	add    $0x20,%esp
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010d5:	0f 4f c1             	cmovg  %ecx,%eax
  8010d8:	eb 1c                	jmp    8010f6 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  8010da:	83 ec 0c             	sub    $0xc,%esp
  8010dd:	6a 05                	push   $0x5
  8010df:	53                   	push   %ebx
  8010e0:	57                   	push   %edi
  8010e1:	53                   	push   %ebx
  8010e2:	6a 00                	push   $0x0
  8010e4:	e8 ff fb ff ff       	call   800ce8 <sys_page_map>
  8010e9:	83 c4 20             	add    $0x20,%esp
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f3:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 67                	js     801161 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010fa:	83 c6 01             	add    $0x1,%esi
  8010fd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801103:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801109:	0f 85 1a ff ff ff    	jne    801029 <fork+0x59>
  80110f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	6a 07                	push   $0x7
  801117:	68 00 f0 bf ee       	push   $0xeebff000
  80111c:	57                   	push   %edi
  80111d:	e8 83 fb ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  801122:	83 c4 10             	add    $0x10,%esp
		return r;
  801125:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  801127:	85 c0                	test   %eax,%eax
  801129:	78 38                	js     801163 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	68 41 24 80 00       	push   $0x802441
  801133:	57                   	push   %edi
  801134:	e8 b7 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  801139:	83 c4 10             	add    $0x10,%esp
		return r;
  80113c:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 21                	js     801163 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801142:	83 ec 08             	sub    $0x8,%esp
  801145:	6a 02                	push   $0x2
  801147:	57                   	push   %edi
  801148:	e8 1f fc ff ff       	call   800d6c <sys_env_set_status>
	if (r < 0)
  80114d:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801150:	85 c0                	test   %eax,%eax
  801152:	0f 48 f8             	cmovs  %eax,%edi
  801155:	89 fa                	mov    %edi,%edx
  801157:	eb 0a                	jmp    801163 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801159:	89 c2                	mov    %eax,%edx
  80115b:	eb 06                	jmp    801163 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	eb 02                	jmp    801163 <fork+0x193>
  801161:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801163:	89 d0                	mov    %edx,%eax
  801165:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801168:	5b                   	pop    %ebx
  801169:	5e                   	pop    %esi
  80116a:	5f                   	pop    %edi
  80116b:	5d                   	pop    %ebp
  80116c:	c3                   	ret    

0080116d <sfork>:

// Challenge!
int
sfork(void)
{
  80116d:	55                   	push   %ebp
  80116e:	89 e5                	mov    %esp,%ebp
  801170:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801173:	68 eb 2b 80 00       	push   $0x802beb
  801178:	68 c9 00 00 00       	push   $0xc9
  80117d:	68 e0 2b 80 00       	push   $0x802be0
  801182:	e8 bd f0 ff ff       	call   800244 <_panic>

00801187 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	56                   	push   %esi
  80118b:	53                   	push   %ebx
  80118c:	8b 75 08             	mov    0x8(%ebp),%esi
  80118f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801192:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801195:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801197:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80119c:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	50                   	push   %eax
  8011a3:	e8 ad fc ff ff       	call   800e55 <sys_ipc_recv>

	if (from_env_store != NULL)
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	85 f6                	test   %esi,%esi
  8011ad:	74 14                	je     8011c3 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  8011af:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 09                	js     8011c1 <ipc_recv+0x3a>
  8011b8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8011be:	8b 52 74             	mov    0x74(%edx),%edx
  8011c1:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8011c3:	85 db                	test   %ebx,%ebx
  8011c5:	74 14                	je     8011db <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8011c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 09                	js     8011d9 <ipc_recv+0x52>
  8011d0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8011d6:	8b 52 78             	mov    0x78(%edx),%edx
  8011d9:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 08                	js     8011e7 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8011df:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e4:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011ea:	5b                   	pop    %ebx
  8011eb:	5e                   	pop    %esi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011ee:	55                   	push   %ebp
  8011ef:	89 e5                	mov    %esp,%ebp
  8011f1:	57                   	push   %edi
  8011f2:	56                   	push   %esi
  8011f3:	53                   	push   %ebx
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801200:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801202:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801207:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  80120a:	ff 75 14             	pushl  0x14(%ebp)
  80120d:	53                   	push   %ebx
  80120e:	56                   	push   %esi
  80120f:	57                   	push   %edi
  801210:	e8 1d fc ff ff       	call   800e32 <sys_ipc_try_send>

		if (err < 0) {
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	79 1e                	jns    80123a <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  80121c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80121f:	75 07                	jne    801228 <ipc_send+0x3a>
				sys_yield();
  801221:	e8 60 fa ff ff       	call   800c86 <sys_yield>
  801226:	eb e2                	jmp    80120a <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801228:	50                   	push   %eax
  801229:	68 01 2c 80 00       	push   $0x802c01
  80122e:	6a 49                	push   $0x49
  801230:	68 0e 2c 80 00       	push   $0x802c0e
  801235:	e8 0a f0 ff ff       	call   800244 <_panic>
		}

	} while (err < 0);

}
  80123a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80123d:	5b                   	pop    %ebx
  80123e:	5e                   	pop    %esi
  80123f:	5f                   	pop    %edi
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80124d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801250:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801256:	8b 52 50             	mov    0x50(%edx),%edx
  801259:	39 ca                	cmp    %ecx,%edx
  80125b:	75 0d                	jne    80126a <ipc_find_env+0x28>
			return envs[i].env_id;
  80125d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801260:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801265:	8b 40 48             	mov    0x48(%eax),%eax
  801268:	eb 0f                	jmp    801279 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80126a:	83 c0 01             	add    $0x1,%eax
  80126d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801272:	75 d9                	jne    80124d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801274:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80127e:	8b 45 08             	mov    0x8(%ebp),%eax
  801281:	05 00 00 00 30       	add    $0x30000000,%eax
  801286:	c1 e8 0c             	shr    $0xc,%eax
}
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    

0080128b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80128e:	8b 45 08             	mov    0x8(%ebp),%eax
  801291:	05 00 00 00 30       	add    $0x30000000,%eax
  801296:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80129b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a0:	5d                   	pop    %ebp
  8012a1:	c3                   	ret    

008012a2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a2:	55                   	push   %ebp
  8012a3:	89 e5                	mov    %esp,%ebp
  8012a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012a8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	c1 ea 16             	shr    $0x16,%edx
  8012b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012b9:	f6 c2 01             	test   $0x1,%dl
  8012bc:	74 11                	je     8012cf <fd_alloc+0x2d>
  8012be:	89 c2                	mov    %eax,%edx
  8012c0:	c1 ea 0c             	shr    $0xc,%edx
  8012c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ca:	f6 c2 01             	test   $0x1,%dl
  8012cd:	75 09                	jne    8012d8 <fd_alloc+0x36>
			*fd_store = fd;
  8012cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	eb 17                	jmp    8012ef <fd_alloc+0x4d>
  8012d8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e2:	75 c9                	jne    8012ad <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012e4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ea:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ef:	5d                   	pop    %ebp
  8012f0:	c3                   	ret    

008012f1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012f7:	83 f8 1f             	cmp    $0x1f,%eax
  8012fa:	77 36                	ja     801332 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012fc:	c1 e0 0c             	shl    $0xc,%eax
  8012ff:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801304:	89 c2                	mov    %eax,%edx
  801306:	c1 ea 16             	shr    $0x16,%edx
  801309:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801310:	f6 c2 01             	test   $0x1,%dl
  801313:	74 24                	je     801339 <fd_lookup+0x48>
  801315:	89 c2                	mov    %eax,%edx
  801317:	c1 ea 0c             	shr    $0xc,%edx
  80131a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801321:	f6 c2 01             	test   $0x1,%dl
  801324:	74 1a                	je     801340 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801326:	8b 55 0c             	mov    0xc(%ebp),%edx
  801329:	89 02                	mov    %eax,(%edx)
	return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb 13                	jmp    801345 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801332:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801337:	eb 0c                	jmp    801345 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb 05                	jmp    801345 <fd_lookup+0x54>
  801340:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801345:	5d                   	pop    %ebp
  801346:	c3                   	ret    

00801347 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801350:	ba 98 2c 80 00       	mov    $0x802c98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801355:	eb 13                	jmp    80136a <dev_lookup+0x23>
  801357:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80135a:	39 08                	cmp    %ecx,(%eax)
  80135c:	75 0c                	jne    80136a <dev_lookup+0x23>
			*dev = devtab[i];
  80135e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801361:	89 01                	mov    %eax,(%ecx)
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb 2e                	jmp    801398 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80136a:	8b 02                	mov    (%edx),%eax
  80136c:	85 c0                	test   %eax,%eax
  80136e:	75 e7                	jne    801357 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801370:	a1 08 40 80 00       	mov    0x804008,%eax
  801375:	8b 40 48             	mov    0x48(%eax),%eax
  801378:	83 ec 04             	sub    $0x4,%esp
  80137b:	51                   	push   %ecx
  80137c:	50                   	push   %eax
  80137d:	68 18 2c 80 00       	push   $0x802c18
  801382:	e8 96 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801387:	8b 45 0c             	mov    0xc(%ebp),%eax
  80138a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801398:	c9                   	leave  
  801399:	c3                   	ret    

0080139a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	83 ec 10             	sub    $0x10,%esp
  8013a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ab:	50                   	push   %eax
  8013ac:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b2:	c1 e8 0c             	shr    $0xc,%eax
  8013b5:	50                   	push   %eax
  8013b6:	e8 36 ff ff ff       	call   8012f1 <fd_lookup>
  8013bb:	83 c4 08             	add    $0x8,%esp
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	78 05                	js     8013c7 <fd_close+0x2d>
	    || fd != fd2)
  8013c2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013c5:	74 0c                	je     8013d3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8013c7:	84 db                	test   %bl,%bl
  8013c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ce:	0f 44 c2             	cmove  %edx,%eax
  8013d1:	eb 41                	jmp    801414 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 36                	pushl  (%esi)
  8013dc:	e8 66 ff ff ff       	call   801347 <dev_lookup>
  8013e1:	89 c3                	mov    %eax,%ebx
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 1a                	js     801404 <fd_close+0x6a>
		if (dev->dev_close)
  8013ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ed:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013f5:	85 c0                	test   %eax,%eax
  8013f7:	74 0b                	je     801404 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013f9:	83 ec 0c             	sub    $0xc,%esp
  8013fc:	56                   	push   %esi
  8013fd:	ff d0                	call   *%eax
  8013ff:	89 c3                	mov    %eax,%ebx
  801401:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	56                   	push   %esi
  801408:	6a 00                	push   $0x0
  80140a:	e8 1b f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80140f:	83 c4 10             	add    $0x10,%esp
  801412:	89 d8                	mov    %ebx,%eax
}
  801414:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801417:	5b                   	pop    %ebx
  801418:	5e                   	pop    %esi
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    

0080141b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	ff 75 08             	pushl  0x8(%ebp)
  801428:	e8 c4 fe ff ff       	call   8012f1 <fd_lookup>
  80142d:	83 c4 08             	add    $0x8,%esp
  801430:	85 c0                	test   %eax,%eax
  801432:	78 10                	js     801444 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	6a 01                	push   $0x1
  801439:	ff 75 f4             	pushl  -0xc(%ebp)
  80143c:	e8 59 ff ff ff       	call   80139a <fd_close>
  801441:	83 c4 10             	add    $0x10,%esp
}
  801444:	c9                   	leave  
  801445:	c3                   	ret    

00801446 <close_all>:

void
close_all(void)
{
  801446:	55                   	push   %ebp
  801447:	89 e5                	mov    %esp,%ebp
  801449:	53                   	push   %ebx
  80144a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80144d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801452:	83 ec 0c             	sub    $0xc,%esp
  801455:	53                   	push   %ebx
  801456:	e8 c0 ff ff ff       	call   80141b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80145b:	83 c3 01             	add    $0x1,%ebx
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	83 fb 20             	cmp    $0x20,%ebx
  801464:	75 ec                	jne    801452 <close_all+0xc>
		close(i);
}
  801466:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801469:	c9                   	leave  
  80146a:	c3                   	ret    

0080146b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80146b:	55                   	push   %ebp
  80146c:	89 e5                	mov    %esp,%ebp
  80146e:	57                   	push   %edi
  80146f:	56                   	push   %esi
  801470:	53                   	push   %ebx
  801471:	83 ec 2c             	sub    $0x2c,%esp
  801474:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801477:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80147a:	50                   	push   %eax
  80147b:	ff 75 08             	pushl  0x8(%ebp)
  80147e:	e8 6e fe ff ff       	call   8012f1 <fd_lookup>
  801483:	83 c4 08             	add    $0x8,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	0f 88 c1 00 00 00    	js     80154f <dup+0xe4>
		return r;
	close(newfdnum);
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	56                   	push   %esi
  801492:	e8 84 ff ff ff       	call   80141b <close>

	newfd = INDEX2FD(newfdnum);
  801497:	89 f3                	mov    %esi,%ebx
  801499:	c1 e3 0c             	shl    $0xc,%ebx
  80149c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a2:	83 c4 04             	add    $0x4,%esp
  8014a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014a8:	e8 de fd ff ff       	call   80128b <fd2data>
  8014ad:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014af:	89 1c 24             	mov    %ebx,(%esp)
  8014b2:	e8 d4 fd ff ff       	call   80128b <fd2data>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014bd:	89 f8                	mov    %edi,%eax
  8014bf:	c1 e8 16             	shr    $0x16,%eax
  8014c2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014c9:	a8 01                	test   $0x1,%al
  8014cb:	74 37                	je     801504 <dup+0x99>
  8014cd:	89 f8                	mov    %edi,%eax
  8014cf:	c1 e8 0c             	shr    $0xc,%eax
  8014d2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014d9:	f6 c2 01             	test   $0x1,%dl
  8014dc:	74 26                	je     801504 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014e5:	83 ec 0c             	sub    $0xc,%esp
  8014e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ed:	50                   	push   %eax
  8014ee:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f1:	6a 00                	push   $0x0
  8014f3:	57                   	push   %edi
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 ed f7 ff ff       	call   800ce8 <sys_page_map>
  8014fb:	89 c7                	mov    %eax,%edi
  8014fd:	83 c4 20             	add    $0x20,%esp
  801500:	85 c0                	test   %eax,%eax
  801502:	78 2e                	js     801532 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801504:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801507:	89 d0                	mov    %edx,%eax
  801509:	c1 e8 0c             	shr    $0xc,%eax
  80150c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801513:	83 ec 0c             	sub    $0xc,%esp
  801516:	25 07 0e 00 00       	and    $0xe07,%eax
  80151b:	50                   	push   %eax
  80151c:	53                   	push   %ebx
  80151d:	6a 00                	push   $0x0
  80151f:	52                   	push   %edx
  801520:	6a 00                	push   $0x0
  801522:	e8 c1 f7 ff ff       	call   800ce8 <sys_page_map>
  801527:	89 c7                	mov    %eax,%edi
  801529:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80152c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80152e:	85 ff                	test   %edi,%edi
  801530:	79 1d                	jns    80154f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	53                   	push   %ebx
  801536:	6a 00                	push   $0x0
  801538:	e8 ed f7 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	ff 75 d4             	pushl  -0x2c(%ebp)
  801543:	6a 00                	push   $0x0
  801545:	e8 e0 f7 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	89 f8                	mov    %edi,%eax
}
  80154f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 14             	sub    $0x14,%esp
  80155e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	53                   	push   %ebx
  801566:	e8 86 fd ff ff       	call   8012f1 <fd_lookup>
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	89 c2                	mov    %eax,%edx
  801570:	85 c0                	test   %eax,%eax
  801572:	78 6d                	js     8015e1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157e:	ff 30                	pushl  (%eax)
  801580:	e8 c2 fd ff ff       	call   801347 <dev_lookup>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 4c                	js     8015d8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80158c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80158f:	8b 42 08             	mov    0x8(%edx),%eax
  801592:	83 e0 03             	and    $0x3,%eax
  801595:	83 f8 01             	cmp    $0x1,%eax
  801598:	75 21                	jne    8015bb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159a:	a1 08 40 80 00       	mov    0x804008,%eax
  80159f:	8b 40 48             	mov    0x48(%eax),%eax
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	50                   	push   %eax
  8015a7:	68 5c 2c 80 00       	push   $0x802c5c
  8015ac:	e8 6c ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b9:	eb 26                	jmp    8015e1 <read+0x8a>
	}
	if (!dev->dev_read)
  8015bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015be:	8b 40 08             	mov    0x8(%eax),%eax
  8015c1:	85 c0                	test   %eax,%eax
  8015c3:	74 17                	je     8015dc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015c5:	83 ec 04             	sub    $0x4,%esp
  8015c8:	ff 75 10             	pushl  0x10(%ebp)
  8015cb:	ff 75 0c             	pushl  0xc(%ebp)
  8015ce:	52                   	push   %edx
  8015cf:	ff d0                	call   *%eax
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 09                	jmp    8015e1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	eb 05                	jmp    8015e1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 0c             	sub    $0xc,%esp
  8015f1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015f4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015fc:	eb 21                	jmp    80161f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015fe:	83 ec 04             	sub    $0x4,%esp
  801601:	89 f0                	mov    %esi,%eax
  801603:	29 d8                	sub    %ebx,%eax
  801605:	50                   	push   %eax
  801606:	89 d8                	mov    %ebx,%eax
  801608:	03 45 0c             	add    0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	57                   	push   %edi
  80160d:	e8 45 ff ff ff       	call   801557 <read>
		if (m < 0)
  801612:	83 c4 10             	add    $0x10,%esp
  801615:	85 c0                	test   %eax,%eax
  801617:	78 10                	js     801629 <readn+0x41>
			return m;
		if (m == 0)
  801619:	85 c0                	test   %eax,%eax
  80161b:	74 0a                	je     801627 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80161d:	01 c3                	add    %eax,%ebx
  80161f:	39 f3                	cmp    %esi,%ebx
  801621:	72 db                	jb     8015fe <readn+0x16>
  801623:	89 d8                	mov    %ebx,%eax
  801625:	eb 02                	jmp    801629 <readn+0x41>
  801627:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801629:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5f                   	pop    %edi
  80162f:	5d                   	pop    %ebp
  801630:	c3                   	ret    

00801631 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801631:	55                   	push   %ebp
  801632:	89 e5                	mov    %esp,%ebp
  801634:	53                   	push   %ebx
  801635:	83 ec 14             	sub    $0x14,%esp
  801638:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80163b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	53                   	push   %ebx
  801640:	e8 ac fc ff ff       	call   8012f1 <fd_lookup>
  801645:	83 c4 08             	add    $0x8,%esp
  801648:	89 c2                	mov    %eax,%edx
  80164a:	85 c0                	test   %eax,%eax
  80164c:	78 68                	js     8016b6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801658:	ff 30                	pushl  (%eax)
  80165a:	e8 e8 fc ff ff       	call   801347 <dev_lookup>
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	85 c0                	test   %eax,%eax
  801664:	78 47                	js     8016ad <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80166d:	75 21                	jne    801690 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80166f:	a1 08 40 80 00       	mov    0x804008,%eax
  801674:	8b 40 48             	mov    0x48(%eax),%eax
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	53                   	push   %ebx
  80167b:	50                   	push   %eax
  80167c:	68 78 2c 80 00       	push   $0x802c78
  801681:	e8 97 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80168e:	eb 26                	jmp    8016b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801690:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801693:	8b 52 0c             	mov    0xc(%edx),%edx
  801696:	85 d2                	test   %edx,%edx
  801698:	74 17                	je     8016b1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80169a:	83 ec 04             	sub    $0x4,%esp
  80169d:	ff 75 10             	pushl  0x10(%ebp)
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	50                   	push   %eax
  8016a4:	ff d2                	call   *%edx
  8016a6:	89 c2                	mov    %eax,%edx
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	eb 09                	jmp    8016b6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	eb 05                	jmp    8016b6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016b6:	89 d0                	mov    %edx,%eax
  8016b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <seek>:

int
seek(int fdnum, off_t offset)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016c3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	ff 75 08             	pushl  0x8(%ebp)
  8016ca:	e8 22 fc ff ff       	call   8012f1 <fd_lookup>
  8016cf:	83 c4 08             	add    $0x8,%esp
  8016d2:	85 c0                	test   %eax,%eax
  8016d4:	78 0e                	js     8016e4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016d6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016d9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016dc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	83 ec 14             	sub    $0x14,%esp
  8016ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016f3:	50                   	push   %eax
  8016f4:	53                   	push   %ebx
  8016f5:	e8 f7 fb ff ff       	call   8012f1 <fd_lookup>
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	89 c2                	mov    %eax,%edx
  8016ff:	85 c0                	test   %eax,%eax
  801701:	78 65                	js     801768 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	83 ec 08             	sub    $0x8,%esp
  801706:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801709:	50                   	push   %eax
  80170a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170d:	ff 30                	pushl  (%eax)
  80170f:	e8 33 fc ff ff       	call   801347 <dev_lookup>
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	85 c0                	test   %eax,%eax
  801719:	78 44                	js     80175f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80171b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801722:	75 21                	jne    801745 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801724:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801729:	8b 40 48             	mov    0x48(%eax),%eax
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	53                   	push   %ebx
  801730:	50                   	push   %eax
  801731:	68 38 2c 80 00       	push   $0x802c38
  801736:	e8 e2 eb ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801743:	eb 23                	jmp    801768 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801745:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801748:	8b 52 18             	mov    0x18(%edx),%edx
  80174b:	85 d2                	test   %edx,%edx
  80174d:	74 14                	je     801763 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	50                   	push   %eax
  801756:	ff d2                	call   *%edx
  801758:	89 c2                	mov    %eax,%edx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	eb 09                	jmp    801768 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80175f:	89 c2                	mov    %eax,%edx
  801761:	eb 05                	jmp    801768 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801763:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801768:	89 d0                	mov    %edx,%eax
  80176a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176d:	c9                   	leave  
  80176e:	c3                   	ret    

0080176f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	83 ec 14             	sub    $0x14,%esp
  801776:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801779:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177c:	50                   	push   %eax
  80177d:	ff 75 08             	pushl  0x8(%ebp)
  801780:	e8 6c fb ff ff       	call   8012f1 <fd_lookup>
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	89 c2                	mov    %eax,%edx
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 58                	js     8017e6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801794:	50                   	push   %eax
  801795:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801798:	ff 30                	pushl  (%eax)
  80179a:	e8 a8 fb ff ff       	call   801347 <dev_lookup>
  80179f:	83 c4 10             	add    $0x10,%esp
  8017a2:	85 c0                	test   %eax,%eax
  8017a4:	78 37                	js     8017dd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017a9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ad:	74 32                	je     8017e1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017af:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017b9:	00 00 00 
	stat->st_isdir = 0;
  8017bc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017c3:	00 00 00 
	stat->st_dev = dev;
  8017c6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	53                   	push   %ebx
  8017d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d3:	ff 50 14             	call   *0x14(%eax)
  8017d6:	89 c2                	mov    %eax,%edx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	eb 09                	jmp    8017e6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	eb 05                	jmp    8017e6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017e6:	89 d0                	mov    %edx,%eax
  8017e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f2:	83 ec 08             	sub    $0x8,%esp
  8017f5:	6a 00                	push   $0x0
  8017f7:	ff 75 08             	pushl  0x8(%ebp)
  8017fa:	e8 d6 01 00 00       	call   8019d5 <open>
  8017ff:	89 c3                	mov    %eax,%ebx
  801801:	83 c4 10             	add    $0x10,%esp
  801804:	85 c0                	test   %eax,%eax
  801806:	78 1b                	js     801823 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801808:	83 ec 08             	sub    $0x8,%esp
  80180b:	ff 75 0c             	pushl  0xc(%ebp)
  80180e:	50                   	push   %eax
  80180f:	e8 5b ff ff ff       	call   80176f <fstat>
  801814:	89 c6                	mov    %eax,%esi
	close(fd);
  801816:	89 1c 24             	mov    %ebx,(%esp)
  801819:	e8 fd fb ff ff       	call   80141b <close>
	return r;
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	89 f0                	mov    %esi,%eax
}
  801823:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	56                   	push   %esi
  80182e:	53                   	push   %ebx
  80182f:	89 c6                	mov    %eax,%esi
  801831:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801833:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80183a:	75 12                	jne    80184e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80183c:	83 ec 0c             	sub    $0xc,%esp
  80183f:	6a 01                	push   $0x1
  801841:	e8 fc f9 ff ff       	call   801242 <ipc_find_env>
  801846:	a3 00 40 80 00       	mov    %eax,0x804000
  80184b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80184e:	6a 07                	push   $0x7
  801850:	68 00 50 80 00       	push   $0x805000
  801855:	56                   	push   %esi
  801856:	ff 35 00 40 80 00    	pushl  0x804000
  80185c:	e8 8d f9 ff ff       	call   8011ee <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801861:	83 c4 0c             	add    $0xc,%esp
  801864:	6a 00                	push   $0x0
  801866:	53                   	push   %ebx
  801867:	6a 00                	push   $0x0
  801869:	e8 19 f9 ff ff       	call   801187 <ipc_recv>
}
  80186e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801871:	5b                   	pop    %ebx
  801872:	5e                   	pop    %esi
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	8b 40 0c             	mov    0xc(%eax),%eax
  801881:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801886:	8b 45 0c             	mov    0xc(%ebp),%eax
  801889:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80188e:	ba 00 00 00 00       	mov    $0x0,%edx
  801893:	b8 02 00 00 00       	mov    $0x2,%eax
  801898:	e8 8d ff ff ff       	call   80182a <fsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ba:	e8 6b ff ff ff       	call   80182a <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	53                   	push   %ebx
  8018c5:	83 ec 04             	sub    $0x4,%esp
  8018c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018db:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e0:	e8 45 ff ff ff       	call   80182a <fsipc>
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 2c                	js     801915 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018e9:	83 ec 08             	sub    $0x8,%esp
  8018ec:	68 00 50 80 00       	push   $0x805000
  8018f1:	53                   	push   %ebx
  8018f2:	e8 ab ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8018fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801902:	a1 84 50 80 00       	mov    0x805084,%eax
  801907:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801918:	c9                   	leave  
  801919:	c3                   	ret    

0080191a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	83 ec 0c             	sub    $0xc,%esp
  801920:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801923:	8b 55 08             	mov    0x8(%ebp),%edx
  801926:	8b 52 0c             	mov    0xc(%edx),%edx
  801929:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80192f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801934:	50                   	push   %eax
  801935:	ff 75 0c             	pushl  0xc(%ebp)
  801938:	68 08 50 80 00       	push   $0x805008
  80193d:	e8 f2 f0 ff ff       	call   800a34 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801942:	ba 00 00 00 00       	mov    $0x0,%edx
  801947:	b8 04 00 00 00       	mov    $0x4,%eax
  80194c:	e8 d9 fe ff ff       	call   80182a <fsipc>

}
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801953:	55                   	push   %ebp
  801954:	89 e5                	mov    %esp,%ebp
  801956:	56                   	push   %esi
  801957:	53                   	push   %ebx
  801958:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80195b:	8b 45 08             	mov    0x8(%ebp),%eax
  80195e:	8b 40 0c             	mov    0xc(%eax),%eax
  801961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801966:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80196c:	ba 00 00 00 00       	mov    $0x0,%edx
  801971:	b8 03 00 00 00       	mov    $0x3,%eax
  801976:	e8 af fe ff ff       	call   80182a <fsipc>
  80197b:	89 c3                	mov    %eax,%ebx
  80197d:	85 c0                	test   %eax,%eax
  80197f:	78 4b                	js     8019cc <devfile_read+0x79>
		return r;
	assert(r <= n);
  801981:	39 c6                	cmp    %eax,%esi
  801983:	73 16                	jae    80199b <devfile_read+0x48>
  801985:	68 ac 2c 80 00       	push   $0x802cac
  80198a:	68 b3 2c 80 00       	push   $0x802cb3
  80198f:	6a 7c                	push   $0x7c
  801991:	68 c8 2c 80 00       	push   $0x802cc8
  801996:	e8 a9 e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  80199b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019a0:	7e 16                	jle    8019b8 <devfile_read+0x65>
  8019a2:	68 d3 2c 80 00       	push   $0x802cd3
  8019a7:	68 b3 2c 80 00       	push   $0x802cb3
  8019ac:	6a 7d                	push   $0x7d
  8019ae:	68 c8 2c 80 00       	push   $0x802cc8
  8019b3:	e8 8c e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b8:	83 ec 04             	sub    $0x4,%esp
  8019bb:	50                   	push   %eax
  8019bc:	68 00 50 80 00       	push   $0x805000
  8019c1:	ff 75 0c             	pushl  0xc(%ebp)
  8019c4:	e8 6b f0 ff ff       	call   800a34 <memmove>
	return r;
  8019c9:	83 c4 10             	add    $0x10,%esp
}
  8019cc:	89 d8                	mov    %ebx,%eax
  8019ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d1:	5b                   	pop    %ebx
  8019d2:	5e                   	pop    %esi
  8019d3:	5d                   	pop    %ebp
  8019d4:	c3                   	ret    

008019d5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019d5:	55                   	push   %ebp
  8019d6:	89 e5                	mov    %esp,%ebp
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 20             	sub    $0x20,%esp
  8019dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019df:	53                   	push   %ebx
  8019e0:	e8 84 ee ff ff       	call   800869 <strlen>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ed:	7f 67                	jg     801a56 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ef:	83 ec 0c             	sub    $0xc,%esp
  8019f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f5:	50                   	push   %eax
  8019f6:	e8 a7 f8 ff ff       	call   8012a2 <fd_alloc>
  8019fb:	83 c4 10             	add    $0x10,%esp
		return r;
  8019fe:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a00:	85 c0                	test   %eax,%eax
  801a02:	78 57                	js     801a5b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	53                   	push   %ebx
  801a08:	68 00 50 80 00       	push   $0x805000
  801a0d:	e8 90 ee ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a1d:	b8 01 00 00 00       	mov    $0x1,%eax
  801a22:	e8 03 fe ff ff       	call   80182a <fsipc>
  801a27:	89 c3                	mov    %eax,%ebx
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	79 14                	jns    801a44 <open+0x6f>
		fd_close(fd, 0);
  801a30:	83 ec 08             	sub    $0x8,%esp
  801a33:	6a 00                	push   $0x0
  801a35:	ff 75 f4             	pushl  -0xc(%ebp)
  801a38:	e8 5d f9 ff ff       	call   80139a <fd_close>
		return r;
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	89 da                	mov    %ebx,%edx
  801a42:	eb 17                	jmp    801a5b <open+0x86>
	}

	return fd2num(fd);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4a:	e8 2c f8 ff ff       	call   80127b <fd2num>
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	eb 05                	jmp    801a5b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a56:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a5b:	89 d0                	mov    %edx,%eax
  801a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a68:	ba 00 00 00 00       	mov    $0x0,%edx
  801a6d:	b8 08 00 00 00       	mov    $0x8,%eax
  801a72:	e8 b3 fd ff ff       	call   80182a <fsipc>
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a7f:	89 d0                	mov    %edx,%eax
  801a81:	c1 e8 16             	shr    $0x16,%eax
  801a84:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801a8b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a90:	f6 c1 01             	test   $0x1,%cl
  801a93:	74 1d                	je     801ab2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801a95:	c1 ea 0c             	shr    $0xc,%edx
  801a98:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801a9f:	f6 c2 01             	test   $0x1,%dl
  801aa2:	74 0e                	je     801ab2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801aa4:	c1 ea 0c             	shr    $0xc,%edx
  801aa7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801aae:	ef 
  801aaf:	0f b7 c0             	movzwl %ax,%eax
}
  801ab2:	5d                   	pop    %ebp
  801ab3:	c3                   	ret    

00801ab4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801ab4:	55                   	push   %ebp
  801ab5:	89 e5                	mov    %esp,%ebp
  801ab7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aba:	68 df 2c 80 00       	push   $0x802cdf
  801abf:	ff 75 0c             	pushl  0xc(%ebp)
  801ac2:	e8 db ed ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
  801acc:	c9                   	leave  
  801acd:	c3                   	ret    

00801ace <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	53                   	push   %ebx
  801ad2:	83 ec 10             	sub    $0x10,%esp
  801ad5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ad8:	53                   	push   %ebx
  801ad9:	e8 9b ff ff ff       	call   801a79 <pageref>
  801ade:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801ae1:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ae6:	83 f8 01             	cmp    $0x1,%eax
  801ae9:	75 10                	jne    801afb <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801aeb:	83 ec 0c             	sub    $0xc,%esp
  801aee:	ff 73 0c             	pushl  0xc(%ebx)
  801af1:	e8 c0 02 00 00       	call   801db6 <nsipc_close>
  801af6:	89 c2                	mov    %eax,%edx
  801af8:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b00:	c9                   	leave  
  801b01:	c3                   	ret    

00801b02 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b08:	6a 00                	push   $0x0
  801b0a:	ff 75 10             	pushl  0x10(%ebp)
  801b0d:	ff 75 0c             	pushl  0xc(%ebp)
  801b10:	8b 45 08             	mov    0x8(%ebp),%eax
  801b13:	ff 70 0c             	pushl  0xc(%eax)
  801b16:	e8 78 03 00 00       	call   801e93 <nsipc_send>
}
  801b1b:	c9                   	leave  
  801b1c:	c3                   	ret    

00801b1d <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b23:	6a 00                	push   $0x0
  801b25:	ff 75 10             	pushl  0x10(%ebp)
  801b28:	ff 75 0c             	pushl  0xc(%ebp)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	ff 70 0c             	pushl  0xc(%eax)
  801b31:	e8 f1 02 00 00       	call   801e27 <nsipc_recv>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b3e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b41:	52                   	push   %edx
  801b42:	50                   	push   %eax
  801b43:	e8 a9 f7 ff ff       	call   8012f1 <fd_lookup>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	78 17                	js     801b66 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b58:	39 08                	cmp    %ecx,(%eax)
  801b5a:	75 05                	jne    801b61 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b5c:	8b 40 0c             	mov    0xc(%eax),%eax
  801b5f:	eb 05                	jmp    801b66 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b61:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	56                   	push   %esi
  801b6c:	53                   	push   %ebx
  801b6d:	83 ec 1c             	sub    $0x1c,%esp
  801b70:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b75:	50                   	push   %eax
  801b76:	e8 27 f7 ff ff       	call   8012a2 <fd_alloc>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 1b                	js     801b9f <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b84:	83 ec 04             	sub    $0x4,%esp
  801b87:	68 07 04 00 00       	push   $0x407
  801b8c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8f:	6a 00                	push   $0x0
  801b91:	e8 0f f1 ff ff       	call   800ca5 <sys_page_alloc>
  801b96:	89 c3                	mov    %eax,%ebx
  801b98:	83 c4 10             	add    $0x10,%esp
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	79 10                	jns    801baf <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b9f:	83 ec 0c             	sub    $0xc,%esp
  801ba2:	56                   	push   %esi
  801ba3:	e8 0e 02 00 00       	call   801db6 <nsipc_close>
		return r;
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	eb 24                	jmp    801bd3 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801baf:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bb8:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801bc4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801bc7:	83 ec 0c             	sub    $0xc,%esp
  801bca:	50                   	push   %eax
  801bcb:	e8 ab f6 ff ff       	call   80127b <fd2num>
  801bd0:	83 c4 10             	add    $0x10,%esp
}
  801bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    

00801bda <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	e8 50 ff ff ff       	call   801b38 <fd2sockid>
		return r;
  801be8:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bea:	85 c0                	test   %eax,%eax
  801bec:	78 1f                	js     801c0d <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	ff 75 10             	pushl  0x10(%ebp)
  801bf4:	ff 75 0c             	pushl  0xc(%ebp)
  801bf7:	50                   	push   %eax
  801bf8:	e8 12 01 00 00       	call   801d0f <nsipc_accept>
  801bfd:	83 c4 10             	add    $0x10,%esp
		return r;
  801c00:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c02:	85 c0                	test   %eax,%eax
  801c04:	78 07                	js     801c0d <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801c06:	e8 5d ff ff ff       	call   801b68 <alloc_sockfd>
  801c0b:	89 c1                	mov    %eax,%ecx
}
  801c0d:	89 c8                	mov    %ecx,%eax
  801c0f:	c9                   	leave  
  801c10:	c3                   	ret    

00801c11 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c17:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1a:	e8 19 ff ff ff       	call   801b38 <fd2sockid>
  801c1f:	85 c0                	test   %eax,%eax
  801c21:	78 12                	js     801c35 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801c23:	83 ec 04             	sub    $0x4,%esp
  801c26:	ff 75 10             	pushl  0x10(%ebp)
  801c29:	ff 75 0c             	pushl  0xc(%ebp)
  801c2c:	50                   	push   %eax
  801c2d:	e8 2d 01 00 00       	call   801d5f <nsipc_bind>
  801c32:	83 c4 10             	add    $0x10,%esp
}
  801c35:	c9                   	leave  
  801c36:	c3                   	ret    

00801c37 <shutdown>:

int
shutdown(int s, int how)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	e8 f3 fe ff ff       	call   801b38 <fd2sockid>
  801c45:	85 c0                	test   %eax,%eax
  801c47:	78 0f                	js     801c58 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c49:	83 ec 08             	sub    $0x8,%esp
  801c4c:	ff 75 0c             	pushl  0xc(%ebp)
  801c4f:	50                   	push   %eax
  801c50:	e8 3f 01 00 00       	call   801d94 <nsipc_shutdown>
  801c55:	83 c4 10             	add    $0x10,%esp
}
  801c58:	c9                   	leave  
  801c59:	c3                   	ret    

00801c5a <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c60:	8b 45 08             	mov    0x8(%ebp),%eax
  801c63:	e8 d0 fe ff ff       	call   801b38 <fd2sockid>
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 12                	js     801c7e <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c6c:	83 ec 04             	sub    $0x4,%esp
  801c6f:	ff 75 10             	pushl  0x10(%ebp)
  801c72:	ff 75 0c             	pushl  0xc(%ebp)
  801c75:	50                   	push   %eax
  801c76:	e8 55 01 00 00       	call   801dd0 <nsipc_connect>
  801c7b:	83 c4 10             	add    $0x10,%esp
}
  801c7e:	c9                   	leave  
  801c7f:	c3                   	ret    

00801c80 <listen>:

int
listen(int s, int backlog)
{
  801c80:	55                   	push   %ebp
  801c81:	89 e5                	mov    %esp,%ebp
  801c83:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	e8 aa fe ff ff       	call   801b38 <fd2sockid>
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 0f                	js     801ca1 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c92:	83 ec 08             	sub    $0x8,%esp
  801c95:	ff 75 0c             	pushl  0xc(%ebp)
  801c98:	50                   	push   %eax
  801c99:	e8 67 01 00 00       	call   801e05 <nsipc_listen>
  801c9e:	83 c4 10             	add    $0x10,%esp
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801ca9:	ff 75 10             	pushl  0x10(%ebp)
  801cac:	ff 75 0c             	pushl  0xc(%ebp)
  801caf:	ff 75 08             	pushl  0x8(%ebp)
  801cb2:	e8 3a 02 00 00       	call   801ef1 <nsipc_socket>
  801cb7:	83 c4 10             	add    $0x10,%esp
  801cba:	85 c0                	test   %eax,%eax
  801cbc:	78 05                	js     801cc3 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801cbe:	e8 a5 fe ff ff       	call   801b68 <alloc_sockfd>
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	53                   	push   %ebx
  801cc9:	83 ec 04             	sub    $0x4,%esp
  801ccc:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cce:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801cd5:	75 12                	jne    801ce9 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cd7:	83 ec 0c             	sub    $0xc,%esp
  801cda:	6a 02                	push   $0x2
  801cdc:	e8 61 f5 ff ff       	call   801242 <ipc_find_env>
  801ce1:	a3 04 40 80 00       	mov    %eax,0x804004
  801ce6:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ce9:	6a 07                	push   $0x7
  801ceb:	68 00 60 80 00       	push   $0x806000
  801cf0:	53                   	push   %ebx
  801cf1:	ff 35 04 40 80 00    	pushl  0x804004
  801cf7:	e8 f2 f4 ff ff       	call   8011ee <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cfc:	83 c4 0c             	add    $0xc,%esp
  801cff:	6a 00                	push   $0x0
  801d01:	6a 00                	push   $0x0
  801d03:	6a 00                	push   $0x0
  801d05:	e8 7d f4 ff ff       	call   801187 <ipc_recv>
}
  801d0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0d:	c9                   	leave  
  801d0e:	c3                   	ret    

00801d0f <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	56                   	push   %esi
  801d13:	53                   	push   %ebx
  801d14:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d17:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d1f:	8b 06                	mov    (%esi),%eax
  801d21:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d26:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2b:	e8 95 ff ff ff       	call   801cc5 <nsipc>
  801d30:	89 c3                	mov    %eax,%ebx
  801d32:	85 c0                	test   %eax,%eax
  801d34:	78 20                	js     801d56 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d36:	83 ec 04             	sub    $0x4,%esp
  801d39:	ff 35 10 60 80 00    	pushl  0x806010
  801d3f:	68 00 60 80 00       	push   $0x806000
  801d44:	ff 75 0c             	pushl  0xc(%ebp)
  801d47:	e8 e8 ec ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801d4c:	a1 10 60 80 00       	mov    0x806010,%eax
  801d51:	89 06                	mov    %eax,(%esi)
  801d53:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d5b:	5b                   	pop    %ebx
  801d5c:	5e                   	pop    %esi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	53                   	push   %ebx
  801d63:	83 ec 08             	sub    $0x8,%esp
  801d66:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d69:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6c:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d71:	53                   	push   %ebx
  801d72:	ff 75 0c             	pushl  0xc(%ebp)
  801d75:	68 04 60 80 00       	push   $0x806004
  801d7a:	e8 b5 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d7f:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d85:	b8 02 00 00 00       	mov    $0x2,%eax
  801d8a:	e8 36 ff ff ff       	call   801cc5 <nsipc>
}
  801d8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d94:	55                   	push   %ebp
  801d95:	89 e5                	mov    %esp,%ebp
  801d97:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801da2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801daa:	b8 03 00 00 00       	mov    $0x3,%eax
  801daf:	e8 11 ff ff ff       	call   801cc5 <nsipc>
}
  801db4:	c9                   	leave  
  801db5:	c3                   	ret    

00801db6 <nsipc_close>:

int
nsipc_close(int s)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801dc4:	b8 04 00 00 00       	mov    $0x4,%eax
  801dc9:	e8 f7 fe ff ff       	call   801cc5 <nsipc>
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    

00801dd0 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801de2:	53                   	push   %ebx
  801de3:	ff 75 0c             	pushl  0xc(%ebp)
  801de6:	68 04 60 80 00       	push   $0x806004
  801deb:	e8 44 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801df0:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801df6:	b8 05 00 00 00       	mov    $0x5,%eax
  801dfb:	e8 c5 fe ff ff       	call   801cc5 <nsipc>
}
  801e00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e03:	c9                   	leave  
  801e04:	c3                   	ret    

00801e05 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e05:	55                   	push   %ebp
  801e06:	89 e5                	mov    %esp,%ebp
  801e08:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e1b:	b8 06 00 00 00       	mov    $0x6,%eax
  801e20:	e8 a0 fe ff ff       	call   801cc5 <nsipc>
}
  801e25:	c9                   	leave  
  801e26:	c3                   	ret    

00801e27 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e27:	55                   	push   %ebp
  801e28:	89 e5                	mov    %esp,%ebp
  801e2a:	56                   	push   %esi
  801e2b:	53                   	push   %ebx
  801e2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e32:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801e37:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801e3d:	8b 45 14             	mov    0x14(%ebp),%eax
  801e40:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e45:	b8 07 00 00 00       	mov    $0x7,%eax
  801e4a:	e8 76 fe ff ff       	call   801cc5 <nsipc>
  801e4f:	89 c3                	mov    %eax,%ebx
  801e51:	85 c0                	test   %eax,%eax
  801e53:	78 35                	js     801e8a <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e55:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e5a:	7f 04                	jg     801e60 <nsipc_recv+0x39>
  801e5c:	39 c6                	cmp    %eax,%esi
  801e5e:	7d 16                	jge    801e76 <nsipc_recv+0x4f>
  801e60:	68 eb 2c 80 00       	push   $0x802ceb
  801e65:	68 b3 2c 80 00       	push   $0x802cb3
  801e6a:	6a 62                	push   $0x62
  801e6c:	68 00 2d 80 00       	push   $0x802d00
  801e71:	e8 ce e3 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e76:	83 ec 04             	sub    $0x4,%esp
  801e79:	50                   	push   %eax
  801e7a:	68 00 60 80 00       	push   $0x806000
  801e7f:	ff 75 0c             	pushl  0xc(%ebp)
  801e82:	e8 ad eb ff ff       	call   800a34 <memmove>
  801e87:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e8a:	89 d8                	mov    %ebx,%eax
  801e8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    

00801e93 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e93:	55                   	push   %ebp
  801e94:	89 e5                	mov    %esp,%ebp
  801e96:	53                   	push   %ebx
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea0:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ea5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801eab:	7e 16                	jle    801ec3 <nsipc_send+0x30>
  801ead:	68 0c 2d 80 00       	push   $0x802d0c
  801eb2:	68 b3 2c 80 00       	push   $0x802cb3
  801eb7:	6a 6d                	push   $0x6d
  801eb9:	68 00 2d 80 00       	push   $0x802d00
  801ebe:	e8 81 e3 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ec3:	83 ec 04             	sub    $0x4,%esp
  801ec6:	53                   	push   %ebx
  801ec7:	ff 75 0c             	pushl  0xc(%ebp)
  801eca:	68 0c 60 80 00       	push   $0x80600c
  801ecf:	e8 60 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  801ed4:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801eda:	8b 45 14             	mov    0x14(%ebp),%eax
  801edd:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ee2:	b8 08 00 00 00       	mov    $0x8,%eax
  801ee7:	e8 d9 fd ff ff       	call   801cc5 <nsipc>
}
  801eec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eef:	c9                   	leave  
  801ef0:	c3                   	ret    

00801ef1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801eff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f02:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801f07:	8b 45 10             	mov    0x10(%ebp),%eax
  801f0a:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801f0f:	b8 09 00 00 00       	mov    $0x9,%eax
  801f14:	e8 ac fd ff ff       	call   801cc5 <nsipc>
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    

00801f1b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f1b:	55                   	push   %ebp
  801f1c:	89 e5                	mov    %esp,%ebp
  801f1e:	56                   	push   %esi
  801f1f:	53                   	push   %ebx
  801f20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	ff 75 08             	pushl  0x8(%ebp)
  801f29:	e8 5d f3 ff ff       	call   80128b <fd2data>
  801f2e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f30:	83 c4 08             	add    $0x8,%esp
  801f33:	68 18 2d 80 00       	push   $0x802d18
  801f38:	53                   	push   %ebx
  801f39:	e8 64 e9 ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f3e:	8b 46 04             	mov    0x4(%esi),%eax
  801f41:	2b 06                	sub    (%esi),%eax
  801f43:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f49:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f50:	00 00 00 
	stat->st_dev = &devpipe;
  801f53:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f5a:	30 80 00 
	return 0;
}
  801f5d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f65:	5b                   	pop    %ebx
  801f66:	5e                   	pop    %esi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    

00801f69 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f69:	55                   	push   %ebp
  801f6a:	89 e5                	mov    %esp,%ebp
  801f6c:	53                   	push   %ebx
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f73:	53                   	push   %ebx
  801f74:	6a 00                	push   $0x0
  801f76:	e8 af ed ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f7b:	89 1c 24             	mov    %ebx,(%esp)
  801f7e:	e8 08 f3 ff ff       	call   80128b <fd2data>
  801f83:	83 c4 08             	add    $0x8,%esp
  801f86:	50                   	push   %eax
  801f87:	6a 00                	push   $0x0
  801f89:	e8 9c ed ff ff       	call   800d2a <sys_page_unmap>
}
  801f8e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f91:	c9                   	leave  
  801f92:	c3                   	ret    

00801f93 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f93:	55                   	push   %ebp
  801f94:	89 e5                	mov    %esp,%ebp
  801f96:	57                   	push   %edi
  801f97:	56                   	push   %esi
  801f98:	53                   	push   %ebx
  801f99:	83 ec 1c             	sub    $0x1c,%esp
  801f9c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f9f:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801fa1:	a1 08 40 80 00       	mov    0x804008,%eax
  801fa6:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801fa9:	83 ec 0c             	sub    $0xc,%esp
  801fac:	ff 75 e0             	pushl  -0x20(%ebp)
  801faf:	e8 c5 fa ff ff       	call   801a79 <pageref>
  801fb4:	89 c3                	mov    %eax,%ebx
  801fb6:	89 3c 24             	mov    %edi,(%esp)
  801fb9:	e8 bb fa ff ff       	call   801a79 <pageref>
  801fbe:	83 c4 10             	add    $0x10,%esp
  801fc1:	39 c3                	cmp    %eax,%ebx
  801fc3:	0f 94 c1             	sete   %cl
  801fc6:	0f b6 c9             	movzbl %cl,%ecx
  801fc9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801fcc:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801fd2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fd5:	39 ce                	cmp    %ecx,%esi
  801fd7:	74 1b                	je     801ff4 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801fd9:	39 c3                	cmp    %eax,%ebx
  801fdb:	75 c4                	jne    801fa1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fdd:	8b 42 58             	mov    0x58(%edx),%eax
  801fe0:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fe3:	50                   	push   %eax
  801fe4:	56                   	push   %esi
  801fe5:	68 1f 2d 80 00       	push   $0x802d1f
  801fea:	e8 2e e3 ff ff       	call   80031d <cprintf>
  801fef:	83 c4 10             	add    $0x10,%esp
  801ff2:	eb ad                	jmp    801fa1 <_pipeisclosed+0xe>
	}
}
  801ff4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ff7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffa:	5b                   	pop    %ebx
  801ffb:	5e                   	pop    %esi
  801ffc:	5f                   	pop    %edi
  801ffd:	5d                   	pop    %ebp
  801ffe:	c3                   	ret    

00801fff <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fff:	55                   	push   %ebp
  802000:	89 e5                	mov    %esp,%ebp
  802002:	57                   	push   %edi
  802003:	56                   	push   %esi
  802004:	53                   	push   %ebx
  802005:	83 ec 28             	sub    $0x28,%esp
  802008:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80200b:	56                   	push   %esi
  80200c:	e8 7a f2 ff ff       	call   80128b <fd2data>
  802011:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802013:	83 c4 10             	add    $0x10,%esp
  802016:	bf 00 00 00 00       	mov    $0x0,%edi
  80201b:	eb 4b                	jmp    802068 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80201d:	89 da                	mov    %ebx,%edx
  80201f:	89 f0                	mov    %esi,%eax
  802021:	e8 6d ff ff ff       	call   801f93 <_pipeisclosed>
  802026:	85 c0                	test   %eax,%eax
  802028:	75 48                	jne    802072 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80202a:	e8 57 ec ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80202f:	8b 43 04             	mov    0x4(%ebx),%eax
  802032:	8b 0b                	mov    (%ebx),%ecx
  802034:	8d 51 20             	lea    0x20(%ecx),%edx
  802037:	39 d0                	cmp    %edx,%eax
  802039:	73 e2                	jae    80201d <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80203b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80203e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802042:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802045:	89 c2                	mov    %eax,%edx
  802047:	c1 fa 1f             	sar    $0x1f,%edx
  80204a:	89 d1                	mov    %edx,%ecx
  80204c:	c1 e9 1b             	shr    $0x1b,%ecx
  80204f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802052:	83 e2 1f             	and    $0x1f,%edx
  802055:	29 ca                	sub    %ecx,%edx
  802057:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80205b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80205f:	83 c0 01             	add    $0x1,%eax
  802062:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802065:	83 c7 01             	add    $0x1,%edi
  802068:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80206b:	75 c2                	jne    80202f <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80206d:	8b 45 10             	mov    0x10(%ebp),%eax
  802070:	eb 05                	jmp    802077 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802072:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802077:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80207a:	5b                   	pop    %ebx
  80207b:	5e                   	pop    %esi
  80207c:	5f                   	pop    %edi
  80207d:	5d                   	pop    %ebp
  80207e:	c3                   	ret    

0080207f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80207f:	55                   	push   %ebp
  802080:	89 e5                	mov    %esp,%ebp
  802082:	57                   	push   %edi
  802083:	56                   	push   %esi
  802084:	53                   	push   %ebx
  802085:	83 ec 18             	sub    $0x18,%esp
  802088:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80208b:	57                   	push   %edi
  80208c:	e8 fa f1 ff ff       	call   80128b <fd2data>
  802091:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	bb 00 00 00 00       	mov    $0x0,%ebx
  80209b:	eb 3d                	jmp    8020da <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80209d:	85 db                	test   %ebx,%ebx
  80209f:	74 04                	je     8020a5 <devpipe_read+0x26>
				return i;
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	eb 44                	jmp    8020e9 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8020a5:	89 f2                	mov    %esi,%edx
  8020a7:	89 f8                	mov    %edi,%eax
  8020a9:	e8 e5 fe ff ff       	call   801f93 <_pipeisclosed>
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	75 32                	jne    8020e4 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8020b2:	e8 cf eb ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8020b7:	8b 06                	mov    (%esi),%eax
  8020b9:	3b 46 04             	cmp    0x4(%esi),%eax
  8020bc:	74 df                	je     80209d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020be:	99                   	cltd   
  8020bf:	c1 ea 1b             	shr    $0x1b,%edx
  8020c2:	01 d0                	add    %edx,%eax
  8020c4:	83 e0 1f             	and    $0x1f,%eax
  8020c7:	29 d0                	sub    %edx,%eax
  8020c9:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8020ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d1:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8020d4:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020d7:	83 c3 01             	add    $0x1,%ebx
  8020da:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8020dd:	75 d8                	jne    8020b7 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8020df:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e2:	eb 05                	jmp    8020e9 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ec:	5b                   	pop    %ebx
  8020ed:	5e                   	pop    %esi
  8020ee:	5f                   	pop    %edi
  8020ef:	5d                   	pop    %ebp
  8020f0:	c3                   	ret    

008020f1 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020f1:	55                   	push   %ebp
  8020f2:	89 e5                	mov    %esp,%ebp
  8020f4:	56                   	push   %esi
  8020f5:	53                   	push   %ebx
  8020f6:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fc:	50                   	push   %eax
  8020fd:	e8 a0 f1 ff ff       	call   8012a2 <fd_alloc>
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	89 c2                	mov    %eax,%edx
  802107:	85 c0                	test   %eax,%eax
  802109:	0f 88 2c 01 00 00    	js     80223b <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80210f:	83 ec 04             	sub    $0x4,%esp
  802112:	68 07 04 00 00       	push   $0x407
  802117:	ff 75 f4             	pushl  -0xc(%ebp)
  80211a:	6a 00                	push   $0x0
  80211c:	e8 84 eb ff ff       	call   800ca5 <sys_page_alloc>
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	89 c2                	mov    %eax,%edx
  802126:	85 c0                	test   %eax,%eax
  802128:	0f 88 0d 01 00 00    	js     80223b <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80212e:	83 ec 0c             	sub    $0xc,%esp
  802131:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802134:	50                   	push   %eax
  802135:	e8 68 f1 ff ff       	call   8012a2 <fd_alloc>
  80213a:	89 c3                	mov    %eax,%ebx
  80213c:	83 c4 10             	add    $0x10,%esp
  80213f:	85 c0                	test   %eax,%eax
  802141:	0f 88 e2 00 00 00    	js     802229 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802147:	83 ec 04             	sub    $0x4,%esp
  80214a:	68 07 04 00 00       	push   $0x407
  80214f:	ff 75 f0             	pushl  -0x10(%ebp)
  802152:	6a 00                	push   $0x0
  802154:	e8 4c eb ff ff       	call   800ca5 <sys_page_alloc>
  802159:	89 c3                	mov    %eax,%ebx
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	0f 88 c3 00 00 00    	js     802229 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802166:	83 ec 0c             	sub    $0xc,%esp
  802169:	ff 75 f4             	pushl  -0xc(%ebp)
  80216c:	e8 1a f1 ff ff       	call   80128b <fd2data>
  802171:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802173:	83 c4 0c             	add    $0xc,%esp
  802176:	68 07 04 00 00       	push   $0x407
  80217b:	50                   	push   %eax
  80217c:	6a 00                	push   $0x0
  80217e:	e8 22 eb ff ff       	call   800ca5 <sys_page_alloc>
  802183:	89 c3                	mov    %eax,%ebx
  802185:	83 c4 10             	add    $0x10,%esp
  802188:	85 c0                	test   %eax,%eax
  80218a:	0f 88 89 00 00 00    	js     802219 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802190:	83 ec 0c             	sub    $0xc,%esp
  802193:	ff 75 f0             	pushl  -0x10(%ebp)
  802196:	e8 f0 f0 ff ff       	call   80128b <fd2data>
  80219b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021a2:	50                   	push   %eax
  8021a3:	6a 00                	push   $0x0
  8021a5:	56                   	push   %esi
  8021a6:	6a 00                	push   $0x0
  8021a8:	e8 3b eb ff ff       	call   800ce8 <sys_page_map>
  8021ad:	89 c3                	mov    %eax,%ebx
  8021af:	83 c4 20             	add    $0x20,%esp
  8021b2:	85 c0                	test   %eax,%eax
  8021b4:	78 55                	js     80220b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8021b6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bf:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8021c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c4:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8021cb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8021d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d4:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8021d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021d9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8021e0:	83 ec 0c             	sub    $0xc,%esp
  8021e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e6:	e8 90 f0 ff ff       	call   80127b <fd2num>
  8021eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ee:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021f0:	83 c4 04             	add    $0x4,%esp
  8021f3:	ff 75 f0             	pushl  -0x10(%ebp)
  8021f6:	e8 80 f0 ff ff       	call   80127b <fd2num>
  8021fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021fe:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802201:	83 c4 10             	add    $0x10,%esp
  802204:	ba 00 00 00 00       	mov    $0x0,%edx
  802209:	eb 30                	jmp    80223b <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80220b:	83 ec 08             	sub    $0x8,%esp
  80220e:	56                   	push   %esi
  80220f:	6a 00                	push   $0x0
  802211:	e8 14 eb ff ff       	call   800d2a <sys_page_unmap>
  802216:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802219:	83 ec 08             	sub    $0x8,%esp
  80221c:	ff 75 f0             	pushl  -0x10(%ebp)
  80221f:	6a 00                	push   $0x0
  802221:	e8 04 eb ff ff       	call   800d2a <sys_page_unmap>
  802226:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802229:	83 ec 08             	sub    $0x8,%esp
  80222c:	ff 75 f4             	pushl  -0xc(%ebp)
  80222f:	6a 00                	push   $0x0
  802231:	e8 f4 ea ff ff       	call   800d2a <sys_page_unmap>
  802236:	83 c4 10             	add    $0x10,%esp
  802239:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802240:	5b                   	pop    %ebx
  802241:	5e                   	pop    %esi
  802242:	5d                   	pop    %ebp
  802243:	c3                   	ret    

00802244 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802244:	55                   	push   %ebp
  802245:	89 e5                	mov    %esp,%ebp
  802247:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80224d:	50                   	push   %eax
  80224e:	ff 75 08             	pushl  0x8(%ebp)
  802251:	e8 9b f0 ff ff       	call   8012f1 <fd_lookup>
  802256:	83 c4 10             	add    $0x10,%esp
  802259:	85 c0                	test   %eax,%eax
  80225b:	78 18                	js     802275 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80225d:	83 ec 0c             	sub    $0xc,%esp
  802260:	ff 75 f4             	pushl  -0xc(%ebp)
  802263:	e8 23 f0 ff ff       	call   80128b <fd2data>
	return _pipeisclosed(fd, p);
  802268:	89 c2                	mov    %eax,%edx
  80226a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80226d:	e8 21 fd ff ff       	call   801f93 <_pipeisclosed>
  802272:	83 c4 10             	add    $0x10,%esp
}
  802275:	c9                   	leave  
  802276:	c3                   	ret    

00802277 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802277:	55                   	push   %ebp
  802278:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80227a:	b8 00 00 00 00       	mov    $0x0,%eax
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802287:	68 37 2d 80 00       	push   $0x802d37
  80228c:	ff 75 0c             	pushl  0xc(%ebp)
  80228f:	e8 0e e6 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  802294:	b8 00 00 00 00       	mov    $0x0,%eax
  802299:	c9                   	leave  
  80229a:	c3                   	ret    

0080229b <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	57                   	push   %edi
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022a7:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022ac:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022b2:	eb 2d                	jmp    8022e1 <devcons_write+0x46>
		m = n - tot;
  8022b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022b7:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8022b9:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8022bc:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8022c1:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8022c4:	83 ec 04             	sub    $0x4,%esp
  8022c7:	53                   	push   %ebx
  8022c8:	03 45 0c             	add    0xc(%ebp),%eax
  8022cb:	50                   	push   %eax
  8022cc:	57                   	push   %edi
  8022cd:	e8 62 e7 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  8022d2:	83 c4 08             	add    $0x8,%esp
  8022d5:	53                   	push   %ebx
  8022d6:	57                   	push   %edi
  8022d7:	e8 0d e9 ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8022dc:	01 de                	add    %ebx,%esi
  8022de:	83 c4 10             	add    $0x10,%esp
  8022e1:	89 f0                	mov    %esi,%eax
  8022e3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022e6:	72 cc                	jb     8022b4 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022eb:	5b                   	pop    %ebx
  8022ec:	5e                   	pop    %esi
  8022ed:	5f                   	pop    %edi
  8022ee:	5d                   	pop    %ebp
  8022ef:	c3                   	ret    

008022f0 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022f0:	55                   	push   %ebp
  8022f1:	89 e5                	mov    %esp,%ebp
  8022f3:	83 ec 08             	sub    $0x8,%esp
  8022f6:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022ff:	74 2a                	je     80232b <devcons_read+0x3b>
  802301:	eb 05                	jmp    802308 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802303:	e8 7e e9 ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802308:	e8 fa e8 ff ff       	call   800c07 <sys_cgetc>
  80230d:	85 c0                	test   %eax,%eax
  80230f:	74 f2                	je     802303 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802311:	85 c0                	test   %eax,%eax
  802313:	78 16                	js     80232b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802315:	83 f8 04             	cmp    $0x4,%eax
  802318:	74 0c                	je     802326 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80231a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231d:	88 02                	mov    %al,(%edx)
	return 1;
  80231f:	b8 01 00 00 00       	mov    $0x1,%eax
  802324:	eb 05                	jmp    80232b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802326:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80232b:	c9                   	leave  
  80232c:	c3                   	ret    

0080232d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80232d:	55                   	push   %ebp
  80232e:	89 e5                	mov    %esp,%ebp
  802330:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802333:	8b 45 08             	mov    0x8(%ebp),%eax
  802336:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802339:	6a 01                	push   $0x1
  80233b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80233e:	50                   	push   %eax
  80233f:	e8 a5 e8 ff ff       	call   800be9 <sys_cputs>
}
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	c9                   	leave  
  802348:	c3                   	ret    

00802349 <getchar>:

int
getchar(void)
{
  802349:	55                   	push   %ebp
  80234a:	89 e5                	mov    %esp,%ebp
  80234c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80234f:	6a 01                	push   $0x1
  802351:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802354:	50                   	push   %eax
  802355:	6a 00                	push   $0x0
  802357:	e8 fb f1 ff ff       	call   801557 <read>
	if (r < 0)
  80235c:	83 c4 10             	add    $0x10,%esp
  80235f:	85 c0                	test   %eax,%eax
  802361:	78 0f                	js     802372 <getchar+0x29>
		return r;
	if (r < 1)
  802363:	85 c0                	test   %eax,%eax
  802365:	7e 06                	jle    80236d <getchar+0x24>
		return -E_EOF;
	return c;
  802367:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80236b:	eb 05                	jmp    802372 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80236d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802372:	c9                   	leave  
  802373:	c3                   	ret    

00802374 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802374:	55                   	push   %ebp
  802375:	89 e5                	mov    %esp,%ebp
  802377:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80237a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80237d:	50                   	push   %eax
  80237e:	ff 75 08             	pushl  0x8(%ebp)
  802381:	e8 6b ef ff ff       	call   8012f1 <fd_lookup>
  802386:	83 c4 10             	add    $0x10,%esp
  802389:	85 c0                	test   %eax,%eax
  80238b:	78 11                	js     80239e <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80238d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802390:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802396:	39 10                	cmp    %edx,(%eax)
  802398:	0f 94 c0             	sete   %al
  80239b:	0f b6 c0             	movzbl %al,%eax
}
  80239e:	c9                   	leave  
  80239f:	c3                   	ret    

008023a0 <opencons>:

int
opencons(void)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a9:	50                   	push   %eax
  8023aa:	e8 f3 ee ff ff       	call   8012a2 <fd_alloc>
  8023af:	83 c4 10             	add    $0x10,%esp
		return r;
  8023b2:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8023b4:	85 c0                	test   %eax,%eax
  8023b6:	78 3e                	js     8023f6 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023b8:	83 ec 04             	sub    $0x4,%esp
  8023bb:	68 07 04 00 00       	push   $0x407
  8023c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8023c3:	6a 00                	push   $0x0
  8023c5:	e8 db e8 ff ff       	call   800ca5 <sys_page_alloc>
  8023ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8023cd:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023cf:	85 c0                	test   %eax,%eax
  8023d1:	78 23                	js     8023f6 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8023d3:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023e8:	83 ec 0c             	sub    $0xc,%esp
  8023eb:	50                   	push   %eax
  8023ec:	e8 8a ee ff ff       	call   80127b <fd2num>
  8023f1:	89 c2                	mov    %eax,%edx
  8023f3:	83 c4 10             	add    $0x10,%esp
}
  8023f6:	89 d0                	mov    %edx,%eax
  8023f8:	c9                   	leave  
  8023f9:	c3                   	ret    

008023fa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023fa:	55                   	push   %ebp
  8023fb:	89 e5                	mov    %esp,%ebp
  8023fd:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802400:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802407:	75 2e                	jne    802437 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  802409:	e8 59 e8 ff ff       	call   800c67 <sys_getenvid>
  80240e:	83 ec 04             	sub    $0x4,%esp
  802411:	68 07 0e 00 00       	push   $0xe07
  802416:	68 00 f0 bf ee       	push   $0xeebff000
  80241b:	50                   	push   %eax
  80241c:	e8 84 e8 ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802421:	e8 41 e8 ff ff       	call   800c67 <sys_getenvid>
  802426:	83 c4 08             	add    $0x8,%esp
  802429:	68 41 24 80 00       	push   $0x802441
  80242e:	50                   	push   %eax
  80242f:	e8 bc e9 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  802434:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802437:	8b 45 08             	mov    0x8(%ebp),%eax
  80243a:	a3 00 70 80 00       	mov    %eax,0x807000
}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    

00802441 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802441:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802442:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802447:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802449:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80244c:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802450:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802454:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802457:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80245a:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  80245b:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80245e:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80245f:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802460:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802464:	c3                   	ret    
  802465:	66 90                	xchg   %ax,%ax
  802467:	66 90                	xchg   %ax,%ax
  802469:	66 90                	xchg   %ax,%ax
  80246b:	66 90                	xchg   %ax,%ax
  80246d:	66 90                	xchg   %ax,%ax
  80246f:	90                   	nop

00802470 <__udivdi3>:
  802470:	55                   	push   %ebp
  802471:	57                   	push   %edi
  802472:	56                   	push   %esi
  802473:	53                   	push   %ebx
  802474:	83 ec 1c             	sub    $0x1c,%esp
  802477:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80247b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80247f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802483:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802487:	85 f6                	test   %esi,%esi
  802489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80248d:	89 ca                	mov    %ecx,%edx
  80248f:	89 f8                	mov    %edi,%eax
  802491:	75 3d                	jne    8024d0 <__udivdi3+0x60>
  802493:	39 cf                	cmp    %ecx,%edi
  802495:	0f 87 c5 00 00 00    	ja     802560 <__udivdi3+0xf0>
  80249b:	85 ff                	test   %edi,%edi
  80249d:	89 fd                	mov    %edi,%ebp
  80249f:	75 0b                	jne    8024ac <__udivdi3+0x3c>
  8024a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024a6:	31 d2                	xor    %edx,%edx
  8024a8:	f7 f7                	div    %edi
  8024aa:	89 c5                	mov    %eax,%ebp
  8024ac:	89 c8                	mov    %ecx,%eax
  8024ae:	31 d2                	xor    %edx,%edx
  8024b0:	f7 f5                	div    %ebp
  8024b2:	89 c1                	mov    %eax,%ecx
  8024b4:	89 d8                	mov    %ebx,%eax
  8024b6:	89 cf                	mov    %ecx,%edi
  8024b8:	f7 f5                	div    %ebp
  8024ba:	89 c3                	mov    %eax,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	39 ce                	cmp    %ecx,%esi
  8024d2:	77 74                	ja     802548 <__udivdi3+0xd8>
  8024d4:	0f bd fe             	bsr    %esi,%edi
  8024d7:	83 f7 1f             	xor    $0x1f,%edi
  8024da:	0f 84 98 00 00 00    	je     802578 <__udivdi3+0x108>
  8024e0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	89 c5                	mov    %eax,%ebp
  8024e9:	29 fb                	sub    %edi,%ebx
  8024eb:	d3 e6                	shl    %cl,%esi
  8024ed:	89 d9                	mov    %ebx,%ecx
  8024ef:	d3 ed                	shr    %cl,%ebp
  8024f1:	89 f9                	mov    %edi,%ecx
  8024f3:	d3 e0                	shl    %cl,%eax
  8024f5:	09 ee                	or     %ebp,%esi
  8024f7:	89 d9                	mov    %ebx,%ecx
  8024f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024fd:	89 d5                	mov    %edx,%ebp
  8024ff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802503:	d3 ed                	shr    %cl,%ebp
  802505:	89 f9                	mov    %edi,%ecx
  802507:	d3 e2                	shl    %cl,%edx
  802509:	89 d9                	mov    %ebx,%ecx
  80250b:	d3 e8                	shr    %cl,%eax
  80250d:	09 c2                	or     %eax,%edx
  80250f:	89 d0                	mov    %edx,%eax
  802511:	89 ea                	mov    %ebp,%edx
  802513:	f7 f6                	div    %esi
  802515:	89 d5                	mov    %edx,%ebp
  802517:	89 c3                	mov    %eax,%ebx
  802519:	f7 64 24 0c          	mull   0xc(%esp)
  80251d:	39 d5                	cmp    %edx,%ebp
  80251f:	72 10                	jb     802531 <__udivdi3+0xc1>
  802521:	8b 74 24 08          	mov    0x8(%esp),%esi
  802525:	89 f9                	mov    %edi,%ecx
  802527:	d3 e6                	shl    %cl,%esi
  802529:	39 c6                	cmp    %eax,%esi
  80252b:	73 07                	jae    802534 <__udivdi3+0xc4>
  80252d:	39 d5                	cmp    %edx,%ebp
  80252f:	75 03                	jne    802534 <__udivdi3+0xc4>
  802531:	83 eb 01             	sub    $0x1,%ebx
  802534:	31 ff                	xor    %edi,%edi
  802536:	89 d8                	mov    %ebx,%eax
  802538:	89 fa                	mov    %edi,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	31 ff                	xor    %edi,%edi
  80254a:	31 db                	xor    %ebx,%ebx
  80254c:	89 d8                	mov    %ebx,%eax
  80254e:	89 fa                	mov    %edi,%edx
  802550:	83 c4 1c             	add    $0x1c,%esp
  802553:	5b                   	pop    %ebx
  802554:	5e                   	pop    %esi
  802555:	5f                   	pop    %edi
  802556:	5d                   	pop    %ebp
  802557:	c3                   	ret    
  802558:	90                   	nop
  802559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802560:	89 d8                	mov    %ebx,%eax
  802562:	f7 f7                	div    %edi
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 c3                	mov    %eax,%ebx
  802568:	89 d8                	mov    %ebx,%eax
  80256a:	89 fa                	mov    %edi,%edx
  80256c:	83 c4 1c             	add    $0x1c,%esp
  80256f:	5b                   	pop    %ebx
  802570:	5e                   	pop    %esi
  802571:	5f                   	pop    %edi
  802572:	5d                   	pop    %ebp
  802573:	c3                   	ret    
  802574:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802578:	39 ce                	cmp    %ecx,%esi
  80257a:	72 0c                	jb     802588 <__udivdi3+0x118>
  80257c:	31 db                	xor    %ebx,%ebx
  80257e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802582:	0f 87 34 ff ff ff    	ja     8024bc <__udivdi3+0x4c>
  802588:	bb 01 00 00 00       	mov    $0x1,%ebx
  80258d:	e9 2a ff ff ff       	jmp    8024bc <__udivdi3+0x4c>
  802592:	66 90                	xchg   %ax,%ax
  802594:	66 90                	xchg   %ax,%ax
  802596:	66 90                	xchg   %ax,%ax
  802598:	66 90                	xchg   %ax,%ax
  80259a:	66 90                	xchg   %ax,%ax
  80259c:	66 90                	xchg   %ax,%ax
  80259e:	66 90                	xchg   %ax,%ax

008025a0 <__umoddi3>:
  8025a0:	55                   	push   %ebp
  8025a1:	57                   	push   %edi
  8025a2:	56                   	push   %esi
  8025a3:	53                   	push   %ebx
  8025a4:	83 ec 1c             	sub    $0x1c,%esp
  8025a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025b7:	85 d2                	test   %edx,%edx
  8025b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 f3                	mov    %esi,%ebx
  8025c3:	89 3c 24             	mov    %edi,(%esp)
  8025c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025ca:	75 1c                	jne    8025e8 <__umoddi3+0x48>
  8025cc:	39 f7                	cmp    %esi,%edi
  8025ce:	76 50                	jbe    802620 <__umoddi3+0x80>
  8025d0:	89 c8                	mov    %ecx,%eax
  8025d2:	89 f2                	mov    %esi,%edx
  8025d4:	f7 f7                	div    %edi
  8025d6:	89 d0                	mov    %edx,%eax
  8025d8:	31 d2                	xor    %edx,%edx
  8025da:	83 c4 1c             	add    $0x1c,%esp
  8025dd:	5b                   	pop    %ebx
  8025de:	5e                   	pop    %esi
  8025df:	5f                   	pop    %edi
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    
  8025e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e8:	39 f2                	cmp    %esi,%edx
  8025ea:	89 d0                	mov    %edx,%eax
  8025ec:	77 52                	ja     802640 <__umoddi3+0xa0>
  8025ee:	0f bd ea             	bsr    %edx,%ebp
  8025f1:	83 f5 1f             	xor    $0x1f,%ebp
  8025f4:	75 5a                	jne    802650 <__umoddi3+0xb0>
  8025f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025fa:	0f 82 e0 00 00 00    	jb     8026e0 <__umoddi3+0x140>
  802600:	39 0c 24             	cmp    %ecx,(%esp)
  802603:	0f 86 d7 00 00 00    	jbe    8026e0 <__umoddi3+0x140>
  802609:	8b 44 24 08          	mov    0x8(%esp),%eax
  80260d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802611:	83 c4 1c             	add    $0x1c,%esp
  802614:	5b                   	pop    %ebx
  802615:	5e                   	pop    %esi
  802616:	5f                   	pop    %edi
  802617:	5d                   	pop    %ebp
  802618:	c3                   	ret    
  802619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802620:	85 ff                	test   %edi,%edi
  802622:	89 fd                	mov    %edi,%ebp
  802624:	75 0b                	jne    802631 <__umoddi3+0x91>
  802626:	b8 01 00 00 00       	mov    $0x1,%eax
  80262b:	31 d2                	xor    %edx,%edx
  80262d:	f7 f7                	div    %edi
  80262f:	89 c5                	mov    %eax,%ebp
  802631:	89 f0                	mov    %esi,%eax
  802633:	31 d2                	xor    %edx,%edx
  802635:	f7 f5                	div    %ebp
  802637:	89 c8                	mov    %ecx,%eax
  802639:	f7 f5                	div    %ebp
  80263b:	89 d0                	mov    %edx,%eax
  80263d:	eb 99                	jmp    8025d8 <__umoddi3+0x38>
  80263f:	90                   	nop
  802640:	89 c8                	mov    %ecx,%eax
  802642:	89 f2                	mov    %esi,%edx
  802644:	83 c4 1c             	add    $0x1c,%esp
  802647:	5b                   	pop    %ebx
  802648:	5e                   	pop    %esi
  802649:	5f                   	pop    %edi
  80264a:	5d                   	pop    %ebp
  80264b:	c3                   	ret    
  80264c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802650:	8b 34 24             	mov    (%esp),%esi
  802653:	bf 20 00 00 00       	mov    $0x20,%edi
  802658:	89 e9                	mov    %ebp,%ecx
  80265a:	29 ef                	sub    %ebp,%edi
  80265c:	d3 e0                	shl    %cl,%eax
  80265e:	89 f9                	mov    %edi,%ecx
  802660:	89 f2                	mov    %esi,%edx
  802662:	d3 ea                	shr    %cl,%edx
  802664:	89 e9                	mov    %ebp,%ecx
  802666:	09 c2                	or     %eax,%edx
  802668:	89 d8                	mov    %ebx,%eax
  80266a:	89 14 24             	mov    %edx,(%esp)
  80266d:	89 f2                	mov    %esi,%edx
  80266f:	d3 e2                	shl    %cl,%edx
  802671:	89 f9                	mov    %edi,%ecx
  802673:	89 54 24 04          	mov    %edx,0x4(%esp)
  802677:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80267b:	d3 e8                	shr    %cl,%eax
  80267d:	89 e9                	mov    %ebp,%ecx
  80267f:	89 c6                	mov    %eax,%esi
  802681:	d3 e3                	shl    %cl,%ebx
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 d0                	mov    %edx,%eax
  802687:	d3 e8                	shr    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	09 d8                	or     %ebx,%eax
  80268d:	89 d3                	mov    %edx,%ebx
  80268f:	89 f2                	mov    %esi,%edx
  802691:	f7 34 24             	divl   (%esp)
  802694:	89 d6                	mov    %edx,%esi
  802696:	d3 e3                	shl    %cl,%ebx
  802698:	f7 64 24 04          	mull   0x4(%esp)
  80269c:	39 d6                	cmp    %edx,%esi
  80269e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026a2:	89 d1                	mov    %edx,%ecx
  8026a4:	89 c3                	mov    %eax,%ebx
  8026a6:	72 08                	jb     8026b0 <__umoddi3+0x110>
  8026a8:	75 11                	jne    8026bb <__umoddi3+0x11b>
  8026aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026ae:	73 0b                	jae    8026bb <__umoddi3+0x11b>
  8026b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026b4:	1b 14 24             	sbb    (%esp),%edx
  8026b7:	89 d1                	mov    %edx,%ecx
  8026b9:	89 c3                	mov    %eax,%ebx
  8026bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026bf:	29 da                	sub    %ebx,%edx
  8026c1:	19 ce                	sbb    %ecx,%esi
  8026c3:	89 f9                	mov    %edi,%ecx
  8026c5:	89 f0                	mov    %esi,%eax
  8026c7:	d3 e0                	shl    %cl,%eax
  8026c9:	89 e9                	mov    %ebp,%ecx
  8026cb:	d3 ea                	shr    %cl,%edx
  8026cd:	89 e9                	mov    %ebp,%ecx
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	09 d0                	or     %edx,%eax
  8026d3:	89 f2                	mov    %esi,%edx
  8026d5:	83 c4 1c             	add    $0x1c,%esp
  8026d8:	5b                   	pop    %ebx
  8026d9:	5e                   	pop    %esi
  8026da:	5f                   	pop    %edi
  8026db:	5d                   	pop    %ebp
  8026dc:	c3                   	ret    
  8026dd:	8d 76 00             	lea    0x0(%esi),%esi
  8026e0:	29 f9                	sub    %edi,%ecx
  8026e2:	19 d6                	sbb    %edx,%esi
  8026e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ec:	e9 18 ff ff ff       	jmp    802609 <__umoddi3+0x69>
