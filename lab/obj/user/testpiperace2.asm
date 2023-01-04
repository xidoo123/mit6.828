
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 e0 21 80 00       	push   $0x8021e0
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 46 1a 00 00       	call   801a97 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 2e 22 80 00       	push   $0x80222e
  80005e:	6a 0d                	push   $0xd
  800060:	68 37 22 80 00       	push   $0x802237
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 f2 0e 00 00       	call   800f61 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 4c 22 80 00       	push   $0x80224c
  80007b:	6a 0f                	push   $0xf
  80007d:	68 37 22 80 00       	push   $0x802237
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 ec 11 00 00       	call   801282 <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 55 22 80 00       	push   $0x802255
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 fa 11 00 00       	call   8012d2 <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 99 11 00 00       	call   801282 <close>
			sys_yield();
  8000e9:	e8 8a 0b 00 00       	call   800c78 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 c8 1a 00 00       	call   801bea <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 59 22 80 00       	push   $0x802259
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 da 0a 00 00       	call   800c18 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 75 22 80 00       	push   $0x802275
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 79 1a 00 00       	call   801bea <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 04 22 80 00       	push   $0x802204
  800180:	6a 40                	push   $0x40
  800182:	68 37 22 80 00       	push   $0x802237
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 bd 0f 00 00       	call   801158 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 8b 22 80 00       	push   $0x80228b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 37 22 80 00       	push   $0x802237
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 33 0f 00 00       	call   8010f2 <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 73 0a 00 00       	call   800c59 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 86 10 00 00       	call   8012ad <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 e7 09 00 00       	call   800c18 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 10 0a 00 00       	call   800c59 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 c4 22 80 00       	push   $0x8022c4
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 bd 27 80 00 	movl   $0x8027bd,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 2f 09 00 00       	call   800bdb <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 54 01 00 00       	call   800446 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 d4 08 00 00       	call   800bdb <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 c9 1b 00 00       	call   801f40 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 b6 1c 00 00       	call   802070 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 e7 22 80 00 	movsbl 0x8022e7(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d5:	83 fa 01             	cmp    $0x1,%edx
  8003d8:	7e 0e                	jle    8003e8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003df:	89 08                	mov    %ecx,(%eax)
  8003e1:	8b 02                	mov    (%edx),%eax
  8003e3:	8b 52 04             	mov    0x4(%edx),%edx
  8003e6:	eb 22                	jmp    80040a <getuint+0x38>
	else if (lflag)
  8003e8:	85 d2                	test   %edx,%edx
  8003ea:	74 10                	je     8003fc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f1:	89 08                	mov    %ecx,(%eax)
  8003f3:	8b 02                	mov    (%edx),%eax
  8003f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fa:	eb 0e                	jmp    80040a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003fc:	8b 10                	mov    (%eax),%edx
  8003fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  800401:	89 08                	mov    %ecx,(%eax)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800412:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800416:	8b 10                	mov    (%eax),%edx
  800418:	3b 50 04             	cmp    0x4(%eax),%edx
  80041b:	73 0a                	jae    800427 <sprintputch+0x1b>
		*b->buf++ = ch;
  80041d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800420:	89 08                	mov    %ecx,(%eax)
  800422:	8b 45 08             	mov    0x8(%ebp),%eax
  800425:	88 02                	mov    %al,(%edx)
}
  800427:	5d                   	pop    %ebp
  800428:	c3                   	ret    

00800429 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80042f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800432:	50                   	push   %eax
  800433:	ff 75 10             	pushl  0x10(%ebp)
  800436:	ff 75 0c             	pushl  0xc(%ebp)
  800439:	ff 75 08             	pushl  0x8(%ebp)
  80043c:	e8 05 00 00 00       	call   800446 <vprintfmt>
	va_end(ap);
}
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	c9                   	leave  
  800445:	c3                   	ret    

