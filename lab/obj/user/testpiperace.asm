
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
  80003b:	68 00 22 80 00       	push   $0x802200
  800040:	e8 d8 02 00 00       	call   80031d <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 a3 1b 00 00       	call   801bf3 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", r);
  800057:	50                   	push   %eax
  800058:	68 19 22 80 00       	push   $0x802219
  80005d:	6a 0d                	push   $0xd
  80005f:	68 22 22 80 00       	push   $0x802222
  800064:	e8 db 01 00 00       	call   800244 <_panic>
	max = 200;
	if ((r = fork()) < 0)
  800069:	e8 01 0f 00 00       	call   800f6f <fork>
  80006e:	89 c6                	mov    %eax,%esi
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", r);
  800074:	50                   	push   %eax
  800075:	68 36 22 80 00       	push   $0x802236
  80007a:	6a 10                	push   $0x10
  80007c:	68 22 22 80 00       	push   $0x802222
  800081:	e8 be 01 00 00       	call   800244 <_panic>
	if (r == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	75 55                	jne    8000df <umain+0xac>
		close(p[1]);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	ff 75 f4             	pushl  -0xc(%ebp)
  800090:	e8 ef 12 00 00       	call   801384 <close>
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
  8000a3:	e8 9e 1c 00 00       	call   801d46 <pipeisclosed>
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	85 c0                	test   %eax,%eax
  8000ad:	74 15                	je     8000c4 <umain+0x91>
				cprintf("RACE: pipe appears closed\n");
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	68 3f 22 80 00       	push   $0x80223f
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
  8000d7:	e8 14 10 00 00       	call   8010f0 <ipc_recv>
  8000dc:	83 c4 10             	add    $0x10,%esp
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	56                   	push   %esi
  8000e3:	68 5a 22 80 00       	push   $0x80225a
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
  800103:	68 65 22 80 00       	push   $0x802265
  800108:	e8 10 02 00 00       	call   80031d <cprintf>
	dup(p[0], 10);
  80010d:	83 c4 08             	add    $0x8,%esp
  800110:	6a 0a                	push   $0xa
  800112:	ff 75 f0             	pushl  -0x10(%ebp)
  800115:	e8 ba 12 00 00       	call   8013d4 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80011a:	83 c4 10             	add    $0x10,%esp
  80011d:	6b de 7c             	imul   $0x7c,%esi,%ebx
  800120:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800126:	eb 10                	jmp    800138 <umain+0x105>
		dup(p[0], 10);
  800128:	83 ec 08             	sub    $0x8,%esp
  80012b:	6a 0a                	push   $0xa
  80012d:	ff 75 f0             	pushl  -0x10(%ebp)
  800130:	e8 9f 12 00 00       	call   8013d4 <dup>
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
  800143:	68 70 22 80 00       	push   $0x802270
  800148:	e8 d0 01 00 00       	call   80031d <cprintf>
	if (pipeisclosed(p[0]))
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 f0             	pushl  -0x10(%ebp)
  800153:	e8 ee 1b 00 00       	call   801d46 <pipeisclosed>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 14                	je     800173 <umain+0x140>
		panic("somehow the other end of p[0] got closed!");
  80015f:	83 ec 04             	sub    $0x4,%esp
  800162:	68 cc 22 80 00       	push   $0x8022cc
  800167:	6a 3a                	push   $0x3a
  800169:	68 22 22 80 00       	push   $0x802222
  80016e:	e8 d1 00 00 00       	call   800244 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800179:	50                   	push   %eax
  80017a:	ff 75 f0             	pushl  -0x10(%ebp)
  80017d:	e8 d8 10 00 00       	call   80125a <fd_lookup>
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	85 c0                	test   %eax,%eax
  800187:	79 12                	jns    80019b <umain+0x168>
		panic("cannot look up p[0]: %e", r);
  800189:	50                   	push   %eax
  80018a:	68 86 22 80 00       	push   $0x802286
  80018f:	6a 3c                	push   $0x3c
  800191:	68 22 22 80 00       	push   $0x802222
  800196:	e8 a9 00 00 00       	call   800244 <_panic>
	va = fd2data(fd);
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	ff 75 ec             	pushl  -0x14(%ebp)
  8001a1:	e8 4e 10 00 00       	call   8011f4 <fd2data>
	if (pageref(va) != 3+1)
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 34 18 00 00       	call   8019e2 <pageref>
  8001ae:	83 c4 10             	add    $0x10,%esp
  8001b1:	83 f8 04             	cmp    $0x4,%eax
  8001b4:	74 12                	je     8001c8 <umain+0x195>
		cprintf("\nchild detected race\n");
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	68 9e 22 80 00       	push   $0x80229e
  8001be:	e8 5a 01 00 00       	call   80031d <cprintf>
  8001c3:	83 c4 10             	add    $0x10,%esp
  8001c6:	eb 15                	jmp    8001dd <umain+0x1aa>
	else
		cprintf("\nrace didn't happen\n", max);
  8001c8:	83 ec 08             	sub    $0x8,%esp
  8001cb:	68 c8 00 00 00       	push   $0xc8
  8001d0:	68 b4 22 80 00       	push   $0x8022b4
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
  800201:	a3 04 40 80 00       	mov    %eax,0x804004

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
  800230:	e8 7a 11 00 00       	call   8013af <close_all>
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
  800262:	68 00 23 80 00       	push   $0x802300
  800267:	e8 b1 00 00 00       	call   80031d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80026c:	83 c4 18             	add    $0x18,%esp
  80026f:	53                   	push   %ebx
  800270:	ff 75 10             	pushl  0x10(%ebp)
  800273:	e8 54 00 00 00       	call   8002cc <vcprintf>
	cprintf("\n");
  800278:	c7 04 24 17 22 80 00 	movl   $0x802217,(%esp)
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
  800380:	e8 eb 1b 00 00       	call   801f70 <__udivdi3>
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
  8003c3:	e8 d8 1c 00 00       	call   8020a0 <__umoddi3>
  8003c8:	83 c4 14             	add    $0x14,%esp
  8003cb:	0f be 80 23 23 80 00 	movsbl 0x802323(%eax),%eax
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
  8004c7:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
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
  80058b:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800592:	85 d2                	test   %edx,%edx
  800594:	75 18                	jne    8005ae <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800596:	50                   	push   %eax
  800597:	68 3b 23 80 00       	push   $0x80233b
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
  8005af:	68 c1 27 80 00       	push   $0x8027c1
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
  8005d3:	b8 34 23 80 00       	mov    $0x802334,%eax
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
  800c4e:	68 1f 26 80 00       	push   $0x80261f
  800c53:	6a 23                	push   $0x23
  800c55:	68 3c 26 80 00       	push   $0x80263c
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
  800ccf:	68 1f 26 80 00       	push   $0x80261f
  800cd4:	6a 23                	push   $0x23
  800cd6:	68 3c 26 80 00       	push   $0x80263c
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
  800d11:	68 1f 26 80 00       	push   $0x80261f
  800d16:	6a 23                	push   $0x23
  800d18:	68 3c 26 80 00       	push   $0x80263c
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
  800d53:	68 1f 26 80 00       	push   $0x80261f
  800d58:	6a 23                	push   $0x23
  800d5a:	68 3c 26 80 00       	push   $0x80263c
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
  800d95:	68 1f 26 80 00       	push   $0x80261f
  800d9a:	6a 23                	push   $0x23
  800d9c:	68 3c 26 80 00       	push   $0x80263c
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
  800dd7:	68 1f 26 80 00       	push   $0x80261f
  800ddc:	6a 23                	push   $0x23
  800dde:	68 3c 26 80 00       	push   $0x80263c
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
  800e19:	68 1f 26 80 00       	push   $0x80261f
  800e1e:	6a 23                	push   $0x23
  800e20:	68 3c 26 80 00       	push   $0x80263c
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
  800e7d:	68 1f 26 80 00       	push   $0x80261f
  800e82:	6a 23                	push   $0x23
  800e84:	68 3c 26 80 00       	push   $0x80263c
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

00800e96 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e9e:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800ea0:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ea4:	75 25                	jne    800ecb <pgfault+0x35>
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	c1 e8 0c             	shr    $0xc,%eax
  800eab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800eb2:	f6 c4 08             	test   $0x8,%ah
  800eb5:	75 14                	jne    800ecb <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	68 4c 26 80 00       	push   $0x80264c
  800ebf:	6a 1e                	push   $0x1e
  800ec1:	68 e0 26 80 00       	push   $0x8026e0
  800ec6:	e8 79 f3 ff ff       	call   800244 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ecb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ed1:	e8 91 fd ff ff       	call   800c67 <sys_getenvid>
  800ed6:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800ed8:	83 ec 04             	sub    $0x4,%esp
  800edb:	6a 07                	push   $0x7
  800edd:	68 00 f0 7f 00       	push   $0x7ff000
  800ee2:	50                   	push   %eax
  800ee3:	e8 bd fd ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	79 12                	jns    800f01 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800eef:	50                   	push   %eax
  800ef0:	68 78 26 80 00       	push   $0x802678
  800ef5:	6a 31                	push   $0x31
  800ef7:	68 e0 26 80 00       	push   $0x8026e0
  800efc:	e8 43 f3 ff ff       	call   800244 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	68 00 10 00 00       	push   $0x1000
  800f09:	53                   	push   %ebx
  800f0a:	68 00 f0 7f 00       	push   $0x7ff000
  800f0f:	e8 88 fb ff ff       	call   800a9c <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f14:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1b:	53                   	push   %ebx
  800f1c:	56                   	push   %esi
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	56                   	push   %esi
  800f23:	e8 c0 fd ff ff       	call   800ce8 <sys_page_map>
	if (r < 0)
  800f28:	83 c4 20             	add    $0x20,%esp
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	79 12                	jns    800f41 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f2f:	50                   	push   %eax
  800f30:	68 9c 26 80 00       	push   $0x80269c
  800f35:	6a 39                	push   $0x39
  800f37:	68 e0 26 80 00       	push   $0x8026e0
  800f3c:	e8 03 f3 ff ff       	call   800244 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	68 00 f0 7f 00       	push   $0x7ff000
  800f49:	56                   	push   %esi
  800f4a:	e8 db fd ff ff       	call   800d2a <sys_page_unmap>
	if (r < 0)
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 12                	jns    800f68 <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f56:	50                   	push   %eax
  800f57:	68 c0 26 80 00       	push   $0x8026c0
  800f5c:	6a 3e                	push   $0x3e
  800f5e:	68 e0 26 80 00       	push   $0x8026e0
  800f63:	e8 dc f2 ff ff       	call   800244 <_panic>
}
  800f68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	57                   	push   %edi
  800f73:	56                   	push   %esi
  800f74:	53                   	push   %ebx
  800f75:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f78:	68 96 0e 80 00       	push   $0x800e96
  800f7d:	e8 7a 0f 00 00       	call   801efc <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f82:	b8 07 00 00 00       	mov    $0x7,%eax
  800f87:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f89:	83 c4 10             	add    $0x10,%esp
  800f8c:	85 c0                	test   %eax,%eax
  800f8e:	0f 88 3a 01 00 00    	js     8010ce <fork+0x15f>
  800f94:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f99:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	75 21                	jne    800fc3 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fa2:	e8 c0 fc ff ff       	call   800c67 <sys_getenvid>
  800fa7:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800faf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fb4:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800fbe:	e9 0b 01 00 00       	jmp    8010ce <fork+0x15f>
  800fc3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fc6:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fc8:	89 d8                	mov    %ebx,%eax
  800fca:	c1 e8 16             	shr    $0x16,%eax
  800fcd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd4:	a8 01                	test   $0x1,%al
  800fd6:	0f 84 99 00 00 00    	je     801075 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fdc:	89 d8                	mov    %ebx,%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
  800fe1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe8:	f6 c2 01             	test   $0x1,%dl
  800feb:	0f 84 84 00 00 00    	je     801075 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800ff1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff8:	a9 02 08 00 00       	test   $0x802,%eax
  800ffd:	74 76                	je     801075 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800fff:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801006:	a8 02                	test   $0x2,%al
  801008:	75 0c                	jne    801016 <fork+0xa7>
  80100a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801011:	f6 c4 08             	test   $0x8,%ah
  801014:	74 3f                	je     801055 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801016:	83 ec 0c             	sub    $0xc,%esp
  801019:	68 05 08 00 00       	push   $0x805
  80101e:	53                   	push   %ebx
  80101f:	57                   	push   %edi
  801020:	53                   	push   %ebx
  801021:	6a 00                	push   $0x0
  801023:	e8 c0 fc ff ff       	call   800ce8 <sys_page_map>
		if (r < 0)
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	0f 88 9b 00 00 00    	js     8010ce <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	68 05 08 00 00       	push   $0x805
  80103b:	53                   	push   %ebx
  80103c:	6a 00                	push   $0x0
  80103e:	53                   	push   %ebx
  80103f:	6a 00                	push   $0x0
  801041:	e8 a2 fc ff ff       	call   800ce8 <sys_page_map>
  801046:	83 c4 20             	add    $0x20,%esp
  801049:	85 c0                	test   %eax,%eax
  80104b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801050:	0f 4f c1             	cmovg  %ecx,%eax
  801053:	eb 1c                	jmp    801071 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	6a 05                	push   $0x5
  80105a:	53                   	push   %ebx
  80105b:	57                   	push   %edi
  80105c:	53                   	push   %ebx
  80105d:	6a 00                	push   $0x0
  80105f:	e8 84 fc ff ff       	call   800ce8 <sys_page_map>
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	b9 00 00 00 00       	mov    $0x0,%ecx
  80106e:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801071:	85 c0                	test   %eax,%eax
  801073:	78 59                	js     8010ce <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801075:	83 c6 01             	add    $0x1,%esi
  801078:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80107e:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801084:	0f 85 3e ff ff ff    	jne    800fc8 <fork+0x59>
  80108a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80108d:	83 ec 04             	sub    $0x4,%esp
  801090:	6a 07                	push   $0x7
  801092:	68 00 f0 bf ee       	push   $0xeebff000
  801097:	57                   	push   %edi
  801098:	e8 08 fc ff ff       	call   800ca5 <sys_page_alloc>
	if (r < 0)
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	85 c0                	test   %eax,%eax
  8010a2:	78 2a                	js     8010ce <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010a4:	83 ec 08             	sub    $0x8,%esp
  8010a7:	68 43 1f 80 00       	push   $0x801f43
  8010ac:	57                   	push   %edi
  8010ad:	e8 3e fd ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 15                	js     8010ce <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010b9:	83 ec 08             	sub    $0x8,%esp
  8010bc:	6a 02                	push   $0x2
  8010be:	57                   	push   %edi
  8010bf:	e8 a8 fc ff ff       	call   800d6c <sys_env_set_status>
	if (r < 0)
  8010c4:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	0f 49 c7             	cmovns %edi,%eax
  8010cc:	eb 00                	jmp    8010ce <fork+0x15f>
	// panic("fork not implemented");
}
  8010ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d1:	5b                   	pop    %ebx
  8010d2:	5e                   	pop    %esi
  8010d3:	5f                   	pop    %edi
  8010d4:	5d                   	pop    %ebp
  8010d5:	c3                   	ret    

