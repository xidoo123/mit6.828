
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
  80003b:	68 c0 26 80 00       	push   $0x8026c0
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 5f 20 00 00       	call   8020af <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 d9 26 80 00       	push   $0x8026d9
  80005d:	6a 0d                	push   $0xd
  80005f:	68 e2 26 80 00       	push   $0x8026e2
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 20 0f 00 00       	call   800f8e <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 f6 26 80 00       	push   $0x8026f6
  80007a:	6a 10                	push   $0x10
  80007c:	68 e2 26 80 00       	push   $0x8026e2
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 44 13 00 00       	call   8013d9 <close>
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
  8000a3:	e8 5a 21 00 00       	call   802202 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 ff 26 80 00       	push   $0x8026ff
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
  8000d7:	e8 69 10 00 00       	call   801145 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 1a 27 80 00       	push   $0x80271a
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
  800103:	68 25 27 80 00       	push   $0x802725
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 0f 13 00 00       	call   801429 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 f4 12 00 00       	call   801429 <dup>
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
  800143:	68 30 27 80 00       	push   $0x802730
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 aa 20 00 00       	call   802202 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 8c 27 80 00       	push   $0x80278c
  800167:	6a 3a                	push   $0x3a
  800169:	68 e2 26 80 00       	push   $0x8026e2
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 2d 11 00 00       	call   8012af <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 46 27 80 00       	push   $0x802746
  80018f:	6a 3c                	push   $0x3c
  800191:	68 e2 26 80 00       	push   $0x8026e2
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 a3 10 00 00       	call   801249 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 89 18 00 00       	call   801a37 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 5e 27 80 00       	push   $0x80275e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 74 27 80 00       	push   $0x802774
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
  800230:	e8 cf 11 00 00       	call   801404 <close_all>
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
  800262:	68 c0 27 80 00       	push   $0x8027c0
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 d7 26 80 00 	movl   $0x8026d7,(%esp)
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
  800380:	e8 ab 20 00 00       	call   802430 <__udivdi3>
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
  8003c3:	e8 98 21 00 00       	call   802560 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 e3 27 80 00 	movsbl 0x8027e3(%eax),%eax
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
  8004c7:	ff 24 85 20 29 80 00 	jmp    *0x802920(,%eax,4)
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
  80058b:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 fb 27 80 00       	push   $0x8027fb
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
  8005af:	68 85 2c 80 00       	push   $0x802c85
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
  8005d3:	b8 f4 27 80 00       	mov    $0x8027f4,%eax
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
  800c4e:	68 df 2a 80 00       	push   $0x802adf
  800c53:	6a 23                	push   $0x23
  800c55:	68 fc 2a 80 00       	push   $0x802afc
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
  800ccf:	68 df 2a 80 00       	push   $0x802adf
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 fc 2a 80 00       	push   $0x802afc
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
  800d11:	68 df 2a 80 00       	push   $0x802adf
  800d16:	6a 23                	push   $0x23
  800d18:	68 fc 2a 80 00       	push   $0x802afc
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
  800d53:	68 df 2a 80 00       	push   $0x802adf
  800d58:	6a 23                	push   $0x23
  800d5a:	68 fc 2a 80 00       	push   $0x802afc
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
  800d95:	68 df 2a 80 00       	push   $0x802adf
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 fc 2a 80 00       	push   $0x802afc
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
  800dd7:	68 df 2a 80 00       	push   $0x802adf
  800ddc:	6a 23                	push   $0x23
  800dde:	68 fc 2a 80 00       	push   $0x802afc
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
  800e19:	68 df 2a 80 00       	push   $0x802adf
  800e1e:	6a 23                	push   $0x23
  800e20:	68 fc 2a 80 00       	push   $0x802afc
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
  800e7d:	68 df 2a 80 00       	push   $0x802adf
  800e82:	6a 23                	push   $0x23
  800e84:	68 fc 2a 80 00       	push   $0x802afc
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

00800eb5 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ebd:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ebf:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ec3:	75 25                	jne    800eea <pgfault+0x35>
  800ec5:	89 d8                	mov    %ebx,%eax
  800ec7:	c1 e8 0c             	shr    $0xc,%eax
  800eca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ed1:	f6 c4 08             	test   $0x8,%ah
  800ed4:	75 14                	jne    800eea <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ed6:	83 ec 04             	sub    $0x4,%esp
  800ed9:	68 0c 2b 80 00       	push   $0x802b0c
  800ede:	6a 1e                	push   $0x1e
  800ee0:	68 a0 2b 80 00       	push   $0x802ba0
  800ee5:	e8 5a f3 ff ff       	call   800244 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800eea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ef0:	e8 72 fd ff ff       	call   800c67 <sys_getenvid>
  800ef5:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ef7:	83 ec 04             	sub    $0x4,%esp
  800efa:	6a 07                	push   $0x7
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	50                   	push   %eax
  800f02:	e8 9e fd ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	79 12                	jns    800f20 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f0e:	50                   	push   %eax
  800f0f:	68 38 2b 80 00       	push   $0x802b38
  800f14:	6a 33                	push   $0x33
  800f16:	68 a0 2b 80 00       	push   $0x802ba0
  800f1b:	e8 24 f3 ff ff       	call   800244 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f20:	83 ec 04             	sub    $0x4,%esp
  800f23:	68 00 10 00 00       	push   $0x1000
  800f28:	53                   	push   %ebx
  800f29:	68 00 f0 7f 00       	push   $0x7ff000
  800f2e:	e8 69 fb ff ff       	call   800a9c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f33:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f3a:	53                   	push   %ebx
  800f3b:	56                   	push   %esi
  800f3c:	68 00 f0 7f 00       	push   $0x7ff000
  800f41:	56                   	push   %esi
  800f42:	e8 a1 fd ff ff       	call   800ce8 <sys_page_map>
	if (r < 0)
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 12                	jns    800f60 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f4e:	50                   	push   %eax
  800f4f:	68 5c 2b 80 00       	push   $0x802b5c
  800f54:	6a 3b                	push   $0x3b
  800f56:	68 a0 2b 80 00       	push   $0x802ba0
  800f5b:	e8 e4 f2 ff ff       	call   800244 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	68 00 f0 7f 00       	push   $0x7ff000
  800f68:	56                   	push   %esi
  800f69:	e8 bc fd ff ff       	call   800d2a <sys_page_unmap>
	if (r < 0)
  800f6e:	83 c4 10             	add    $0x10,%esp
  800f71:	85 c0                	test   %eax,%eax
  800f73:	79 12                	jns    800f87 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f75:	50                   	push   %eax
  800f76:	68 80 2b 80 00       	push   $0x802b80
  800f7b:	6a 40                	push   $0x40
  800f7d:	68 a0 2b 80 00       	push   $0x802ba0
  800f82:	e8 bd f2 ff ff       	call   800244 <_panic>
}
  800f87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8a:	5b                   	pop    %ebx
  800f8b:	5e                   	pop    %esi
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	57                   	push   %edi
  800f92:	56                   	push   %esi
  800f93:	53                   	push   %ebx
  800f94:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f97:	68 b5 0e 80 00       	push   $0x800eb5
  800f9c:	e8 17 14 00 00       	call   8023b8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fa1:	b8 07 00 00 00       	mov    $0x7,%eax
  800fa6:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	0f 88 64 01 00 00    	js     801117 <fork+0x189>
  800fb3:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800fb8:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	75 21                	jne    800fe2 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fc1:	e8 a1 fc ff ff       	call   800c67 <sys_getenvid>
  800fc6:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fcb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fd3:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  800fd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdd:	e9 3f 01 00 00       	jmp    801121 <fork+0x193>
  800fe2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fe5:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fe7:	89 d8                	mov    %ebx,%eax
  800fe9:	c1 e8 16             	shr    $0x16,%eax
  800fec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ff3:	a8 01                	test   $0x1,%al
  800ff5:	0f 84 bd 00 00 00    	je     8010b8 <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800ffb:	89 d8                	mov    %ebx,%eax
  800ffd:	c1 e8 0c             	shr    $0xc,%eax
  801000:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801007:	f6 c2 01             	test   $0x1,%dl
  80100a:	0f 84 a8 00 00 00    	je     8010b8 <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801010:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801017:	a8 04                	test   $0x4,%al
  801019:	0f 84 99 00 00 00    	je     8010b8 <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  80101f:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801026:	f6 c4 04             	test   $0x4,%ah
  801029:	74 17                	je     801042 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	68 07 0e 00 00       	push   $0xe07
  801033:	53                   	push   %ebx
  801034:	57                   	push   %edi
  801035:	53                   	push   %ebx
  801036:	6a 00                	push   $0x0
  801038:	e8 ab fc ff ff       	call   800ce8 <sys_page_map>
  80103d:	83 c4 20             	add    $0x20,%esp
  801040:	eb 76                	jmp    8010b8 <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  801042:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801049:	a8 02                	test   $0x2,%al
  80104b:	75 0c                	jne    801059 <fork+0xcb>
  80104d:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801054:	f6 c4 08             	test   $0x8,%ah
  801057:	74 3f                	je     801098 <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801059:	83 ec 0c             	sub    $0xc,%esp
  80105c:	68 05 08 00 00       	push   $0x805
  801061:	53                   	push   %ebx
  801062:	57                   	push   %edi
  801063:	53                   	push   %ebx
  801064:	6a 00                	push   $0x0
  801066:	e8 7d fc ff ff       	call   800ce8 <sys_page_map>
		if (r < 0)
  80106b:	83 c4 20             	add    $0x20,%esp
  80106e:	85 c0                	test   %eax,%eax
  801070:	0f 88 a5 00 00 00    	js     80111b <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801076:	83 ec 0c             	sub    $0xc,%esp
  801079:	68 05 08 00 00       	push   $0x805
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	53                   	push   %ebx
  801082:	6a 00                	push   $0x0
  801084:	e8 5f fc ff ff       	call   800ce8 <sys_page_map>
  801089:	83 c4 20             	add    $0x20,%esp
  80108c:	85 c0                	test   %eax,%eax
  80108e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801093:	0f 4f c1             	cmovg  %ecx,%eax
  801096:	eb 1c                	jmp    8010b4 <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801098:	83 ec 0c             	sub    $0xc,%esp
  80109b:	6a 05                	push   $0x5
  80109d:	53                   	push   %ebx
  80109e:	57                   	push   %edi
  80109f:	53                   	push   %ebx
  8010a0:	6a 00                	push   $0x0
  8010a2:	e8 41 fc ff ff       	call   800ce8 <sys_page_map>
  8010a7:	83 c4 20             	add    $0x20,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010b1:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	78 67                	js     80111f <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  8010b8:	83 c6 01             	add    $0x1,%esi
  8010bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010c1:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8010c7:	0f 85 1a ff ff ff    	jne    800fe7 <fork+0x59>
  8010cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  8010d0:	83 ec 04             	sub    $0x4,%esp
  8010d3:	6a 07                	push   $0x7
  8010d5:	68 00 f0 bf ee       	push   $0xeebff000
  8010da:	57                   	push   %edi
  8010db:	e8 c5 fb ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  8010e0:	83 c4 10             	add    $0x10,%esp
		return r;
  8010e3:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 38                	js     801121 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010e9:	83 ec 08             	sub    $0x8,%esp
  8010ec:	68 ff 23 80 00       	push   $0x8023ff
  8010f1:	57                   	push   %edi
  8010f2:	e8 f9 fc ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8010fa:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	78 21                	js     801121 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801100:	83 ec 08             	sub    $0x8,%esp
  801103:	6a 02                	push   $0x2
  801105:	57                   	push   %edi
  801106:	e8 61 fc ff ff       	call   800d6c <sys_env_set_status>
	if (r < 0)
  80110b:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  80110e:	85 c0                	test   %eax,%eax
  801110:	0f 48 f8             	cmovs  %eax,%edi
  801113:	89 fa                	mov    %edi,%edx
  801115:	eb 0a                	jmp    801121 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  801117:	89 c2                	mov    %eax,%edx
  801119:	eb 06                	jmp    801121 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  80111b:	89 c2                	mov    %eax,%edx
  80111d:	eb 02                	jmp    801121 <fork+0x193>
  80111f:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801121:	89 d0                	mov    %edx,%eax
  801123:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801126:	5b                   	pop    %ebx
  801127:	5e                   	pop    %esi
  801128:	5f                   	pop    %edi
  801129:	5d                   	pop    %ebp
  80112a:	c3                   	ret    