00800446 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	57                   	push   %edi
  80044a:	56                   	push   %esi
  80044b:	53                   	push   %ebx
  80044c:	83 ec 2c             	sub    $0x2c,%esp
  80044f:	8b 75 08             	mov    0x8(%ebp),%esi
  800452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800455:	8b 7d 10             	mov    0x10(%ebp),%edi
  800458:	eb 12                	jmp    80046c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045a:	85 c0                	test   %eax,%eax
  80045c:	0f 84 89 03 00 00    	je     8007eb <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	53                   	push   %ebx
  800466:	50                   	push   %eax
  800467:	ff d6                	call   *%esi
  800469:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046c:	83 c7 01             	add    $0x1,%edi
  80046f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800473:	83 f8 25             	cmp    $0x25,%eax
  800476:	75 e2                	jne    80045a <vprintfmt+0x14>
  800478:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80047c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800483:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80048a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800491:	ba 00 00 00 00       	mov    $0x0,%edx
  800496:	eb 07                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049b:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049f:	8d 47 01             	lea    0x1(%edi),%eax
  8004a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004a5:	0f b6 07             	movzbl (%edi),%eax
  8004a8:	0f b6 c8             	movzbl %al,%ecx
  8004ab:	83 e8 23             	sub    $0x23,%eax
  8004ae:	3c 55                	cmp    $0x55,%al
  8004b0:	0f 87 1a 03 00 00    	ja     8007d0 <vprintfmt+0x38a>
  8004b6:	0f b6 c0             	movzbl %al,%eax
  8004b9:	ff 24 85 20 24 80 00 	jmp    *0x802420(,%eax,4)
  8004c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004c3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004c7:	eb d6                	jmp    80049f <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004d4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004d7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004db:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004de:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004e1:	83 fa 09             	cmp    $0x9,%edx
  8004e4:	77 39                	ja     80051f <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004e6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e9:	eb e9                	jmp    8004d4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8d 48 04             	lea    0x4(%eax),%ecx
  8004f1:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004f4:	8b 00                	mov    (%eax),%eax
  8004f6:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004fc:	eb 27                	jmp    800525 <vprintfmt+0xdf>
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	85 c0                	test   %eax,%eax
  800503:	b9 00 00 00 00       	mov    $0x0,%ecx
  800508:	0f 49 c8             	cmovns %eax,%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800511:	eb 8c                	jmp    80049f <vprintfmt+0x59>
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80051d:	eb 80                	jmp    80049f <vprintfmt+0x59>
  80051f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800522:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800525:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800529:	0f 89 70 ff ff ff    	jns    80049f <vprintfmt+0x59>
				width = precision, precision = -1;
  80052f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800532:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800535:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80053c:	e9 5e ff ff ff       	jmp    80049f <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800541:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800544:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800547:	e9 53 ff ff ff       	jmp    80049f <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8d 50 04             	lea    0x4(%eax),%edx
  800552:	89 55 14             	mov    %edx,0x14(%ebp)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	53                   	push   %ebx
  800559:	ff 30                	pushl  (%eax)
  80055b:	ff d6                	call   *%esi
			break;
  80055d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800560:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800563:	e9 04 ff ff ff       	jmp    80046c <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8d 50 04             	lea    0x4(%eax),%edx
  80056e:	89 55 14             	mov    %edx,0x14(%ebp)
  800571:	8b 00                	mov    (%eax),%eax
  800573:	99                   	cltd   
  800574:	31 d0                	xor    %edx,%eax
  800576:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800578:	83 f8 0f             	cmp    $0xf,%eax
  80057b:	7f 0b                	jg     800588 <vprintfmt+0x142>
  80057d:	8b 14 85 80 25 80 00 	mov    0x802580(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 ff 22 80 00       	push   $0x8022ff
  80058e:	53                   	push   %ebx
  80058f:	56                   	push   %esi
  800590:	e8 94 fe ff ff       	call   800429 <printfmt>
  800595:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80059b:	e9 cc fe ff ff       	jmp    80046c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8005a0:	52                   	push   %edx
  8005a1:	68 96 27 80 00       	push   $0x802796
  8005a6:	53                   	push   %ebx
  8005a7:	56                   	push   %esi
  8005a8:	e8 7c fe ff ff       	call   800429 <printfmt>
  8005ad:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b3:	e9 b4 fe ff ff       	jmp    80046c <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	b8 f8 22 80 00       	mov    $0x8022f8,%eax
  8005ca:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 8e 94 00 00 00    	jle    80066b <vprintfmt+0x225>
  8005d7:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005db:	0f 84 98 00 00 00    	je     800679 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	ff 75 d0             	pushl  -0x30(%ebp)
  8005e7:	57                   	push   %edi
  8005e8:	e8 86 02 00 00       	call   800873 <strnlen>
  8005ed:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f0:	29 c1                	sub    %eax,%ecx
  8005f2:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f5:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f8:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005fc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005ff:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800602:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	eb 0f                	jmp    800615 <vprintfmt+0x1cf>
					putch(padc, putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	ff 75 e0             	pushl  -0x20(%ebp)
  80060d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 ef 01             	sub    $0x1,%edi
  800612:	83 c4 10             	add    $0x10,%esp
  800615:	85 ff                	test   %edi,%edi
  800617:	7f ed                	jg     800606 <vprintfmt+0x1c0>
  800619:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80061c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	b8 00 00 00 00       	mov    $0x0,%eax
  800626:	0f 49 c1             	cmovns %ecx,%eax
  800629:	29 c1                	sub    %eax,%ecx
  80062b:	89 75 08             	mov    %esi,0x8(%ebp)
  80062e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800631:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800634:	89 cb                	mov    %ecx,%ebx
  800636:	eb 4d                	jmp    800685 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800638:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063c:	74 1b                	je     800659 <vprintfmt+0x213>
  80063e:	0f be c0             	movsbl %al,%eax
  800641:	83 e8 20             	sub    $0x20,%eax
  800644:	83 f8 5e             	cmp    $0x5e,%eax
  800647:	76 10                	jbe    800659 <vprintfmt+0x213>
					putch('?', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	ff 75 0c             	pushl  0xc(%ebp)
  80064f:	6a 3f                	push   $0x3f
  800651:	ff 55 08             	call   *0x8(%ebp)
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	eb 0d                	jmp    800666 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	ff 75 0c             	pushl  0xc(%ebp)
  80065f:	52                   	push   %edx
  800660:	ff 55 08             	call   *0x8(%ebp)
  800663:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800666:	83 eb 01             	sub    $0x1,%ebx
  800669:	eb 1a                	jmp    800685 <vprintfmt+0x23f>
  80066b:	89 75 08             	mov    %esi,0x8(%ebp)
  80066e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800671:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800674:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800677:	eb 0c                	jmp    800685 <vprintfmt+0x23f>
  800679:	89 75 08             	mov    %esi,0x8(%ebp)
  80067c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800682:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800685:	83 c7 01             	add    $0x1,%edi
  800688:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80068c:	0f be d0             	movsbl %al,%edx
  80068f:	85 d2                	test   %edx,%edx
  800691:	74 23                	je     8006b6 <vprintfmt+0x270>
  800693:	85 f6                	test   %esi,%esi
  800695:	78 a1                	js     800638 <vprintfmt+0x1f2>
  800697:	83 ee 01             	sub    $0x1,%esi
  80069a:	79 9c                	jns    800638 <vprintfmt+0x1f2>
  80069c:	89 df                	mov    %ebx,%edi
  80069e:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a4:	eb 18                	jmp    8006be <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 20                	push   $0x20
  8006ac:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ae:	83 ef 01             	sub    $0x1,%edi
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb 08                	jmp    8006be <vprintfmt+0x278>
  8006b6:	89 df                	mov    %ebx,%edi
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006be:	85 ff                	test   %edi,%edi
  8006c0:	7f e4                	jg     8006a6 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c5:	e9 a2 fd ff ff       	jmp    80046c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ca:	83 fa 01             	cmp    $0x1,%edx
  8006cd:	7e 16                	jle    8006e5 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 08             	lea    0x8(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 50 04             	mov    0x4(%eax),%edx
  8006db:	8b 00                	mov    (%eax),%eax
  8006dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006e3:	eb 32                	jmp    800717 <vprintfmt+0x2d1>
	else if (lflag)
  8006e5:	85 d2                	test   %edx,%edx
  8006e7:	74 18                	je     800701 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8006e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ec:	8d 50 04             	lea    0x4(%eax),%edx
  8006ef:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f2:	8b 00                	mov    (%eax),%eax
  8006f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f7:	89 c1                	mov    %eax,%ecx
  8006f9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006fc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  800701:	8b 45 14             	mov    0x14(%ebp),%eax
  800704:	8d 50 04             	lea    0x4(%eax),%edx
  800707:	89 55 14             	mov    %edx,0x14(%ebp)
  80070a:	8b 00                	mov    (%eax),%eax
  80070c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070f:	89 c1                	mov    %eax,%ecx
  800711:	c1 f9 1f             	sar    $0x1f,%ecx
  800714:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800717:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80071d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800722:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800726:	79 74                	jns    80079c <vprintfmt+0x356>
				putch('-', putdat);
  800728:	83 ec 08             	sub    $0x8,%esp
  80072b:	53                   	push   %ebx
  80072c:	6a 2d                	push   $0x2d
  80072e:	ff d6                	call   *%esi
				num = -(long long) num;
  800730:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800733:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800736:	f7 d8                	neg    %eax
  800738:	83 d2 00             	adc    $0x0,%edx
  80073b:	f7 da                	neg    %edx
  80073d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800740:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800745:	eb 55                	jmp    80079c <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800747:	8d 45 14             	lea    0x14(%ebp),%eax
  80074a:	e8 83 fc ff ff       	call   8003d2 <getuint>
			base = 10;
  80074f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800754:	eb 46                	jmp    80079c <vprintfmt+0x356>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800756:	8d 45 14             	lea    0x14(%ebp),%eax
  800759:	e8 74 fc ff ff       	call   8003d2 <getuint>
			base = 8;
  80075e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800763:	eb 37                	jmp    80079c <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
  800765:	83 ec 08             	sub    $0x8,%esp
  800768:	53                   	push   %ebx
  800769:	6a 30                	push   $0x30
  80076b:	ff d6                	call   *%esi
			putch('x', putdat);
  80076d:	83 c4 08             	add    $0x8,%esp
  800770:	53                   	push   %ebx
  800771:	6a 78                	push   $0x78
  800773:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800775:	8b 45 14             	mov    0x14(%ebp),%eax
  800778:	8d 50 04             	lea    0x4(%eax),%edx
  80077b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077e:	8b 00                	mov    (%eax),%eax
  800780:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800785:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800788:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80078d:	eb 0d                	jmp    80079c <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078f:	8d 45 14             	lea    0x14(%ebp),%eax
  800792:	e8 3b fc ff ff       	call   8003d2 <getuint>
			base = 16;
  800797:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	83 ec 0c             	sub    $0xc,%esp
  80079f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007a3:	57                   	push   %edi
  8007a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a7:	51                   	push   %ecx
  8007a8:	52                   	push   %edx
  8007a9:	50                   	push   %eax
  8007aa:	89 da                	mov    %ebx,%edx
  8007ac:	89 f0                	mov    %esi,%eax
  8007ae:	e8 70 fb ff ff       	call   800323 <printnum>
			break;
  8007b3:	83 c4 20             	add    $0x20,%esp
  8007b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b9:	e9 ae fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	51                   	push   %ecx
  8007c3:	ff d6                	call   *%esi
			break;
  8007c5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cb:	e9 9c fc ff ff       	jmp    80046c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	6a 25                	push   $0x25
  8007d6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	eb 03                	jmp    8007e0 <vprintfmt+0x39a>
  8007dd:	83 ef 01             	sub    $0x1,%edi
  8007e0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e4:	75 f7                	jne    8007dd <vprintfmt+0x397>
  8007e6:	e9 81 fc ff ff       	jmp    80046c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ee:	5b                   	pop    %ebx
  8007ef:	5e                   	pop    %esi
  8007f0:	5f                   	pop    %edi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 18             	sub    $0x18,%esp
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800802:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800806:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800809:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800810:	85 c0                	test   %eax,%eax
  800812:	74 26                	je     80083a <vsnprintf+0x47>
  800814:	85 d2                	test   %edx,%edx
  800816:	7e 22                	jle    80083a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800818:	ff 75 14             	pushl  0x14(%ebp)
  80081b:	ff 75 10             	pushl  0x10(%ebp)
  80081e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	68 0c 04 80 00       	push   $0x80040c
  800827:	e8 1a fc ff ff       	call   800446 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800832:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	eb 05                	jmp    80083f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80083a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 9a ff ff ff       	call   8007f3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800859:	c9                   	leave  
  80085a:	c3                   	ret    

0080085b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80085b:	55                   	push   %ebp
  80085c:	89 e5                	mov    %esp,%ebp
  80085e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800861:	b8 00 00 00 00       	mov    $0x0,%eax
  800866:	eb 03                	jmp    80086b <strlen+0x10>
		n++;
  800868:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80086b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086f:	75 f7                	jne    800868 <strlen+0xd>
		n++;
	return n;
}
  800871:	5d                   	pop    %ebp
  800872:	c3                   	ret    

00800873 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800873:	55                   	push   %ebp
  800874:	89 e5                	mov    %esp,%ebp
  800876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80087c:	ba 00 00 00 00       	mov    $0x0,%edx
  800881:	eb 03                	jmp    800886 <strnlen+0x13>
		n++;
  800883:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c2                	cmp    %eax,%edx
  800888:	74 08                	je     800892 <strnlen+0x1f>
  80088a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x10>
  800890:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	53                   	push   %ebx
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089e:	89 c2                	mov    %eax,%edx
  8008a0:	83 c2 01             	add    $0x1,%edx
  8008a3:	83 c1 01             	add    $0x1,%ecx
  8008a6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008aa:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ad:	84 db                	test   %bl,%bl
  8008af:	75 ef                	jne    8008a0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	53                   	push   %ebx
  8008b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008bb:	53                   	push   %ebx
  8008bc:	e8 9a ff ff ff       	call   80085b <strlen>
  8008c1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c4:	ff 75 0c             	pushl  0xc(%ebp)
  8008c7:	01 d8                	add    %ebx,%eax
  8008c9:	50                   	push   %eax
  8008ca:	e8 c5 ff ff ff       	call   800894 <strcpy>
	return dst;
}
  8008cf:	89 d8                	mov    %ebx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
  8008db:	8b 75 08             	mov    0x8(%ebp),%esi
  8008de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008e1:	89 f3                	mov    %esi,%ebx
  8008e3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e6:	89 f2                	mov    %esi,%edx
  8008e8:	eb 0f                	jmp    8008f9 <strncpy+0x23>
		*dst++ = *src;
  8008ea:	83 c2 01             	add    $0x1,%edx
  8008ed:	0f b6 01             	movzbl (%ecx),%eax
  8008f0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008f3:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f9:	39 da                	cmp    %ebx,%edx
  8008fb:	75 ed                	jne    8008ea <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 75 08             	mov    0x8(%ebp),%esi
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 55 10             	mov    0x10(%ebp),%edx
  800911:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800913:	85 d2                	test   %edx,%edx
  800915:	74 21                	je     800938 <strlcpy+0x35>
  800917:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80091b:	89 f2                	mov    %esi,%edx
  80091d:	eb 09                	jmp    800928 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800928:	39 c2                	cmp    %eax,%edx
  80092a:	74 09                	je     800935 <strlcpy+0x32>
  80092c:	0f b6 19             	movzbl (%ecx),%ebx
  80092f:	84 db                	test   %bl,%bl
  800931:	75 ec                	jne    80091f <strlcpy+0x1c>
  800933:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800935:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800938:	29 f0                	sub    %esi,%eax
}
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800944:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800947:	eb 06                	jmp    80094f <strcmp+0x11>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x1c>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 45 08             	mov    0x8(%ebp),%eax
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096e:	89 c3                	mov    %eax,%ebx
  800970:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800973:	eb 06                	jmp    80097b <strncmp+0x17>
		n--, p++, q++;
  800975:	83 c0 01             	add    $0x1,%eax
  800978:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	39 d8                	cmp    %ebx,%eax
  80097d:	74 15                	je     800994 <strncmp+0x30>
  80097f:	0f b6 08             	movzbl (%eax),%ecx
  800982:	84 c9                	test   %cl,%cl
  800984:	74 04                	je     80098a <strncmp+0x26>
  800986:	3a 0a                	cmp    (%edx),%cl
  800988:	74 eb                	je     800975 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80098a:	0f b6 00             	movzbl (%eax),%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
  800992:	eb 05                	jmp    800999 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800999:	5b                   	pop    %ebx
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a6:	eb 07                	jmp    8009af <strchr+0x13>
		if (*s == c)
  8009a8:	38 ca                	cmp    %cl,%dl
  8009aa:	74 0f                	je     8009bb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ac:	83 c0 01             	add    $0x1,%eax
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	84 d2                	test   %dl,%dl
  8009b4:	75 f2                	jne    8009a8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 03                	jmp    8009cc <strfind+0xf>
  8009c9:	83 c0 01             	add    $0x1,%eax
  8009cc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	74 04                	je     8009d7 <strfind+0x1a>
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	57                   	push   %edi
  8009dd:	56                   	push   %esi
  8009de:	53                   	push   %ebx
  8009df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009e5:	85 c9                	test   %ecx,%ecx
  8009e7:	74 36                	je     800a1f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ef:	75 28                	jne    800a19 <memset+0x40>
  8009f1:	f6 c1 03             	test   $0x3,%cl
  8009f4:	75 23                	jne    800a19 <memset+0x40>
		c &= 0xFF;
  8009f6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009fa:	89 d3                	mov    %edx,%ebx
  8009fc:	c1 e3 08             	shl    $0x8,%ebx
  8009ff:	89 d6                	mov    %edx,%esi
  800a01:	c1 e6 18             	shl    $0x18,%esi
  800a04:	89 d0                	mov    %edx,%eax
  800a06:	c1 e0 10             	shl    $0x10,%eax
  800a09:	09 f0                	or     %esi,%eax
  800a0b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a0d:	89 d8                	mov    %ebx,%eax
  800a0f:	09 d0                	or     %edx,%eax
  800a11:	c1 e9 02             	shr    $0x2,%ecx
  800a14:	fc                   	cld    
  800a15:	f3 ab                	rep stos %eax,%es:(%edi)
  800a17:	eb 06                	jmp    800a1f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1c:	fc                   	cld    
  800a1d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1f:	89 f8                	mov    %edi,%eax
  800a21:	5b                   	pop    %ebx
  800a22:	5e                   	pop    %esi
  800a23:	5f                   	pop    %edi
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	57                   	push   %edi
  800a2a:	56                   	push   %esi
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a34:	39 c6                	cmp    %eax,%esi
  800a36:	73 35                	jae    800a6d <memmove+0x47>
  800a38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a3b:	39 d0                	cmp    %edx,%eax
  800a3d:	73 2e                	jae    800a6d <memmove+0x47>
		s += n;
		d += n;
  800a3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	89 d6                	mov    %edx,%esi
  800a44:	09 fe                	or     %edi,%esi
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 13                	jne    800a61 <memmove+0x3b>
  800a4e:	f6 c1 03             	test   $0x3,%cl
  800a51:	75 0e                	jne    800a61 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a53:	83 ef 04             	sub    $0x4,%edi
  800a56:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a59:	c1 e9 02             	shr    $0x2,%ecx
  800a5c:	fd                   	std    
  800a5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5f:	eb 09                	jmp    800a6a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a61:	83 ef 01             	sub    $0x1,%edi
  800a64:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a67:	fd                   	std    
  800a68:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6a:	fc                   	cld    
  800a6b:	eb 1d                	jmp    800a8a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	89 f2                	mov    %esi,%edx
  800a6f:	09 c2                	or     %eax,%edx
  800a71:	f6 c2 03             	test   $0x3,%dl
  800a74:	75 0f                	jne    800a85 <memmove+0x5f>
  800a76:	f6 c1 03             	test   $0x3,%cl
  800a79:	75 0a                	jne    800a85 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a7b:	c1 e9 02             	shr    $0x2,%ecx
  800a7e:	89 c7                	mov    %eax,%edi
  800a80:	fc                   	cld    
  800a81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a83:	eb 05                	jmp    800a8a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a85:	89 c7                	mov    %eax,%edi
  800a87:	fc                   	cld    
  800a88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a8a:	5e                   	pop    %esi
  800a8b:	5f                   	pop    %edi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a91:	ff 75 10             	pushl  0x10(%ebp)
  800a94:	ff 75 0c             	pushl  0xc(%ebp)
  800a97:	ff 75 08             	pushl  0x8(%ebp)
  800a9a:	e8 87 ff ff ff       	call   800a26 <memmove>
}
  800a9f:	c9                   	leave  
  800aa0:	c3                   	ret    