008010d6 <sfork>:

// Challenge!
int
sfork(void)
{
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010dc:	68 eb 26 80 00       	push   $0x8026eb
  8010e1:	68 c3 00 00 00       	push   $0xc3
  8010e6:	68 e0 26 80 00       	push   $0x8026e0
  8010eb:	e8 54 f1 ff ff       	call   800244 <_panic>

008010f0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	56                   	push   %esi
  8010f4:	53                   	push   %ebx
  8010f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8010f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  8010fe:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801100:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801105:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801108:	83 ec 0c             	sub    $0xc,%esp
  80110b:	50                   	push   %eax
  80110c:	e8 44 fd ff ff       	call   800e55 <sys_ipc_recv>

	if (from_env_store != NULL)
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	85 f6                	test   %esi,%esi
  801116:	74 14                	je     80112c <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801118:	ba 00 00 00 00       	mov    $0x0,%edx
  80111d:	85 c0                	test   %eax,%eax
  80111f:	78 09                	js     80112a <ipc_recv+0x3a>
  801121:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801127:	8b 52 74             	mov    0x74(%edx),%edx
  80112a:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  80112c:	85 db                	test   %ebx,%ebx
  80112e:	74 14                	je     801144 <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801130:	ba 00 00 00 00       	mov    $0x0,%edx
  801135:	85 c0                	test   %eax,%eax
  801137:	78 09                	js     801142 <ipc_recv+0x52>
  801139:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80113f:	8b 52 78             	mov    0x78(%edx),%edx
  801142:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801144:	85 c0                	test   %eax,%eax
  801146:	78 08                	js     801150 <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801148:	a1 04 40 80 00       	mov    0x804004,%eax
  80114d:	8b 40 70             	mov    0x70(%eax),%eax
}
  801150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801153:	5b                   	pop    %ebx
  801154:	5e                   	pop    %esi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    

00801157 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	8b 7d 08             	mov    0x8(%ebp),%edi
  801163:	8b 75 0c             	mov    0xc(%ebp),%esi
  801166:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801169:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  80116b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801170:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801173:	ff 75 14             	pushl  0x14(%ebp)
  801176:	53                   	push   %ebx
  801177:	56                   	push   %esi
  801178:	57                   	push   %edi
  801179:	e8 b4 fc ff ff       	call   800e32 <sys_ipc_try_send>

		if (err < 0) {
  80117e:	83 c4 10             	add    $0x10,%esp
  801181:	85 c0                	test   %eax,%eax
  801183:	79 1e                	jns    8011a3 <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801185:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801188:	75 07                	jne    801191 <ipc_send+0x3a>
				sys_yield();
  80118a:	e8 f7 fa ff ff       	call   800c86 <sys_yield>
  80118f:	eb e2                	jmp    801173 <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801191:	50                   	push   %eax
  801192:	68 01 27 80 00       	push   $0x802701
  801197:	6a 49                	push   $0x49
  801199:	68 0e 27 80 00       	push   $0x80270e
  80119e:	e8 a1 f0 ff ff       	call   800244 <_panic>
		}

	} while (err < 0);

}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8011b6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8011b9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8011bf:	8b 52 50             	mov    0x50(%edx),%edx
  8011c2:	39 ca                	cmp    %ecx,%edx
  8011c4:	75 0d                	jne    8011d3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8011c6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011c9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011ce:	8b 40 48             	mov    0x48(%eax),%eax
  8011d1:	eb 0f                	jmp    8011e2 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8011d3:	83 c0 01             	add    $0x1,%eax
  8011d6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011db:	75 d9                	jne    8011b6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e2:	5d                   	pop    %ebp
  8011e3:	c3                   	ret    

008011e4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e4:	55                   	push   %ebp
  8011e5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ea:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ef:	c1 e8 0c             	shr    $0xc,%eax
}
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    