0080112b <sfork>:

// Challenge!
int
sfork(void)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801131:	68 ab 2b 80 00       	push   $0x802bab
  801136:	68 c9 00 00 00       	push   $0xc9
  80113b:	68 a0 2b 80 00       	push   $0x802ba0
  801140:	e8 ff f0 ff ff       	call   800244 <_panic>

00801145 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	56                   	push   %esi
  801149:	53                   	push   %ebx
  80114a:	8b 75 08             	mov    0x8(%ebp),%esi
  80114d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801150:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801153:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801155:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80115a:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	50                   	push   %eax
  801161:	e8 ef fc ff ff       	call   800e55 <sys_ipc_recv>

	if (from_env_store != NULL)
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	85 f6                	test   %esi,%esi
  80116b:	74 14                	je     801181 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  80116d:	ba 00 00 00 00       	mov    $0x0,%edx
  801172:	85 c0                	test   %eax,%eax
  801174:	78 09                	js     80117f <ipc_recv+0x3a>
  801176:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80117c:	8b 52 74             	mov    0x74(%edx),%edx
  80117f:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801181:	85 db                	test   %ebx,%ebx
  801183:	74 14                	je     801199 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801185:	ba 00 00 00 00       	mov    $0x0,%edx
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 09                	js     801197 <ipc_recv+0x52>
  80118e:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801194:	8b 52 78             	mov    0x78(%edx),%edx
  801197:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801199:	85 c0                	test   %eax,%eax
  80119b:	78 08                	js     8011a5 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  80119d:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a2:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011a8:	5b                   	pop    %ebx
  8011a9:	5e                   	pop    %esi
  8011aa:	5d                   	pop    %ebp
  8011ab:	c3                   	ret    

008011ac <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011ac:	55                   	push   %ebp
  8011ad:	89 e5                	mov    %esp,%ebp
  8011af:	57                   	push   %edi
  8011b0:	56                   	push   %esi
  8011b1:	53                   	push   %ebx
  8011b2:	83 ec 0c             	sub    $0xc,%esp
  8011b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8011be:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8011c0:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011c5:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8011c8:	ff 75 14             	pushl  0x14(%ebp)
  8011cb:	53                   	push   %ebx
  8011cc:	56                   	push   %esi
  8011cd:	57                   	push   %edi
  8011ce:	e8 5f fc ff ff       	call   800e32 <sys_ipc_try_send>

		if (err < 0) {
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	79 1e                	jns    8011f8 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8011da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011dd:	75 07                	jne    8011e6 <ipc_send+0x3a>
				sys_yield();
  8011df:	e8 a2 fa ff ff       	call   800c86 <sys_yield>
  8011e4:	eb e2                	jmp    8011c8 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  8011e6:	50                   	push   %eax
  8011e7:	68 c1 2b 80 00       	push   $0x802bc1
  8011ec:	6a 49                	push   $0x49
  8011ee:	68 ce 2b 80 00       	push   $0x802bce
  8011f3:	e8 4c f0 ff ff       	call   800244 <_panic>
		}

	} while (err < 0);

}
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80120b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80120e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801214:	8b 52 50             	mov    0x50(%edx),%edx
  801217:	39 ca                	cmp    %ecx,%edx
  801219:	75 0d                	jne    801228 <ipc_find_env+0x28>
			return envs[i].env_id;
  80121b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80121e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801223:	8b 40 48             	mov    0x48(%eax),%eax
  801226:	eb 0f                	jmp    801237 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801228:	83 c0 01             	add    $0x1,%eax
  80122b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801230:	75 d9                	jne    80120b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801232:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80123c:	8b 45 08             	mov    0x8(%ebp),%eax
  80123f:	05 00 00 00 30       	add    $0x30000000,%eax
  801244:	c1 e8 0c             	shr    $0xc,%eax
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80124c:	8b 45 08             	mov    0x8(%ebp),%eax
  80124f:	05 00 00 00 30       	add    $0x30000000,%eax
  801254:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801259:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80125e:	5d                   	pop    %ebp
  80125f:	c3                   	ret    

00801260 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801266:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80126b:	89 c2                	mov    %eax,%edx
  80126d:	c1 ea 16             	shr    $0x16,%edx
  801270:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801277:	f6 c2 01             	test   $0x1,%dl
  80127a:	74 11                	je     80128d <fd_alloc+0x2d>
  80127c:	89 c2                	mov    %eax,%edx
  80127e:	c1 ea 0c             	shr    $0xc,%edx
  801281:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801288:	f6 c2 01             	test   $0x1,%dl
  80128b:	75 09                	jne    801296 <fd_alloc+0x36>
			*fd_store = fd;
  80128d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80128f:	b8 00 00 00 00       	mov    $0x0,%eax
  801294:	eb 17                	jmp    8012ad <fd_alloc+0x4d>
  801296:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80129b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a0:	75 c9                	jne    80126b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012a8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b5:	83 f8 1f             	cmp    $0x1f,%eax
  8012b8:	77 36                	ja     8012f0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012ba:	c1 e0 0c             	shl    $0xc,%eax
  8012bd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c2:	89 c2                	mov    %eax,%edx
  8012c4:	c1 ea 16             	shr    $0x16,%edx
  8012c7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ce:	f6 c2 01             	test   $0x1,%dl
  8012d1:	74 24                	je     8012f7 <fd_lookup+0x48>
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	c1 ea 0c             	shr    $0xc,%edx
  8012d8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012df:	f6 c2 01             	test   $0x1,%dl
  8012e2:	74 1a                	je     8012fe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e7:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	eb 13                	jmp    801303 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f5:	eb 0c                	jmp    801303 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fc:	eb 05                	jmp    801303 <fd_lookup+0x54>
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130e:	ba 58 2c 80 00       	mov    $0x802c58,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801313:	eb 13                	jmp    801328 <dev_lookup+0x23>
  801315:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801318:	39 08                	cmp    %ecx,(%eax)
  80131a:	75 0c                	jne    801328 <dev_lookup+0x23>
			*dev = devtab[i];
  80131c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80131f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801321:	b8 00 00 00 00       	mov    $0x0,%eax
  801326:	eb 2e                	jmp    801356 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801328:	8b 02                	mov    (%edx),%eax
  80132a:	85 c0                	test   %eax,%eax
  80132c:	75 e7                	jne    801315 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80132e:	a1 08 40 80 00       	mov    0x804008,%eax
  801333:	8b 40 48             	mov    0x48(%eax),%eax
  801336:	83 ec 04             	sub    $0x4,%esp
  801339:	51                   	push   %ecx
  80133a:	50                   	push   %eax
  80133b:	68 d8 2b 80 00       	push   $0x802bd8
  801340:	e8 d8 ef ff ff       	call   80031d <cprintf>
	*dev = 0;
  801345:	8b 45 0c             	mov    0xc(%ebp),%eax
  801348:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801356:	c9                   	leave  
  801357:	c3                   	ret    

00801358 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	56                   	push   %esi
  80135c:	53                   	push   %ebx
  80135d:	83 ec 10             	sub    $0x10,%esp
  801360:	8b 75 08             	mov    0x8(%ebp),%esi
  801363:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801366:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801369:	50                   	push   %eax
  80136a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801370:	c1 e8 0c             	shr    $0xc,%eax
  801373:	50                   	push   %eax
  801374:	e8 36 ff ff ff       	call   8012af <fd_lookup>
  801379:	83 c4 08             	add    $0x8,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 05                	js     801385 <fd_close+0x2d>
	    || fd != fd2)
  801380:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801383:	74 0c                	je     801391 <fd_close+0x39>
		return (must_exist ? r : 0);
  801385:	84 db                	test   %bl,%bl
  801387:	ba 00 00 00 00       	mov    $0x0,%edx
  80138c:	0f 44 c2             	cmove  %edx,%eax
  80138f:	eb 41                	jmp    8013d2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	ff 36                	pushl  (%esi)
  80139a:	e8 66 ff ff ff       	call   801305 <dev_lookup>
  80139f:	89 c3                	mov    %eax,%ebx
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 1a                	js     8013c2 <fd_close+0x6a>
		if (dev->dev_close)
  8013a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013ae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	74 0b                	je     8013c2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013b7:	83 ec 0c             	sub    $0xc,%esp
  8013ba:	56                   	push   %esi
  8013bb:	ff d0                	call   *%eax
  8013bd:	89 c3                	mov    %eax,%ebx
  8013bf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	56                   	push   %esi
  8013c6:	6a 00                	push   $0x0
  8013c8:	e8 5d f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	89 d8                	mov    %ebx,%eax
}
  8013d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5d                   	pop    %ebp
  8013d8:	c3                   	ret    

008013d9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	ff 75 08             	pushl  0x8(%ebp)
  8013e6:	e8 c4 fe ff ff       	call   8012af <fd_lookup>
  8013eb:	83 c4 08             	add    $0x8,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 10                	js     801402 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	ff 75 f4             	pushl  -0xc(%ebp)
  8013fa:	e8 59 ff ff ff       	call   801358 <fd_close>
  8013ff:	83 c4 10             	add    $0x10,%esp
}
  801402:	c9                   	leave  
  801403:	c3                   	ret    

00801404 <close_all>:

void
close_all(void)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	53                   	push   %ebx
  801408:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80140b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801410:	83 ec 0c             	sub    $0xc,%esp
  801413:	53                   	push   %ebx
  801414:	e8 c0 ff ff ff       	call   8013d9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801419:	83 c3 01             	add    $0x1,%ebx
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	83 fb 20             	cmp    $0x20,%ebx
  801422:	75 ec                	jne    801410 <close_all+0xc>
		close(i);
}
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	57                   	push   %edi
  80142d:	56                   	push   %esi
  80142e:	53                   	push   %ebx
  80142f:	83 ec 2c             	sub    $0x2c,%esp
  801432:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801435:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801438:	50                   	push   %eax
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	e8 6e fe ff ff       	call   8012af <fd_lookup>
  801441:	83 c4 08             	add    $0x8,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	0f 88 c1 00 00 00    	js     80150d <dup+0xe4>
		return r;
	close(newfdnum);
  80144c:	83 ec 0c             	sub    $0xc,%esp
  80144f:	56                   	push   %esi
  801450:	e8 84 ff ff ff       	call   8013d9 <close>

	newfd = INDEX2FD(newfdnum);
  801455:	89 f3                	mov    %esi,%ebx
  801457:	c1 e3 0c             	shl    $0xc,%ebx
  80145a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801460:	83 c4 04             	add    $0x4,%esp
  801463:	ff 75 e4             	pushl  -0x1c(%ebp)
  801466:	e8 de fd ff ff       	call   801249 <fd2data>
  80146b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80146d:	89 1c 24             	mov    %ebx,(%esp)
  801470:	e8 d4 fd ff ff       	call   801249 <fd2data>
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80147b:	89 f8                	mov    %edi,%eax
  80147d:	c1 e8 16             	shr    $0x16,%eax
  801480:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801487:	a8 01                	test   $0x1,%al
  801489:	74 37                	je     8014c2 <dup+0x99>
  80148b:	89 f8                	mov    %edi,%eax
  80148d:	c1 e8 0c             	shr    $0xc,%eax
  801490:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801497:	f6 c2 01             	test   $0x1,%dl
  80149a:	74 26                	je     8014c2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80149c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	25 07 0e 00 00       	and    $0xe07,%eax
  8014ab:	50                   	push   %eax
  8014ac:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014af:	6a 00                	push   $0x0
  8014b1:	57                   	push   %edi
  8014b2:	6a 00                	push   $0x0
  8014b4:	e8 2f f8 ff ff       	call   800ce8 <sys_page_map>
  8014b9:	89 c7                	mov    %eax,%edi
  8014bb:	83 c4 20             	add    $0x20,%esp
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 2e                	js     8014f0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014c5:	89 d0                	mov    %edx,%eax
  8014c7:	c1 e8 0c             	shr    $0xc,%eax
  8014ca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d1:	83 ec 0c             	sub    $0xc,%esp
  8014d4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d9:	50                   	push   %eax
  8014da:	53                   	push   %ebx
  8014db:	6a 00                	push   $0x0
  8014dd:	52                   	push   %edx
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 03 f8 ff ff       	call   800ce8 <sys_page_map>
  8014e5:	89 c7                	mov    %eax,%edi
  8014e7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014ea:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ec:	85 ff                	test   %edi,%edi
  8014ee:	79 1d                	jns    80150d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f0:	83 ec 08             	sub    $0x8,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 2f f8 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014fb:	83 c4 08             	add    $0x8,%esp
  8014fe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801501:	6a 00                	push   $0x0
  801503:	e8 22 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	89 f8                	mov    %edi,%eax
}
  80150d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801510:	5b                   	pop    %ebx
  801511:	5e                   	pop    %esi
  801512:	5f                   	pop    %edi
  801513:	5d                   	pop    %ebp
  801514:	c3                   	ret    

00801515 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	53                   	push   %ebx
  801519:	83 ec 14             	sub    $0x14,%esp
  80151c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	53                   	push   %ebx
  801524:	e8 86 fd ff ff       	call   8012af <fd_lookup>
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 6d                	js     80159f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 c2 fd ff ff       	call   801305 <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 4c                	js     801596 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80154a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154d:	8b 42 08             	mov    0x8(%edx),%eax
  801550:	83 e0 03             	and    $0x3,%eax
  801553:	83 f8 01             	cmp    $0x1,%eax
  801556:	75 21                	jne    801579 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801558:	a1 08 40 80 00       	mov    0x804008,%eax
  80155d:	8b 40 48             	mov    0x48(%eax),%eax
  801560:	83 ec 04             	sub    $0x4,%esp
  801563:	53                   	push   %ebx
  801564:	50                   	push   %eax
  801565:	68 1c 2c 80 00       	push   $0x802c1c
  80156a:	e8 ae ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80156f:	83 c4 10             	add    $0x10,%esp
  801572:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801577:	eb 26                	jmp    80159f <read+0x8a>
	}
	if (!dev->dev_read)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	8b 40 08             	mov    0x8(%eax),%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 17                	je     80159a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801583:	83 ec 04             	sub    $0x4,%esp
  801586:	ff 75 10             	pushl  0x10(%ebp)
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	52                   	push   %edx
  80158d:	ff d0                	call   *%eax
  80158f:	89 c2                	mov    %eax,%edx
  801591:	83 c4 10             	add    $0x10,%esp
  801594:	eb 09                	jmp    80159f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801596:	89 c2                	mov    %eax,%edx
  801598:	eb 05                	jmp    80159f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80159a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80159f:	89 d0                	mov    %edx,%eax
  8015a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a4:	c9                   	leave  
  8015a5:	c3                   	ret    

008015a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a6:	55                   	push   %ebp
  8015a7:	89 e5                	mov    %esp,%ebp
  8015a9:	57                   	push   %edi
  8015aa:	56                   	push   %esi
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ba:	eb 21                	jmp    8015dd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bc:	83 ec 04             	sub    $0x4,%esp
  8015bf:	89 f0                	mov    %esi,%eax
  8015c1:	29 d8                	sub    %ebx,%eax
  8015c3:	50                   	push   %eax
  8015c4:	89 d8                	mov    %ebx,%eax
  8015c6:	03 45 0c             	add    0xc(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	57                   	push   %edi
  8015cb:	e8 45 ff ff ff       	call   801515 <read>
		if (m < 0)
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 10                	js     8015e7 <readn+0x41>
			return m;
		if (m == 0)
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	74 0a                	je     8015e5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015db:	01 c3                	add    %eax,%ebx
  8015dd:	39 f3                	cmp    %esi,%ebx
  8015df:	72 db                	jb     8015bc <readn+0x16>
  8015e1:	89 d8                	mov    %ebx,%eax
  8015e3:	eb 02                	jmp    8015e7 <readn+0x41>
  8015e5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	53                   	push   %ebx
  8015f3:	83 ec 14             	sub    $0x14,%esp
  8015f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015fc:	50                   	push   %eax
  8015fd:	53                   	push   %ebx
  8015fe:	e8 ac fc ff ff       	call   8012af <fd_lookup>
  801603:	83 c4 08             	add    $0x8,%esp
  801606:	89 c2                	mov    %eax,%edx
  801608:	85 c0                	test   %eax,%eax
  80160a:	78 68                	js     801674 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801616:	ff 30                	pushl  (%eax)
  801618:	e8 e8 fc ff ff       	call   801305 <dev_lookup>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 47                	js     80166b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801624:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801627:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162b:	75 21                	jne    80164e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80162d:	a1 08 40 80 00       	mov    0x804008,%eax
  801632:	8b 40 48             	mov    0x48(%eax),%eax
  801635:	83 ec 04             	sub    $0x4,%esp
  801638:	53                   	push   %ebx
  801639:	50                   	push   %eax
  80163a:	68 38 2c 80 00       	push   $0x802c38
  80163f:	e8 d9 ec ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80164c:	eb 26                	jmp    801674 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80164e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801651:	8b 52 0c             	mov    0xc(%edx),%edx
  801654:	85 d2                	test   %edx,%edx
  801656:	74 17                	je     80166f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801658:	83 ec 04             	sub    $0x4,%esp
  80165b:	ff 75 10             	pushl  0x10(%ebp)
  80165e:	ff 75 0c             	pushl  0xc(%ebp)
  801661:	50                   	push   %eax
  801662:	ff d2                	call   *%edx
  801664:	89 c2                	mov    %eax,%edx
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 09                	jmp    801674 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166b:	89 c2                	mov    %eax,%edx
  80166d:	eb 05                	jmp    801674 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80166f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801674:	89 d0                	mov    %edx,%eax
  801676:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801679:	c9                   	leave  
  80167a:	c3                   	ret    

0080167b <seek>:

int
seek(int fdnum, off_t offset)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801681:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801684:	50                   	push   %eax
  801685:	ff 75 08             	pushl  0x8(%ebp)
  801688:	e8 22 fc ff ff       	call   8012af <fd_lookup>
  80168d:	83 c4 08             	add    $0x8,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	78 0e                	js     8016a2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801694:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801697:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 14             	sub    $0x14,%esp
  8016ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	53                   	push   %ebx
  8016b3:	e8 f7 fb ff ff       	call   8012af <fd_lookup>
  8016b8:	83 c4 08             	add    $0x8,%esp
  8016bb:	89 c2                	mov    %eax,%edx
  8016bd:	85 c0                	test   %eax,%eax
  8016bf:	78 65                	js     801726 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c1:	83 ec 08             	sub    $0x8,%esp
  8016c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cb:	ff 30                	pushl  (%eax)
  8016cd:	e8 33 fc ff ff       	call   801305 <dev_lookup>
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	78 44                	js     80171d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e0:	75 21                	jne    801703 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e2:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016e7:	8b 40 48             	mov    0x48(%eax),%eax
  8016ea:	83 ec 04             	sub    $0x4,%esp
  8016ed:	53                   	push   %ebx
  8016ee:	50                   	push   %eax
  8016ef:	68 f8 2b 80 00       	push   $0x802bf8
  8016f4:	e8 24 ec ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801701:	eb 23                	jmp    801726 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801703:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801706:	8b 52 18             	mov    0x18(%edx),%edx
  801709:	85 d2                	test   %edx,%edx
  80170b:	74 14                	je     801721 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80170d:	83 ec 08             	sub    $0x8,%esp
  801710:	ff 75 0c             	pushl  0xc(%ebp)
  801713:	50                   	push   %eax
  801714:	ff d2                	call   *%edx
  801716:	89 c2                	mov    %eax,%edx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	eb 09                	jmp    801726 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	eb 05                	jmp    801726 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801721:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801726:	89 d0                	mov    %edx,%eax
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	53                   	push   %ebx
  801731:	83 ec 14             	sub    $0x14,%esp
  801734:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801737:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173a:	50                   	push   %eax
  80173b:	ff 75 08             	pushl  0x8(%ebp)
  80173e:	e8 6c fb ff ff       	call   8012af <fd_lookup>
  801743:	83 c4 08             	add    $0x8,%esp
  801746:	89 c2                	mov    %eax,%edx
  801748:	85 c0                	test   %eax,%eax
  80174a:	78 58                	js     8017a4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174c:	83 ec 08             	sub    $0x8,%esp
  80174f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801756:	ff 30                	pushl  (%eax)
  801758:	e8 a8 fb ff ff       	call   801305 <dev_lookup>
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 37                	js     80179b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801764:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801767:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176b:	74 32                	je     80179f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80176d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801770:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801777:	00 00 00 
	stat->st_isdir = 0;
  80177a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801781:	00 00 00 
	stat->st_dev = dev;
  801784:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178a:	83 ec 08             	sub    $0x8,%esp
  80178d:	53                   	push   %ebx
  80178e:	ff 75 f0             	pushl  -0x10(%ebp)
  801791:	ff 50 14             	call   *0x14(%eax)
  801794:	89 c2                	mov    %eax,%edx
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	eb 09                	jmp    8017a4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179b:	89 c2                	mov    %eax,%edx
  80179d:	eb 05                	jmp    8017a4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80179f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a4:	89 d0                	mov    %edx,%eax
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    

008017ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	56                   	push   %esi
  8017af:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b0:	83 ec 08             	sub    $0x8,%esp
  8017b3:	6a 00                	push   $0x0
  8017b5:	ff 75 08             	pushl  0x8(%ebp)
  8017b8:	e8 d6 01 00 00       	call   801993 <open>
  8017bd:	89 c3                	mov    %eax,%ebx
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 1b                	js     8017e1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	ff 75 0c             	pushl  0xc(%ebp)
  8017cc:	50                   	push   %eax
  8017cd:	e8 5b ff ff ff       	call   80172d <fstat>
  8017d2:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d4:	89 1c 24             	mov    %ebx,(%esp)
  8017d7:	e8 fd fb ff ff       	call   8013d9 <close>
	return r;
  8017dc:	83 c4 10             	add    $0x10,%esp
  8017df:	89 f0                	mov    %esi,%eax
}
  8017e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e4:	5b                   	pop    %ebx
  8017e5:	5e                   	pop    %esi
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	56                   	push   %esi
  8017ec:	53                   	push   %ebx
  8017ed:	89 c6                	mov    %eax,%esi
  8017ef:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017f8:	75 12                	jne    80180c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fa:	83 ec 0c             	sub    $0xc,%esp
  8017fd:	6a 01                	push   $0x1
  8017ff:	e8 fc f9 ff ff       	call   801200 <ipc_find_env>
  801804:	a3 00 40 80 00       	mov    %eax,0x804000
  801809:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80180c:	6a 07                	push   $0x7
  80180e:	68 00 50 80 00       	push   $0x805000
  801813:	56                   	push   %esi
  801814:	ff 35 00 40 80 00    	pushl  0x804000
  80181a:	e8 8d f9 ff ff       	call   8011ac <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80181f:	83 c4 0c             	add    $0xc,%esp
  801822:	6a 00                	push   $0x0
  801824:	53                   	push   %ebx
  801825:	6a 00                	push   $0x0
  801827:	e8 19 f9 ff ff       	call   801145 <ipc_recv>
}
  80182c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182f:	5b                   	pop    %ebx
  801830:	5e                   	pop    %esi
  801831:	5d                   	pop    %ebp
  801832:	c3                   	ret    