00800aa1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa1:	55                   	push   %ebp
  800aa2:	89 e5                	mov    %esp,%ebp
  800aa4:	56                   	push   %esi
  800aa5:	53                   	push   %ebx
  800aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aac:	89 c6                	mov    %eax,%esi
  800aae:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	eb 1a                	jmp    800acd <memcmp+0x2c>
		if (*s1 != *s2)
  800ab3:	0f b6 08             	movzbl (%eax),%ecx
  800ab6:	0f b6 1a             	movzbl (%edx),%ebx
  800ab9:	38 d9                	cmp    %bl,%cl
  800abb:	74 0a                	je     800ac7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800abd:	0f b6 c1             	movzbl %cl,%eax
  800ac0:	0f b6 db             	movzbl %bl,%ebx
  800ac3:	29 d8                	sub    %ebx,%eax
  800ac5:	eb 0f                	jmp    800ad6 <memcmp+0x35>
		s1++, s2++;
  800ac7:	83 c0 01             	add    $0x1,%eax
  800aca:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acd:	39 f0                	cmp    %esi,%eax
  800acf:	75 e2                	jne    800ab3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ad1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	53                   	push   %ebx
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ae1:	89 c1                	mov    %eax,%ecx
  800ae3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	eb 0a                	jmp    800af6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aec:	0f b6 10             	movzbl (%eax),%edx
  800aef:	39 da                	cmp    %ebx,%edx
  800af1:	74 07                	je     800afa <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800af3:	83 c0 01             	add    $0x1,%eax
  800af6:	39 c8                	cmp    %ecx,%eax
  800af8:	72 f2                	jb     800aec <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800afa:	5b                   	pop    %ebx
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b09:	eb 03                	jmp    800b0e <strtol+0x11>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b0e:	0f b6 01             	movzbl (%ecx),%eax
  800b11:	3c 20                	cmp    $0x20,%al
  800b13:	74 f6                	je     800b0b <strtol+0xe>
  800b15:	3c 09                	cmp    $0x9,%al
  800b17:	74 f2                	je     800b0b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b19:	3c 2b                	cmp    $0x2b,%al
  800b1b:	75 0a                	jne    800b27 <strtol+0x2a>
		s++;
  800b1d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b20:	bf 00 00 00 00       	mov    $0x0,%edi
  800b25:	eb 11                	jmp    800b38 <strtol+0x3b>
  800b27:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b2c:	3c 2d                	cmp    $0x2d,%al
  800b2e:	75 08                	jne    800b38 <strtol+0x3b>
		s++, neg = 1;
  800b30:	83 c1 01             	add    $0x1,%ecx
  800b33:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b3e:	75 15                	jne    800b55 <strtol+0x58>
  800b40:	80 39 30             	cmpb   $0x30,(%ecx)
  800b43:	75 10                	jne    800b55 <strtol+0x58>
  800b45:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b49:	75 7c                	jne    800bc7 <strtol+0xca>
		s += 2, base = 16;
  800b4b:	83 c1 02             	add    $0x2,%ecx
  800b4e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b53:	eb 16                	jmp    800b6b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b55:	85 db                	test   %ebx,%ebx
  800b57:	75 12                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b59:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800b61:	75 08                	jne    800b6b <strtol+0x6e>
		s++, base = 8;
  800b63:	83 c1 01             	add    $0x1,%ecx
  800b66:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b70:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b73:	0f b6 11             	movzbl (%ecx),%edx
  800b76:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b79:	89 f3                	mov    %esi,%ebx
  800b7b:	80 fb 09             	cmp    $0x9,%bl
  800b7e:	77 08                	ja     800b88 <strtol+0x8b>
			dig = *s - '0';
  800b80:	0f be d2             	movsbl %dl,%edx
  800b83:	83 ea 30             	sub    $0x30,%edx
  800b86:	eb 22                	jmp    800baa <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b88:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b8b:	89 f3                	mov    %esi,%ebx
  800b8d:	80 fb 19             	cmp    $0x19,%bl
  800b90:	77 08                	ja     800b9a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b92:	0f be d2             	movsbl %dl,%edx
  800b95:	83 ea 57             	sub    $0x57,%edx
  800b98:	eb 10                	jmp    800baa <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b9a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9d:	89 f3                	mov    %esi,%ebx
  800b9f:	80 fb 19             	cmp    $0x19,%bl
  800ba2:	77 16                	ja     800bba <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ba4:	0f be d2             	movsbl %dl,%edx
  800ba7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800baa:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bad:	7d 0b                	jge    800bba <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb8:	eb b9                	jmp    800b73 <strtol+0x76>

	if (endptr)
  800bba:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bbe:	74 0d                	je     800bcd <strtol+0xd0>
		*endptr = (char *) s;
  800bc0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc3:	89 0e                	mov    %ecx,(%esi)
  800bc5:	eb 06                	jmp    800bcd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	74 98                	je     800b63 <strtol+0x66>
  800bcb:	eb 9e                	jmp    800b6b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bcd:	89 c2                	mov    %eax,%edx
  800bcf:	f7 da                	neg    %edx
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	0f 45 c2             	cmovne %edx,%eax
}
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be9:	8b 55 08             	mov    0x8(%ebp),%edx
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 c7                	mov    %eax,%edi
  800bf0:	89 c6                	mov    %eax,%esi
  800bf2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf4:	5b                   	pop    %ebx
  800bf5:	5e                   	pop    %esi
  800bf6:	5f                   	pop    %edi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bff:	ba 00 00 00 00       	mov    $0x0,%edx
  800c04:	b8 01 00 00 00       	mov    $0x1,%eax
  800c09:	89 d1                	mov    %edx,%ecx
  800c0b:	89 d3                	mov    %edx,%ebx
  800c0d:	89 d7                	mov    %edx,%edi
  800c0f:	89 d6                	mov    %edx,%esi
  800c11:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c21:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c26:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	89 cb                	mov    %ecx,%ebx
  800c30:	89 cf                	mov    %ecx,%edi
  800c32:	89 ce                	mov    %ecx,%esi
  800c34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c36:	85 c0                	test   %eax,%eax
  800c38:	7e 17                	jle    800c51 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3a:	83 ec 0c             	sub    $0xc,%esp
  800c3d:	50                   	push   %eax
  800c3e:	6a 03                	push   $0x3
  800c40:	68 df 25 80 00       	push   $0x8025df
  800c45:	6a 23                	push   $0x23
  800c47:	68 fc 25 80 00       	push   $0x8025fc
  800c4c:	e8 e5 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	57                   	push   %edi
  800c5d:	56                   	push   %esi
  800c5e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c64:	b8 02 00 00 00       	mov    $0x2,%eax
  800c69:	89 d1                	mov    %edx,%ecx
  800c6b:	89 d3                	mov    %edx,%ebx
  800c6d:	89 d7                	mov    %edx,%edi
  800c6f:	89 d6                	mov    %edx,%esi
  800c71:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_yield>:

void
sys_yield(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	be 00 00 00 00       	mov    $0x0,%esi
  800ca5:	b8 04 00 00 00       	mov    $0x4,%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cad:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb3:	89 f7                	mov    %esi,%edi
  800cb5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7e 17                	jle    800cd2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbb:	83 ec 0c             	sub    $0xc,%esp
  800cbe:	50                   	push   %eax
  800cbf:	6a 04                	push   $0x4
  800cc1:	68 df 25 80 00       	push   $0x8025df
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 fc 25 80 00       	push   $0x8025fc
  800ccd:	e8 64 f5 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf4:	8b 75 18             	mov    0x18(%ebp),%esi
  800cf7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7e 17                	jle    800d14 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	50                   	push   %eax
  800d01:	6a 05                	push   $0x5
  800d03:	68 df 25 80 00       	push   $0x8025df
  800d08:	6a 23                	push   $0x23
  800d0a:	68 fc 25 80 00       	push   $0x8025fc
  800d0f:	e8 22 f5 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d17:	5b                   	pop    %ebx
  800d18:	5e                   	pop    %esi
  800d19:	5f                   	pop    %edi
  800d1a:	5d                   	pop    %ebp
  800d1b:	c3                   	ret    

00800d1c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 06                	push   $0x6
  800d45:	68 df 25 80 00       	push   $0x8025df
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 fc 25 80 00       	push   $0x8025fc
  800d51:	e8 e0 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800d71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d74:	8b 55 08             	mov    0x8(%ebp),%edx
  800d77:	89 df                	mov    %ebx,%edi
  800d79:	89 de                	mov    %ebx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 08                	push   $0x8
  800d87:	68 df 25 80 00       	push   $0x8025df
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 fc 25 80 00       	push   $0x8025fc
  800d93:	e8 9e f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 09 00 00 00       	mov    $0x9,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 09                	push   $0x9
  800dc9:	68 df 25 80 00       	push   $0x8025df
  800dce:	6a 23                	push   $0x23
  800dd0:	68 fc 25 80 00       	push   $0x8025fc
  800dd5:	e8 5c f4 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 0a                	push   $0xa
  800e0b:	68 df 25 80 00       	push   $0x8025df
  800e10:	6a 23                	push   $0x23
  800e12:	68 fc 25 80 00       	push   $0x8025fc
  800e17:	e8 1a f4 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2a:	be 00 00 00 00       	mov    $0x0,%esi
  800e2f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e42:	5b                   	pop    %ebx
  800e43:	5e                   	pop    %esi
  800e44:	5f                   	pop    %edi
  800e45:	5d                   	pop    %ebp
  800e46:	c3                   	ret    

00800e47 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	57                   	push   %edi
  800e4b:	56                   	push   %esi
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e55:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5d:	89 cb                	mov    %ecx,%ebx
  800e5f:	89 cf                	mov    %ecx,%edi
  800e61:	89 ce                	mov    %ecx,%esi
  800e63:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e65:	85 c0                	test   %eax,%eax
  800e67:	7e 17                	jle    800e80 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e69:	83 ec 0c             	sub    $0xc,%esp
  800e6c:	50                   	push   %eax
  800e6d:	6a 0d                	push   $0xd
  800e6f:	68 df 25 80 00       	push   $0x8025df
  800e74:	6a 23                	push   $0x23
  800e76:	68 fc 25 80 00       	push   $0x8025fc
  800e7b:	e8 b6 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e83:	5b                   	pop    %ebx
  800e84:	5e                   	pop    %esi
  800e85:	5f                   	pop    %edi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	56                   	push   %esi
  800e8c:	53                   	push   %ebx
  800e8d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e90:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800e92:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e96:	75 25                	jne    800ebd <pgfault+0x35>
  800e98:	89 d8                	mov    %ebx,%eax
  800e9a:	c1 e8 0c             	shr    $0xc,%eax
  800e9d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ea4:	f6 c4 08             	test   $0x8,%ah
  800ea7:	75 14                	jne    800ebd <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800ea9:	83 ec 04             	sub    $0x4,%esp
  800eac:	68 0c 26 80 00       	push   $0x80260c
  800eb1:	6a 1e                	push   $0x1e
  800eb3:	68 a0 26 80 00       	push   $0x8026a0
  800eb8:	e8 79 f3 ff ff       	call   800236 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800ebd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800ec3:	e8 91 fd ff ff       	call   800c59 <sys_getenvid>
  800ec8:	89 c6                	mov    %eax,%esi

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	6a 07                	push   $0x7
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	50                   	push   %eax
  800ed5:	e8 bd fd ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	79 12                	jns    800ef3 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800ee1:	50                   	push   %eax
  800ee2:	68 38 26 80 00       	push   $0x802638
  800ee7:	6a 31                	push   $0x31
  800ee9:	68 a0 26 80 00       	push   $0x8026a0
  800eee:	e8 43 f3 ff ff       	call   800236 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800ef3:	83 ec 04             	sub    $0x4,%esp
  800ef6:	68 00 10 00 00       	push   $0x1000
  800efb:	53                   	push   %ebx
  800efc:	68 00 f0 7f 00       	push   $0x7ff000
  800f01:	e8 88 fb ff ff       	call   800a8e <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800f06:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f0d:	53                   	push   %ebx
  800f0e:	56                   	push   %esi
  800f0f:	68 00 f0 7f 00       	push   $0x7ff000
  800f14:	56                   	push   %esi
  800f15:	e8 c0 fd ff ff       	call   800cda <sys_page_map>
	if (r < 0)
  800f1a:	83 c4 20             	add    $0x20,%esp
  800f1d:	85 c0                	test   %eax,%eax
  800f1f:	79 12                	jns    800f33 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800f21:	50                   	push   %eax
  800f22:	68 5c 26 80 00       	push   $0x80265c
  800f27:	6a 39                	push   $0x39
  800f29:	68 a0 26 80 00       	push   $0x8026a0
  800f2e:	e8 03 f3 ff ff       	call   800236 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800f33:	83 ec 08             	sub    $0x8,%esp
  800f36:	68 00 f0 7f 00       	push   $0x7ff000
  800f3b:	56                   	push   %esi
  800f3c:	e8 db fd ff ff       	call   800d1c <sys_page_unmap>
	if (r < 0)
  800f41:	83 c4 10             	add    $0x10,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	79 12                	jns    800f5a <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800f48:	50                   	push   %eax
  800f49:	68 80 26 80 00       	push   $0x802680
  800f4e:	6a 3e                	push   $0x3e
  800f50:	68 a0 26 80 00       	push   $0x8026a0
  800f55:	e8 dc f2 ff ff       	call   800236 <_panic>
}
  800f5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f5d:	5b                   	pop    %ebx
  800f5e:	5e                   	pop    %esi
  800f5f:	5d                   	pop    %ebp
  800f60:	c3                   	ret    