008011f4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f4:	55                   	push   %ebp
  8011f5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801204:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801211:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801216:	89 c2                	mov    %eax,%edx
  801218:	c1 ea 16             	shr    $0x16,%edx
  80121b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 11                	je     801238 <fd_alloc+0x2d>
  801227:	89 c2                	mov    %eax,%edx
  801229:	c1 ea 0c             	shr    $0xc,%edx
  80122c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801233:	f6 c2 01             	test   $0x1,%dl
  801236:	75 09                	jne    801241 <fd_alloc+0x36>
			*fd_store = fd;
  801238:	89 01                	mov    %eax,(%ecx)
			return 0;
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
  80123f:	eb 17                	jmp    801258 <fd_alloc+0x4d>
  801241:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801246:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80124b:	75 c9                	jne    801216 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80124d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801253:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801260:	83 f8 1f             	cmp    $0x1f,%eax
  801263:	77 36                	ja     80129b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801265:	c1 e0 0c             	shl    $0xc,%eax
  801268:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	c1 ea 16             	shr    $0x16,%edx
  801272:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801279:	f6 c2 01             	test   $0x1,%dl
  80127c:	74 24                	je     8012a2 <fd_lookup+0x48>
  80127e:	89 c2                	mov    %eax,%edx
  801280:	c1 ea 0c             	shr    $0xc,%edx
  801283:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128a:	f6 c2 01             	test   $0x1,%dl
  80128d:	74 1a                	je     8012a9 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801292:	89 02                	mov    %eax,(%edx)
	return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
  801299:	eb 13                	jmp    8012ae <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a0:	eb 0c                	jmp    8012ae <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a7:	eb 05                	jmp    8012ae <fd_lookup+0x54>
  8012a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ae:	5d                   	pop    %ebp
  8012af:	c3                   	ret    

008012b0 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b9:	ba 98 27 80 00       	mov    $0x802798,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012be:	eb 13                	jmp    8012d3 <dev_lookup+0x23>
  8012c0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c3:	39 08                	cmp    %ecx,(%eax)
  8012c5:	75 0c                	jne    8012d3 <dev_lookup+0x23>
			*dev = devtab[i];
  8012c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d1:	eb 2e                	jmp    801301 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d3:	8b 02                	mov    (%edx),%eax
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	75 e7                	jne    8012c0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8012de:	8b 40 48             	mov    0x48(%eax),%eax
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	51                   	push   %ecx
  8012e5:	50                   	push   %eax
  8012e6:	68 18 27 80 00       	push   $0x802718
  8012eb:	e8 2d f0 ff ff       	call   80031d <cprintf>
	*dev = 0;
  8012f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801301:	c9                   	leave  
  801302:	c3                   	ret    

00801303 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	56                   	push   %esi
  801307:	53                   	push   %ebx
  801308:	83 ec 10             	sub    $0x10,%esp
  80130b:	8b 75 08             	mov    0x8(%ebp),%esi
  80130e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80131b:	c1 e8 0c             	shr    $0xc,%eax
  80131e:	50                   	push   %eax
  80131f:	e8 36 ff ff ff       	call   80125a <fd_lookup>
  801324:	83 c4 08             	add    $0x8,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 05                	js     801330 <fd_close+0x2d>
	    || fd != fd2)
  80132b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80132e:	74 0c                	je     80133c <fd_close+0x39>
		return (must_exist ? r : 0);
  801330:	84 db                	test   %bl,%bl
  801332:	ba 00 00 00 00       	mov    $0x0,%edx
  801337:	0f 44 c2             	cmove  %edx,%eax
  80133a:	eb 41                	jmp    80137d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801342:	50                   	push   %eax
  801343:	ff 36                	pushl  (%esi)
  801345:	e8 66 ff ff ff       	call   8012b0 <dev_lookup>
  80134a:	89 c3                	mov    %eax,%ebx
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 1a                	js     80136d <fd_close+0x6a>
		if (dev->dev_close)
  801353:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801356:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801359:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80135e:	85 c0                	test   %eax,%eax
  801360:	74 0b                	je     80136d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801362:	83 ec 0c             	sub    $0xc,%esp
  801365:	56                   	push   %esi
  801366:	ff d0                	call   *%eax
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	56                   	push   %esi
  801371:	6a 00                	push   $0x0
  801373:	e8 b2 f9 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	89 d8                	mov    %ebx,%eax
}
  80137d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80138a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138d:	50                   	push   %eax
  80138e:	ff 75 08             	pushl  0x8(%ebp)
  801391:	e8 c4 fe ff ff       	call   80125a <fd_lookup>
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	78 10                	js     8013ad <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80139d:	83 ec 08             	sub    $0x8,%esp
  8013a0:	6a 01                	push   $0x1
  8013a2:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a5:	e8 59 ff ff ff       	call   801303 <fd_close>
  8013aa:	83 c4 10             	add    $0x10,%esp
}
  8013ad:	c9                   	leave  
  8013ae:	c3                   	ret    

008013af <close_all>:

void
close_all(void)
{
  8013af:	55                   	push   %ebp
  8013b0:	89 e5                	mov    %esp,%ebp
  8013b2:	53                   	push   %ebx
  8013b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	53                   	push   %ebx
  8013bf:	e8 c0 ff ff ff       	call   801384 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c4:	83 c3 01             	add    $0x1,%ebx
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	83 fb 20             	cmp    $0x20,%ebx
  8013cd:	75 ec                	jne    8013bb <close_all+0xc>
		close(i);
}
  8013cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    

008013d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	57                   	push   %edi
  8013d8:	56                   	push   %esi
  8013d9:	53                   	push   %ebx
  8013da:	83 ec 2c             	sub    $0x2c,%esp
  8013dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e3:	50                   	push   %eax
  8013e4:	ff 75 08             	pushl  0x8(%ebp)
  8013e7:	e8 6e fe ff ff       	call   80125a <fd_lookup>
  8013ec:	83 c4 08             	add    $0x8,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	0f 88 c1 00 00 00    	js     8014b8 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f7:	83 ec 0c             	sub    $0xc,%esp
  8013fa:	56                   	push   %esi
  8013fb:	e8 84 ff ff ff       	call   801384 <close>

	newfd = INDEX2FD(newfdnum);
  801400:	89 f3                	mov    %esi,%ebx
  801402:	c1 e3 0c             	shl    $0xc,%ebx
  801405:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80140b:	83 c4 04             	add    $0x4,%esp
  80140e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801411:	e8 de fd ff ff       	call   8011f4 <fd2data>
  801416:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801418:	89 1c 24             	mov    %ebx,(%esp)
  80141b:	e8 d4 fd ff ff       	call   8011f4 <fd2data>
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801426:	89 f8                	mov    %edi,%eax
  801428:	c1 e8 16             	shr    $0x16,%eax
  80142b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801432:	a8 01                	test   $0x1,%al
  801434:	74 37                	je     80146d <dup+0x99>
  801436:	89 f8                	mov    %edi,%eax
  801438:	c1 e8 0c             	shr    $0xc,%eax
  80143b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801442:	f6 c2 01             	test   $0x1,%dl
  801445:	74 26                	je     80146d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801447:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144e:	83 ec 0c             	sub    $0xc,%esp
  801451:	25 07 0e 00 00       	and    $0xe07,%eax
  801456:	50                   	push   %eax
  801457:	ff 75 d4             	pushl  -0x2c(%ebp)
  80145a:	6a 00                	push   $0x0
  80145c:	57                   	push   %edi
  80145d:	6a 00                	push   $0x0
  80145f:	e8 84 f8 ff ff       	call   800ce8 <sys_page_map>
  801464:	89 c7                	mov    %eax,%edi
  801466:	83 c4 20             	add    $0x20,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 2e                	js     80149b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801470:	89 d0                	mov    %edx,%eax
  801472:	c1 e8 0c             	shr    $0xc,%eax
  801475:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	25 07 0e 00 00       	and    $0xe07,%eax
  801484:	50                   	push   %eax
  801485:	53                   	push   %ebx
  801486:	6a 00                	push   $0x0
  801488:	52                   	push   %edx
  801489:	6a 00                	push   $0x0
  80148b:	e8 58 f8 ff ff       	call   800ce8 <sys_page_map>
  801490:	89 c7                	mov    %eax,%edi
  801492:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801495:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801497:	85 ff                	test   %edi,%edi
  801499:	79 1d                	jns    8014b8 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	53                   	push   %ebx
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 84 f8 ff ff       	call   800d2a <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a6:	83 c4 08             	add    $0x8,%esp
  8014a9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014ac:	6a 00                	push   $0x0
  8014ae:	e8 77 f8 ff ff       	call   800d2a <sys_page_unmap>
	return r;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	89 f8                	mov    %edi,%eax
}
  8014b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5f                   	pop    %edi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	53                   	push   %ebx
  8014c4:	83 ec 14             	sub    $0x14,%esp
  8014c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ca:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	53                   	push   %ebx
  8014cf:	e8 86 fd ff ff       	call   80125a <fd_lookup>
  8014d4:	83 c4 08             	add    $0x8,%esp
  8014d7:	89 c2                	mov    %eax,%edx
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 6d                	js     80154a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014dd:	83 ec 08             	sub    $0x8,%esp
  8014e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e7:	ff 30                	pushl  (%eax)
  8014e9:	e8 c2 fd ff ff       	call   8012b0 <dev_lookup>
  8014ee:	83 c4 10             	add    $0x10,%esp
  8014f1:	85 c0                	test   %eax,%eax
  8014f3:	78 4c                	js     801541 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f8:	8b 42 08             	mov    0x8(%edx),%eax
  8014fb:	83 e0 03             	and    $0x3,%eax
  8014fe:	83 f8 01             	cmp    $0x1,%eax
  801501:	75 21                	jne    801524 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801503:	a1 04 40 80 00       	mov    0x804004,%eax
  801508:	8b 40 48             	mov    0x48(%eax),%eax
  80150b:	83 ec 04             	sub    $0x4,%esp
  80150e:	53                   	push   %ebx
  80150f:	50                   	push   %eax
  801510:	68 5c 27 80 00       	push   $0x80275c
  801515:	e8 03 ee ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801522:	eb 26                	jmp    80154a <read+0x8a>
	}
	if (!dev->dev_read)
  801524:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801527:	8b 40 08             	mov    0x8(%eax),%eax
  80152a:	85 c0                	test   %eax,%eax
  80152c:	74 17                	je     801545 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	ff 75 10             	pushl  0x10(%ebp)
  801534:	ff 75 0c             	pushl  0xc(%ebp)
  801537:	52                   	push   %edx
  801538:	ff d0                	call   *%eax
  80153a:	89 c2                	mov    %eax,%edx
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	eb 09                	jmp    80154a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801541:	89 c2                	mov    %eax,%edx
  801543:	eb 05                	jmp    80154a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801545:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80154a:	89 d0                	mov    %edx,%eax
  80154c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154f:	c9                   	leave  
  801550:	c3                   	ret    