00801833 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801839:	8b 45 08             	mov    0x8(%ebp),%eax
  80183c:	8b 40 0c             	mov    0xc(%eax),%eax
  80183f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801844:	8b 45 0c             	mov    0xc(%ebp),%eax
  801847:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	b8 02 00 00 00       	mov    $0x2,%eax
  801856:	e8 8d ff ff ff       	call   8017e8 <fsipc>
}
  80185b:	c9                   	leave  
  80185c:	c3                   	ret    

0080185d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80185d:	55                   	push   %ebp
  80185e:	89 e5                	mov    %esp,%ebp
  801860:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 40 0c             	mov    0xc(%eax),%eax
  801869:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80186e:	ba 00 00 00 00       	mov    $0x0,%edx
  801873:	b8 06 00 00 00       	mov    $0x6,%eax
  801878:	e8 6b ff ff ff       	call   8017e8 <fsipc>
}
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    

0080187f <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	53                   	push   %ebx
  801883:	83 ec 04             	sub    $0x4,%esp
  801886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801889:	8b 45 08             	mov    0x8(%ebp),%eax
  80188c:	8b 40 0c             	mov    0xc(%eax),%eax
  80188f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801894:	ba 00 00 00 00       	mov    $0x0,%edx
  801899:	b8 05 00 00 00       	mov    $0x5,%eax
  80189e:	e8 45 ff ff ff       	call   8017e8 <fsipc>
  8018a3:	85 c0                	test   %eax,%eax
  8018a5:	78 2c                	js     8018d3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018a7:	83 ec 08             	sub    $0x8,%esp
  8018aa:	68 00 50 80 00       	push   $0x805000
  8018af:	53                   	push   %ebx
  8018b0:	e8 ed ef ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e4:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e7:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ed:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018f2:	50                   	push   %eax
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	68 08 50 80 00       	push   $0x805008
  8018fb:	e8 34 f1 ff ff       	call   800a34 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801900:	ba 00 00 00 00       	mov    $0x0,%edx
  801905:	b8 04 00 00 00       	mov    $0x4,%eax
  80190a:	e8 d9 fe ff ff       	call   8017e8 <fsipc>

}
  80190f:	c9                   	leave  
  801910:	c3                   	ret    

00801911 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	56                   	push   %esi
  801915:	53                   	push   %ebx
  801916:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801919:	8b 45 08             	mov    0x8(%ebp),%eax
  80191c:	8b 40 0c             	mov    0xc(%eax),%eax
  80191f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801924:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192a:	ba 00 00 00 00       	mov    $0x0,%edx
  80192f:	b8 03 00 00 00       	mov    $0x3,%eax
  801934:	e8 af fe ff ff       	call   8017e8 <fsipc>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 4b                	js     80198a <devfile_read+0x79>
		return r;
	assert(r <= n);
  80193f:	39 c6                	cmp    %eax,%esi
  801941:	73 16                	jae    801959 <devfile_read+0x48>
  801943:	68 6c 2c 80 00       	push   $0x802c6c
  801948:	68 73 2c 80 00       	push   $0x802c73
  80194d:	6a 7c                	push   $0x7c
  80194f:	68 88 2c 80 00       	push   $0x802c88
  801954:	e8 eb e8 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801959:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80195e:	7e 16                	jle    801976 <devfile_read+0x65>
  801960:	68 93 2c 80 00       	push   $0x802c93
  801965:	68 73 2c 80 00       	push   $0x802c73
  80196a:	6a 7d                	push   $0x7d
  80196c:	68 88 2c 80 00       	push   $0x802c88
  801971:	e8 ce e8 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	50                   	push   %eax
  80197a:	68 00 50 80 00       	push   $0x805000
  80197f:	ff 75 0c             	pushl  0xc(%ebp)
  801982:	e8 ad f0 ff ff       	call   800a34 <memmove>
	return r;
  801987:	83 c4 10             	add    $0x10,%esp
}
  80198a:	89 d8                	mov    %ebx,%eax
  80198c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198f:	5b                   	pop    %ebx
  801990:	5e                   	pop    %esi
  801991:	5d                   	pop    %ebp
  801992:	c3                   	ret    

00801993 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801993:	55                   	push   %ebp
  801994:	89 e5                	mov    %esp,%ebp
  801996:	53                   	push   %ebx
  801997:	83 ec 20             	sub    $0x20,%esp
  80199a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80199d:	53                   	push   %ebx
  80199e:	e8 c6 ee ff ff       	call   800869 <strlen>
  8019a3:	83 c4 10             	add    $0x10,%esp
  8019a6:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019ab:	7f 67                	jg     801a14 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b3:	50                   	push   %eax
  8019b4:	e8 a7 f8 ff ff       	call   801260 <fd_alloc>
  8019b9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019bc:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019be:	85 c0                	test   %eax,%eax
  8019c0:	78 57                	js     801a19 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	68 00 50 80 00       	push   $0x805000
  8019cb:	e8 d2 ee ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	b8 01 00 00 00       	mov    $0x1,%eax
  8019e0:	e8 03 fe ff ff       	call   8017e8 <fsipc>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	79 14                	jns    801a02 <open+0x6f>
		fd_close(fd, 0);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	6a 00                	push   $0x0
  8019f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f6:	e8 5d f9 ff ff       	call   801358 <fd_close>
		return r;
  8019fb:	83 c4 10             	add    $0x10,%esp
  8019fe:	89 da                	mov    %ebx,%edx
  801a00:	eb 17                	jmp    801a19 <open+0x86>
	}

	return fd2num(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 f4             	pushl  -0xc(%ebp)
  801a08:	e8 2c f8 ff ff       	call   801239 <fd2num>
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	eb 05                	jmp    801a19 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a14:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a19:	89 d0                	mov    %edx,%eax
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a26:	ba 00 00 00 00       	mov    $0x0,%edx
  801a2b:	b8 08 00 00 00       	mov    $0x8,%eax
  801a30:	e8 b3 fd ff ff       	call   8017e8 <fsipc>
}
  801a35:	c9                   	leave  
  801a36:	c3                   	ret    

00801a37 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a37:	55                   	push   %ebp
  801a38:	89 e5                	mov    %esp,%ebp
  801a3a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a3d:	89 d0                	mov    %edx,%eax
  801a3f:	c1 e8 16             	shr    $0x16,%eax
  801a42:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801a49:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a4e:	f6 c1 01             	test   $0x1,%cl
  801a51:	74 1d                	je     801a70 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801a53:	c1 ea 0c             	shr    $0xc,%edx
  801a56:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801a5d:	f6 c2 01             	test   $0x1,%dl
  801a60:	74 0e                	je     801a70 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801a62:	c1 ea 0c             	shr    $0xc,%edx
  801a65:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801a6c:	ef 
  801a6d:	0f b7 c0             	movzwl %ax,%eax
}
  801a70:	5d                   	pop    %ebp
  801a71:	c3                   	ret    

00801a72 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a78:	68 9f 2c 80 00       	push   $0x802c9f
  801a7d:	ff 75 0c             	pushl  0xc(%ebp)
  801a80:	e8 1d ee ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801a85:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8a:	c9                   	leave  
  801a8b:	c3                   	ret    

00801a8c <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a8c:	55                   	push   %ebp
  801a8d:	89 e5                	mov    %esp,%ebp
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 10             	sub    $0x10,%esp
  801a93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a96:	53                   	push   %ebx
  801a97:	e8 9b ff ff ff       	call   801a37 <pageref>
  801a9c:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801a9f:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801aa4:	83 f8 01             	cmp    $0x1,%eax
  801aa7:	75 10                	jne    801ab9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	ff 73 0c             	pushl  0xc(%ebx)
  801aaf:	e8 c0 02 00 00       	call   801d74 <nsipc_close>
  801ab4:	89 c2                	mov    %eax,%edx
  801ab6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ab9:	89 d0                	mov    %edx,%eax
  801abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abe:	c9                   	leave  
  801abf:	c3                   	ret    

00801ac0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ac0:	55                   	push   %ebp
  801ac1:	89 e5                	mov    %esp,%ebp
  801ac3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ac6:	6a 00                	push   $0x0
  801ac8:	ff 75 10             	pushl  0x10(%ebp)
  801acb:	ff 75 0c             	pushl  0xc(%ebp)
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	ff 70 0c             	pushl  0xc(%eax)
  801ad4:	e8 78 03 00 00       	call   801e51 <nsipc_send>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801ae1:	6a 00                	push   $0x0
  801ae3:	ff 75 10             	pushl  0x10(%ebp)
  801ae6:	ff 75 0c             	pushl  0xc(%ebp)
  801ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  801aec:	ff 70 0c             	pushl  0xc(%eax)
  801aef:	e8 f1 02 00 00       	call   801de5 <nsipc_recv>
}
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801afc:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aff:	52                   	push   %edx
  801b00:	50                   	push   %eax
  801b01:	e8 a9 f7 ff ff       	call   8012af <fd_lookup>
  801b06:	83 c4 10             	add    $0x10,%esp
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 17                	js     801b24 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b10:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801b16:	39 08                	cmp    %ecx,(%eax)
  801b18:	75 05                	jne    801b1f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b1a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b1d:	eb 05                	jmp    801b24 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801b1f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801b24:	c9                   	leave  
  801b25:	c3                   	ret    