00800f61 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	57                   	push   %edi
  800f65:	56                   	push   %esi
  800f66:	53                   	push   %ebx
  800f67:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  800f6a:	68 88 0e 80 00       	push   $0x800e88
  800f6f:	e8 2c 0e 00 00       	call   801da0 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f74:	b8 07 00 00 00       	mov    $0x7,%eax
  800f79:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	0f 88 3a 01 00 00    	js     8010c0 <fork+0x15f>
  800f86:	bb 00 00 80 00       	mov    $0x800000,%ebx
  800f8b:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  800f90:	85 c0                	test   %eax,%eax
  800f92:	75 21                	jne    800fb5 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f94:	e8 c0 fc ff ff       	call   800c59 <sys_getenvid>
  800f99:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f9e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fa1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fa6:	a3 04 40 80 00       	mov    %eax,0x804004
        return 0;
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	e9 0b 01 00 00       	jmp    8010c0 <fork+0x15f>
  800fb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fb8:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  800fba:	89 d8                	mov    %ebx,%eax
  800fbc:	c1 e8 16             	shr    $0x16,%eax
  800fbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc6:	a8 01                	test   $0x1,%al
  800fc8:	0f 84 99 00 00 00    	je     801067 <fork+0x106>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  800fce:	89 d8                	mov    %ebx,%eax
  800fd0:	c1 e8 0c             	shr    $0xc,%eax
  800fd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fda:	f6 c2 01             	test   $0x1,%dl
  800fdd:	0f 84 84 00 00 00    	je     801067 <fork+0x106>

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
  800fe3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fea:	a9 02 08 00 00       	test   $0x802,%eax
  800fef:	74 76                	je     801067 <fork+0x106>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;
	
	if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  800ff1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff8:	a8 02                	test   $0x2,%al
  800ffa:	75 0c                	jne    801008 <fork+0xa7>
  800ffc:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801003:	f6 c4 08             	test   $0x8,%ah
  801006:	74 3f                	je     801047 <fork+0xe6>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	68 05 08 00 00       	push   $0x805
  801010:	53                   	push   %ebx
  801011:	57                   	push   %edi
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	e8 c0 fc ff ff       	call   800cda <sys_page_map>
		if (r < 0)
  80101a:	83 c4 20             	add    $0x20,%esp
  80101d:	85 c0                	test   %eax,%eax
  80101f:	0f 88 9b 00 00 00    	js     8010c0 <fork+0x15f>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	68 05 08 00 00       	push   $0x805
  80102d:	53                   	push   %ebx
  80102e:	6a 00                	push   $0x0
  801030:	53                   	push   %ebx
  801031:	6a 00                	push   $0x0
  801033:	e8 a2 fc ff ff       	call   800cda <sys_page_map>
  801038:	83 c4 20             	add    $0x20,%esp
  80103b:	85 c0                	test   %eax,%eax
  80103d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801042:	0f 4f c1             	cmovg  %ecx,%eax
  801045:	eb 1c                	jmp    801063 <fork+0x102>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  801047:	83 ec 0c             	sub    $0xc,%esp
  80104a:	6a 05                	push   $0x5
  80104c:	53                   	push   %ebx
  80104d:	57                   	push   %edi
  80104e:	53                   	push   %ebx
  80104f:	6a 00                	push   $0x0
  801051:	e8 84 fc ff ff       	call   800cda <sys_page_map>
  801056:	83 c4 20             	add    $0x20,%esp
  801059:	85 c0                	test   %eax,%eax
  80105b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801060:	0f 4f c1             	cmovg  %ecx,%eax
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {

				// For each writable or copy-on-write page
				if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  801063:	85 c0                	test   %eax,%eax
  801065:	78 59                	js     8010c0 <fork+0x15f>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  801067:	83 c6 01             	add    $0x1,%esi
  80106a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801070:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  801076:	0f 85 3e ff ff ff    	jne    800fba <fork+0x59>
  80107c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	6a 07                	push   $0x7
  801084:	68 00 f0 bf ee       	push   $0xeebff000
  801089:	57                   	push   %edi
  80108a:	e8 08 fc ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  80108f:	83 c4 10             	add    $0x10,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	78 2a                	js     8010c0 <fork+0x15f>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	68 e7 1d 80 00       	push   $0x801de7
  80109e:	57                   	push   %edi
  80109f:	e8 3e fd ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	if (r < 0)
  8010a4:	83 c4 10             	add    $0x10,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	78 15                	js     8010c0 <fork+0x15f>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	6a 02                	push   $0x2
  8010b0:	57                   	push   %edi
  8010b1:	e8 a8 fc ff ff       	call   800d5e <sys_env_set_status>
	if (r < 0)
  8010b6:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	0f 49 c7             	cmovns %edi,%eax
  8010be:	eb 00                	jmp    8010c0 <fork+0x15f>
	// panic("fork not implemented");
}
  8010c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c3:	5b                   	pop    %ebx
  8010c4:	5e                   	pop    %esi
  8010c5:	5f                   	pop    %edi
  8010c6:	5d                   	pop    %ebp
  8010c7:	c3                   	ret    

008010c8 <sfork>:

// Challenge!
int
sfork(void)
{
  8010c8:	55                   	push   %ebp
  8010c9:	89 e5                	mov    %esp,%ebp
  8010cb:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8010ce:	68 ab 26 80 00       	push   $0x8026ab
  8010d3:	68 c3 00 00 00       	push   $0xc3
  8010d8:	68 a0 26 80 00       	push   $0x8026a0
  8010dd:	e8 54 f1 ff ff       	call   800236 <_panic>

008010e2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010ed:	c1 e8 0c             	shr    $0xc,%eax
}
  8010f0:	5d                   	pop    %ebp
  8010f1:	c3                   	ret    

008010f2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010f2:	55                   	push   %ebp
  8010f3:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	05 00 00 00 30       	add    $0x30000000,%eax
  8010fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801102:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801107:	5d                   	pop    %ebp
  801108:	c3                   	ret    

00801109 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801109:	55                   	push   %ebp
  80110a:	89 e5                	mov    %esp,%ebp
  80110c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801114:	89 c2                	mov    %eax,%edx
  801116:	c1 ea 16             	shr    $0x16,%edx
  801119:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801120:	f6 c2 01             	test   $0x1,%dl
  801123:	74 11                	je     801136 <fd_alloc+0x2d>
  801125:	89 c2                	mov    %eax,%edx
  801127:	c1 ea 0c             	shr    $0xc,%edx
  80112a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801131:	f6 c2 01             	test   $0x1,%dl
  801134:	75 09                	jne    80113f <fd_alloc+0x36>
			*fd_store = fd;
  801136:	89 01                	mov    %eax,(%ecx)
			return 0;
  801138:	b8 00 00 00 00       	mov    $0x0,%eax
  80113d:	eb 17                	jmp    801156 <fd_alloc+0x4d>
  80113f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801144:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801149:	75 c9                	jne    801114 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80114b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801151:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80115e:	83 f8 1f             	cmp    $0x1f,%eax
  801161:	77 36                	ja     801199 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801163:	c1 e0 0c             	shl    $0xc,%eax
  801166:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	c1 ea 16             	shr    $0x16,%edx
  801170:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801177:	f6 c2 01             	test   $0x1,%dl
  80117a:	74 24                	je     8011a0 <fd_lookup+0x48>
  80117c:	89 c2                	mov    %eax,%edx
  80117e:	c1 ea 0c             	shr    $0xc,%edx
  801181:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801188:	f6 c2 01             	test   $0x1,%dl
  80118b:	74 1a                	je     8011a7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80118d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801190:	89 02                	mov    %eax,(%edx)
	return 0;
  801192:	b8 00 00 00 00       	mov    $0x0,%eax
  801197:	eb 13                	jmp    8011ac <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801199:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80119e:	eb 0c                	jmp    8011ac <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a5:	eb 05                	jmp    8011ac <fd_lookup+0x54>
  8011a7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    

008011ae <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ae:	55                   	push   %ebp
  8011af:	89 e5                	mov    %esp,%ebp
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011b7:	ba 44 27 80 00       	mov    $0x802744,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011bc:	eb 13                	jmp    8011d1 <dev_lookup+0x23>
  8011be:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011c1:	39 08                	cmp    %ecx,(%eax)
  8011c3:	75 0c                	jne    8011d1 <dev_lookup+0x23>
			*dev = devtab[i];
  8011c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8011cf:	eb 2e                	jmp    8011ff <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011d1:	8b 02                	mov    (%edx),%eax
  8011d3:	85 c0                	test   %eax,%eax
  8011d5:	75 e7                	jne    8011be <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011d7:	a1 04 40 80 00       	mov    0x804004,%eax
  8011dc:	8b 40 48             	mov    0x48(%eax),%eax
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	51                   	push   %ecx
  8011e3:	50                   	push   %eax
  8011e4:	68 c4 26 80 00       	push   $0x8026c4
  8011e9:	e8 21 f1 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8011ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011f1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011ff:	c9                   	leave  
  801200:	c3                   	ret    

00801201 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	56                   	push   %esi
  801205:	53                   	push   %ebx
  801206:	83 ec 10             	sub    $0x10,%esp
  801209:	8b 75 08             	mov    0x8(%ebp),%esi
  80120c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	50                   	push   %eax
  801213:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801219:	c1 e8 0c             	shr    $0xc,%eax
  80121c:	50                   	push   %eax
  80121d:	e8 36 ff ff ff       	call   801158 <fd_lookup>
  801222:	83 c4 08             	add    $0x8,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	78 05                	js     80122e <fd_close+0x2d>
	    || fd != fd2)
  801229:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80122c:	74 0c                	je     80123a <fd_close+0x39>
		return (must_exist ? r : 0);
  80122e:	84 db                	test   %bl,%bl
  801230:	ba 00 00 00 00       	mov    $0x0,%edx
  801235:	0f 44 c2             	cmove  %edx,%eax
  801238:	eb 41                	jmp    80127b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80123a:	83 ec 08             	sub    $0x8,%esp
  80123d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801240:	50                   	push   %eax
  801241:	ff 36                	pushl  (%esi)
  801243:	e8 66 ff ff ff       	call   8011ae <dev_lookup>
  801248:	89 c3                	mov    %eax,%ebx
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 1a                	js     80126b <fd_close+0x6a>
		if (dev->dev_close)
  801251:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801254:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801257:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80125c:	85 c0                	test   %eax,%eax
  80125e:	74 0b                	je     80126b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	56                   	push   %esi
  801264:	ff d0                	call   *%eax
  801266:	89 c3                	mov    %eax,%ebx
  801268:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	56                   	push   %esi
  80126f:	6a 00                	push   $0x0
  801271:	e8 a6 fa ff ff       	call   800d1c <sys_page_unmap>
	return r;
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	89 d8                	mov    %ebx,%eax
}
  80127b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80127e:	5b                   	pop    %ebx
  80127f:	5e                   	pop    %esi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    

00801282 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
  801285:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801288:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 c4 fe ff ff       	call   801158 <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 10                	js     8012ab <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	6a 01                	push   $0x1
  8012a0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a3:	e8 59 ff ff ff       	call   801201 <fd_close>
  8012a8:	83 c4 10             	add    $0x10,%esp
}
  8012ab:	c9                   	leave  
  8012ac:	c3                   	ret    

008012ad <close_all>:

void
close_all(void)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	53                   	push   %ebx
  8012b1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012b9:	83 ec 0c             	sub    $0xc,%esp
  8012bc:	53                   	push   %ebx
  8012bd:	e8 c0 ff ff ff       	call   801282 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c2:	83 c3 01             	add    $0x1,%ebx
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	83 fb 20             	cmp    $0x20,%ebx
  8012cb:	75 ec                	jne    8012b9 <close_all+0xc>
		close(i);
}
  8012cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	57                   	push   %edi
  8012d6:	56                   	push   %esi
  8012d7:	53                   	push   %ebx
  8012d8:	83 ec 2c             	sub    $0x2c,%esp
  8012db:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012e1:	50                   	push   %eax
  8012e2:	ff 75 08             	pushl  0x8(%ebp)
  8012e5:	e8 6e fe ff ff       	call   801158 <fd_lookup>
  8012ea:	83 c4 08             	add    $0x8,%esp
  8012ed:	85 c0                	test   %eax,%eax
  8012ef:	0f 88 c1 00 00 00    	js     8013b6 <dup+0xe4>
		return r;
	close(newfdnum);
  8012f5:	83 ec 0c             	sub    $0xc,%esp
  8012f8:	56                   	push   %esi
  8012f9:	e8 84 ff ff ff       	call   801282 <close>

	newfd = INDEX2FD(newfdnum);
  8012fe:	89 f3                	mov    %esi,%ebx
  801300:	c1 e3 0c             	shl    $0xc,%ebx
  801303:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801309:	83 c4 04             	add    $0x4,%esp
  80130c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80130f:	e8 de fd ff ff       	call   8010f2 <fd2data>
  801314:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801316:	89 1c 24             	mov    %ebx,(%esp)
  801319:	e8 d4 fd ff ff       	call   8010f2 <fd2data>
  80131e:	83 c4 10             	add    $0x10,%esp
  801321:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801324:	89 f8                	mov    %edi,%eax
  801326:	c1 e8 16             	shr    $0x16,%eax
  801329:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801330:	a8 01                	test   $0x1,%al
  801332:	74 37                	je     80136b <dup+0x99>
  801334:	89 f8                	mov    %edi,%eax
  801336:	c1 e8 0c             	shr    $0xc,%eax
  801339:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801340:	f6 c2 01             	test   $0x1,%dl
  801343:	74 26                	je     80136b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801345:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80134c:	83 ec 0c             	sub    $0xc,%esp
  80134f:	25 07 0e 00 00       	and    $0xe07,%eax
  801354:	50                   	push   %eax
  801355:	ff 75 d4             	pushl  -0x2c(%ebp)
  801358:	6a 00                	push   $0x0
  80135a:	57                   	push   %edi
  80135b:	6a 00                	push   $0x0
  80135d:	e8 78 f9 ff ff       	call   800cda <sys_page_map>
  801362:	89 c7                	mov    %eax,%edi
  801364:	83 c4 20             	add    $0x20,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 2e                	js     801399 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80136b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80136e:	89 d0                	mov    %edx,%eax
  801370:	c1 e8 0c             	shr    $0xc,%eax
  801373:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80137a:	83 ec 0c             	sub    $0xc,%esp
  80137d:	25 07 0e 00 00       	and    $0xe07,%eax
  801382:	50                   	push   %eax
  801383:	53                   	push   %ebx
  801384:	6a 00                	push   $0x0
  801386:	52                   	push   %edx
  801387:	6a 00                	push   $0x0
  801389:	e8 4c f9 ff ff       	call   800cda <sys_page_map>
  80138e:	89 c7                	mov    %eax,%edi
  801390:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801393:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801395:	85 ff                	test   %edi,%edi
  801397:	79 1d                	jns    8013b6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801399:	83 ec 08             	sub    $0x8,%esp
  80139c:	53                   	push   %ebx
  80139d:	6a 00                	push   $0x0
  80139f:	e8 78 f9 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013a4:	83 c4 08             	add    $0x8,%esp
  8013a7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013aa:	6a 00                	push   $0x0
  8013ac:	e8 6b f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  8013b1:	83 c4 10             	add    $0x10,%esp
  8013b4:	89 f8                	mov    %edi,%eax
}
  8013b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5f                   	pop    %edi
  8013bc:	5d                   	pop    %ebp
  8013bd:	c3                   	ret    