00801551 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801551:	55                   	push   %ebp
  801552:	89 e5                	mov    %esp,%ebp
  801554:	57                   	push   %edi
  801555:	56                   	push   %esi
  801556:	53                   	push   %ebx
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801560:	bb 00 00 00 00       	mov    $0x0,%ebx
  801565:	eb 21                	jmp    801588 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801567:	83 ec 04             	sub    $0x4,%esp
  80156a:	89 f0                	mov    %esi,%eax
  80156c:	29 d8                	sub    %ebx,%eax
  80156e:	50                   	push   %eax
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	03 45 0c             	add    0xc(%ebp),%eax
  801574:	50                   	push   %eax
  801575:	57                   	push   %edi
  801576:	e8 45 ff ff ff       	call   8014c0 <read>
		if (m < 0)
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 10                	js     801592 <readn+0x41>
			return m;
		if (m == 0)
  801582:	85 c0                	test   %eax,%eax
  801584:	74 0a                	je     801590 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801586:	01 c3                	add    %eax,%ebx
  801588:	39 f3                	cmp    %esi,%ebx
  80158a:	72 db                	jb     801567 <readn+0x16>
  80158c:	89 d8                	mov    %ebx,%eax
  80158e:	eb 02                	jmp    801592 <readn+0x41>
  801590:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801592:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5f                   	pop    %edi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    

0080159a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80159a:	55                   	push   %ebp
  80159b:	89 e5                	mov    %esp,%ebp
  80159d:	53                   	push   %ebx
  80159e:	83 ec 14             	sub    $0x14,%esp
  8015a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	53                   	push   %ebx
  8015a9:	e8 ac fc ff ff       	call   80125a <fd_lookup>
  8015ae:	83 c4 08             	add    $0x8,%esp
  8015b1:	89 c2                	mov    %eax,%edx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 68                	js     80161f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015bd:	50                   	push   %eax
  8015be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c1:	ff 30                	pushl  (%eax)
  8015c3:	e8 e8 fc ff ff       	call   8012b0 <dev_lookup>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	78 47                	js     801616 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015d2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d6:	75 21                	jne    8015f9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d8:	a1 04 40 80 00       	mov    0x804004,%eax
  8015dd:	8b 40 48             	mov    0x48(%eax),%eax
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	50                   	push   %eax
  8015e5:	68 78 27 80 00       	push   $0x802778
  8015ea:	e8 2e ed ff ff       	call   80031d <cprintf>
		return -E_INVAL;
  8015ef:	83 c4 10             	add    $0x10,%esp
  8015f2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f7:	eb 26                	jmp    80161f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ff:	85 d2                	test   %edx,%edx
  801601:	74 17                	je     80161a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801603:	83 ec 04             	sub    $0x4,%esp
  801606:	ff 75 10             	pushl  0x10(%ebp)
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	50                   	push   %eax
  80160d:	ff d2                	call   *%edx
  80160f:	89 c2                	mov    %eax,%edx
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	eb 09                	jmp    80161f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801616:	89 c2                	mov    %eax,%edx
  801618:	eb 05                	jmp    80161f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80161a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80161f:	89 d0                	mov    %edx,%eax
  801621:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <seek>:

int
seek(int fdnum, off_t offset)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80162c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	ff 75 08             	pushl  0x8(%ebp)
  801633:	e8 22 fc ff ff       	call   80125a <fd_lookup>
  801638:	83 c4 08             	add    $0x8,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 0e                	js     80164d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80163f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801642:	8b 55 0c             	mov    0xc(%ebp),%edx
  801645:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801648:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164d:	c9                   	leave  
  80164e:	c3                   	ret    

0080164f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	53                   	push   %ebx
  801653:	83 ec 14             	sub    $0x14,%esp
  801656:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801659:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80165c:	50                   	push   %eax
  80165d:	53                   	push   %ebx
  80165e:	e8 f7 fb ff ff       	call   80125a <fd_lookup>
  801663:	83 c4 08             	add    $0x8,%esp
  801666:	89 c2                	mov    %eax,%edx
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 65                	js     8016d1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166c:	83 ec 08             	sub    $0x8,%esp
  80166f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801672:	50                   	push   %eax
  801673:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801676:	ff 30                	pushl  (%eax)
  801678:	e8 33 fc ff ff       	call   8012b0 <dev_lookup>
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	85 c0                	test   %eax,%eax
  801682:	78 44                	js     8016c8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801684:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801687:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80168b:	75 21                	jne    8016ae <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80168d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801692:	8b 40 48             	mov    0x48(%eax),%eax
  801695:	83 ec 04             	sub    $0x4,%esp
  801698:	53                   	push   %ebx
  801699:	50                   	push   %eax
  80169a:	68 38 27 80 00       	push   $0x802738
  80169f:	e8 79 ec ff ff       	call   80031d <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016ac:	eb 23                	jmp    8016d1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b1:	8b 52 18             	mov    0x18(%edx),%edx
  8016b4:	85 d2                	test   %edx,%edx
  8016b6:	74 14                	je     8016cc <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	ff 75 0c             	pushl  0xc(%ebp)
  8016be:	50                   	push   %eax
  8016bf:	ff d2                	call   *%edx
  8016c1:	89 c2                	mov    %eax,%edx
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	eb 09                	jmp    8016d1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	eb 05                	jmp    8016d1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016d1:	89 d0                	mov    %edx,%eax
  8016d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 14             	sub    $0x14,%esp
  8016df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e5:	50                   	push   %eax
  8016e6:	ff 75 08             	pushl  0x8(%ebp)
  8016e9:	e8 6c fb ff ff       	call   80125a <fd_lookup>
  8016ee:	83 c4 08             	add    $0x8,%esp
  8016f1:	89 c2                	mov    %eax,%edx
  8016f3:	85 c0                	test   %eax,%eax
  8016f5:	78 58                	js     80174f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f7:	83 ec 08             	sub    $0x8,%esp
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801701:	ff 30                	pushl  (%eax)
  801703:	e8 a8 fb ff ff       	call   8012b0 <dev_lookup>
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 37                	js     801746 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80170f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801712:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801716:	74 32                	je     80174a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801718:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80171b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801722:	00 00 00 
	stat->st_isdir = 0;
  801725:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80172c:	00 00 00 
	stat->st_dev = dev;
  80172f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	53                   	push   %ebx
  801739:	ff 75 f0             	pushl  -0x10(%ebp)
  80173c:	ff 50 14             	call   *0x14(%eax)
  80173f:	89 c2                	mov    %eax,%edx
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	eb 09                	jmp    80174f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	89 c2                	mov    %eax,%edx
  801748:	eb 05                	jmp    80174f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80174a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174f:	89 d0                	mov    %edx,%eax
  801751:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801754:	c9                   	leave  
  801755:	c3                   	ret    

00801756 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	56                   	push   %esi
  80175a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80175b:	83 ec 08             	sub    $0x8,%esp
  80175e:	6a 00                	push   $0x0
  801760:	ff 75 08             	pushl  0x8(%ebp)
  801763:	e8 d6 01 00 00       	call   80193e <open>
  801768:	89 c3                	mov    %eax,%ebx
  80176a:	83 c4 10             	add    $0x10,%esp
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 1b                	js     80178c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	50                   	push   %eax
  801778:	e8 5b ff ff ff       	call   8016d8 <fstat>
  80177d:	89 c6                	mov    %eax,%esi
	close(fd);
  80177f:	89 1c 24             	mov    %ebx,(%esp)
  801782:	e8 fd fb ff ff       	call   801384 <close>
	return r;
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	89 f0                	mov    %esi,%eax
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    