00801b26 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 1c             	sub    $0x1c,%esp
  801b2e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801b30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b33:	50                   	push   %eax
  801b34:	e8 27 f7 ff ff       	call   801260 <fd_alloc>
  801b39:	89 c3                	mov    %eax,%ebx
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 1b                	js     801b5d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	68 07 04 00 00       	push   $0x407
  801b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 51 f1 ff ff       	call   800ca5 <sys_page_alloc>
  801b54:	89 c3                	mov    %eax,%ebx
  801b56:	83 c4 10             	add    $0x10,%esp
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	79 10                	jns    801b6d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801b5d:	83 ec 0c             	sub    $0xc,%esp
  801b60:	56                   	push   %esi
  801b61:	e8 0e 02 00 00       	call   801d74 <nsipc_close>
		return r;
  801b66:	83 c4 10             	add    $0x10,%esp
  801b69:	89 d8                	mov    %ebx,%eax
  801b6b:	eb 24                	jmp    801b91 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b6d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b7b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b82:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b85:	83 ec 0c             	sub    $0xc,%esp
  801b88:	50                   	push   %eax
  801b89:	e8 ab f6 ff ff       	call   801239 <fd2num>
  801b8e:	83 c4 10             	add    $0x10,%esp
}
  801b91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b94:	5b                   	pop    %ebx
  801b95:	5e                   	pop    %esi
  801b96:	5d                   	pop    %ebp
  801b97:	c3                   	ret    

00801b98 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	e8 50 ff ff ff       	call   801af6 <fd2sockid>
		return r;
  801ba6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ba8:	85 c0                	test   %eax,%eax
  801baa:	78 1f                	js     801bcb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bac:	83 ec 04             	sub    $0x4,%esp
  801baf:	ff 75 10             	pushl  0x10(%ebp)
  801bb2:	ff 75 0c             	pushl  0xc(%ebp)
  801bb5:	50                   	push   %eax
  801bb6:	e8 12 01 00 00       	call   801ccd <nsipc_accept>
  801bbb:	83 c4 10             	add    $0x10,%esp
		return r;
  801bbe:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bc0:	85 c0                	test   %eax,%eax
  801bc2:	78 07                	js     801bcb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801bc4:	e8 5d ff ff ff       	call   801b26 <alloc_sockfd>
  801bc9:	89 c1                	mov    %eax,%ecx
}
  801bcb:	89 c8                	mov    %ecx,%eax
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	e8 19 ff ff ff       	call   801af6 <fd2sockid>
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	78 12                	js     801bf3 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801be1:	83 ec 04             	sub    $0x4,%esp
  801be4:	ff 75 10             	pushl  0x10(%ebp)
  801be7:	ff 75 0c             	pushl  0xc(%ebp)
  801bea:	50                   	push   %eax
  801beb:	e8 2d 01 00 00       	call   801d1d <nsipc_bind>
  801bf0:	83 c4 10             	add    $0x10,%esp
}
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <shutdown>:

int
shutdown(int s, int how)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfe:	e8 f3 fe ff ff       	call   801af6 <fd2sockid>
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 0f                	js     801c16 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801c07:	83 ec 08             	sub    $0x8,%esp
  801c0a:	ff 75 0c             	pushl  0xc(%ebp)
  801c0d:	50                   	push   %eax
  801c0e:	e8 3f 01 00 00       	call   801d52 <nsipc_shutdown>
  801c13:	83 c4 10             	add    $0x10,%esp
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	e8 d0 fe ff ff       	call   801af6 <fd2sockid>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 12                	js     801c3c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801c2a:	83 ec 04             	sub    $0x4,%esp
  801c2d:	ff 75 10             	pushl  0x10(%ebp)
  801c30:	ff 75 0c             	pushl  0xc(%ebp)
  801c33:	50                   	push   %eax
  801c34:	e8 55 01 00 00       	call   801d8e <nsipc_connect>
  801c39:	83 c4 10             	add    $0x10,%esp
}
  801c3c:	c9                   	leave  
  801c3d:	c3                   	ret    

00801c3e <listen>:

int
listen(int s, int backlog)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	e8 aa fe ff ff       	call   801af6 <fd2sockid>
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 0f                	js     801c5f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	ff 75 0c             	pushl  0xc(%ebp)
  801c56:	50                   	push   %eax
  801c57:	e8 67 01 00 00       	call   801dc3 <nsipc_listen>
  801c5c:	83 c4 10             	add    $0x10,%esp
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c67:	ff 75 10             	pushl  0x10(%ebp)
  801c6a:	ff 75 0c             	pushl  0xc(%ebp)
  801c6d:	ff 75 08             	pushl  0x8(%ebp)
  801c70:	e8 3a 02 00 00       	call   801eaf <nsipc_socket>
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	85 c0                	test   %eax,%eax
  801c7a:	78 05                	js     801c81 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c7c:	e8 a5 fe ff ff       	call   801b26 <alloc_sockfd>
}
  801c81:	c9                   	leave  
  801c82:	c3                   	ret    

00801c83 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	83 ec 04             	sub    $0x4,%esp
  801c8a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c8c:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c93:	75 12                	jne    801ca7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c95:	83 ec 0c             	sub    $0xc,%esp
  801c98:	6a 02                	push   $0x2
  801c9a:	e8 61 f5 ff ff       	call   801200 <ipc_find_env>
  801c9f:	a3 04 40 80 00       	mov    %eax,0x804004
  801ca4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ca7:	6a 07                	push   $0x7
  801ca9:	68 00 60 80 00       	push   $0x806000
  801cae:	53                   	push   %ebx
  801caf:	ff 35 04 40 80 00    	pushl  0x804004
  801cb5:	e8 f2 f4 ff ff       	call   8011ac <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cba:	83 c4 0c             	add    $0xc,%esp
  801cbd:	6a 00                	push   $0x0
  801cbf:	6a 00                	push   $0x0
  801cc1:	6a 00                	push   $0x0
  801cc3:	e8 7d f4 ff ff       	call   801145 <ipc_recv>
}
  801cc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801cdd:	8b 06                	mov    (%esi),%eax
  801cdf:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ce4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce9:	e8 95 ff ff ff       	call   801c83 <nsipc>
  801cee:	89 c3                	mov    %eax,%ebx
  801cf0:	85 c0                	test   %eax,%eax
  801cf2:	78 20                	js     801d14 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801cf4:	83 ec 04             	sub    $0x4,%esp
  801cf7:	ff 35 10 60 80 00    	pushl  0x806010
  801cfd:	68 00 60 80 00       	push   $0x806000
  801d02:	ff 75 0c             	pushl  0xc(%ebp)
  801d05:	e8 2a ed ff ff       	call   800a34 <memmove>
		*addrlen = ret->ret_addrlen;
  801d0a:	a1 10 60 80 00       	mov    0x806010,%eax
  801d0f:	89 06                	mov    %eax,(%esi)
  801d11:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801d14:	89 d8                	mov    %ebx,%eax
  801d16:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d19:	5b                   	pop    %ebx
  801d1a:	5e                   	pop    %esi
  801d1b:	5d                   	pop    %ebp
  801d1c:	c3                   	ret    

00801d1d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	53                   	push   %ebx
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d2f:	53                   	push   %ebx
  801d30:	ff 75 0c             	pushl  0xc(%ebp)
  801d33:	68 04 60 80 00       	push   $0x806004
  801d38:	e8 f7 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d3d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801d43:	b8 02 00 00 00       	mov    $0x2,%eax
  801d48:	e8 36 ff ff ff       	call   801c83 <nsipc>
}
  801d4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d68:	b8 03 00 00 00       	mov    $0x3,%eax
  801d6d:	e8 11 ff ff ff       	call   801c83 <nsipc>
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <nsipc_close>:

int
nsipc_close(int s)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d82:	b8 04 00 00 00       	mov    $0x4,%eax
  801d87:	e8 f7 fe ff ff       	call   801c83 <nsipc>
}
  801d8c:	c9                   	leave  
  801d8d:	c3                   	ret    

00801d8e <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	53                   	push   %ebx
  801d92:	83 ec 08             	sub    $0x8,%esp
  801d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da0:	53                   	push   %ebx
  801da1:	ff 75 0c             	pushl  0xc(%ebp)
  801da4:	68 04 60 80 00       	push   $0x806004
  801da9:	e8 86 ec ff ff       	call   800a34 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dae:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801db4:	b8 05 00 00 00       	mov    $0x5,%eax
  801db9:	e8 c5 fe ff ff       	call   801c83 <nsipc>
}
  801dbe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd4:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801dd9:	b8 06 00 00 00       	mov    $0x6,%eax
  801dde:	e8 a0 fe ff ff       	call   801c83 <nsipc>
}
  801de3:	c9                   	leave  
  801de4:	c3                   	ret    

00801de5 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	56                   	push   %esi
  801de9:	53                   	push   %ebx
  801dea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801df5:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfe:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e03:	b8 07 00 00 00       	mov    $0x7,%eax
  801e08:	e8 76 fe ff ff       	call   801c83 <nsipc>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 35                	js     801e48 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801e13:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e18:	7f 04                	jg     801e1e <nsipc_recv+0x39>
  801e1a:	39 c6                	cmp    %eax,%esi
  801e1c:	7d 16                	jge    801e34 <nsipc_recv+0x4f>
  801e1e:	68 ab 2c 80 00       	push   $0x802cab
  801e23:	68 73 2c 80 00       	push   $0x802c73
  801e28:	6a 62                	push   $0x62
  801e2a:	68 c0 2c 80 00       	push   $0x802cc0
  801e2f:	e8 10 e4 ff ff       	call   800244 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e34:	83 ec 04             	sub    $0x4,%esp
  801e37:	50                   	push   %eax
  801e38:	68 00 60 80 00       	push   $0x806000
  801e3d:	ff 75 0c             	pushl  0xc(%ebp)
  801e40:	e8 ef eb ff ff       	call   800a34 <memmove>
  801e45:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	83 ec 04             	sub    $0x4,%esp
  801e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e63:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e69:	7e 16                	jle    801e81 <nsipc_send+0x30>
  801e6b:	68 cc 2c 80 00       	push   $0x802ccc
  801e70:	68 73 2c 80 00       	push   $0x802c73
  801e75:	6a 6d                	push   $0x6d
  801e77:	68 c0 2c 80 00       	push   $0x802cc0
  801e7c:	e8 c3 e3 ff ff       	call   800244 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e81:	83 ec 04             	sub    $0x4,%esp
  801e84:	53                   	push   %ebx
  801e85:	ff 75 0c             	pushl  0xc(%ebp)
  801e88:	68 0c 60 80 00       	push   $0x80600c
  801e8d:	e8 a2 eb ff ff       	call   800a34 <memmove>
	nsipcbuf.send.req_size = size;
  801e92:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e98:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9b:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea0:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea5:	e8 d9 fd ff ff       	call   801c83 <nsipc>
}
  801eaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ead:	c9                   	leave  
  801eae:	c3                   	ret    

00801eaf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801eaf:	55                   	push   %ebp
  801eb0:	89 e5                	mov    %esp,%ebp
  801eb2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  801eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ec5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ec8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ecd:	b8 09 00 00 00       	mov    $0x9,%eax
  801ed2:	e8 ac fd ff ff       	call   801c83 <nsipc>
}
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ee1:	83 ec 0c             	sub    $0xc,%esp
  801ee4:	ff 75 08             	pushl  0x8(%ebp)
  801ee7:	e8 5d f3 ff ff       	call   801249 <fd2data>
  801eec:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eee:	83 c4 08             	add    $0x8,%esp
  801ef1:	68 d8 2c 80 00       	push   $0x802cd8
  801ef6:	53                   	push   %ebx
  801ef7:	e8 a6 e9 ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801efc:	8b 46 04             	mov    0x4(%esi),%eax
  801eff:	2b 06                	sub    (%esi),%eax
  801f01:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f07:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f0e:	00 00 00 
	stat->st_dev = &devpipe;
  801f11:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801f18:	30 80 00 
	return 0;
}
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    