008013be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 14             	sub    $0x14,%esp
  8013c5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013cb:	50                   	push   %eax
  8013cc:	53                   	push   %ebx
  8013cd:	e8 86 fd ff ff       	call   801158 <fd_lookup>
  8013d2:	83 c4 08             	add    $0x8,%esp
  8013d5:	89 c2                	mov    %eax,%edx
  8013d7:	85 c0                	test   %eax,%eax
  8013d9:	78 6d                	js     801448 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e1:	50                   	push   %eax
  8013e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013e5:	ff 30                	pushl  (%eax)
  8013e7:	e8 c2 fd ff ff       	call   8011ae <dev_lookup>
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 c0                	test   %eax,%eax
  8013f1:	78 4c                	js     80143f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013f6:	8b 42 08             	mov    0x8(%edx),%eax
  8013f9:	83 e0 03             	and    $0x3,%eax
  8013fc:	83 f8 01             	cmp    $0x1,%eax
  8013ff:	75 21                	jne    801422 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801401:	a1 04 40 80 00       	mov    0x804004,%eax
  801406:	8b 40 48             	mov    0x48(%eax),%eax
  801409:	83 ec 04             	sub    $0x4,%esp
  80140c:	53                   	push   %ebx
  80140d:	50                   	push   %eax
  80140e:	68 08 27 80 00       	push   $0x802708
  801413:	e8 f7 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801418:	83 c4 10             	add    $0x10,%esp
  80141b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801420:	eb 26                	jmp    801448 <read+0x8a>
	}
	if (!dev->dev_read)
  801422:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801425:	8b 40 08             	mov    0x8(%eax),%eax
  801428:	85 c0                	test   %eax,%eax
  80142a:	74 17                	je     801443 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80142c:	83 ec 04             	sub    $0x4,%esp
  80142f:	ff 75 10             	pushl  0x10(%ebp)
  801432:	ff 75 0c             	pushl  0xc(%ebp)
  801435:	52                   	push   %edx
  801436:	ff d0                	call   *%eax
  801438:	89 c2                	mov    %eax,%edx
  80143a:	83 c4 10             	add    $0x10,%esp
  80143d:	eb 09                	jmp    801448 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80143f:	89 c2                	mov    %eax,%edx
  801441:	eb 05                	jmp    801448 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801443:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801448:	89 d0                	mov    %edx,%eax
  80144a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	57                   	push   %edi
  801453:	56                   	push   %esi
  801454:	53                   	push   %ebx
  801455:	83 ec 0c             	sub    $0xc,%esp
  801458:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80145e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801463:	eb 21                	jmp    801486 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801465:	83 ec 04             	sub    $0x4,%esp
  801468:	89 f0                	mov    %esi,%eax
  80146a:	29 d8                	sub    %ebx,%eax
  80146c:	50                   	push   %eax
  80146d:	89 d8                	mov    %ebx,%eax
  80146f:	03 45 0c             	add    0xc(%ebp),%eax
  801472:	50                   	push   %eax
  801473:	57                   	push   %edi
  801474:	e8 45 ff ff ff       	call   8013be <read>
		if (m < 0)
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 10                	js     801490 <readn+0x41>
			return m;
		if (m == 0)
  801480:	85 c0                	test   %eax,%eax
  801482:	74 0a                	je     80148e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801484:	01 c3                	add    %eax,%ebx
  801486:	39 f3                	cmp    %esi,%ebx
  801488:	72 db                	jb     801465 <readn+0x16>
  80148a:	89 d8                	mov    %ebx,%eax
  80148c:	eb 02                	jmp    801490 <readn+0x41>
  80148e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801490:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801493:	5b                   	pop    %ebx
  801494:	5e                   	pop    %esi
  801495:	5f                   	pop    %edi
  801496:	5d                   	pop    %ebp
  801497:	c3                   	ret    

00801498 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801498:	55                   	push   %ebp
  801499:	89 e5                	mov    %esp,%ebp
  80149b:	53                   	push   %ebx
  80149c:	83 ec 14             	sub    $0x14,%esp
  80149f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a5:	50                   	push   %eax
  8014a6:	53                   	push   %ebx
  8014a7:	e8 ac fc ff ff       	call   801158 <fd_lookup>
  8014ac:	83 c4 08             	add    $0x8,%esp
  8014af:	89 c2                	mov    %eax,%edx
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 68                	js     80151d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bf:	ff 30                	pushl  (%eax)
  8014c1:	e8 e8 fc ff ff       	call   8011ae <dev_lookup>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 47                	js     801514 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014d4:	75 21                	jne    8014f7 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014db:	8b 40 48             	mov    0x48(%eax),%eax
  8014de:	83 ec 04             	sub    $0x4,%esp
  8014e1:	53                   	push   %ebx
  8014e2:	50                   	push   %eax
  8014e3:	68 24 27 80 00       	push   $0x802724
  8014e8:	e8 22 ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014ed:	83 c4 10             	add    $0x10,%esp
  8014f0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f5:	eb 26                	jmp    80151d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8014fd:	85 d2                	test   %edx,%edx
  8014ff:	74 17                	je     801518 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801501:	83 ec 04             	sub    $0x4,%esp
  801504:	ff 75 10             	pushl  0x10(%ebp)
  801507:	ff 75 0c             	pushl  0xc(%ebp)
  80150a:	50                   	push   %eax
  80150b:	ff d2                	call   *%edx
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	eb 09                	jmp    80151d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801514:	89 c2                	mov    %eax,%edx
  801516:	eb 05                	jmp    80151d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801518:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80151d:	89 d0                	mov    %edx,%eax
  80151f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801522:	c9                   	leave  
  801523:	c3                   	ret    

00801524 <seek>:

int
seek(int fdnum, off_t offset)
{
  801524:	55                   	push   %ebp
  801525:	89 e5                	mov    %esp,%ebp
  801527:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80152a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80152d:	50                   	push   %eax
  80152e:	ff 75 08             	pushl  0x8(%ebp)
  801531:	e8 22 fc ff ff       	call   801158 <fd_lookup>
  801536:	83 c4 08             	add    $0x8,%esp
  801539:	85 c0                	test   %eax,%eax
  80153b:	78 0e                	js     80154b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80153d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801540:	8b 55 0c             	mov    0xc(%ebp),%edx
  801543:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801546:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80154b:	c9                   	leave  
  80154c:	c3                   	ret    

0080154d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80154d:	55                   	push   %ebp
  80154e:	89 e5                	mov    %esp,%ebp
  801550:	53                   	push   %ebx
  801551:	83 ec 14             	sub    $0x14,%esp
  801554:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801557:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80155a:	50                   	push   %eax
  80155b:	53                   	push   %ebx
  80155c:	e8 f7 fb ff ff       	call   801158 <fd_lookup>
  801561:	83 c4 08             	add    $0x8,%esp
  801564:	89 c2                	mov    %eax,%edx
  801566:	85 c0                	test   %eax,%eax
  801568:	78 65                	js     8015cf <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801570:	50                   	push   %eax
  801571:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801574:	ff 30                	pushl  (%eax)
  801576:	e8 33 fc ff ff       	call   8011ae <dev_lookup>
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 44                	js     8015c6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801589:	75 21                	jne    8015ac <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80158b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801590:	8b 40 48             	mov    0x48(%eax),%eax
  801593:	83 ec 04             	sub    $0x4,%esp
  801596:	53                   	push   %ebx
  801597:	50                   	push   %eax
  801598:	68 e4 26 80 00       	push   $0x8026e4
  80159d:	e8 6d ed ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015aa:	eb 23                	jmp    8015cf <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015af:	8b 52 18             	mov    0x18(%edx),%edx
  8015b2:	85 d2                	test   %edx,%edx
  8015b4:	74 14                	je     8015ca <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	ff 75 0c             	pushl  0xc(%ebp)
  8015bc:	50                   	push   %eax
  8015bd:	ff d2                	call   *%edx
  8015bf:	89 c2                	mov    %eax,%edx
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	eb 09                	jmp    8015cf <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015c6:	89 c2                	mov    %eax,%edx
  8015c8:	eb 05                	jmp    8015cf <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015cf:	89 d0                	mov    %edx,%eax
  8015d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d4:	c9                   	leave  
  8015d5:	c3                   	ret    

008015d6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 14             	sub    $0x14,%esp
  8015dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	ff 75 08             	pushl  0x8(%ebp)
  8015e7:	e8 6c fb ff ff       	call   801158 <fd_lookup>
  8015ec:	83 c4 08             	add    $0x8,%esp
  8015ef:	89 c2                	mov    %eax,%edx
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	78 58                	js     80164d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ff:	ff 30                	pushl  (%eax)
  801601:	e8 a8 fb ff ff       	call   8011ae <dev_lookup>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 37                	js     801644 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80160d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801610:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801614:	74 32                	je     801648 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801616:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801619:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801620:	00 00 00 
	stat->st_isdir = 0;
  801623:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80162a:	00 00 00 
	stat->st_dev = dev;
  80162d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	53                   	push   %ebx
  801637:	ff 75 f0             	pushl  -0x10(%ebp)
  80163a:	ff 50 14             	call   *0x14(%eax)
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	eb 09                	jmp    80164d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801644:	89 c2                	mov    %eax,%edx
  801646:	eb 05                	jmp    80164d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801648:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80164d:	89 d0                	mov    %edx,%eax
  80164f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	56                   	push   %esi
  801658:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801659:	83 ec 08             	sub    $0x8,%esp
  80165c:	6a 00                	push   $0x0
  80165e:	ff 75 08             	pushl  0x8(%ebp)
  801661:	e8 b7 01 00 00       	call   80181d <open>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 1b                	js     80168a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	ff 75 0c             	pushl  0xc(%ebp)
  801675:	50                   	push   %eax
  801676:	e8 5b ff ff ff       	call   8015d6 <fstat>
  80167b:	89 c6                	mov    %eax,%esi
	close(fd);
  80167d:	89 1c 24             	mov    %ebx,(%esp)
  801680:	e8 fd fb ff ff       	call   801282 <close>
	return r;
  801685:	83 c4 10             	add    $0x10,%esp
  801688:	89 f0                	mov    %esi,%eax
}
  80168a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168d:	5b                   	pop    %ebx
  80168e:	5e                   	pop    %esi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	89 c6                	mov    %eax,%esi
  801698:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80169a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016a1:	75 12                	jne    8016b5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a3:	83 ec 0c             	sub    $0xc,%esp
  8016a6:	6a 01                	push   $0x1
  8016a8:	e8 19 08 00 00       	call   801ec6 <ipc_find_env>
  8016ad:	a3 00 40 80 00       	mov    %eax,0x804000
  8016b2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b5:	6a 07                	push   $0x7
  8016b7:	68 00 50 80 00       	push   $0x805000
  8016bc:	56                   	push   %esi
  8016bd:	ff 35 00 40 80 00    	pushl  0x804000
  8016c3:	e8 aa 07 00 00       	call   801e72 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c8:	83 c4 0c             	add    $0xc,%esp
  8016cb:	6a 00                	push   $0x0
  8016cd:	53                   	push   %ebx
  8016ce:	6a 00                	push   $0x0
  8016d0:	e8 36 07 00 00       	call   801e0b <ipc_recv>
}
  8016d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d8:	5b                   	pop    %ebx
  8016d9:	5e                   	pop    %esi
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fa:	b8 02 00 00 00       	mov    $0x2,%eax
  8016ff:	e8 8d ff ff ff       	call   801691 <fsipc>
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	8b 40 0c             	mov    0xc(%eax),%eax
  801712:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801717:	ba 00 00 00 00       	mov    $0x0,%edx
  80171c:	b8 06 00 00 00       	mov    $0x6,%eax
  801721:	e8 6b ff ff ff       	call   801691 <fsipc>
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 04             	sub    $0x4,%esp
  80172f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	8b 40 0c             	mov    0xc(%eax),%eax
  801738:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 05 00 00 00       	mov    $0x5,%eax
  801747:	e8 45 ff ff ff       	call   801691 <fsipc>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 2c                	js     80177c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	68 00 50 80 00       	push   $0x805000
  801758:	53                   	push   %ebx
  801759:	e8 36 f1 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80175e:	a1 80 50 80 00       	mov    0x805080,%eax
  801763:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801769:	a1 84 50 80 00       	mov    0x805084,%eax
  80176e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801774:	83 c4 10             	add    $0x10,%esp
  801777:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80177c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80177f:	c9                   	leave  
  801780:	c3                   	ret    

00801781 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 0c             	sub    $0xc,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801787:	68 54 27 80 00       	push   $0x802754
  80178c:	68 90 00 00 00       	push   $0x90
  801791:	68 72 27 80 00       	push   $0x802772
  801796:	e8 9b ea ff ff       	call   800236 <_panic>