00801793 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801793:	55                   	push   %ebp
  801794:	89 e5                	mov    %esp,%ebp
  801796:	56                   	push   %esi
  801797:	53                   	push   %ebx
  801798:	89 c6                	mov    %eax,%esi
  80179a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80179c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a3:	75 12                	jne    8017b7 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	6a 01                	push   $0x1
  8017aa:	e8 fc f9 ff ff       	call   8011ab <ipc_find_env>
  8017af:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b7:	6a 07                	push   $0x7
  8017b9:	68 00 50 80 00       	push   $0x805000
  8017be:	56                   	push   %esi
  8017bf:	ff 35 00 40 80 00    	pushl  0x804000
  8017c5:	e8 8d f9 ff ff       	call   801157 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017ca:	83 c4 0c             	add    $0xc,%esp
  8017cd:	6a 00                	push   $0x0
  8017cf:	53                   	push   %ebx
  8017d0:	6a 00                	push   $0x0
  8017d2:	e8 19 f9 ff ff       	call   8010f0 <ipc_recv>
}
  8017d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017da:	5b                   	pop    %ebx
  8017db:	5e                   	pop    %esi
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801801:	e8 8d ff ff ff       	call   801793 <fsipc>
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	8b 40 0c             	mov    0xc(%eax),%eax
  801814:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801819:	ba 00 00 00 00       	mov    $0x0,%edx
  80181e:	b8 06 00 00 00       	mov    $0x6,%eax
  801823:	e8 6b ff ff ff       	call   801793 <fsipc>
}
  801828:	c9                   	leave  
  801829:	c3                   	ret    

0080182a <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	53                   	push   %ebx
  80182e:	83 ec 04             	sub    $0x4,%esp
  801831:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 40 0c             	mov    0xc(%eax),%eax
  80183a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 05 00 00 00       	mov    $0x5,%eax
  801849:	e8 45 ff ff ff       	call   801793 <fsipc>
  80184e:	85 c0                	test   %eax,%eax
  801850:	78 2c                	js     80187e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	68 00 50 80 00       	push   $0x805000
  80185a:	53                   	push   %ebx
  80185b:	e8 42 f0 ff ff       	call   8008a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801860:	a1 80 50 80 00       	mov    0x805080,%eax
  801865:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186b:	a1 84 50 80 00       	mov    0x805084,%eax
  801870:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801876:	83 c4 10             	add    $0x10,%esp
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 0c             	sub    $0xc,%esp
  801889:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80188c:	8b 55 08             	mov    0x8(%ebp),%edx
  80188f:	8b 52 0c             	mov    0xc(%edx),%edx
  801892:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801898:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80189d:	50                   	push   %eax
  80189e:	ff 75 0c             	pushl  0xc(%ebp)
  8018a1:	68 08 50 80 00       	push   $0x805008
  8018a6:	e8 89 f1 ff ff       	call   800a34 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b5:	e8 d9 fe ff ff       	call   801793 <fsipc>

}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	56                   	push   %esi
  8018c0:	53                   	push   %ebx
  8018c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018cf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018da:	b8 03 00 00 00       	mov    $0x3,%eax
  8018df:	e8 af fe ff ff       	call   801793 <fsipc>
  8018e4:	89 c3                	mov    %eax,%ebx
  8018e6:	85 c0                	test   %eax,%eax
  8018e8:	78 4b                	js     801935 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018ea:	39 c6                	cmp    %eax,%esi
  8018ec:	73 16                	jae    801904 <devfile_read+0x48>
  8018ee:	68 a8 27 80 00       	push   $0x8027a8
  8018f3:	68 af 27 80 00       	push   $0x8027af
  8018f8:	6a 7c                	push   $0x7c
  8018fa:	68 c4 27 80 00       	push   $0x8027c4
  8018ff:	e8 40 e9 ff ff       	call   800244 <_panic>
	assert(r <= PGSIZE);
  801904:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801909:	7e 16                	jle    801921 <devfile_read+0x65>
  80190b:	68 cf 27 80 00       	push   $0x8027cf
  801910:	68 af 27 80 00       	push   $0x8027af
  801915:	6a 7d                	push   $0x7d
  801917:	68 c4 27 80 00       	push   $0x8027c4
  80191c:	e8 23 e9 ff ff       	call   800244 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801921:	83 ec 04             	sub    $0x4,%esp
  801924:	50                   	push   %eax
  801925:	68 00 50 80 00       	push   $0x805000
  80192a:	ff 75 0c             	pushl  0xc(%ebp)
  80192d:	e8 02 f1 ff ff       	call   800a34 <memmove>
	return r;
  801932:	83 c4 10             	add    $0x10,%esp
}
  801935:	89 d8                	mov    %ebx,%eax
  801937:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5d                   	pop    %ebp
  80193d:	c3                   	ret    

0080193e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 20             	sub    $0x20,%esp
  801945:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801948:	53                   	push   %ebx
  801949:	e8 1b ef ff ff       	call   800869 <strlen>
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801956:	7f 67                	jg     8019bf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195e:	50                   	push   %eax
  80195f:	e8 a7 f8 ff ff       	call   80120b <fd_alloc>
  801964:	83 c4 10             	add    $0x10,%esp
		return r;
  801967:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801969:	85 c0                	test   %eax,%eax
  80196b:	78 57                	js     8019c4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80196d:	83 ec 08             	sub    $0x8,%esp
  801970:	53                   	push   %ebx
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	e8 27 ef ff ff       	call   8008a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80197b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80197e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801983:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801986:	b8 01 00 00 00       	mov    $0x1,%eax
  80198b:	e8 03 fe ff ff       	call   801793 <fsipc>
  801990:	89 c3                	mov    %eax,%ebx
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	85 c0                	test   %eax,%eax
  801997:	79 14                	jns    8019ad <open+0x6f>
		fd_close(fd, 0);
  801999:	83 ec 08             	sub    $0x8,%esp
  80199c:	6a 00                	push   $0x0
  80199e:	ff 75 f4             	pushl  -0xc(%ebp)
  8019a1:	e8 5d f9 ff ff       	call   801303 <fd_close>
		return r;
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	89 da                	mov    %ebx,%edx
  8019ab:	eb 17                	jmp    8019c4 <open+0x86>
	}

	return fd2num(fd);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b3:	e8 2c f8 ff ff       	call   8011e4 <fd2num>
  8019b8:	89 c2                	mov    %eax,%edx
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	eb 05                	jmp    8019c4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019bf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019c4:	89 d0                	mov    %edx,%eax
  8019c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019db:	e8 b3 fd ff ff       	call   801793 <fsipc>
}
  8019e0:	c9                   	leave  
  8019e1:	c3                   	ret    

008019e2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8019e2:	55                   	push   %ebp
  8019e3:	89 e5                	mov    %esp,%ebp
  8019e5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8019e8:	89 d0                	mov    %edx,%eax
  8019ea:	c1 e8 16             	shr    $0x16,%eax
  8019ed:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8019f4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8019f9:	f6 c1 01             	test   $0x1,%cl
  8019fc:	74 1d                	je     801a1b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8019fe:	c1 ea 0c             	shr    $0xc,%edx
  801a01:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801a08:	f6 c2 01             	test   $0x1,%dl
  801a0b:	74 0e                	je     801a1b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801a0d:	c1 ea 0c             	shr    $0xc,%edx
  801a10:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801a17:	ef 
  801a18:	0f b7 c0             	movzwl %ax,%eax
}
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a25:	83 ec 0c             	sub    $0xc,%esp
  801a28:	ff 75 08             	pushl  0x8(%ebp)
  801a2b:	e8 c4 f7 ff ff       	call   8011f4 <fd2data>
  801a30:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a32:	83 c4 08             	add    $0x8,%esp
  801a35:	68 db 27 80 00       	push   $0x8027db
  801a3a:	53                   	push   %ebx
  801a3b:	e8 62 ee ff ff       	call   8008a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a40:	8b 46 04             	mov    0x4(%esi),%eax
  801a43:	2b 06                	sub    (%esi),%eax
  801a45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a4b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a52:	00 00 00 
	stat->st_dev = &devpipe;
  801a55:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a5c:	30 80 00 
	return 0;
}
  801a5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    

00801a6b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a75:	53                   	push   %ebx
  801a76:	6a 00                	push   $0x0
  801a78:	e8 ad f2 ff ff       	call   800d2a <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a7d:	89 1c 24             	mov    %ebx,(%esp)
  801a80:	e8 6f f7 ff ff       	call   8011f4 <fd2data>
  801a85:	83 c4 08             	add    $0x8,%esp
  801a88:	50                   	push   %eax
  801a89:	6a 00                	push   $0x0
  801a8b:	e8 9a f2 ff ff       	call   800d2a <sys_page_unmap>
}
  801a90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a93:	c9                   	leave  
  801a94:	c3                   	ret    