00801f27 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f27:	55                   	push   %ebp
  801f28:	89 e5                	mov    %esp,%ebp
  801f2a:	53                   	push   %ebx
  801f2b:	83 ec 0c             	sub    $0xc,%esp
  801f2e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f31:	53                   	push   %ebx
  801f32:	6a 00                	push   $0x0
  801f34:	e8 f1 ed ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f39:	89 1c 24             	mov    %ebx,(%esp)
  801f3c:	e8 08 f3 ff ff       	call   801249 <fd2data>
  801f41:	83 c4 08             	add    $0x8,%esp
  801f44:	50                   	push   %eax
  801f45:	6a 00                	push   $0x0
  801f47:	e8 de ed ff ff       	call   800d2a <sys_page_unmap>
}
  801f4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f4f:	c9                   	leave  
  801f50:	c3                   	ret    

00801f51 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	57                   	push   %edi
  801f55:	56                   	push   %esi
  801f56:	53                   	push   %ebx
  801f57:	83 ec 1c             	sub    $0x1c,%esp
  801f5a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801f5d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801f5f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f64:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	ff 75 e0             	pushl  -0x20(%ebp)
  801f6d:	e8 c5 fa ff ff       	call   801a37 <pageref>
  801f72:	89 c3                	mov    %eax,%ebx
  801f74:	89 3c 24             	mov    %edi,(%esp)
  801f77:	e8 bb fa ff ff       	call   801a37 <pageref>
  801f7c:	83 c4 10             	add    $0x10,%esp
  801f7f:	39 c3                	cmp    %eax,%ebx
  801f81:	0f 94 c1             	sete   %cl
  801f84:	0f b6 c9             	movzbl %cl,%ecx
  801f87:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801f8a:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801f90:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f93:	39 ce                	cmp    %ecx,%esi
  801f95:	74 1b                	je     801fb2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801f97:	39 c3                	cmp    %eax,%ebx
  801f99:	75 c4                	jne    801f5f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f9b:	8b 42 58             	mov    0x58(%edx),%eax
  801f9e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801fa1:	50                   	push   %eax
  801fa2:	56                   	push   %esi
  801fa3:	68 df 2c 80 00       	push   $0x802cdf
  801fa8:	e8 70 e3 ff ff       	call   80031d <cprintf>
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	eb ad                	jmp    801f5f <_pipeisclosed+0xe>
	}
}
  801fb2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    

00801fbd <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801fbd:	55                   	push   %ebp
  801fbe:	89 e5                	mov    %esp,%ebp
  801fc0:	57                   	push   %edi
  801fc1:	56                   	push   %esi
  801fc2:	53                   	push   %ebx
  801fc3:	83 ec 28             	sub    $0x28,%esp
  801fc6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801fc9:	56                   	push   %esi
  801fca:	e8 7a f2 ff ff       	call   801249 <fd2data>
  801fcf:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fd1:	83 c4 10             	add    $0x10,%esp
  801fd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801fd9:	eb 4b                	jmp    802026 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801fdb:	89 da                	mov    %ebx,%edx
  801fdd:	89 f0                	mov    %esi,%eax
  801fdf:	e8 6d ff ff ff       	call   801f51 <_pipeisclosed>
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	75 48                	jne    802030 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801fe8:	e8 99 ec ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fed:	8b 43 04             	mov    0x4(%ebx),%eax
  801ff0:	8b 0b                	mov    (%ebx),%ecx
  801ff2:	8d 51 20             	lea    0x20(%ecx),%edx
  801ff5:	39 d0                	cmp    %edx,%eax
  801ff7:	73 e2                	jae    801fdb <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ff9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802000:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802003:	89 c2                	mov    %eax,%edx
  802005:	c1 fa 1f             	sar    $0x1f,%edx
  802008:	89 d1                	mov    %edx,%ecx
  80200a:	c1 e9 1b             	shr    $0x1b,%ecx
  80200d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802010:	83 e2 1f             	and    $0x1f,%edx
  802013:	29 ca                	sub    %ecx,%edx
  802015:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802019:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80201d:	83 c0 01             	add    $0x1,%eax
  802020:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802023:	83 c7 01             	add    $0x1,%edi
  802026:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802029:	75 c2                	jne    801fed <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80202b:	8b 45 10             	mov    0x10(%ebp),%eax
  80202e:	eb 05                	jmp    802035 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802030:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802035:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802038:	5b                   	pop    %ebx
  802039:	5e                   	pop    %esi
  80203a:	5f                   	pop    %edi
  80203b:	5d                   	pop    %ebp
  80203c:	c3                   	ret    

0080203d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80203d:	55                   	push   %ebp
  80203e:	89 e5                	mov    %esp,%ebp
  802040:	57                   	push   %edi
  802041:	56                   	push   %esi
  802042:	53                   	push   %ebx
  802043:	83 ec 18             	sub    $0x18,%esp
  802046:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802049:	57                   	push   %edi
  80204a:	e8 fa f1 ff ff       	call   801249 <fd2data>
  80204f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802051:	83 c4 10             	add    $0x10,%esp
  802054:	bb 00 00 00 00       	mov    $0x0,%ebx
  802059:	eb 3d                	jmp    802098 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80205b:	85 db                	test   %ebx,%ebx
  80205d:	74 04                	je     802063 <devpipe_read+0x26>
				return i;
  80205f:	89 d8                	mov    %ebx,%eax
  802061:	eb 44                	jmp    8020a7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802063:	89 f2                	mov    %esi,%edx
  802065:	89 f8                	mov    %edi,%eax
  802067:	e8 e5 fe ff ff       	call   801f51 <_pipeisclosed>
  80206c:	85 c0                	test   %eax,%eax
  80206e:	75 32                	jne    8020a2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802070:	e8 11 ec ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802075:	8b 06                	mov    (%esi),%eax
  802077:	3b 46 04             	cmp    0x4(%esi),%eax
  80207a:	74 df                	je     80205b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80207c:	99                   	cltd   
  80207d:	c1 ea 1b             	shr    $0x1b,%edx
  802080:	01 d0                	add    %edx,%eax
  802082:	83 e0 1f             	and    $0x1f,%eax
  802085:	29 d0                	sub    %edx,%eax
  802087:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80208c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80208f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802092:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802095:	83 c3 01             	add    $0x1,%ebx
  802098:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80209b:	75 d8                	jne    802075 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80209d:	8b 45 10             	mov    0x10(%ebp),%eax
  8020a0:	eb 05                	jmp    8020a7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020a2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8020a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020aa:	5b                   	pop    %ebx
  8020ab:	5e                   	pop    %esi
  8020ac:	5f                   	pop    %edi
  8020ad:	5d                   	pop    %ebp
  8020ae:	c3                   	ret    

008020af <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	56                   	push   %esi
  8020b3:	53                   	push   %ebx
  8020b4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8020b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ba:	50                   	push   %eax
  8020bb:	e8 a0 f1 ff ff       	call   801260 <fd_alloc>
  8020c0:	83 c4 10             	add    $0x10,%esp
  8020c3:	89 c2                	mov    %eax,%edx
  8020c5:	85 c0                	test   %eax,%eax
  8020c7:	0f 88 2c 01 00 00    	js     8021f9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020cd:	83 ec 04             	sub    $0x4,%esp
  8020d0:	68 07 04 00 00       	push   $0x407
  8020d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020d8:	6a 00                	push   $0x0
  8020da:	e8 c6 eb ff ff       	call   800ca5 <sys_page_alloc>
  8020df:	83 c4 10             	add    $0x10,%esp
  8020e2:	89 c2                	mov    %eax,%edx
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	0f 88 0d 01 00 00    	js     8021f9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8020ec:	83 ec 0c             	sub    $0xc,%esp
  8020ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020f2:	50                   	push   %eax
  8020f3:	e8 68 f1 ff ff       	call   801260 <fd_alloc>
  8020f8:	89 c3                	mov    %eax,%ebx
  8020fa:	83 c4 10             	add    $0x10,%esp
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	0f 88 e2 00 00 00    	js     8021e7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802105:	83 ec 04             	sub    $0x4,%esp
  802108:	68 07 04 00 00       	push   $0x407
  80210d:	ff 75 f0             	pushl  -0x10(%ebp)
  802110:	6a 00                	push   $0x0
  802112:	e8 8e eb ff ff       	call   800ca5 <sys_page_alloc>
  802117:	89 c3                	mov    %eax,%ebx
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	0f 88 c3 00 00 00    	js     8021e7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802124:	83 ec 0c             	sub    $0xc,%esp
  802127:	ff 75 f4             	pushl  -0xc(%ebp)
  80212a:	e8 1a f1 ff ff       	call   801249 <fd2data>
  80212f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802131:	83 c4 0c             	add    $0xc,%esp
  802134:	68 07 04 00 00       	push   $0x407
  802139:	50                   	push   %eax
  80213a:	6a 00                	push   $0x0
  80213c:	e8 64 eb ff ff       	call   800ca5 <sys_page_alloc>
  802141:	89 c3                	mov    %eax,%ebx
  802143:	83 c4 10             	add    $0x10,%esp
  802146:	85 c0                	test   %eax,%eax
  802148:	0f 88 89 00 00 00    	js     8021d7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80214e:	83 ec 0c             	sub    $0xc,%esp
  802151:	ff 75 f0             	pushl  -0x10(%ebp)
  802154:	e8 f0 f0 ff ff       	call   801249 <fd2data>
  802159:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802160:	50                   	push   %eax
  802161:	6a 00                	push   $0x0
  802163:	56                   	push   %esi
  802164:	6a 00                	push   $0x0
  802166:	e8 7d eb ff ff       	call   800ce8 <sys_page_map>
  80216b:	89 c3                	mov    %eax,%ebx
  80216d:	83 c4 20             	add    $0x20,%esp
  802170:	85 c0                	test   %eax,%eax
  802172:	78 55                	js     8021c9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802174:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80217a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80217f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802182:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802189:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80218f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802192:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802194:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802197:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80219e:	83 ec 0c             	sub    $0xc,%esp
  8021a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021a4:	e8 90 f0 ff ff       	call   801239 <fd2num>
  8021a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ac:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ae:	83 c4 04             	add    $0x4,%esp
  8021b1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021b4:	e8 80 f0 ff ff       	call   801239 <fd2num>
  8021b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021bc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8021c7:	eb 30                	jmp    8021f9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8021c9:	83 ec 08             	sub    $0x8,%esp
  8021cc:	56                   	push   %esi
  8021cd:	6a 00                	push   $0x0
  8021cf:	e8 56 eb ff ff       	call   800d2a <sys_page_unmap>
  8021d4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8021d7:	83 ec 08             	sub    $0x8,%esp
  8021da:	ff 75 f0             	pushl  -0x10(%ebp)
  8021dd:	6a 00                	push   $0x0
  8021df:	e8 46 eb ff ff       	call   800d2a <sys_page_unmap>
  8021e4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8021e7:	83 ec 08             	sub    $0x8,%esp
  8021ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 36 eb ff ff       	call   800d2a <sys_page_unmap>
  8021f4:	83 c4 10             	add    $0x10,%esp
  8021f7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8021f9:	89 d0                	mov    %edx,%eax
  8021fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021fe:	5b                   	pop    %ebx
  8021ff:	5e                   	pop    %esi
  802200:	5d                   	pop    %ebp
  802201:	c3                   	ret    