0080179b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	56                   	push   %esi
  80179f:	53                   	push   %ebx
  8017a0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017ae:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b9:	b8 03 00 00 00       	mov    $0x3,%eax
  8017be:	e8 ce fe ff ff       	call   801691 <fsipc>
  8017c3:	89 c3                	mov    %eax,%ebx
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 4b                	js     801814 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8017c9:	39 c6                	cmp    %eax,%esi
  8017cb:	73 16                	jae    8017e3 <devfile_read+0x48>
  8017cd:	68 7d 27 80 00       	push   $0x80277d
  8017d2:	68 84 27 80 00       	push   $0x802784
  8017d7:	6a 7c                	push   $0x7c
  8017d9:	68 72 27 80 00       	push   $0x802772
  8017de:	e8 53 ea ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8017e3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017e8:	7e 16                	jle    801800 <devfile_read+0x65>
  8017ea:	68 99 27 80 00       	push   $0x802799
  8017ef:	68 84 27 80 00       	push   $0x802784
  8017f4:	6a 7d                	push   $0x7d
  8017f6:	68 72 27 80 00       	push   $0x802772
  8017fb:	e8 36 ea ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801800:	83 ec 04             	sub    $0x4,%esp
  801803:	50                   	push   %eax
  801804:	68 00 50 80 00       	push   $0x805000
  801809:	ff 75 0c             	pushl  0xc(%ebp)
  80180c:	e8 15 f2 ff ff       	call   800a26 <memmove>
	return r;
  801811:	83 c4 10             	add    $0x10,%esp
}
  801814:	89 d8                	mov    %ebx,%eax
  801816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801819:	5b                   	pop    %ebx
  80181a:	5e                   	pop    %esi
  80181b:	5d                   	pop    %ebp
  80181c:	c3                   	ret    

0080181d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80181d:	55                   	push   %ebp
  80181e:	89 e5                	mov    %esp,%ebp
  801820:	53                   	push   %ebx
  801821:	83 ec 20             	sub    $0x20,%esp
  801824:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801827:	53                   	push   %ebx
  801828:	e8 2e f0 ff ff       	call   80085b <strlen>
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801835:	7f 67                	jg     80189e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801837:	83 ec 0c             	sub    $0xc,%esp
  80183a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80183d:	50                   	push   %eax
  80183e:	e8 c6 f8 ff ff       	call   801109 <fd_alloc>
  801843:	83 c4 10             	add    $0x10,%esp
		return r;
  801846:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801848:	85 c0                	test   %eax,%eax
  80184a:	78 57                	js     8018a3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	53                   	push   %ebx
  801850:	68 00 50 80 00       	push   $0x805000
  801855:	e8 3a f0 ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80185a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801862:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801865:	b8 01 00 00 00       	mov    $0x1,%eax
  80186a:	e8 22 fe ff ff       	call   801691 <fsipc>
  80186f:	89 c3                	mov    %eax,%ebx
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	85 c0                	test   %eax,%eax
  801876:	79 14                	jns    80188c <open+0x6f>
		fd_close(fd, 0);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	6a 00                	push   $0x0
  80187d:	ff 75 f4             	pushl  -0xc(%ebp)
  801880:	e8 7c f9 ff ff       	call   801201 <fd_close>
		return r;
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	89 da                	mov    %ebx,%edx
  80188a:	eb 17                	jmp    8018a3 <open+0x86>
	}

	return fd2num(fd);
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	ff 75 f4             	pushl  -0xc(%ebp)
  801892:	e8 4b f8 ff ff       	call   8010e2 <fd2num>
  801897:	89 c2                	mov    %eax,%edx
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	eb 05                	jmp    8018a3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80189e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018a3:	89 d0                	mov    %edx,%eax
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    

008018aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
  8018ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8018ba:	e8 d2 fd ff ff       	call   801691 <fsipc>
}
  8018bf:	c9                   	leave  
  8018c0:	c3                   	ret    

008018c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018c1:	55                   	push   %ebp
  8018c2:	89 e5                	mov    %esp,%ebp
  8018c4:	56                   	push   %esi
  8018c5:	53                   	push   %ebx
  8018c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018c9:	83 ec 0c             	sub    $0xc,%esp
  8018cc:	ff 75 08             	pushl  0x8(%ebp)
  8018cf:	e8 1e f8 ff ff       	call   8010f2 <fd2data>
  8018d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018d6:	83 c4 08             	add    $0x8,%esp
  8018d9:	68 a5 27 80 00       	push   $0x8027a5
  8018de:	53                   	push   %ebx
  8018df:	e8 b0 ef ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018e4:	8b 46 04             	mov    0x4(%esi),%eax
  8018e7:	2b 06                	sub    (%esi),%eax
  8018e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018f6:	00 00 00 
	stat->st_dev = &devpipe;
  8018f9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801900:	30 80 00 
	return 0;
}
  801903:	b8 00 00 00 00       	mov    $0x0,%eax
  801908:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	53                   	push   %ebx
  801913:	83 ec 0c             	sub    $0xc,%esp
  801916:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801919:	53                   	push   %ebx
  80191a:	6a 00                	push   $0x0
  80191c:	e8 fb f3 ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801921:	89 1c 24             	mov    %ebx,(%esp)
  801924:	e8 c9 f7 ff ff       	call   8010f2 <fd2data>
  801929:	83 c4 08             	add    $0x8,%esp
  80192c:	50                   	push   %eax
  80192d:	6a 00                	push   $0x0
  80192f:	e8 e8 f3 ff ff       	call   800d1c <sys_page_unmap>
}
  801934:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801937:	c9                   	leave  
  801938:	c3                   	ret    

00801939 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	57                   	push   %edi
  80193d:	56                   	push   %esi
  80193e:	53                   	push   %ebx
  80193f:	83 ec 1c             	sub    $0x1c,%esp
  801942:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801945:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801947:	a1 04 40 80 00       	mov    0x804004,%eax
  80194c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	ff 75 e0             	pushl  -0x20(%ebp)
  801955:	e8 a5 05 00 00       	call   801eff <pageref>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	89 3c 24             	mov    %edi,(%esp)
  80195f:	e8 9b 05 00 00       	call   801eff <pageref>
  801964:	83 c4 10             	add    $0x10,%esp
  801967:	39 c3                	cmp    %eax,%ebx
  801969:	0f 94 c1             	sete   %cl
  80196c:	0f b6 c9             	movzbl %cl,%ecx
  80196f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801972:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801978:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80197b:	39 ce                	cmp    %ecx,%esi
  80197d:	74 1b                	je     80199a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80197f:	39 c3                	cmp    %eax,%ebx
  801981:	75 c4                	jne    801947 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801983:	8b 42 58             	mov    0x58(%edx),%eax
  801986:	ff 75 e4             	pushl  -0x1c(%ebp)
  801989:	50                   	push   %eax
  80198a:	56                   	push   %esi
  80198b:	68 ac 27 80 00       	push   $0x8027ac
  801990:	e8 7a e9 ff ff       	call   80030f <cprintf>
  801995:	83 c4 10             	add    $0x10,%esp
  801998:	eb ad                	jmp    801947 <_pipeisclosed+0xe>
	}
}
  80199a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80199d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a0:	5b                   	pop    %ebx
  8019a1:	5e                   	pop    %esi
  8019a2:	5f                   	pop    %edi
  8019a3:	5d                   	pop    %ebp
  8019a4:	c3                   	ret    

008019a5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8019a5:	55                   	push   %ebp
  8019a6:	89 e5                	mov    %esp,%ebp
  8019a8:	57                   	push   %edi
  8019a9:	56                   	push   %esi
  8019aa:	53                   	push   %ebx
  8019ab:	83 ec 28             	sub    $0x28,%esp
  8019ae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8019b1:	56                   	push   %esi
  8019b2:	e8 3b f7 ff ff       	call   8010f2 <fd2data>
  8019b7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	bf 00 00 00 00       	mov    $0x0,%edi
  8019c1:	eb 4b                	jmp    801a0e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019c3:	89 da                	mov    %ebx,%edx
  8019c5:	89 f0                	mov    %esi,%eax
  8019c7:	e8 6d ff ff ff       	call   801939 <_pipeisclosed>
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	75 48                	jne    801a18 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019d0:	e8 a3 f2 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019d5:	8b 43 04             	mov    0x4(%ebx),%eax
  8019d8:	8b 0b                	mov    (%ebx),%ecx
  8019da:	8d 51 20             	lea    0x20(%ecx),%edx
  8019dd:	39 d0                	cmp    %edx,%eax
  8019df:	73 e2                	jae    8019c3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019e4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019e8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019eb:	89 c2                	mov    %eax,%edx
  8019ed:	c1 fa 1f             	sar    $0x1f,%edx
  8019f0:	89 d1                	mov    %edx,%ecx
  8019f2:	c1 e9 1b             	shr    $0x1b,%ecx
  8019f5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019f8:	83 e2 1f             	and    $0x1f,%edx
  8019fb:	29 ca                	sub    %ecx,%edx
  8019fd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a05:	83 c0 01             	add    $0x1,%eax
  801a08:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a0b:	83 c7 01             	add    $0x1,%edi
  801a0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a11:	75 c2                	jne    8019d5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801a13:	8b 45 10             	mov    0x10(%ebp),%eax
  801a16:	eb 05                	jmp    801a1d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a20:	5b                   	pop    %ebx
  801a21:	5e                   	pop    %esi
  801a22:	5f                   	pop    %edi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    

00801a25 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a25:	55                   	push   %ebp
  801a26:	89 e5                	mov    %esp,%ebp
  801a28:	57                   	push   %edi
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	83 ec 18             	sub    $0x18,%esp
  801a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a31:	57                   	push   %edi
  801a32:	e8 bb f6 ff ff       	call   8010f2 <fd2data>
  801a37:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a39:	83 c4 10             	add    $0x10,%esp
  801a3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a41:	eb 3d                	jmp    801a80 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	74 04                	je     801a4b <devpipe_read+0x26>
				return i;
  801a47:	89 d8                	mov    %ebx,%eax
  801a49:	eb 44                	jmp    801a8f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a4b:	89 f2                	mov    %esi,%edx
  801a4d:	89 f8                	mov    %edi,%eax
  801a4f:	e8 e5 fe ff ff       	call   801939 <_pipeisclosed>
  801a54:	85 c0                	test   %eax,%eax
  801a56:	75 32                	jne    801a8a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a58:	e8 1b f2 ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a5d:	8b 06                	mov    (%esi),%eax
  801a5f:	3b 46 04             	cmp    0x4(%esi),%eax
  801a62:	74 df                	je     801a43 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a64:	99                   	cltd   
  801a65:	c1 ea 1b             	shr    $0x1b,%edx
  801a68:	01 d0                	add    %edx,%eax
  801a6a:	83 e0 1f             	and    $0x1f,%eax
  801a6d:	29 d0                	sub    %edx,%eax
  801a6f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a77:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a7a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a7d:	83 c3 01             	add    $0x1,%ebx
  801a80:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a83:	75 d8                	jne    801a5d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a85:	8b 45 10             	mov    0x10(%ebp),%eax
  801a88:	eb 05                	jmp    801a8f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5f                   	pop    %edi
  801a95:	5d                   	pop    %ebp
  801a96:	c3                   	ret    

00801a97 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a97:	55                   	push   %ebp
  801a98:	89 e5                	mov    %esp,%ebp
  801a9a:	56                   	push   %esi
  801a9b:	53                   	push   %ebx
  801a9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa2:	50                   	push   %eax
  801aa3:	e8 61 f6 ff ff       	call   801109 <fd_alloc>
  801aa8:	83 c4 10             	add    $0x10,%esp
  801aab:	89 c2                	mov    %eax,%edx
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	0f 88 2c 01 00 00    	js     801be1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	68 07 04 00 00       	push   $0x407
  801abd:	ff 75 f4             	pushl  -0xc(%ebp)
  801ac0:	6a 00                	push   $0x0
  801ac2:	e8 d0 f1 ff ff       	call   800c97 <sys_page_alloc>
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	89 c2                	mov    %eax,%edx
  801acc:	85 c0                	test   %eax,%eax
  801ace:	0f 88 0d 01 00 00    	js     801be1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ada:	50                   	push   %eax
  801adb:	e8 29 f6 ff ff       	call   801109 <fd_alloc>
  801ae0:	89 c3                	mov    %eax,%ebx
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 e2 00 00 00    	js     801bcf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	68 07 04 00 00       	push   $0x407
  801af5:	ff 75 f0             	pushl  -0x10(%ebp)
  801af8:	6a 00                	push   $0x0
  801afa:	e8 98 f1 ff ff       	call   800c97 <sys_page_alloc>
  801aff:	89 c3                	mov    %eax,%ebx
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	85 c0                	test   %eax,%eax
  801b06:	0f 88 c3 00 00 00    	js     801bcf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b0c:	83 ec 0c             	sub    $0xc,%esp
  801b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b12:	e8 db f5 ff ff       	call   8010f2 <fd2data>
  801b17:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b19:	83 c4 0c             	add    $0xc,%esp
  801b1c:	68 07 04 00 00       	push   $0x407
  801b21:	50                   	push   %eax
  801b22:	6a 00                	push   $0x0
  801b24:	e8 6e f1 ff ff       	call   800c97 <sys_page_alloc>
  801b29:	89 c3                	mov    %eax,%ebx
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	0f 88 89 00 00 00    	js     801bbf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b36:	83 ec 0c             	sub    $0xc,%esp
  801b39:	ff 75 f0             	pushl  -0x10(%ebp)
  801b3c:	e8 b1 f5 ff ff       	call   8010f2 <fd2data>
  801b41:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b48:	50                   	push   %eax
  801b49:	6a 00                	push   $0x0
  801b4b:	56                   	push   %esi
  801b4c:	6a 00                	push   $0x0
  801b4e:	e8 87 f1 ff ff       	call   800cda <sys_page_map>
  801b53:	89 c3                	mov    %eax,%ebx
  801b55:	83 c4 20             	add    $0x20,%esp
  801b58:	85 c0                	test   %eax,%eax
  801b5a:	78 55                	js     801bb1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b71:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 f4             	pushl  -0xc(%ebp)
  801b8c:	e8 51 f5 ff ff       	call   8010e2 <fd2num>
  801b91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b96:	83 c4 04             	add    $0x4,%esp
  801b99:	ff 75 f0             	pushl  -0x10(%ebp)
  801b9c:	e8 41 f5 ff ff       	call   8010e2 <fd2num>
  801ba1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	ba 00 00 00 00       	mov    $0x0,%edx
  801baf:	eb 30                	jmp    801be1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801bb1:	83 ec 08             	sub    $0x8,%esp
  801bb4:	56                   	push   %esi
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 60 f1 ff ff       	call   800d1c <sys_page_unmap>
  801bbc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801bbf:	83 ec 08             	sub    $0x8,%esp
  801bc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 50 f1 ff ff       	call   800d1c <sys_page_unmap>
  801bcc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bcf:	83 ec 08             	sub    $0x8,%esp
  801bd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bd5:	6a 00                	push   $0x0
  801bd7:	e8 40 f1 ff ff       	call   800d1c <sys_page_unmap>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801be1:	89 d0                	mov    %edx,%eax
  801be3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801be6:	5b                   	pop    %ebx
  801be7:	5e                   	pop    %esi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    