00801a95 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a95:	55                   	push   %ebp
  801a96:	89 e5                	mov    %esp,%ebp
  801a98:	57                   	push   %edi
  801a99:	56                   	push   %esi
  801a9a:	53                   	push   %ebx
  801a9b:	83 ec 1c             	sub    $0x1c,%esp
  801a9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801aa1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801aa3:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab1:	e8 2c ff ff ff       	call   8019e2 <pageref>
  801ab6:	89 c3                	mov    %eax,%ebx
  801ab8:	89 3c 24             	mov    %edi,(%esp)
  801abb:	e8 22 ff ff ff       	call   8019e2 <pageref>
  801ac0:	83 c4 10             	add    $0x10,%esp
  801ac3:	39 c3                	cmp    %eax,%ebx
  801ac5:	0f 94 c1             	sete   %cl
  801ac8:	0f b6 c9             	movzbl %cl,%ecx
  801acb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ace:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ad4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ad7:	39 ce                	cmp    %ecx,%esi
  801ad9:	74 1b                	je     801af6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801adb:	39 c3                	cmp    %eax,%ebx
  801add:	75 c4                	jne    801aa3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801adf:	8b 42 58             	mov    0x58(%edx),%eax
  801ae2:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ae5:	50                   	push   %eax
  801ae6:	56                   	push   %esi
  801ae7:	68 e2 27 80 00       	push   $0x8027e2
  801aec:	e8 2c e8 ff ff       	call   80031d <cprintf>
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	eb ad                	jmp    801aa3 <_pipeisclosed+0xe>
	}
}
  801af6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5f                   	pop    %edi
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	57                   	push   %edi
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	83 ec 28             	sub    $0x28,%esp
  801b0a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b0d:	56                   	push   %esi
  801b0e:	e8 e1 f6 ff ff       	call   8011f4 <fd2data>
  801b13:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	bf 00 00 00 00       	mov    $0x0,%edi
  801b1d:	eb 4b                	jmp    801b6a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b1f:	89 da                	mov    %ebx,%edx
  801b21:	89 f0                	mov    %esi,%eax
  801b23:	e8 6d ff ff ff       	call   801a95 <_pipeisclosed>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	75 48                	jne    801b74 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b2c:	e8 55 f1 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b31:	8b 43 04             	mov    0x4(%ebx),%eax
  801b34:	8b 0b                	mov    (%ebx),%ecx
  801b36:	8d 51 20             	lea    0x20(%ecx),%edx
  801b39:	39 d0                	cmp    %edx,%eax
  801b3b:	73 e2                	jae    801b1f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b40:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b44:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b47:	89 c2                	mov    %eax,%edx
  801b49:	c1 fa 1f             	sar    $0x1f,%edx
  801b4c:	89 d1                	mov    %edx,%ecx
  801b4e:	c1 e9 1b             	shr    $0x1b,%ecx
  801b51:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b54:	83 e2 1f             	and    $0x1f,%edx
  801b57:	29 ca                	sub    %ecx,%edx
  801b59:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b5d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b61:	83 c0 01             	add    $0x1,%eax
  801b64:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b67:	83 c7 01             	add    $0x1,%edi
  801b6a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b6d:	75 c2                	jne    801b31 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b6f:	8b 45 10             	mov    0x10(%ebp),%eax
  801b72:	eb 05                	jmp    801b79 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b74:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b7c:	5b                   	pop    %ebx
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    

00801b81 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
  801b84:	57                   	push   %edi
  801b85:	56                   	push   %esi
  801b86:	53                   	push   %ebx
  801b87:	83 ec 18             	sub    $0x18,%esp
  801b8a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b8d:	57                   	push   %edi
  801b8e:	e8 61 f6 ff ff       	call   8011f4 <fd2data>
  801b93:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b95:	83 c4 10             	add    $0x10,%esp
  801b98:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b9d:	eb 3d                	jmp    801bdc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b9f:	85 db                	test   %ebx,%ebx
  801ba1:	74 04                	je     801ba7 <devpipe_read+0x26>
				return i;
  801ba3:	89 d8                	mov    %ebx,%eax
  801ba5:	eb 44                	jmp    801beb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ba7:	89 f2                	mov    %esi,%edx
  801ba9:	89 f8                	mov    %edi,%eax
  801bab:	e8 e5 fe ff ff       	call   801a95 <_pipeisclosed>
  801bb0:	85 c0                	test   %eax,%eax
  801bb2:	75 32                	jne    801be6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bb4:	e8 cd f0 ff ff       	call   800c86 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bb9:	8b 06                	mov    (%esi),%eax
  801bbb:	3b 46 04             	cmp    0x4(%esi),%eax
  801bbe:	74 df                	je     801b9f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bc0:	99                   	cltd   
  801bc1:	c1 ea 1b             	shr    $0x1b,%edx
  801bc4:	01 d0                	add    %edx,%eax
  801bc6:	83 e0 1f             	and    $0x1f,%eax
  801bc9:	29 d0                	sub    %edx,%eax
  801bcb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bd6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd9:	83 c3 01             	add    $0x1,%ebx
  801bdc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bdf:	75 d8                	jne    801bb9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801be1:	8b 45 10             	mov    0x10(%ebp),%eax
  801be4:	eb 05                	jmp    801beb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	56                   	push   %esi
  801bf7:	53                   	push   %ebx
  801bf8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bfe:	50                   	push   %eax
  801bff:	e8 07 f6 ff ff       	call   80120b <fd_alloc>
  801c04:	83 c4 10             	add    $0x10,%esp
  801c07:	89 c2                	mov    %eax,%edx
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	0f 88 2c 01 00 00    	js     801d3d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c11:	83 ec 04             	sub    $0x4,%esp
  801c14:	68 07 04 00 00       	push   $0x407
  801c19:	ff 75 f4             	pushl  -0xc(%ebp)
  801c1c:	6a 00                	push   $0x0
  801c1e:	e8 82 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c23:	83 c4 10             	add    $0x10,%esp
  801c26:	89 c2                	mov    %eax,%edx
  801c28:	85 c0                	test   %eax,%eax
  801c2a:	0f 88 0d 01 00 00    	js     801d3d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c30:	83 ec 0c             	sub    $0xc,%esp
  801c33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c36:	50                   	push   %eax
  801c37:	e8 cf f5 ff ff       	call   80120b <fd_alloc>
  801c3c:	89 c3                	mov    %eax,%ebx
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	85 c0                	test   %eax,%eax
  801c43:	0f 88 e2 00 00 00    	js     801d2b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c49:	83 ec 04             	sub    $0x4,%esp
  801c4c:	68 07 04 00 00       	push   $0x407
  801c51:	ff 75 f0             	pushl  -0x10(%ebp)
  801c54:	6a 00                	push   $0x0
  801c56:	e8 4a f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c5b:	89 c3                	mov    %eax,%ebx
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	0f 88 c3 00 00 00    	js     801d2b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c68:	83 ec 0c             	sub    $0xc,%esp
  801c6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6e:	e8 81 f5 ff ff       	call   8011f4 <fd2data>
  801c73:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c75:	83 c4 0c             	add    $0xc,%esp
  801c78:	68 07 04 00 00       	push   $0x407
  801c7d:	50                   	push   %eax
  801c7e:	6a 00                	push   $0x0
  801c80:	e8 20 f0 ff ff       	call   800ca5 <sys_page_alloc>
  801c85:	89 c3                	mov    %eax,%ebx
  801c87:	83 c4 10             	add    $0x10,%esp
  801c8a:	85 c0                	test   %eax,%eax
  801c8c:	0f 88 89 00 00 00    	js     801d1b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	ff 75 f0             	pushl  -0x10(%ebp)
  801c98:	e8 57 f5 ff ff       	call   8011f4 <fd2data>
  801c9d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ca4:	50                   	push   %eax
  801ca5:	6a 00                	push   $0x0
  801ca7:	56                   	push   %esi
  801ca8:	6a 00                	push   $0x0
  801caa:	e8 39 f0 ff ff       	call   800ce8 <sys_page_map>
  801caf:	89 c3                	mov    %eax,%ebx
  801cb1:	83 c4 20             	add    $0x20,%esp
  801cb4:	85 c0                	test   %eax,%eax
  801cb6:	78 55                	js     801d0d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cb8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ccd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cd6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cd8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cdb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ce2:	83 ec 0c             	sub    $0xc,%esp
  801ce5:	ff 75 f4             	pushl  -0xc(%ebp)
  801ce8:	e8 f7 f4 ff ff       	call   8011e4 <fd2num>
  801ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cf2:	83 c4 04             	add    $0x4,%esp
  801cf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf8:	e8 e7 f4 ff ff       	call   8011e4 <fd2num>
  801cfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d00:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d03:	83 c4 10             	add    $0x10,%esp
  801d06:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0b:	eb 30                	jmp    801d3d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d0d:	83 ec 08             	sub    $0x8,%esp
  801d10:	56                   	push   %esi
  801d11:	6a 00                	push   $0x0
  801d13:	e8 12 f0 ff ff       	call   800d2a <sys_page_unmap>
  801d18:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d1b:	83 ec 08             	sub    $0x8,%esp
  801d1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d21:	6a 00                	push   $0x0
  801d23:	e8 02 f0 ff ff       	call   800d2a <sys_page_unmap>
  801d28:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d2b:	83 ec 08             	sub    $0x8,%esp
  801d2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d31:	6a 00                	push   $0x0
  801d33:	e8 f2 ef ff ff       	call   800d2a <sys_page_unmap>
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d3d:	89 d0                	mov    %edx,%eax
  801d3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d42:	5b                   	pop    %ebx
  801d43:	5e                   	pop    %esi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	ff 75 08             	pushl  0x8(%ebp)
  801d53:	e8 02 f5 ff ff       	call   80125a <fd_lookup>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 18                	js     801d77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d5f:	83 ec 0c             	sub    $0xc,%esp
  801d62:	ff 75 f4             	pushl  -0xc(%ebp)
  801d65:	e8 8a f4 ff ff       	call   8011f4 <fd2data>
	return _pipeisclosed(fd, p);
  801d6a:	89 c2                	mov    %eax,%edx
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	e8 21 fd ff ff       	call   801a95 <_pipeisclosed>
  801d74:	83 c4 10             	add    $0x10,%esp
}
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    