00802202 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80220b:	50                   	push   %eax
  80220c:	ff 75 08             	pushl  0x8(%ebp)
  80220f:	e8 9b f0 ff ff       	call   8012af <fd_lookup>
  802214:	83 c4 10             	add    $0x10,%esp
  802217:	85 c0                	test   %eax,%eax
  802219:	78 18                	js     802233 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80221b:	83 ec 0c             	sub    $0xc,%esp
  80221e:	ff 75 f4             	pushl  -0xc(%ebp)
  802221:	e8 23 f0 ff ff       	call   801249 <fd2data>
	return _pipeisclosed(fd, p);
  802226:	89 c2                	mov    %eax,%edx
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	e8 21 fd ff ff       	call   801f51 <_pipeisclosed>
  802230:	83 c4 10             	add    $0x10,%esp
}
  802233:	c9                   	leave  
  802234:	c3                   	ret    

00802235 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802235:	55                   	push   %ebp
  802236:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802238:	b8 00 00 00 00       	mov    $0x0,%eax
  80223d:	5d                   	pop    %ebp
  80223e:	c3                   	ret    

0080223f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80223f:	55                   	push   %ebp
  802240:	89 e5                	mov    %esp,%ebp
  802242:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802245:	68 f7 2c 80 00       	push   $0x802cf7
  80224a:	ff 75 0c             	pushl  0xc(%ebp)
  80224d:	e8 50 e6 ff ff       	call   8008a2 <strcpy>
	return 0;
}
  802252:	b8 00 00 00 00       	mov    $0x0,%eax
  802257:	c9                   	leave  
  802258:	c3                   	ret    

00802259 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	57                   	push   %edi
  80225d:	56                   	push   %esi
  80225e:	53                   	push   %ebx
  80225f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802265:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80226a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802270:	eb 2d                	jmp    80229f <devcons_write+0x46>
		m = n - tot;
  802272:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802275:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  802277:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80227a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80227f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802282:	83 ec 04             	sub    $0x4,%esp
  802285:	53                   	push   %ebx
  802286:	03 45 0c             	add    0xc(%ebp),%eax
  802289:	50                   	push   %eax
  80228a:	57                   	push   %edi
  80228b:	e8 a4 e7 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  802290:	83 c4 08             	add    $0x8,%esp
  802293:	53                   	push   %ebx
  802294:	57                   	push   %edi
  802295:	e8 4f e9 ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80229a:	01 de                	add    %ebx,%esi
  80229c:	83 c4 10             	add    $0x10,%esp
  80229f:	89 f0                	mov    %esi,%eax
  8022a1:	3b 75 10             	cmp    0x10(%ebp),%esi
  8022a4:	72 cc                	jb     802272 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8022a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022a9:	5b                   	pop    %ebx
  8022aa:	5e                   	pop    %esi
  8022ab:	5f                   	pop    %edi
  8022ac:	5d                   	pop    %ebp
  8022ad:	c3                   	ret    

008022ae <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8022ae:	55                   	push   %ebp
  8022af:	89 e5                	mov    %esp,%ebp
  8022b1:	83 ec 08             	sub    $0x8,%esp
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8022b9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8022bd:	74 2a                	je     8022e9 <devcons_read+0x3b>
  8022bf:	eb 05                	jmp    8022c6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8022c1:	e8 c0 e9 ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8022c6:	e8 3c e9 ff ff       	call   800c07 <sys_cgetc>
  8022cb:	85 c0                	test   %eax,%eax
  8022cd:	74 f2                	je     8022c1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 16                	js     8022e9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8022d3:	83 f8 04             	cmp    $0x4,%eax
  8022d6:	74 0c                	je     8022e4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8022d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022db:	88 02                	mov    %al,(%edx)
	return 1;
  8022dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8022e2:	eb 05                	jmp    8022e9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8022e4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8022e9:	c9                   	leave  
  8022ea:	c3                   	ret    

008022eb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8022f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8022f7:	6a 01                	push   $0x1
  8022f9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8022fc:	50                   	push   %eax
  8022fd:	e8 e7 e8 ff ff       	call   800be9 <sys_cputs>
}
  802302:	83 c4 10             	add    $0x10,%esp
  802305:	c9                   	leave  
  802306:	c3                   	ret    

00802307 <getchar>:

int
getchar(void)
{
  802307:	55                   	push   %ebp
  802308:	89 e5                	mov    %esp,%ebp
  80230a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80230d:	6a 01                	push   $0x1
  80230f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802312:	50                   	push   %eax
  802313:	6a 00                	push   $0x0
  802315:	e8 fb f1 ff ff       	call   801515 <read>
	if (r < 0)
  80231a:	83 c4 10             	add    $0x10,%esp
  80231d:	85 c0                	test   %eax,%eax
  80231f:	78 0f                	js     802330 <getchar+0x29>
		return r;
	if (r < 1)
  802321:	85 c0                	test   %eax,%eax
  802323:	7e 06                	jle    80232b <getchar+0x24>
		return -E_EOF;
	return c;
  802325:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802329:	eb 05                	jmp    802330 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80232b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802330:	c9                   	leave  
  802331:	c3                   	ret    

00802332 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802332:	55                   	push   %ebp
  802333:	89 e5                	mov    %esp,%ebp
  802335:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802338:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80233b:	50                   	push   %eax
  80233c:	ff 75 08             	pushl  0x8(%ebp)
  80233f:	e8 6b ef ff ff       	call   8012af <fd_lookup>
  802344:	83 c4 10             	add    $0x10,%esp
  802347:	85 c0                	test   %eax,%eax
  802349:	78 11                	js     80235c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80234b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80234e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802354:	39 10                	cmp    %edx,(%eax)
  802356:	0f 94 c0             	sete   %al
  802359:	0f b6 c0             	movzbl %al,%eax
}
  80235c:	c9                   	leave  
  80235d:	c3                   	ret    

0080235e <opencons>:

int
opencons(void)
{
  80235e:	55                   	push   %ebp
  80235f:	89 e5                	mov    %esp,%ebp
  802361:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802367:	50                   	push   %eax
  802368:	e8 f3 ee ff ff       	call   801260 <fd_alloc>
  80236d:	83 c4 10             	add    $0x10,%esp
		return r;
  802370:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802372:	85 c0                	test   %eax,%eax
  802374:	78 3e                	js     8023b4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802376:	83 ec 04             	sub    $0x4,%esp
  802379:	68 07 04 00 00       	push   $0x407
  80237e:	ff 75 f4             	pushl  -0xc(%ebp)
  802381:	6a 00                	push   $0x0
  802383:	e8 1d e9 ff ff       	call   800ca5 <sys_page_alloc>
  802388:	83 c4 10             	add    $0x10,%esp
		return r;
  80238b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80238d:	85 c0                	test   %eax,%eax
  80238f:	78 23                	js     8023b4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802391:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802397:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80239c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80239f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8023a6:	83 ec 0c             	sub    $0xc,%esp
  8023a9:	50                   	push   %eax
  8023aa:	e8 8a ee ff ff       	call   801239 <fd2num>
  8023af:	89 c2                	mov    %eax,%edx
  8023b1:	83 c4 10             	add    $0x10,%esp
}
  8023b4:	89 d0                	mov    %edx,%eax
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8023be:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8023c5:	75 2e                	jne    8023f5 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  8023c7:	e8 9b e8 ff ff       	call   800c67 <sys_getenvid>
  8023cc:	83 ec 04             	sub    $0x4,%esp
  8023cf:	68 07 0e 00 00       	push   $0xe07
  8023d4:	68 00 f0 bf ee       	push   $0xeebff000
  8023d9:	50                   	push   %eax
  8023da:	e8 c6 e8 ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  8023df:	e8 83 e8 ff ff       	call   800c67 <sys_getenvid>
  8023e4:	83 c4 08             	add    $0x8,%esp
  8023e7:	68 ff 23 80 00       	push   $0x8023ff
  8023ec:	50                   	push   %eax
  8023ed:	e8 fe e9 ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  8023f2:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8023f8:	a3 00 70 80 00       	mov    %eax,0x807000
}
  8023fd:	c9                   	leave  
  8023fe:	c3                   	ret    

008023ff <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023ff:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802400:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802405:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802407:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  80240a:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  80240e:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802412:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  802415:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  802418:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802419:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  80241c:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  80241d:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  80241e:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802422:	c3                   	ret    
  802423:	66 90                	xchg   %ax,%ax
  802425:	66 90                	xchg   %ax,%ax
  802427:	66 90                	xchg   %ax,%ax
  802429:	66 90                	xchg   %ax,%ax
  80242b:	66 90                	xchg   %ax,%ax
  80242d:	66 90                	xchg   %ax,%ax
  80242f:	90                   	nop