00801bea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bea:	55                   	push   %ebp
  801beb:	89 e5                	mov    %esp,%ebp
  801bed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf3:	50                   	push   %eax
  801bf4:	ff 75 08             	pushl  0x8(%ebp)
  801bf7:	e8 5c f5 ff ff       	call   801158 <fd_lookup>
  801bfc:	83 c4 10             	add    $0x10,%esp
  801bff:	85 c0                	test   %eax,%eax
  801c01:	78 18                	js     801c1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 75 f4             	pushl  -0xc(%ebp)
  801c09:	e8 e4 f4 ff ff       	call   8010f2 <fd2data>
	return _pipeisclosed(fd, p);
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c13:	e8 21 fd ff ff       	call   801939 <_pipeisclosed>
  801c18:	83 c4 10             	add    $0x10,%esp
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c20:	b8 00 00 00 00       	mov    $0x0,%eax
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    

00801c27 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c27:	55                   	push   %ebp
  801c28:	89 e5                	mov    %esp,%ebp
  801c2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c2d:	68 c4 27 80 00       	push   $0x8027c4
  801c32:	ff 75 0c             	pushl  0xc(%ebp)
  801c35:	e8 5a ec ff ff       	call   800894 <strcpy>
	return 0;
}
  801c3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	57                   	push   %edi
  801c45:	56                   	push   %esi
  801c46:	53                   	push   %ebx
  801c47:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c4d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c52:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c58:	eb 2d                	jmp    801c87 <devcons_write+0x46>
		m = n - tot;
  801c5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c5d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c5f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c62:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c67:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c6a:	83 ec 04             	sub    $0x4,%esp
  801c6d:	53                   	push   %ebx
  801c6e:	03 45 0c             	add    0xc(%ebp),%eax
  801c71:	50                   	push   %eax
  801c72:	57                   	push   %edi
  801c73:	e8 ae ed ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  801c78:	83 c4 08             	add    $0x8,%esp
  801c7b:	53                   	push   %ebx
  801c7c:	57                   	push   %edi
  801c7d:	e8 59 ef ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c82:	01 de                	add    %ebx,%esi
  801c84:	83 c4 10             	add    $0x10,%esp
  801c87:	89 f0                	mov    %esi,%eax
  801c89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c8c:	72 cc                	jb     801c5a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5f                   	pop    %edi
  801c94:	5d                   	pop    %ebp
  801c95:	c3                   	ret    

00801c96 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	83 ec 08             	sub    $0x8,%esp
  801c9c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ca1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ca5:	74 2a                	je     801cd1 <devcons_read+0x3b>
  801ca7:	eb 05                	jmp    801cae <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ca9:	e8 ca ef ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801cae:	e8 46 ef ff ff       	call   800bf9 <sys_cgetc>
  801cb3:	85 c0                	test   %eax,%eax
  801cb5:	74 f2                	je     801ca9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	78 16                	js     801cd1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801cbb:	83 f8 04             	cmp    $0x4,%eax
  801cbe:	74 0c                	je     801ccc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801cc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc3:	88 02                	mov    %al,(%edx)
	return 1;
  801cc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801cca:	eb 05                	jmp    801cd1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ccc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cd1:	c9                   	leave  
  801cd2:	c3                   	ret    

00801cd3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cd3:	55                   	push   %ebp
  801cd4:	89 e5                	mov    %esp,%ebp
  801cd6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cdf:	6a 01                	push   $0x1
  801ce1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce4:	50                   	push   %eax
  801ce5:	e8 f1 ee ff ff       	call   800bdb <sys_cputs>
}
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	c9                   	leave  
  801cee:	c3                   	ret    

00801cef <getchar>:

int
getchar(void)
{
  801cef:	55                   	push   %ebp
  801cf0:	89 e5                	mov    %esp,%ebp
  801cf2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cf5:	6a 01                	push   $0x1
  801cf7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801cfa:	50                   	push   %eax
  801cfb:	6a 00                	push   $0x0
  801cfd:	e8 bc f6 ff ff       	call   8013be <read>
	if (r < 0)
  801d02:	83 c4 10             	add    $0x10,%esp
  801d05:	85 c0                	test   %eax,%eax
  801d07:	78 0f                	js     801d18 <getchar+0x29>
		return r;
	if (r < 1)
  801d09:	85 c0                	test   %eax,%eax
  801d0b:	7e 06                	jle    801d13 <getchar+0x24>
		return -E_EOF;
	return c;
  801d0d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801d11:	eb 05                	jmp    801d18 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801d13:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d18:	c9                   	leave  
  801d19:	c3                   	ret    

00801d1a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d1a:	55                   	push   %ebp
  801d1b:	89 e5                	mov    %esp,%ebp
  801d1d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d23:	50                   	push   %eax
  801d24:	ff 75 08             	pushl  0x8(%ebp)
  801d27:	e8 2c f4 ff ff       	call   801158 <fd_lookup>
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	78 11                	js     801d44 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d3c:	39 10                	cmp    %edx,(%eax)
  801d3e:	0f 94 c0             	sete   %al
  801d41:	0f b6 c0             	movzbl %al,%eax
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <opencons>:

int
opencons(void)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d4f:	50                   	push   %eax
  801d50:	e8 b4 f3 ff ff       	call   801109 <fd_alloc>
  801d55:	83 c4 10             	add    $0x10,%esp
		return r;
  801d58:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d5a:	85 c0                	test   %eax,%eax
  801d5c:	78 3e                	js     801d9c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d5e:	83 ec 04             	sub    $0x4,%esp
  801d61:	68 07 04 00 00       	push   $0x407
  801d66:	ff 75 f4             	pushl  -0xc(%ebp)
  801d69:	6a 00                	push   $0x0
  801d6b:	e8 27 ef ff ff       	call   800c97 <sys_page_alloc>
  801d70:	83 c4 10             	add    $0x10,%esp
		return r;
  801d73:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d75:	85 c0                	test   %eax,%eax
  801d77:	78 23                	js     801d9c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d82:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d87:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	50                   	push   %eax
  801d92:	e8 4b f3 ff ff       	call   8010e2 <fd2num>
  801d97:	89 c2                	mov    %eax,%edx
  801d99:	83 c4 10             	add    $0x10,%esp
}
  801d9c:	89 d0                	mov    %edx,%eax
  801d9e:	c9                   	leave  
  801d9f:	c3                   	ret    

00801da0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801da6:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801dad:	75 2e                	jne    801ddd <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  801daf:	e8 a5 ee ff ff       	call   800c59 <sys_getenvid>
  801db4:	83 ec 04             	sub    $0x4,%esp
  801db7:	68 07 0e 00 00       	push   $0xe07
  801dbc:	68 00 f0 bf ee       	push   $0xeebff000
  801dc1:	50                   	push   %eax
  801dc2:	e8 d0 ee ff ff       	call   800c97 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801dc7:	e8 8d ee ff ff       	call   800c59 <sys_getenvid>
  801dcc:	83 c4 08             	add    $0x8,%esp
  801dcf:	68 e7 1d 80 00       	push   $0x801de7
  801dd4:	50                   	push   %eax
  801dd5:	e8 08 f0 ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  801dda:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801ddd:	8b 45 08             	mov    0x8(%ebp),%eax
  801de0:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801de7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801de8:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801ded:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801def:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  801df2:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  801df6:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  801dfa:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  801dfd:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  801e00:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  801e01:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  801e04:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  801e05:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  801e06:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  801e0a:	c3                   	ret    

00801e0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e0b:	55                   	push   %ebp
  801e0c:	89 e5                	mov    %esp,%ebp
  801e0e:	56                   	push   %esi
  801e0f:	53                   	push   %ebx
  801e10:	8b 75 08             	mov    0x8(%ebp),%esi
  801e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  801e19:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  801e1b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e20:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  801e23:	83 ec 0c             	sub    $0xc,%esp
  801e26:	50                   	push   %eax
  801e27:	e8 1b f0 ff ff       	call   800e47 <sys_ipc_recv>

	if (from_env_store != NULL)
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	85 f6                	test   %esi,%esi
  801e31:	74 14                	je     801e47 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  801e33:	ba 00 00 00 00       	mov    $0x0,%edx
  801e38:	85 c0                	test   %eax,%eax
  801e3a:	78 09                	js     801e45 <ipc_recv+0x3a>
  801e3c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e42:	8b 52 74             	mov    0x74(%edx),%edx
  801e45:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  801e47:	85 db                	test   %ebx,%ebx
  801e49:	74 14                	je     801e5f <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  801e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  801e50:	85 c0                	test   %eax,%eax
  801e52:	78 09                	js     801e5d <ipc_recv+0x52>
  801e54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e5a:	8b 52 78             	mov    0x78(%edx),%edx
  801e5d:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  801e5f:	85 c0                	test   %eax,%eax
  801e61:	78 08                	js     801e6b <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  801e63:	a1 04 40 80 00       	mov    0x804004,%eax
  801e68:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e6b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6e:	5b                   	pop    %ebx
  801e6f:	5e                   	pop    %esi
  801e70:	5d                   	pop    %ebp
  801e71:	c3                   	ret    

00801e72 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	57                   	push   %edi
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	83 ec 0c             	sub    $0xc,%esp
  801e7b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  801e84:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  801e86:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e8b:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  801e8e:	ff 75 14             	pushl  0x14(%ebp)
  801e91:	53                   	push   %ebx
  801e92:	56                   	push   %esi
  801e93:	57                   	push   %edi
  801e94:	e8 8b ef ff ff       	call   800e24 <sys_ipc_try_send>

		if (err < 0) {
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	79 1e                	jns    801ebe <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  801ea0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ea3:	75 07                	jne    801eac <ipc_send+0x3a>
				sys_yield();
  801ea5:	e8 ce ed ff ff       	call   800c78 <sys_yield>
  801eaa:	eb e2                	jmp    801e8e <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  801eac:	50                   	push   %eax
  801ead:	68 d0 27 80 00       	push   $0x8027d0
  801eb2:	6a 49                	push   $0x49
  801eb4:	68 dd 27 80 00       	push   $0x8027dd
  801eb9:	e8 78 e3 ff ff       	call   800236 <_panic>
		}

	} while (err < 0);

}
  801ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ecc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ed1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ed4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801eda:	8b 52 50             	mov    0x50(%edx),%edx
  801edd:	39 ca                	cmp    %ecx,%edx
  801edf:	75 0d                	jne    801eee <ipc_find_env+0x28>
			return envs[i].env_id;
  801ee1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ee4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ee9:	8b 40 48             	mov    0x48(%eax),%eax
  801eec:	eb 0f                	jmp    801efd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801eee:	83 c0 01             	add    $0x1,%eax
  801ef1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef6:	75 d9                	jne    801ed1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ef8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801efd:	5d                   	pop    %ebp
  801efe:	c3                   	ret    

00801eff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eff:	55                   	push   %ebp
  801f00:	89 e5                	mov    %esp,%ebp
  801f02:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f05:	89 d0                	mov    %edx,%eax
  801f07:	c1 e8 16             	shr    $0x16,%eax
  801f0a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f11:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f16:	f6 c1 01             	test   $0x1,%cl
  801f19:	74 1d                	je     801f38 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f1b:	c1 ea 0c             	shr    $0xc,%edx
  801f1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f25:	f6 c2 01             	test   $0x1,%dl
  801f28:	74 0e                	je     801f38 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f2a:	c1 ea 0c             	shr    $0xc,%edx
  801f2d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f34:	ef 
  801f35:	0f b7 c0             	movzwl %ax,%eax
}
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    
  801f3a:	66 90                	xchg   %ax,%ax
  801f3c:	66 90                	xchg   %ax,%ax
  801f3e:	66 90                	xchg   %ax,%ax