00801d83 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d83:	55                   	push   %ebp
  801d84:	89 e5                	mov    %esp,%ebp
  801d86:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d89:	68 fa 27 80 00       	push   $0x8027fa
  801d8e:	ff 75 0c             	pushl  0xc(%ebp)
  801d91:	e8 0c eb ff ff       	call   8008a2 <strcpy>
	return 0;
}
  801d96:	b8 00 00 00 00       	mov    $0x0,%eax
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	57                   	push   %edi
  801da1:	56                   	push   %esi
  801da2:	53                   	push   %ebx
  801da3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801db4:	eb 2d                	jmp    801de3 <devcons_write+0x46>
		m = n - tot;
  801db6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801db9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dbb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801dbe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801dc3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dc6:	83 ec 04             	sub    $0x4,%esp
  801dc9:	53                   	push   %ebx
  801dca:	03 45 0c             	add    0xc(%ebp),%eax
  801dcd:	50                   	push   %eax
  801dce:	57                   	push   %edi
  801dcf:	e8 60 ec ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  801dd4:	83 c4 08             	add    $0x8,%esp
  801dd7:	53                   	push   %ebx
  801dd8:	57                   	push   %edi
  801dd9:	e8 0b ee ff ff       	call   800be9 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dde:	01 de                	add    %ebx,%esi
  801de0:	83 c4 10             	add    $0x10,%esp
  801de3:	89 f0                	mov    %esi,%eax
  801de5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801de8:	72 cc                	jb     801db6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ded:	5b                   	pop    %ebx
  801dee:	5e                   	pop    %esi
  801def:	5f                   	pop    %edi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	83 ec 08             	sub    $0x8,%esp
  801df8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dfd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e01:	74 2a                	je     801e2d <devcons_read+0x3b>
  801e03:	eb 05                	jmp    801e0a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e05:	e8 7c ee ff ff       	call   800c86 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e0a:	e8 f8 ed ff ff       	call   800c07 <sys_cgetc>
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	74 f2                	je     801e05 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e13:	85 c0                	test   %eax,%eax
  801e15:	78 16                	js     801e2d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e17:	83 f8 04             	cmp    $0x4,%eax
  801e1a:	74 0c                	je     801e28 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e1f:	88 02                	mov    %al,(%edx)
	return 1;
  801e21:	b8 01 00 00 00       	mov    $0x1,%eax
  801e26:	eb 05                	jmp    801e2d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e2d:	c9                   	leave  
  801e2e:	c3                   	ret    

00801e2f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e2f:	55                   	push   %ebp
  801e30:	89 e5                	mov    %esp,%ebp
  801e32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e35:	8b 45 08             	mov    0x8(%ebp),%eax
  801e38:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e3b:	6a 01                	push   $0x1
  801e3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e40:	50                   	push   %eax
  801e41:	e8 a3 ed ff ff       	call   800be9 <sys_cputs>
}
  801e46:	83 c4 10             	add    $0x10,%esp
  801e49:	c9                   	leave  
  801e4a:	c3                   	ret    

00801e4b <getchar>:

int
getchar(void)
{
  801e4b:	55                   	push   %ebp
  801e4c:	89 e5                	mov    %esp,%ebp
  801e4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e51:	6a 01                	push   $0x1
  801e53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e56:	50                   	push   %eax
  801e57:	6a 00                	push   $0x0
  801e59:	e8 62 f6 ff ff       	call   8014c0 <read>
	if (r < 0)
  801e5e:	83 c4 10             	add    $0x10,%esp
  801e61:	85 c0                	test   %eax,%eax
  801e63:	78 0f                	js     801e74 <getchar+0x29>
		return r;
	if (r < 1)
  801e65:	85 c0                	test   %eax,%eax
  801e67:	7e 06                	jle    801e6f <getchar+0x24>
		return -E_EOF;
	return c;
  801e69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e6d:	eb 05                	jmp    801e74 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e74:	c9                   	leave  
  801e75:	c3                   	ret    

00801e76 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e76:	55                   	push   %ebp
  801e77:	89 e5                	mov    %esp,%ebp
  801e79:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7f:	50                   	push   %eax
  801e80:	ff 75 08             	pushl  0x8(%ebp)
  801e83:	e8 d2 f3 ff ff       	call   80125a <fd_lookup>
  801e88:	83 c4 10             	add    $0x10,%esp
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	78 11                	js     801ea0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e98:	39 10                	cmp    %edx,(%eax)
  801e9a:	0f 94 c0             	sete   %al
  801e9d:	0f b6 c0             	movzbl %al,%eax
}
  801ea0:	c9                   	leave  
  801ea1:	c3                   	ret    

00801ea2 <opencons>:

int
opencons(void)
{
  801ea2:	55                   	push   %ebp
  801ea3:	89 e5                	mov    %esp,%ebp
  801ea5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eab:	50                   	push   %eax
  801eac:	e8 5a f3 ff ff       	call   80120b <fd_alloc>
  801eb1:	83 c4 10             	add    $0x10,%esp
		return r;
  801eb4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 3e                	js     801ef8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eba:	83 ec 04             	sub    $0x4,%esp
  801ebd:	68 07 04 00 00       	push   $0x407
  801ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec5:	6a 00                	push   $0x0
  801ec7:	e8 d9 ed ff ff       	call   800ca5 <sys_page_alloc>
  801ecc:	83 c4 10             	add    $0x10,%esp
		return r;
  801ecf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ed1:	85 c0                	test   %eax,%eax
  801ed3:	78 23                	js     801ef8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ed5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801edb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ede:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	50                   	push   %eax
  801eee:	e8 f1 f2 ff ff       	call   8011e4 <fd2num>
  801ef3:	89 c2                	mov    %eax,%edx
  801ef5:	83 c4 10             	add    $0x10,%esp
}
  801ef8:	89 d0                	mov    %edx,%eax
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f02:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f09:	75 2e                	jne    801f39 <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801f0b:	e8 57 ed ff ff       	call   800c67 <sys_getenvid>
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	68 07 0e 00 00       	push   $0xe07
  801f18:	68 00 f0 bf ee       	push   $0xeebff000
  801f1d:	50                   	push   %eax
  801f1e:	e8 82 ed ff ff       	call   800ca5 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f23:	e8 3f ed ff ff       	call   800c67 <sys_getenvid>
  801f28:	83 c4 08             	add    $0x8,%esp
  801f2b:	68 43 1f 80 00       	push   $0x801f43
  801f30:	50                   	push   %eax
  801f31:	e8 ba ee ff ff       	call   800df0 <sys_env_set_pgfault_upcall>
  801f36:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f39:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3c:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801f41:	c9                   	leave  
  801f42:	c3                   	ret    

00801f43 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f43:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f44:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f49:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f4b:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801f4e:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801f52:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801f56:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801f59:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801f5c:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801f5d:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801f60:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801f61:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801f62:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801f66:	c3                   	ret    
  801f67:	66 90                	xchg   %ax,%ax
  801f69:	66 90                	xchg   %ax,%ax
  801f6b:	66 90                	xchg   %ax,%ax
  801f6d:	66 90                	xchg   %ax,%ax
  801f6f:	90                   	nop