00802430 <__udivdi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	53                   	push   %ebx
  802434:	83 ec 1c             	sub    $0x1c,%esp
  802437:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80243b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80243f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802443:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802447:	85 f6                	test   %esi,%esi
  802449:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80244d:	89 ca                	mov    %ecx,%edx
  80244f:	89 f8                	mov    %edi,%eax
  802451:	75 3d                	jne    802490 <__udivdi3+0x60>
  802453:	39 cf                	cmp    %ecx,%edi
  802455:	0f 87 c5 00 00 00    	ja     802520 <__udivdi3+0xf0>
  80245b:	85 ff                	test   %edi,%edi
  80245d:	89 fd                	mov    %edi,%ebp
  80245f:	75 0b                	jne    80246c <__udivdi3+0x3c>
  802461:	b8 01 00 00 00       	mov    $0x1,%eax
  802466:	31 d2                	xor    %edx,%edx
  802468:	f7 f7                	div    %edi
  80246a:	89 c5                	mov    %eax,%ebp
  80246c:	89 c8                	mov    %ecx,%eax
  80246e:	31 d2                	xor    %edx,%edx
  802470:	f7 f5                	div    %ebp
  802472:	89 c1                	mov    %eax,%ecx
  802474:	89 d8                	mov    %ebx,%eax
  802476:	89 cf                	mov    %ecx,%edi
  802478:	f7 f5                	div    %ebp
  80247a:	89 c3                	mov    %eax,%ebx
  80247c:	89 d8                	mov    %ebx,%eax
  80247e:	89 fa                	mov    %edi,%edx
  802480:	83 c4 1c             	add    $0x1c,%esp
  802483:	5b                   	pop    %ebx
  802484:	5e                   	pop    %esi
  802485:	5f                   	pop    %edi
  802486:	5d                   	pop    %ebp
  802487:	c3                   	ret    
  802488:	90                   	nop
  802489:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802490:	39 ce                	cmp    %ecx,%esi
  802492:	77 74                	ja     802508 <__udivdi3+0xd8>
  802494:	0f bd fe             	bsr    %esi,%edi
  802497:	83 f7 1f             	xor    $0x1f,%edi
  80249a:	0f 84 98 00 00 00    	je     802538 <__udivdi3+0x108>
  8024a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8024a5:	89 f9                	mov    %edi,%ecx
  8024a7:	89 c5                	mov    %eax,%ebp
  8024a9:	29 fb                	sub    %edi,%ebx
  8024ab:	d3 e6                	shl    %cl,%esi
  8024ad:	89 d9                	mov    %ebx,%ecx
  8024af:	d3 ed                	shr    %cl,%ebp
  8024b1:	89 f9                	mov    %edi,%ecx
  8024b3:	d3 e0                	shl    %cl,%eax
  8024b5:	09 ee                	or     %ebp,%esi
  8024b7:	89 d9                	mov    %ebx,%ecx
  8024b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024bd:	89 d5                	mov    %edx,%ebp
  8024bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8024c3:	d3 ed                	shr    %cl,%ebp
  8024c5:	89 f9                	mov    %edi,%ecx
  8024c7:	d3 e2                	shl    %cl,%edx
  8024c9:	89 d9                	mov    %ebx,%ecx
  8024cb:	d3 e8                	shr    %cl,%eax
  8024cd:	09 c2                	or     %eax,%edx
  8024cf:	89 d0                	mov    %edx,%eax
  8024d1:	89 ea                	mov    %ebp,%edx
  8024d3:	f7 f6                	div    %esi
  8024d5:	89 d5                	mov    %edx,%ebp
  8024d7:	89 c3                	mov    %eax,%ebx
  8024d9:	f7 64 24 0c          	mull   0xc(%esp)
  8024dd:	39 d5                	cmp    %edx,%ebp
  8024df:	72 10                	jb     8024f1 <__udivdi3+0xc1>
  8024e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8024e5:	89 f9                	mov    %edi,%ecx
  8024e7:	d3 e6                	shl    %cl,%esi
  8024e9:	39 c6                	cmp    %eax,%esi
  8024eb:	73 07                	jae    8024f4 <__udivdi3+0xc4>
  8024ed:	39 d5                	cmp    %edx,%ebp
  8024ef:	75 03                	jne    8024f4 <__udivdi3+0xc4>
  8024f1:	83 eb 01             	sub    $0x1,%ebx
  8024f4:	31 ff                	xor    %edi,%edi
  8024f6:	89 d8                	mov    %ebx,%eax
  8024f8:	89 fa                	mov    %edi,%edx
  8024fa:	83 c4 1c             	add    $0x1c,%esp
  8024fd:	5b                   	pop    %ebx
  8024fe:	5e                   	pop    %esi
  8024ff:	5f                   	pop    %edi
  802500:	5d                   	pop    %ebp
  802501:	c3                   	ret    
  802502:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802508:	31 ff                	xor    %edi,%edi
  80250a:	31 db                	xor    %ebx,%ebx
  80250c:	89 d8                	mov    %ebx,%eax
  80250e:	89 fa                	mov    %edi,%edx
  802510:	83 c4 1c             	add    $0x1c,%esp
  802513:	5b                   	pop    %ebx
  802514:	5e                   	pop    %esi
  802515:	5f                   	pop    %edi
  802516:	5d                   	pop    %ebp
  802517:	c3                   	ret    
  802518:	90                   	nop
  802519:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802520:	89 d8                	mov    %ebx,%eax
  802522:	f7 f7                	div    %edi
  802524:	31 ff                	xor    %edi,%edi
  802526:	89 c3                	mov    %eax,%ebx
  802528:	89 d8                	mov    %ebx,%eax
  80252a:	89 fa                	mov    %edi,%edx
  80252c:	83 c4 1c             	add    $0x1c,%esp
  80252f:	5b                   	pop    %ebx
  802530:	5e                   	pop    %esi
  802531:	5f                   	pop    %edi
  802532:	5d                   	pop    %ebp
  802533:	c3                   	ret    
  802534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802538:	39 ce                	cmp    %ecx,%esi
  80253a:	72 0c                	jb     802548 <__udivdi3+0x118>
  80253c:	31 db                	xor    %ebx,%ebx
  80253e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802542:	0f 87 34 ff ff ff    	ja     80247c <__udivdi3+0x4c>
  802548:	bb 01 00 00 00       	mov    $0x1,%ebx
  80254d:	e9 2a ff ff ff       	jmp    80247c <__udivdi3+0x4c>
  802552:	66 90                	xchg   %ax,%ax
  802554:	66 90                	xchg   %ax,%ax
  802556:	66 90                	xchg   %ax,%ax
  802558:	66 90                	xchg   %ax,%ax
  80255a:	66 90                	xchg   %ax,%ax
  80255c:	66 90                	xchg   %ax,%ax
  80255e:	66 90                	xchg   %ax,%ax

00802560 <__umoddi3>:
  802560:	55                   	push   %ebp
  802561:	57                   	push   %edi
  802562:	56                   	push   %esi
  802563:	53                   	push   %ebx
  802564:	83 ec 1c             	sub    $0x1c,%esp
  802567:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80256b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80256f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802573:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802577:	85 d2                	test   %edx,%edx
  802579:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80257d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802581:	89 f3                	mov    %esi,%ebx
  802583:	89 3c 24             	mov    %edi,(%esp)
  802586:	89 74 24 04          	mov    %esi,0x4(%esp)
  80258a:	75 1c                	jne    8025a8 <__umoddi3+0x48>
  80258c:	39 f7                	cmp    %esi,%edi
  80258e:	76 50                	jbe    8025e0 <__umoddi3+0x80>
  802590:	89 c8                	mov    %ecx,%eax
  802592:	89 f2                	mov    %esi,%edx
  802594:	f7 f7                	div    %edi
  802596:	89 d0                	mov    %edx,%eax
  802598:	31 d2                	xor    %edx,%edx
  80259a:	83 c4 1c             	add    $0x1c,%esp
  80259d:	5b                   	pop    %ebx
  80259e:	5e                   	pop    %esi
  80259f:	5f                   	pop    %edi
  8025a0:	5d                   	pop    %ebp
  8025a1:	c3                   	ret    
  8025a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025a8:	39 f2                	cmp    %esi,%edx
  8025aa:	89 d0                	mov    %edx,%eax
  8025ac:	77 52                	ja     802600 <__umoddi3+0xa0>
  8025ae:	0f bd ea             	bsr    %edx,%ebp
  8025b1:	83 f5 1f             	xor    $0x1f,%ebp
  8025b4:	75 5a                	jne    802610 <__umoddi3+0xb0>
  8025b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8025ba:	0f 82 e0 00 00 00    	jb     8026a0 <__umoddi3+0x140>
  8025c0:	39 0c 24             	cmp    %ecx,(%esp)
  8025c3:	0f 86 d7 00 00 00    	jbe    8026a0 <__umoddi3+0x140>
  8025c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8025cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025d1:	83 c4 1c             	add    $0x1c,%esp
  8025d4:	5b                   	pop    %ebx
  8025d5:	5e                   	pop    %esi
  8025d6:	5f                   	pop    %edi
  8025d7:	5d                   	pop    %ebp
  8025d8:	c3                   	ret    
  8025d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025e0:	85 ff                	test   %edi,%edi
  8025e2:	89 fd                	mov    %edi,%ebp
  8025e4:	75 0b                	jne    8025f1 <__umoddi3+0x91>
  8025e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025eb:	31 d2                	xor    %edx,%edx
  8025ed:	f7 f7                	div    %edi
  8025ef:	89 c5                	mov    %eax,%ebp
  8025f1:	89 f0                	mov    %esi,%eax
  8025f3:	31 d2                	xor    %edx,%edx
  8025f5:	f7 f5                	div    %ebp
  8025f7:	89 c8                	mov    %ecx,%eax
  8025f9:	f7 f5                	div    %ebp
  8025fb:	89 d0                	mov    %edx,%eax
  8025fd:	eb 99                	jmp    802598 <__umoddi3+0x38>
  8025ff:	90                   	nop
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	83 c4 1c             	add    $0x1c,%esp
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    
  80260c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802610:	8b 34 24             	mov    (%esp),%esi
  802613:	bf 20 00 00 00       	mov    $0x20,%edi
  802618:	89 e9                	mov    %ebp,%ecx
  80261a:	29 ef                	sub    %ebp,%edi
  80261c:	d3 e0                	shl    %cl,%eax
  80261e:	89 f9                	mov    %edi,%ecx
  802620:	89 f2                	mov    %esi,%edx
  802622:	d3 ea                	shr    %cl,%edx
  802624:	89 e9                	mov    %ebp,%ecx
  802626:	09 c2                	or     %eax,%edx
  802628:	89 d8                	mov    %ebx,%eax
  80262a:	89 14 24             	mov    %edx,(%esp)
  80262d:	89 f2                	mov    %esi,%edx
  80262f:	d3 e2                	shl    %cl,%edx
  802631:	89 f9                	mov    %edi,%ecx
  802633:	89 54 24 04          	mov    %edx,0x4(%esp)
  802637:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80263b:	d3 e8                	shr    %cl,%eax
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	89 c6                	mov    %eax,%esi
  802641:	d3 e3                	shl    %cl,%ebx
  802643:	89 f9                	mov    %edi,%ecx
  802645:	89 d0                	mov    %edx,%eax
  802647:	d3 e8                	shr    %cl,%eax
  802649:	89 e9                	mov    %ebp,%ecx
  80264b:	09 d8                	or     %ebx,%eax
  80264d:	89 d3                	mov    %edx,%ebx
  80264f:	89 f2                	mov    %esi,%edx
  802651:	f7 34 24             	divl   (%esp)
  802654:	89 d6                	mov    %edx,%esi
  802656:	d3 e3                	shl    %cl,%ebx
  802658:	f7 64 24 04          	mull   0x4(%esp)
  80265c:	39 d6                	cmp    %edx,%esi
  80265e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802662:	89 d1                	mov    %edx,%ecx
  802664:	89 c3                	mov    %eax,%ebx
  802666:	72 08                	jb     802670 <__umoddi3+0x110>
  802668:	75 11                	jne    80267b <__umoddi3+0x11b>
  80266a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80266e:	73 0b                	jae    80267b <__umoddi3+0x11b>
  802670:	2b 44 24 04          	sub    0x4(%esp),%eax
  802674:	1b 14 24             	sbb    (%esp),%edx
  802677:	89 d1                	mov    %edx,%ecx
  802679:	89 c3                	mov    %eax,%ebx
  80267b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80267f:	29 da                	sub    %ebx,%edx
  802681:	19 ce                	sbb    %ecx,%esi
  802683:	89 f9                	mov    %edi,%ecx
  802685:	89 f0                	mov    %esi,%eax
  802687:	d3 e0                	shl    %cl,%eax
  802689:	89 e9                	mov    %ebp,%ecx
  80268b:	d3 ea                	shr    %cl,%edx
  80268d:	89 e9                	mov    %ebp,%ecx
  80268f:	d3 ee                	shr    %cl,%esi
  802691:	09 d0                	or     %edx,%eax
  802693:	89 f2                	mov    %esi,%edx
  802695:	83 c4 1c             	add    $0x1c,%esp
  802698:	5b                   	pop    %ebx
  802699:	5e                   	pop    %esi
  80269a:	5f                   	pop    %edi
  80269b:	5d                   	pop    %ebp
  80269c:	c3                   	ret    
  80269d:	8d 76 00             	lea    0x0(%esi),%esi
  8026a0:	29 f9                	sub    %edi,%ecx
  8026a2:	19 d6                	sbb    %edx,%esi
  8026a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8026a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026ac:	e9 18 ff ff ff       	jmp    8025c9 <__umoddi3+0x69>