00801f40 <__udivdi3>:
  801f40:	55                   	push   %ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 1c             	sub    $0x1c,%esp
  801f47:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f4b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f4f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f57:	85 f6                	test   %esi,%esi
  801f59:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f5d:	89 ca                	mov    %ecx,%edx
  801f5f:	89 f8                	mov    %edi,%eax
  801f61:	75 3d                	jne    801fa0 <__udivdi3+0x60>
  801f63:	39 cf                	cmp    %ecx,%edi
  801f65:	0f 87 c5 00 00 00    	ja     802030 <__udivdi3+0xf0>
  801f6b:	85 ff                	test   %edi,%edi
  801f6d:	89 fd                	mov    %edi,%ebp
  801f6f:	75 0b                	jne    801f7c <__udivdi3+0x3c>
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
  801f76:	31 d2                	xor    %edx,%edx
  801f78:	f7 f7                	div    %edi
  801f7a:	89 c5                	mov    %eax,%ebp
  801f7c:	89 c8                	mov    %ecx,%eax
  801f7e:	31 d2                	xor    %edx,%edx
  801f80:	f7 f5                	div    %ebp
  801f82:	89 c1                	mov    %eax,%ecx
  801f84:	89 d8                	mov    %ebx,%eax
  801f86:	89 cf                	mov    %ecx,%edi
  801f88:	f7 f5                	div    %ebp
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	89 d8                	mov    %ebx,%eax
  801f8e:	89 fa                	mov    %edi,%edx
  801f90:	83 c4 1c             	add    $0x1c,%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
  801f98:	90                   	nop
  801f99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fa0:	39 ce                	cmp    %ecx,%esi
  801fa2:	77 74                	ja     802018 <__udivdi3+0xd8>
  801fa4:	0f bd fe             	bsr    %esi,%edi
  801fa7:	83 f7 1f             	xor    $0x1f,%edi
  801faa:	0f 84 98 00 00 00    	je     802048 <__udivdi3+0x108>
  801fb0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fb5:	89 f9                	mov    %edi,%ecx
  801fb7:	89 c5                	mov    %eax,%ebp
  801fb9:	29 fb                	sub    %edi,%ebx
  801fbb:	d3 e6                	shl    %cl,%esi
  801fbd:	89 d9                	mov    %ebx,%ecx
  801fbf:	d3 ed                	shr    %cl,%ebp
  801fc1:	89 f9                	mov    %edi,%ecx
  801fc3:	d3 e0                	shl    %cl,%eax
  801fc5:	09 ee                	or     %ebp,%esi
  801fc7:	89 d9                	mov    %ebx,%ecx
  801fc9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fcd:	89 d5                	mov    %edx,%ebp
  801fcf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fd3:	d3 ed                	shr    %cl,%ebp
  801fd5:	89 f9                	mov    %edi,%ecx
  801fd7:	d3 e2                	shl    %cl,%edx
  801fd9:	89 d9                	mov    %ebx,%ecx
  801fdb:	d3 e8                	shr    %cl,%eax
  801fdd:	09 c2                	or     %eax,%edx
  801fdf:	89 d0                	mov    %edx,%eax
  801fe1:	89 ea                	mov    %ebp,%edx
  801fe3:	f7 f6                	div    %esi
  801fe5:	89 d5                	mov    %edx,%ebp
  801fe7:	89 c3                	mov    %eax,%ebx
  801fe9:	f7 64 24 0c          	mull   0xc(%esp)
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	72 10                	jb     802001 <__udivdi3+0xc1>
  801ff1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ff5:	89 f9                	mov    %edi,%ecx
  801ff7:	d3 e6                	shl    %cl,%esi
  801ff9:	39 c6                	cmp    %eax,%esi
  801ffb:	73 07                	jae    802004 <__udivdi3+0xc4>
  801ffd:	39 d5                	cmp    %edx,%ebp
  801fff:	75 03                	jne    802004 <__udivdi3+0xc4>
  802001:	83 eb 01             	sub    $0x1,%ebx
  802004:	31 ff                	xor    %edi,%edi
  802006:	89 d8                	mov    %ebx,%eax
  802008:	89 fa                	mov    %edi,%edx
  80200a:	83 c4 1c             	add    $0x1c,%esp
  80200d:	5b                   	pop    %ebx
  80200e:	5e                   	pop    %esi
  80200f:	5f                   	pop    %edi
  802010:	5d                   	pop    %ebp
  802011:	c3                   	ret    
  802012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802018:	31 ff                	xor    %edi,%edi
  80201a:	31 db                	xor    %ebx,%ebx
  80201c:	89 d8                	mov    %ebx,%eax
  80201e:	89 fa                	mov    %edi,%edx
  802020:	83 c4 1c             	add    $0x1c,%esp
  802023:	5b                   	pop    %ebx
  802024:	5e                   	pop    %esi
  802025:	5f                   	pop    %edi
  802026:	5d                   	pop    %ebp
  802027:	c3                   	ret    
  802028:	90                   	nop
  802029:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802030:	89 d8                	mov    %ebx,%eax
  802032:	f7 f7                	div    %edi
  802034:	31 ff                	xor    %edi,%edi
  802036:	89 c3                	mov    %eax,%ebx
  802038:	89 d8                	mov    %ebx,%eax
  80203a:	89 fa                	mov    %edi,%edx
  80203c:	83 c4 1c             	add    $0x1c,%esp
  80203f:	5b                   	pop    %ebx
  802040:	5e                   	pop    %esi
  802041:	5f                   	pop    %edi
  802042:	5d                   	pop    %ebp
  802043:	c3                   	ret    
  802044:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802048:	39 ce                	cmp    %ecx,%esi
  80204a:	72 0c                	jb     802058 <__udivdi3+0x118>
  80204c:	31 db                	xor    %ebx,%ebx
  80204e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802052:	0f 87 34 ff ff ff    	ja     801f8c <__udivdi3+0x4c>
  802058:	bb 01 00 00 00       	mov    $0x1,%ebx
  80205d:	e9 2a ff ff ff       	jmp    801f8c <__udivdi3+0x4c>
  802062:	66 90                	xchg   %ax,%ax
  802064:	66 90                	xchg   %ax,%ax
  802066:	66 90                	xchg   %ax,%ax
  802068:	66 90                	xchg   %ax,%ax
  80206a:	66 90                	xchg   %ax,%ax
  80206c:	66 90                	xchg   %ax,%ax
  80206e:	66 90                	xchg   %ax,%ax

00802070 <__umoddi3>:
  802070:	55                   	push   %ebp
  802071:	57                   	push   %edi
  802072:	56                   	push   %esi
  802073:	53                   	push   %ebx
  802074:	83 ec 1c             	sub    $0x1c,%esp
  802077:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80207b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80207f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802083:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802087:	85 d2                	test   %edx,%edx
  802089:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80208d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802091:	89 f3                	mov    %esi,%ebx
  802093:	89 3c 24             	mov    %edi,(%esp)
  802096:	89 74 24 04          	mov    %esi,0x4(%esp)
  80209a:	75 1c                	jne    8020b8 <__umoddi3+0x48>
  80209c:	39 f7                	cmp    %esi,%edi
  80209e:	76 50                	jbe    8020f0 <__umoddi3+0x80>
  8020a0:	89 c8                	mov    %ecx,%eax
  8020a2:	89 f2                	mov    %esi,%edx
  8020a4:	f7 f7                	div    %edi
  8020a6:	89 d0                	mov    %edx,%eax
  8020a8:	31 d2                	xor    %edx,%edx
  8020aa:	83 c4 1c             	add    $0x1c,%esp
  8020ad:	5b                   	pop    %ebx
  8020ae:	5e                   	pop    %esi
  8020af:	5f                   	pop    %edi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    
  8020b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020b8:	39 f2                	cmp    %esi,%edx
  8020ba:	89 d0                	mov    %edx,%eax
  8020bc:	77 52                	ja     802110 <__umoddi3+0xa0>
  8020be:	0f bd ea             	bsr    %edx,%ebp
  8020c1:	83 f5 1f             	xor    $0x1f,%ebp
  8020c4:	75 5a                	jne    802120 <__umoddi3+0xb0>
  8020c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ca:	0f 82 e0 00 00 00    	jb     8021b0 <__umoddi3+0x140>
  8020d0:	39 0c 24             	cmp    %ecx,(%esp)
  8020d3:	0f 86 d7 00 00 00    	jbe    8021b0 <__umoddi3+0x140>
  8020d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020e1:	83 c4 1c             	add    $0x1c,%esp
  8020e4:	5b                   	pop    %ebx
  8020e5:	5e                   	pop    %esi
  8020e6:	5f                   	pop    %edi
  8020e7:	5d                   	pop    %ebp
  8020e8:	c3                   	ret    
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	85 ff                	test   %edi,%edi
  8020f2:	89 fd                	mov    %edi,%ebp
  8020f4:	75 0b                	jne    802101 <__umoddi3+0x91>
  8020f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020fb:	31 d2                	xor    %edx,%edx
  8020fd:	f7 f7                	div    %edi
  8020ff:	89 c5                	mov    %eax,%ebp
  802101:	89 f0                	mov    %esi,%eax
  802103:	31 d2                	xor    %edx,%edx
  802105:	f7 f5                	div    %ebp
  802107:	89 c8                	mov    %ecx,%eax
  802109:	f7 f5                	div    %ebp
  80210b:	89 d0                	mov    %edx,%eax
  80210d:	eb 99                	jmp    8020a8 <__umoddi3+0x38>
  80210f:	90                   	nop
  802110:	89 c8                	mov    %ecx,%eax
  802112:	89 f2                	mov    %esi,%edx
  802114:	83 c4 1c             	add    $0x1c,%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    
  80211c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802120:	8b 34 24             	mov    (%esp),%esi
  802123:	bf 20 00 00 00       	mov    $0x20,%edi
  802128:	89 e9                	mov    %ebp,%ecx
  80212a:	29 ef                	sub    %ebp,%edi
  80212c:	d3 e0                	shl    %cl,%eax
  80212e:	89 f9                	mov    %edi,%ecx
  802130:	89 f2                	mov    %esi,%edx
  802132:	d3 ea                	shr    %cl,%edx
  802134:	89 e9                	mov    %ebp,%ecx
  802136:	09 c2                	or     %eax,%edx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 14 24             	mov    %edx,(%esp)
  80213d:	89 f2                	mov    %esi,%edx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	89 f9                	mov    %edi,%ecx
  802143:	89 54 24 04          	mov    %edx,0x4(%esp)
  802147:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80214b:	d3 e8                	shr    %cl,%eax
  80214d:	89 e9                	mov    %ebp,%ecx
  80214f:	89 c6                	mov    %eax,%esi
  802151:	d3 e3                	shl    %cl,%ebx
  802153:	89 f9                	mov    %edi,%ecx
  802155:	89 d0                	mov    %edx,%eax
  802157:	d3 e8                	shr    %cl,%eax
  802159:	89 e9                	mov    %ebp,%ecx
  80215b:	09 d8                	or     %ebx,%eax
  80215d:	89 d3                	mov    %edx,%ebx
  80215f:	89 f2                	mov    %esi,%edx
  802161:	f7 34 24             	divl   (%esp)
  802164:	89 d6                	mov    %edx,%esi
  802166:	d3 e3                	shl    %cl,%ebx
  802168:	f7 64 24 04          	mull   0x4(%esp)
  80216c:	39 d6                	cmp    %edx,%esi
  80216e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802172:	89 d1                	mov    %edx,%ecx
  802174:	89 c3                	mov    %eax,%ebx
  802176:	72 08                	jb     802180 <__umoddi3+0x110>
  802178:	75 11                	jne    80218b <__umoddi3+0x11b>
  80217a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80217e:	73 0b                	jae    80218b <__umoddi3+0x11b>
  802180:	2b 44 24 04          	sub    0x4(%esp),%eax
  802184:	1b 14 24             	sbb    (%esp),%edx
  802187:	89 d1                	mov    %edx,%ecx
  802189:	89 c3                	mov    %eax,%ebx
  80218b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80218f:	29 da                	sub    %ebx,%edx
  802191:	19 ce                	sbb    %ecx,%esi
  802193:	89 f9                	mov    %edi,%ecx
  802195:	89 f0                	mov    %esi,%eax
  802197:	d3 e0                	shl    %cl,%eax
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	d3 ea                	shr    %cl,%edx
  80219d:	89 e9                	mov    %ebp,%ecx
  80219f:	d3 ee                	shr    %cl,%esi
  8021a1:	09 d0                	or     %edx,%eax
  8021a3:	89 f2                	mov    %esi,%edx
  8021a5:	83 c4 1c             	add    $0x1c,%esp
  8021a8:	5b                   	pop    %ebx
  8021a9:	5e                   	pop    %esi
  8021aa:	5f                   	pop    %edi
  8021ab:	5d                   	pop    %ebp
  8021ac:	c3                   	ret    
  8021ad:	8d 76 00             	lea    0x0(%esi),%esi
  8021b0:	29 f9                	sub    %edi,%ecx
  8021b2:	19 d6                	sbb    %edx,%esi
  8021b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bc:	e9 18 ff ff ff       	jmp    8020d9 <__umoddi3+0x69>