00801f70 <__udivdi3>:
  801f70:	55                   	push   %ebp
  801f71:	57                   	push   %edi
  801f72:	56                   	push   %esi
  801f73:	53                   	push   %ebx
  801f74:	83 ec 1c             	sub    $0x1c,%esp
  801f77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f83:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f87:	85 f6                	test   %esi,%esi
  801f89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f8d:	89 ca                	mov    %ecx,%edx
  801f8f:	89 f8                	mov    %edi,%eax
  801f91:	75 3d                	jne    801fd0 <__udivdi3+0x60>
  801f93:	39 cf                	cmp    %ecx,%edi
  801f95:	0f 87 c5 00 00 00    	ja     802060 <__udivdi3+0xf0>
  801f9b:	85 ff                	test   %edi,%edi
  801f9d:	89 fd                	mov    %edi,%ebp
  801f9f:	75 0b                	jne    801fac <__udivdi3+0x3c>
  801fa1:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa6:	31 d2                	xor    %edx,%edx
  801fa8:	f7 f7                	div    %edi
  801faa:	89 c5                	mov    %eax,%ebp
  801fac:	89 c8                	mov    %ecx,%eax
  801fae:	31 d2                	xor    %edx,%edx
  801fb0:	f7 f5                	div    %ebp
  801fb2:	89 c1                	mov    %eax,%ecx
  801fb4:	89 d8                	mov    %ebx,%eax
  801fb6:	89 cf                	mov    %ecx,%edi
  801fb8:	f7 f5                	div    %ebp
  801fba:	89 c3                	mov    %eax,%ebx
  801fbc:	89 d8                	mov    %ebx,%eax
  801fbe:	89 fa                	mov    %edi,%edx
  801fc0:	83 c4 1c             	add    $0x1c,%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    
  801fc8:	90                   	nop
  801fc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	39 ce                	cmp    %ecx,%esi
  801fd2:	77 74                	ja     802048 <__udivdi3+0xd8>
  801fd4:	0f bd fe             	bsr    %esi,%edi
  801fd7:	83 f7 1f             	xor    $0x1f,%edi
  801fda:	0f 84 98 00 00 00    	je     802078 <__udivdi3+0x108>
  801fe0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	89 c5                	mov    %eax,%ebp
  801fe9:	29 fb                	sub    %edi,%ebx
  801feb:	d3 e6                	shl    %cl,%esi
  801fed:	89 d9                	mov    %ebx,%ecx
  801fef:	d3 ed                	shr    %cl,%ebp
  801ff1:	89 f9                	mov    %edi,%ecx
  801ff3:	d3 e0                	shl    %cl,%eax
  801ff5:	09 ee                	or     %ebp,%esi
  801ff7:	89 d9                	mov    %ebx,%ecx
  801ff9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ffd:	89 d5                	mov    %edx,%ebp
  801fff:	8b 44 24 08          	mov    0x8(%esp),%eax
  802003:	d3 ed                	shr    %cl,%ebp
  802005:	89 f9                	mov    %edi,%ecx
  802007:	d3 e2                	shl    %cl,%edx
  802009:	89 d9                	mov    %ebx,%ecx
  80200b:	d3 e8                	shr    %cl,%eax
  80200d:	09 c2                	or     %eax,%edx
  80200f:	89 d0                	mov    %edx,%eax
  802011:	89 ea                	mov    %ebp,%edx
  802013:	f7 f6                	div    %esi
  802015:	89 d5                	mov    %edx,%ebp
  802017:	89 c3                	mov    %eax,%ebx
  802019:	f7 64 24 0c          	mull   0xc(%esp)
  80201d:	39 d5                	cmp    %edx,%ebp
  80201f:	72 10                	jb     802031 <__udivdi3+0xc1>
  802021:	8b 74 24 08          	mov    0x8(%esp),%esi
  802025:	89 f9                	mov    %edi,%ecx
  802027:	d3 e6                	shl    %cl,%esi
  802029:	39 c6                	cmp    %eax,%esi
  80202b:	73 07                	jae    802034 <__udivdi3+0xc4>
  80202d:	39 d5                	cmp    %edx,%ebp
  80202f:	75 03                	jne    802034 <__udivdi3+0xc4>
  802031:	83 eb 01             	sub    $0x1,%ebx
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 d8                	mov    %ebx,%eax
  802038:	89 fa                	mov    %edi,%edx
  80203a:	83 c4 1c             	add    $0x1c,%esp
  80203d:	5b                   	pop    %ebx
  80203e:	5e                   	pop    %esi
  80203f:	5f                   	pop    %edi
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
  802042:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802048:	31 ff                	xor    %edi,%edi
  80204a:	31 db                	xor    %ebx,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d8                	mov    %ebx,%eax
  802062:	f7 f7                	div    %edi
  802064:	31 ff                	xor    %edi,%edi
  802066:	89 c3                	mov    %eax,%ebx
  802068:	89 d8                	mov    %ebx,%eax
  80206a:	89 fa                	mov    %edi,%edx
  80206c:	83 c4 1c             	add    $0x1c,%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    
  802074:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802078:	39 ce                	cmp    %ecx,%esi
  80207a:	72 0c                	jb     802088 <__udivdi3+0x118>
  80207c:	31 db                	xor    %ebx,%ebx
  80207e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802082:	0f 87 34 ff ff ff    	ja     801fbc <__udivdi3+0x4c>
  802088:	bb 01 00 00 00       	mov    $0x1,%ebx
  80208d:	e9 2a ff ff ff       	jmp    801fbc <__udivdi3+0x4c>
  802092:	66 90                	xchg   %ax,%ax
  802094:	66 90                	xchg   %ax,%ax
  802096:	66 90                	xchg   %ax,%ax
  802098:	66 90                	xchg   %ax,%ax
  80209a:	66 90                	xchg   %ax,%ax
  80209c:	66 90                	xchg   %ax,%ax
  80209e:	66 90                	xchg   %ax,%ax

008020a0 <__umoddi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	57                   	push   %edi
  8020a2:	56                   	push   %esi
  8020a3:	53                   	push   %ebx
  8020a4:	83 ec 1c             	sub    $0x1c,%esp
  8020a7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020ab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020af:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020b7:	85 d2                	test   %edx,%edx
  8020b9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f3                	mov    %esi,%ebx
  8020c3:	89 3c 24             	mov    %edi,(%esp)
  8020c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020ca:	75 1c                	jne    8020e8 <__umoddi3+0x48>
  8020cc:	39 f7                	cmp    %esi,%edi
  8020ce:	76 50                	jbe    802120 <__umoddi3+0x80>
  8020d0:	89 c8                	mov    %ecx,%eax
  8020d2:	89 f2                	mov    %esi,%edx
  8020d4:	f7 f7                	div    %edi
  8020d6:	89 d0                	mov    %edx,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	83 c4 1c             	add    $0x1c,%esp
  8020dd:	5b                   	pop    %ebx
  8020de:	5e                   	pop    %esi
  8020df:	5f                   	pop    %edi
  8020e0:	5d                   	pop    %ebp
  8020e1:	c3                   	ret    
  8020e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020e8:	39 f2                	cmp    %esi,%edx
  8020ea:	89 d0                	mov    %edx,%eax
  8020ec:	77 52                	ja     802140 <__umoddi3+0xa0>
  8020ee:	0f bd ea             	bsr    %edx,%ebp
  8020f1:	83 f5 1f             	xor    $0x1f,%ebp
  8020f4:	75 5a                	jne    802150 <__umoddi3+0xb0>
  8020f6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020fa:	0f 82 e0 00 00 00    	jb     8021e0 <__umoddi3+0x140>
  802100:	39 0c 24             	cmp    %ecx,(%esp)
  802103:	0f 86 d7 00 00 00    	jbe    8021e0 <__umoddi3+0x140>
  802109:	8b 44 24 08          	mov    0x8(%esp),%eax
  80210d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802111:	83 c4 1c             	add    $0x1c,%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	85 ff                	test   %edi,%edi
  802122:	89 fd                	mov    %edi,%ebp
  802124:	75 0b                	jne    802131 <__umoddi3+0x91>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f7                	div    %edi
  80212f:	89 c5                	mov    %eax,%ebp
  802131:	89 f0                	mov    %esi,%eax
  802133:	31 d2                	xor    %edx,%edx
  802135:	f7 f5                	div    %ebp
  802137:	89 c8                	mov    %ecx,%eax
  802139:	f7 f5                	div    %ebp
  80213b:	89 d0                	mov    %edx,%eax
  80213d:	eb 99                	jmp    8020d8 <__umoddi3+0x38>
  80213f:	90                   	nop
  802140:	89 c8                	mov    %ecx,%eax
  802142:	89 f2                	mov    %esi,%edx
  802144:	83 c4 1c             	add    $0x1c,%esp
  802147:	5b                   	pop    %ebx
  802148:	5e                   	pop    %esi
  802149:	5f                   	pop    %edi
  80214a:	5d                   	pop    %ebp
  80214b:	c3                   	ret    
  80214c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802150:	8b 34 24             	mov    (%esp),%esi
  802153:	bf 20 00 00 00       	mov    $0x20,%edi
  802158:	89 e9                	mov    %ebp,%ecx
  80215a:	29 ef                	sub    %ebp,%edi
  80215c:	d3 e0                	shl    %cl,%eax
  80215e:	89 f9                	mov    %edi,%ecx
  802160:	89 f2                	mov    %esi,%edx
  802162:	d3 ea                	shr    %cl,%edx
  802164:	89 e9                	mov    %ebp,%ecx
  802166:	09 c2                	or     %eax,%edx
  802168:	89 d8                	mov    %ebx,%eax
  80216a:	89 14 24             	mov    %edx,(%esp)
  80216d:	89 f2                	mov    %esi,%edx
  80216f:	d3 e2                	shl    %cl,%edx
  802171:	89 f9                	mov    %edi,%ecx
  802173:	89 54 24 04          	mov    %edx,0x4(%esp)
  802177:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	89 e9                	mov    %ebp,%ecx
  80217f:	89 c6                	mov    %eax,%esi
  802181:	d3 e3                	shl    %cl,%ebx
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 d0                	mov    %edx,%eax
  802187:	d3 e8                	shr    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	09 d8                	or     %ebx,%eax
  80218d:	89 d3                	mov    %edx,%ebx
  80218f:	89 f2                	mov    %esi,%edx
  802191:	f7 34 24             	divl   (%esp)
  802194:	89 d6                	mov    %edx,%esi
  802196:	d3 e3                	shl    %cl,%ebx
  802198:	f7 64 24 04          	mull   0x4(%esp)
  80219c:	39 d6                	cmp    %edx,%esi
  80219e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021a2:	89 d1                	mov    %edx,%ecx
  8021a4:	89 c3                	mov    %eax,%ebx
  8021a6:	72 08                	jb     8021b0 <__umoddi3+0x110>
  8021a8:	75 11                	jne    8021bb <__umoddi3+0x11b>
  8021aa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021ae:	73 0b                	jae    8021bb <__umoddi3+0x11b>
  8021b0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8021b4:	1b 14 24             	sbb    (%esp),%edx
  8021b7:	89 d1                	mov    %edx,%ecx
  8021b9:	89 c3                	mov    %eax,%ebx
  8021bb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8021bf:	29 da                	sub    %ebx,%edx
  8021c1:	19 ce                	sbb    %ecx,%esi
  8021c3:	89 f9                	mov    %edi,%ecx
  8021c5:	89 f0                	mov    %esi,%eax
  8021c7:	d3 e0                	shl    %cl,%eax
  8021c9:	89 e9                	mov    %ebp,%ecx
  8021cb:	d3 ea                	shr    %cl,%edx
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	09 d0                	or     %edx,%eax
  8021d3:	89 f2                	mov    %esi,%edx
  8021d5:	83 c4 1c             	add    $0x1c,%esp
  8021d8:	5b                   	pop    %ebx
  8021d9:	5e                   	pop    %esi
  8021da:	5f                   	pop    %edi
  8021db:	5d                   	pop    %ebp
  8021dc:	c3                   	ret    
  8021dd:	8d 76 00             	lea    0x0(%esi),%esi
  8021e0:	29 f9                	sub    %edi,%ecx
  8021e2:	19 d6                	sbb    %edx,%esi
  8021e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ec:	e9 18 ff ff ff       	jmp    802109 <__umoddi3+0x69>
