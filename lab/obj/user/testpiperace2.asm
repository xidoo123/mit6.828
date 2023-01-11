
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
  80003c:	68 40 27 80 00       	push   $0x802740
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 a5 1f 00 00       	call   801ff6 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 8e 27 80 00       	push   $0x80278e
  80005e:	6a 0d                	push   $0xd
  800060:	68 97 27 80 00       	push   $0x802797
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 95 0f 00 00       	call   801004 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ac 27 80 00       	push   $0x8027ac
  80007b:	6a 0f                	push   $0xf
  80007d:	68 97 27 80 00       	push   $0x802797
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
  800091:	e8 c5 12 00 00       	call   80135b <close>
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
  8000be:	68 b5 27 80 00       	push   $0x8027b5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 d3 12 00 00       	call   8013ab <dup>
			sys_yield();
  8000d8:	e8 9b 0b 00 00       	call   800c78 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 72 12 00 00       	call   80135b <close>
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
  80011d:	e8 27 20 00 00       	call   802149 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 b9 27 80 00       	push   $0x8027b9
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
  80015c:	68 d5 27 80 00       	push   $0x8027d5
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 d8 1f 00 00       	call   802149 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 64 27 80 00       	push   $0x802764
  800180:	6a 40                	push   $0x40
  800182:	68 97 27 80 00       	push   $0x802797
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 96 10 00 00       	call   801231 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 eb 27 80 00       	push   $0x8027eb
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 97 27 80 00       	push   $0x802797
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 0c 10 00 00       	call   8011cb <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 03 28 80 00 	movl   $0x802803,(%esp)
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
  8001f3:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800222:	e8 5f 11 00 00       	call   801386 <close_all>
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
  800254:	68 24 28 80 00       	push   $0x802824
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 3c 2d 80 00 	movl   $0x802d3c,(%esp)
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
  800372:	e8 29 21 00 00       	call   8024a0 <__udivdi3>
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
  8003b5:	e8 16 22 00 00       	call   8025d0 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 47 28 80 00 	movsbl 0x802847(%eax),%eax
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
  8004b9:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
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
  80057d:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800584:	85 d2                	test   %edx,%edx
  800586:	75 18                	jne    8005a0 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800588:	50                   	push   %eax
  800589:	68 5f 28 80 00       	push   $0x80285f
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
  8005a1:	68 d1 2c 80 00       	push   $0x802cd1
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
  8005c5:	b8 58 28 80 00       	mov    $0x802858,%eax
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
  800c40:	68 3f 2b 80 00       	push   $0x802b3f
  800c45:	6a 23                	push   $0x23
  800c47:	68 5c 2b 80 00       	push   $0x802b5c
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
  800cc1:	68 3f 2b 80 00       	push   $0x802b3f
  800cc6:	6a 23                	push   $0x23
  800cc8:	68 5c 2b 80 00       	push   $0x802b5c
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
  800d03:	68 3f 2b 80 00       	push   $0x802b3f
  800d08:	6a 23                	push   $0x23
  800d0a:	68 5c 2b 80 00       	push   $0x802b5c
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
  800d45:	68 3f 2b 80 00       	push   $0x802b3f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 5c 2b 80 00       	push   $0x802b5c
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
  800d87:	68 3f 2b 80 00       	push   $0x802b3f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 5c 2b 80 00       	push   $0x802b5c
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
  800dc9:	68 3f 2b 80 00       	push   $0x802b3f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 5c 2b 80 00       	push   $0x802b5c
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
  800e0b:	68 3f 2b 80 00       	push   $0x802b3f
  800e10:	6a 23                	push   $0x23
  800e12:	68 5c 2b 80 00       	push   $0x802b5c
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
  800e6f:	68 3f 2b 80 00       	push   $0x802b3f
  800e74:	6a 23                	push   $0x23
  800e76:	68 5c 2b 80 00       	push   $0x802b5c
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

00800e88 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	57                   	push   %edi
  800e8c:	56                   	push   %esi
  800e8d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e93:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e98:	89 d1                	mov    %edx,%ecx
  800e9a:	89 d3                	mov    %edx,%ebx
  800e9c:	89 d7                	mov    %edx,%edi
  800e9e:	89 d6                	mov    %edx,%esi
  800ea0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *data, uint32_t len)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	57                   	push   %edi
  800eab:	56                   	push   %esi
  800eac:	53                   	push   %ebx
  800ead:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb5:	b8 0f 00 00 00       	mov    $0xf,%eax
  800eba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	89 df                	mov    %ebx,%edi
  800ec2:	89 de                	mov    %ebx,%esi
  800ec4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <sys_e1000_try_send+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 0f                	push   $0xf
  800ed0:	68 3f 2b 80 00       	push   $0x802b3f
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 5c 2b 80 00       	push   $0x802b5c
  800edc:	e8 55 f3 ff ff       	call   800236 <_panic>

int
sys_e1000_try_send(void *data, uint32_t len)
{
	return syscall(SYS_e1000_try_send, 1, (uint32_t)data, len, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <sys_e1000_try_recv>:

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	57                   	push   %edi
  800eed:	56                   	push   %esi
  800eee:	53                   	push   %ebx
  800eef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef7:	b8 10 00 00 00       	mov    $0x10,%eax
  800efc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eff:	8b 55 08             	mov    0x8(%ebp),%edx
  800f02:	89 df                	mov    %ebx,%edi
  800f04:	89 de                	mov    %ebx,%esi
  800f06:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	7e 17                	jle    800f23 <sys_e1000_try_recv+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0c:	83 ec 0c             	sub    $0xc,%esp
  800f0f:	50                   	push   %eax
  800f10:	6a 10                	push   $0x10
  800f12:	68 3f 2b 80 00       	push   $0x802b3f
  800f17:	6a 23                	push   $0x23
  800f19:	68 5c 2b 80 00       	push   $0x802b5c
  800f1e:	e8 13 f3 ff ff       	call   800236 <_panic>

int
sys_e1000_try_recv(void *buf, uint32_t* len)
{
	return syscall(SYS_e1000_try_recv, 1, (uint32_t)buf, (uint32_t)len, 0, 0, 0);
}
  800f23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5f                   	pop    %edi
  800f29:	5d                   	pop    %ebp
  800f2a:	c3                   	ret    

00800f2b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f2b:	55                   	push   %ebp
  800f2c:	89 e5                	mov    %esp,%ebp
  800f2e:	56                   	push   %esi
  800f2f:	53                   	push   %ebx
  800f30:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f33:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.

	if ((err & FEC_WR) != FEC_WR && ((uvpt[PGNUM(addr)] & PTE_COW) != PTE_COW)) {
  800f35:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f39:	75 25                	jne    800f60 <pgfault+0x35>
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	c1 e8 0c             	shr    $0xc,%eax
  800f40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f47:	f6 c4 08             	test   $0x8,%ah
  800f4a:	75 14                	jne    800f60 <pgfault+0x35>
		panic("pgfault: not due to a write or a COW page");
  800f4c:	83 ec 04             	sub    $0x4,%esp
  800f4f:	68 6c 2b 80 00       	push   $0x802b6c
  800f54:	6a 1e                	push   $0x1e
  800f56:	68 00 2c 80 00       	push   $0x802c00
  800f5b:	e8 d6 f2 ff ff       	call   800236 <_panic>

	// LAB 4: Your code here.

	// panic("pgfault not implemented");

	addr = ROUNDDOWN(addr, PGSIZE);
  800f60:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	envid_t envid = sys_getenvid();
  800f66:	e8 ee fc ff ff       	call   800c59 <sys_getenvid>
  800f6b:	89 c6                	mov    %eax,%esi

	// envid = 0;

	// Allocate a new page, map it at a temporary location (PFTEMP)
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_U | PTE_P | PTE_W);
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	6a 07                	push   $0x7
  800f72:	68 00 f0 7f 00       	push   $0x7ff000
  800f77:	50                   	push   %eax
  800f78:	e8 1a fd ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  800f7d:	83 c4 10             	add    $0x10,%esp
  800f80:	85 c0                	test   %eax,%eax
  800f82:	79 12                	jns    800f96 <pgfault+0x6b>
		panic("pgfault: sys_page_alloc failed: %e\n", r);
  800f84:	50                   	push   %eax
  800f85:	68 98 2b 80 00       	push   $0x802b98
  800f8a:	6a 33                	push   $0x33
  800f8c:	68 00 2c 80 00       	push   $0x802c00
  800f91:	e8 a0 f2 ff ff       	call   800236 <_panic>
	
	// copy the data from the old page to the new page
	memcpy((void *) PFTEMP, (const void *) addr, PGSIZE);
  800f96:	83 ec 04             	sub    $0x4,%esp
  800f99:	68 00 10 00 00       	push   $0x1000
  800f9e:	53                   	push   %ebx
  800f9f:	68 00 f0 7f 00       	push   $0x7ff000
  800fa4:	e8 e5 fa ff ff       	call   800a8e <memcpy>

	// move the new page to the old page's address
	r = sys_page_map(envid, (void *) PFTEMP, envid, addr, PTE_U | PTE_P | PTE_W);
  800fa9:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800fb0:	53                   	push   %ebx
  800fb1:	56                   	push   %esi
  800fb2:	68 00 f0 7f 00       	push   $0x7ff000
  800fb7:	56                   	push   %esi
  800fb8:	e8 1d fd ff ff       	call   800cda <sys_page_map>
	if (r < 0)
  800fbd:	83 c4 20             	add    $0x20,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	79 12                	jns    800fd6 <pgfault+0xab>
		panic("pgfault: sys_page_map failed: %e\n", r);
  800fc4:	50                   	push   %eax
  800fc5:	68 bc 2b 80 00       	push   $0x802bbc
  800fca:	6a 3b                	push   $0x3b
  800fcc:	68 00 2c 80 00       	push   $0x802c00
  800fd1:	e8 60 f2 ff ff       	call   800236 <_panic>

	// unmap temporary region
	r = sys_page_unmap(envid, (void *) PFTEMP);
  800fd6:	83 ec 08             	sub    $0x8,%esp
  800fd9:	68 00 f0 7f 00       	push   $0x7ff000
  800fde:	56                   	push   %esi
  800fdf:	e8 38 fd ff ff       	call   800d1c <sys_page_unmap>
	if (r < 0)
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	79 12                	jns    800ffd <pgfault+0xd2>
        panic("pgfault: page unmap failed: %e\n", r);
  800feb:	50                   	push   %eax
  800fec:	68 e0 2b 80 00       	push   $0x802be0
  800ff1:	6a 40                	push   $0x40
  800ff3:	68 00 2c 80 00       	push   $0x802c00
  800ff8:	e8 39 f2 ff ff       	call   800236 <_panic>
}
  800ffd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801000:	5b                   	pop    %ebx
  801001:	5e                   	pop    %esi
  801002:	5d                   	pop    %ebp
  801003:	c3                   	ret    

00801004 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801004:	55                   	push   %ebp
  801005:	89 e5                	mov    %esp,%ebp
  801007:	57                   	push   %edi
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	// cprintf("[fork]\n");
	int r;

	set_pgfault_handler(pgfault);
  80100d:	68 2b 0f 80 00       	push   $0x800f2b
  801012:	e8 e8 12 00 00       	call   8022ff <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801017:	b8 07 00 00 00       	mov    $0x7,%eax
  80101c:	cd 30                	int    $0x30

	envid_t envid = sys_exofork();
	if (envid < 0)
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 64 01 00 00    	js     80118d <fork+0x189>
  801029:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80102e:	be 00 08 00 00       	mov    $0x800,%esi
		return envid;

	// fix "thisenv" in the child process
	if (envid == 0) {
  801033:	85 c0                	test   %eax,%eax
  801035:	75 21                	jne    801058 <fork+0x54>
		thisenv = &envs[ENVX(sys_getenvid())];
  801037:	e8 1d fc ff ff       	call   800c59 <sys_getenvid>
  80103c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801041:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801044:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801049:	a3 08 40 80 00       	mov    %eax,0x804008
        return 0;
  80104e:	ba 00 00 00 00       	mov    $0x0,%edx
  801053:	e9 3f 01 00 00       	jmp    801197 <fork+0x193>
  801058:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80105b:	89 c7                	mov    %eax,%edi
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {

		addr = pn * PGSIZE;

		// if level-2 page exists
		if ((uvpd[PDX(addr)] & PTE_P) == PTE_P) {
  80105d:	89 d8                	mov    %ebx,%eax
  80105f:	c1 e8 16             	shr    $0x16,%eax
  801062:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801069:	a8 01                	test   $0x1,%al
  80106b:	0f 84 bd 00 00 00    	je     80112e <fork+0x12a>
			
			// if real PTE exists
			if ((uvpt[PGNUM(addr)] & PTE_P) == PTE_P) {
  801071:	89 d8                	mov    %ebx,%eax
  801073:	c1 e8 0c             	shr    $0xc,%eax
  801076:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80107d:	f6 c2 01             	test   $0x1,%dl
  801080:	0f 84 a8 00 00 00    	je     80112e <fork+0x12a>

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
  801086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108d:	a8 04                	test   $0x4,%al
  80108f:	0f 84 99 00 00 00    	je     80112e <fork+0x12a>
	// r = envid2env(envid, &env, 1);
	// if (r < 0)
	// 	return r;	// E_BAD_ENV
	// envid_t parent_envid = env->env_parent_id;

	if (uvpt[pn] & PTE_SHARE) {
  801095:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80109c:	f6 c4 04             	test   $0x4,%ah
  80109f:	74 17                	je     8010b8 <fork+0xb4>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
  8010a1:	83 ec 0c             	sub    $0xc,%esp
  8010a4:	68 07 0e 00 00       	push   $0xe07
  8010a9:	53                   	push   %ebx
  8010aa:	57                   	push   %edi
  8010ab:	53                   	push   %ebx
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 27 fc ff ff       	call   800cda <sys_page_map>
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	eb 76                	jmp    80112e <fork+0x12a>
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {
  8010b8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010bf:	a8 02                	test   $0x2,%al
  8010c1:	75 0c                	jne    8010cf <fork+0xcb>
  8010c3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ca:	f6 c4 08             	test   $0x8,%ah
  8010cd:	74 3f                	je     80110e <fork+0x10a>

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010cf:	83 ec 0c             	sub    $0xc,%esp
  8010d2:	68 05 08 00 00       	push   $0x805
  8010d7:	53                   	push   %ebx
  8010d8:	57                   	push   %edi
  8010d9:	53                   	push   %ebx
  8010da:	6a 00                	push   $0x0
  8010dc:	e8 f9 fb ff ff       	call   800cda <sys_page_map>
		if (r < 0)
  8010e1:	83 c4 20             	add    $0x20,%esp
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	0f 88 a5 00 00 00    	js     801191 <fork+0x18d>
            return r;

		// remap the page copy-on-write in its own(parent) address space
        r = sys_page_map(0, (void *)va, 0, (void *)va, PTE_P|PTE_U|PTE_COW);
  8010ec:	83 ec 0c             	sub    $0xc,%esp
  8010ef:	68 05 08 00 00       	push   $0x805
  8010f4:	53                   	push   %ebx
  8010f5:	6a 00                	push   $0x0
  8010f7:	53                   	push   %ebx
  8010f8:	6a 00                	push   $0x0
  8010fa:	e8 db fb ff ff       	call   800cda <sys_page_map>
  8010ff:	83 c4 20             	add    $0x20,%esp
  801102:	85 c0                	test   %eax,%eax
  801104:	b9 00 00 00 00       	mov    $0x0,%ecx
  801109:	0f 4f c1             	cmovg  %ecx,%eax
  80110c:	eb 1c                	jmp    80112a <fork+0x126>
		if (r < 0)
            return r;
    }
    else {
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U);
  80110e:	83 ec 0c             	sub    $0xc,%esp
  801111:	6a 05                	push   $0x5
  801113:	53                   	push   %ebx
  801114:	57                   	push   %edi
  801115:	53                   	push   %ebx
  801116:	6a 00                	push   $0x0
  801118:	e8 bd fb ff ff       	call   800cda <sys_page_map>
  80111d:	83 c4 20             	add    $0x20,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	b9 00 00 00 00       	mov    $0x0,%ecx
  801127:	0f 4f c1             	cmovg  %ecx,%eax

				// For each writable or copy-on-write page
				// if ((uvpt[PGNUM(addr)] & (PTE_W | PTE_COW)) != 0) {
				if ((uvpt[PGNUM(addr)] & PTE_U) != 0) {
					r = duppage(envid, pn);
					if (r < 0)
  80112a:	85 c0                	test   %eax,%eax
  80112c:	78 67                	js     801195 <fork+0x191>
        return 0;
	}

	// For each writable or copy-on-write page in its address space below UTOP, the parent calls duppage
	uint32_t addr;
	for (uint32_t pn = PGNUM(UTEXT); pn < PGNUM(USTACKTOP); pn++) {
  80112e:	83 c6 01             	add    $0x1,%esi
  801131:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801137:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80113d:	0f 85 1a ff ff ff    	jne    80105d <fork+0x59>
  801143:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	6a 07                	push   $0x7
  80114b:	68 00 f0 bf ee       	push   $0xeebff000
  801150:	57                   	push   %edi
  801151:	e8 41 fb ff ff       	call   800c97 <sys_page_alloc>
	if (r < 0)
  801156:	83 c4 10             	add    $0x10,%esp
		return r;
  801159:	89 c2                	mov    %eax,%edx
		}
	}

	// allocate a fresh page in the child for the exception stack
	r = sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W);
	if (r < 0)
  80115b:	85 c0                	test   %eax,%eax
  80115d:	78 38                	js     801197 <fork+0x193>
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	68 46 23 80 00       	push   $0x802346
  801167:	57                   	push   %edi
  801168:	e8 75 fc ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
	if (r < 0)
  80116d:	83 c4 10             	add    $0x10,%esp
		return r;
  801170:	89 c2                	mov    %eax,%edx
		return r;

	// The parent sets the user page fault entrypoint for the child to look like its own
	extern void _pgfault_upcall(void);
	r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
	if (r < 0)
  801172:	85 c0                	test   %eax,%eax
  801174:	78 21                	js     801197 <fork+0x193>
		return r;

	// The child is now ready to run, so the parent marks it runnable
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801176:	83 ec 08             	sub    $0x8,%esp
  801179:	6a 02                	push   $0x2
  80117b:	57                   	push   %edi
  80117c:	e8 dd fb ff ff       	call   800d5e <sys_env_set_status>
	if (r < 0)
  801181:	83 c4 10             	add    $0x10,%esp
		return r;

	return envid;
  801184:	85 c0                	test   %eax,%eax
  801186:	0f 48 f8             	cmovs  %eax,%edi
  801189:	89 fa                	mov    %edi,%edx
  80118b:	eb 0a                	jmp    801197 <fork+0x193>

	set_pgfault_handler(pgfault);

	envid_t envid = sys_exofork();
	if (envid < 0)
		return envid;
  80118d:	89 c2                	mov    %eax,%edx
  80118f:	eb 06                	jmp    801197 <fork+0x193>
		sys_page_map(0, (void *)va, envid, (void *)va, PTE_SYSCALL);
	}
	else if ((uvpt[pn] & PTE_W) == PTE_W || (uvpt[pn] & PTE_COW) == PTE_COW) {

		// map the page copy-on-write into the address space of the child
        r = sys_page_map(0, (void *)va, envid, (void *)va, PTE_P|PTE_U|PTE_COW);
  801191:	89 c2                	mov    %eax,%edx
  801193:	eb 02                	jmp    801197 <fork+0x193>
  801195:	89 c2                	mov    %eax,%edx
	if (r < 0)
		return r;

	return envid;
	// panic("fork not implemented");
}
  801197:	89 d0                	mov    %edx,%eax
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a7:	68 0b 2c 80 00       	push   $0x802c0b
  8011ac:	68 c9 00 00 00       	push   $0xc9
  8011b1:	68 00 2c 80 00       	push   $0x802c00
  8011b6:	e8 7b f0 ff ff       	call   800236 <_panic>

008011bb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011be:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011c6:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    

008011cb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011cb:	55                   	push   %ebp
  8011cc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d1:	05 00 00 00 30       	add    $0x30000000,%eax
  8011d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011db:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011ed:	89 c2                	mov    %eax,%edx
  8011ef:	c1 ea 16             	shr    $0x16,%edx
  8011f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011f9:	f6 c2 01             	test   $0x1,%dl
  8011fc:	74 11                	je     80120f <fd_alloc+0x2d>
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	c1 ea 0c             	shr    $0xc,%edx
  801203:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80120a:	f6 c2 01             	test   $0x1,%dl
  80120d:	75 09                	jne    801218 <fd_alloc+0x36>
			*fd_store = fd;
  80120f:	89 01                	mov    %eax,(%ecx)
			return 0;
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
  801216:	eb 17                	jmp    80122f <fd_alloc+0x4d>
  801218:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80121d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801222:	75 c9                	jne    8011ed <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801224:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80122a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801237:	83 f8 1f             	cmp    $0x1f,%eax
  80123a:	77 36                	ja     801272 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80123c:	c1 e0 0c             	shl    $0xc,%eax
  80123f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801244:	89 c2                	mov    %eax,%edx
  801246:	c1 ea 16             	shr    $0x16,%edx
  801249:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801250:	f6 c2 01             	test   $0x1,%dl
  801253:	74 24                	je     801279 <fd_lookup+0x48>
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 0c             	shr    $0xc,%edx
  80125a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 1a                	je     801280 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801266:	8b 55 0c             	mov    0xc(%ebp),%edx
  801269:	89 02                	mov    %eax,(%edx)
	return 0;
  80126b:	b8 00 00 00 00       	mov    $0x0,%eax
  801270:	eb 13                	jmp    801285 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801272:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801277:	eb 0c                	jmp    801285 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801279:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80127e:	eb 05                	jmp    801285 <fd_lookup+0x54>
  801280:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801290:	ba a4 2c 80 00       	mov    $0x802ca4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801295:	eb 13                	jmp    8012aa <dev_lookup+0x23>
  801297:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80129a:	39 08                	cmp    %ecx,(%eax)
  80129c:	75 0c                	jne    8012aa <dev_lookup+0x23>
			*dev = devtab[i];
  80129e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012a1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a8:	eb 2e                	jmp    8012d8 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012aa:	8b 02                	mov    (%edx),%eax
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	75 e7                	jne    801297 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012b0:	a1 08 40 80 00       	mov    0x804008,%eax
  8012b5:	8b 40 48             	mov    0x48(%eax),%eax
  8012b8:	83 ec 04             	sub    $0x4,%esp
  8012bb:	51                   	push   %ecx
  8012bc:	50                   	push   %eax
  8012bd:	68 24 2c 80 00       	push   $0x802c24
  8012c2:	e8 48 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  8012c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012ca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012d0:	83 c4 10             	add    $0x10,%esp
  8012d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012d8:	c9                   	leave  
  8012d9:	c3                   	ret    

008012da <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	56                   	push   %esi
  8012de:	53                   	push   %ebx
  8012df:	83 ec 10             	sub    $0x10,%esp
  8012e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8012e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012f2:	c1 e8 0c             	shr    $0xc,%eax
  8012f5:	50                   	push   %eax
  8012f6:	e8 36 ff ff ff       	call   801231 <fd_lookup>
  8012fb:	83 c4 08             	add    $0x8,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 05                	js     801307 <fd_close+0x2d>
	    || fd != fd2)
  801302:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801305:	74 0c                	je     801313 <fd_close+0x39>
		return (must_exist ? r : 0);
  801307:	84 db                	test   %bl,%bl
  801309:	ba 00 00 00 00       	mov    $0x0,%edx
  80130e:	0f 44 c2             	cmove  %edx,%eax
  801311:	eb 41                	jmp    801354 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801319:	50                   	push   %eax
  80131a:	ff 36                	pushl  (%esi)
  80131c:	e8 66 ff ff ff       	call   801287 <dev_lookup>
  801321:	89 c3                	mov    %eax,%ebx
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	85 c0                	test   %eax,%eax
  801328:	78 1a                	js     801344 <fd_close+0x6a>
		if (dev->dev_close)
  80132a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801330:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801335:	85 c0                	test   %eax,%eax
  801337:	74 0b                	je     801344 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	56                   	push   %esi
  80133d:	ff d0                	call   *%eax
  80133f:	89 c3                	mov    %eax,%ebx
  801341:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	56                   	push   %esi
  801348:	6a 00                	push   $0x0
  80134a:	e8 cd f9 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	89 d8                	mov    %ebx,%eax
}
  801354:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801357:	5b                   	pop    %ebx
  801358:	5e                   	pop    %esi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    

0080135b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80135b:	55                   	push   %ebp
  80135c:	89 e5                	mov    %esp,%ebp
  80135e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801361:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801364:	50                   	push   %eax
  801365:	ff 75 08             	pushl  0x8(%ebp)
  801368:	e8 c4 fe ff ff       	call   801231 <fd_lookup>
  80136d:	83 c4 08             	add    $0x8,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	78 10                	js     801384 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	6a 01                	push   $0x1
  801379:	ff 75 f4             	pushl  -0xc(%ebp)
  80137c:	e8 59 ff ff ff       	call   8012da <fd_close>
  801381:	83 c4 10             	add    $0x10,%esp
}
  801384:	c9                   	leave  
  801385:	c3                   	ret    

00801386 <close_all>:

void
close_all(void)
{
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	53                   	push   %ebx
  80138a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80138d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801392:	83 ec 0c             	sub    $0xc,%esp
  801395:	53                   	push   %ebx
  801396:	e8 c0 ff ff ff       	call   80135b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80139b:	83 c3 01             	add    $0x1,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	83 fb 20             	cmp    $0x20,%ebx
  8013a4:	75 ec                	jne    801392 <close_all+0xc>
		close(i);
}
  8013a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a9:	c9                   	leave  
  8013aa:	c3                   	ret    

008013ab <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ab:	55                   	push   %ebp
  8013ac:	89 e5                	mov    %esp,%ebp
  8013ae:	57                   	push   %edi
  8013af:	56                   	push   %esi
  8013b0:	53                   	push   %ebx
  8013b1:	83 ec 2c             	sub    $0x2c,%esp
  8013b4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	ff 75 08             	pushl  0x8(%ebp)
  8013be:	e8 6e fe ff ff       	call   801231 <fd_lookup>
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	0f 88 c1 00 00 00    	js     80148f <dup+0xe4>
		return r;
	close(newfdnum);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	56                   	push   %esi
  8013d2:	e8 84 ff ff ff       	call   80135b <close>

	newfd = INDEX2FD(newfdnum);
  8013d7:	89 f3                	mov    %esi,%ebx
  8013d9:	c1 e3 0c             	shl    $0xc,%ebx
  8013dc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013e2:	83 c4 04             	add    $0x4,%esp
  8013e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013e8:	e8 de fd ff ff       	call   8011cb <fd2data>
  8013ed:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013ef:	89 1c 24             	mov    %ebx,(%esp)
  8013f2:	e8 d4 fd ff ff       	call   8011cb <fd2data>
  8013f7:	83 c4 10             	add    $0x10,%esp
  8013fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013fd:	89 f8                	mov    %edi,%eax
  8013ff:	c1 e8 16             	shr    $0x16,%eax
  801402:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801409:	a8 01                	test   $0x1,%al
  80140b:	74 37                	je     801444 <dup+0x99>
  80140d:	89 f8                	mov    %edi,%eax
  80140f:	c1 e8 0c             	shr    $0xc,%eax
  801412:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801419:	f6 c2 01             	test   $0x1,%dl
  80141c:	74 26                	je     801444 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80141e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801425:	83 ec 0c             	sub    $0xc,%esp
  801428:	25 07 0e 00 00       	and    $0xe07,%eax
  80142d:	50                   	push   %eax
  80142e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801431:	6a 00                	push   $0x0
  801433:	57                   	push   %edi
  801434:	6a 00                	push   $0x0
  801436:	e8 9f f8 ff ff       	call   800cda <sys_page_map>
  80143b:	89 c7                	mov    %eax,%edi
  80143d:	83 c4 20             	add    $0x20,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 2e                	js     801472 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801444:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801447:	89 d0                	mov    %edx,%eax
  801449:	c1 e8 0c             	shr    $0xc,%eax
  80144c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	25 07 0e 00 00       	and    $0xe07,%eax
  80145b:	50                   	push   %eax
  80145c:	53                   	push   %ebx
  80145d:	6a 00                	push   $0x0
  80145f:	52                   	push   %edx
  801460:	6a 00                	push   $0x0
  801462:	e8 73 f8 ff ff       	call   800cda <sys_page_map>
  801467:	89 c7                	mov    %eax,%edi
  801469:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80146c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146e:	85 ff                	test   %edi,%edi
  801470:	79 1d                	jns    80148f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	53                   	push   %ebx
  801476:	6a 00                	push   $0x0
  801478:	e8 9f f8 ff ff       	call   800d1c <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	ff 75 d4             	pushl  -0x2c(%ebp)
  801483:	6a 00                	push   $0x0
  801485:	e8 92 f8 ff ff       	call   800d1c <sys_page_unmap>
	return r;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	89 f8                	mov    %edi,%eax
}
  80148f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801492:	5b                   	pop    %ebx
  801493:	5e                   	pop    %esi
  801494:	5f                   	pop    %edi
  801495:	5d                   	pop    %ebp
  801496:	c3                   	ret    

00801497 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	53                   	push   %ebx
  80149b:	83 ec 14             	sub    $0x14,%esp
  80149e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a4:	50                   	push   %eax
  8014a5:	53                   	push   %ebx
  8014a6:	e8 86 fd ff ff       	call   801231 <fd_lookup>
  8014ab:	83 c4 08             	add    $0x8,%esp
  8014ae:	89 c2                	mov    %eax,%edx
  8014b0:	85 c0                	test   %eax,%eax
  8014b2:	78 6d                	js     801521 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	50                   	push   %eax
  8014bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014be:	ff 30                	pushl  (%eax)
  8014c0:	e8 c2 fd ff ff       	call   801287 <dev_lookup>
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	85 c0                	test   %eax,%eax
  8014ca:	78 4c                	js     801518 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014cf:	8b 42 08             	mov    0x8(%edx),%eax
  8014d2:	83 e0 03             	and    $0x3,%eax
  8014d5:	83 f8 01             	cmp    $0x1,%eax
  8014d8:	75 21                	jne    8014fb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014da:	a1 08 40 80 00       	mov    0x804008,%eax
  8014df:	8b 40 48             	mov    0x48(%eax),%eax
  8014e2:	83 ec 04             	sub    $0x4,%esp
  8014e5:	53                   	push   %ebx
  8014e6:	50                   	push   %eax
  8014e7:	68 68 2c 80 00       	push   $0x802c68
  8014ec:	e8 1e ee ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014f9:	eb 26                	jmp    801521 <read+0x8a>
	}
	if (!dev->dev_read)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	8b 40 08             	mov    0x8(%eax),%eax
  801501:	85 c0                	test   %eax,%eax
  801503:	74 17                	je     80151c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801505:	83 ec 04             	sub    $0x4,%esp
  801508:	ff 75 10             	pushl  0x10(%ebp)
  80150b:	ff 75 0c             	pushl  0xc(%ebp)
  80150e:	52                   	push   %edx
  80150f:	ff d0                	call   *%eax
  801511:	89 c2                	mov    %eax,%edx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	eb 09                	jmp    801521 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801518:	89 c2                	mov    %eax,%edx
  80151a:	eb 05                	jmp    801521 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80151c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801521:	89 d0                	mov    %edx,%eax
  801523:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801526:	c9                   	leave  
  801527:	c3                   	ret    

00801528 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	57                   	push   %edi
  80152c:	56                   	push   %esi
  80152d:	53                   	push   %ebx
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	8b 7d 08             	mov    0x8(%ebp),%edi
  801534:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801537:	bb 00 00 00 00       	mov    $0x0,%ebx
  80153c:	eb 21                	jmp    80155f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	89 f0                	mov    %esi,%eax
  801543:	29 d8                	sub    %ebx,%eax
  801545:	50                   	push   %eax
  801546:	89 d8                	mov    %ebx,%eax
  801548:	03 45 0c             	add    0xc(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	57                   	push   %edi
  80154d:	e8 45 ff ff ff       	call   801497 <read>
		if (m < 0)
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 10                	js     801569 <readn+0x41>
			return m;
		if (m == 0)
  801559:	85 c0                	test   %eax,%eax
  80155b:	74 0a                	je     801567 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155d:	01 c3                	add    %eax,%ebx
  80155f:	39 f3                	cmp    %esi,%ebx
  801561:	72 db                	jb     80153e <readn+0x16>
  801563:	89 d8                	mov    %ebx,%eax
  801565:	eb 02                	jmp    801569 <readn+0x41>
  801567:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801569:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5f                   	pop    %edi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	53                   	push   %ebx
  801575:	83 ec 14             	sub    $0x14,%esp
  801578:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	53                   	push   %ebx
  801580:	e8 ac fc ff ff       	call   801231 <fd_lookup>
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	89 c2                	mov    %eax,%edx
  80158a:	85 c0                	test   %eax,%eax
  80158c:	78 68                	js     8015f6 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158e:	83 ec 08             	sub    $0x8,%esp
  801591:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801598:	ff 30                	pushl  (%eax)
  80159a:	e8 e8 fc ff ff       	call   801287 <dev_lookup>
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	85 c0                	test   %eax,%eax
  8015a4:	78 47                	js     8015ed <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015a9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015ad:	75 21                	jne    8015d0 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015af:	a1 08 40 80 00       	mov    0x804008,%eax
  8015b4:	8b 40 48             	mov    0x48(%eax),%eax
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	50                   	push   %eax
  8015bc:	68 84 2c 80 00       	push   $0x802c84
  8015c1:	e8 49 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015ce:	eb 26                	jmp    8015f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015d3:	8b 52 0c             	mov    0xc(%edx),%edx
  8015d6:	85 d2                	test   %edx,%edx
  8015d8:	74 17                	je     8015f1 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015da:	83 ec 04             	sub    $0x4,%esp
  8015dd:	ff 75 10             	pushl  0x10(%ebp)
  8015e0:	ff 75 0c             	pushl  0xc(%ebp)
  8015e3:	50                   	push   %eax
  8015e4:	ff d2                	call   *%edx
  8015e6:	89 c2                	mov    %eax,%edx
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 09                	jmp    8015f6 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ed:	89 c2                	mov    %eax,%edx
  8015ef:	eb 05                	jmp    8015f6 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015f1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015f6:	89 d0                	mov    %edx,%eax
  8015f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <seek>:

int
seek(int fdnum, off_t offset)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801603:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	ff 75 08             	pushl  0x8(%ebp)
  80160a:	e8 22 fc ff ff       	call   801231 <fd_lookup>
  80160f:	83 c4 08             	add    $0x8,%esp
  801612:	85 c0                	test   %eax,%eax
  801614:	78 0e                	js     801624 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801616:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801619:	8b 55 0c             	mov    0xc(%ebp),%edx
  80161c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80161f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	53                   	push   %ebx
  80162a:	83 ec 14             	sub    $0x14,%esp
  80162d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801630:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801633:	50                   	push   %eax
  801634:	53                   	push   %ebx
  801635:	e8 f7 fb ff ff       	call   801231 <fd_lookup>
  80163a:	83 c4 08             	add    $0x8,%esp
  80163d:	89 c2                	mov    %eax,%edx
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 65                	js     8016a8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	ff 30                	pushl  (%eax)
  80164f:	e8 33 fc ff ff       	call   801287 <dev_lookup>
  801654:	83 c4 10             	add    $0x10,%esp
  801657:	85 c0                	test   %eax,%eax
  801659:	78 44                	js     80169f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80165b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801662:	75 21                	jne    801685 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801664:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801669:	8b 40 48             	mov    0x48(%eax),%eax
  80166c:	83 ec 04             	sub    $0x4,%esp
  80166f:	53                   	push   %ebx
  801670:	50                   	push   %eax
  801671:	68 44 2c 80 00       	push   $0x802c44
  801676:	e8 94 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801683:	eb 23                	jmp    8016a8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801685:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801688:	8b 52 18             	mov    0x18(%edx),%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	74 14                	je     8016a3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	ff 75 0c             	pushl  0xc(%ebp)
  801695:	50                   	push   %eax
  801696:	ff d2                	call   *%edx
  801698:	89 c2                	mov    %eax,%edx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	eb 09                	jmp    8016a8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169f:	89 c2                	mov    %eax,%edx
  8016a1:	eb 05                	jmp    8016a8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016a8:	89 d0                	mov    %edx,%eax
  8016aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 14             	sub    $0x14,%esp
  8016b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016bc:	50                   	push   %eax
  8016bd:	ff 75 08             	pushl  0x8(%ebp)
  8016c0:	e8 6c fb ff ff       	call   801231 <fd_lookup>
  8016c5:	83 c4 08             	add    $0x8,%esp
  8016c8:	89 c2                	mov    %eax,%edx
  8016ca:	85 c0                	test   %eax,%eax
  8016cc:	78 58                	js     801726 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d4:	50                   	push   %eax
  8016d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d8:	ff 30                	pushl  (%eax)
  8016da:	e8 a8 fb ff ff       	call   801287 <dev_lookup>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 37                	js     80171d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016ed:	74 32                	je     801721 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016ef:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016f2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016f9:	00 00 00 
	stat->st_isdir = 0;
  8016fc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801703:	00 00 00 
	stat->st_dev = dev;
  801706:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	53                   	push   %ebx
  801710:	ff 75 f0             	pushl  -0x10(%ebp)
  801713:	ff 50 14             	call   *0x14(%eax)
  801716:	89 c2                	mov    %eax,%edx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	eb 09                	jmp    801726 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80171d:	89 c2                	mov    %eax,%edx
  80171f:	eb 05                	jmp    801726 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801721:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801726:	89 d0                	mov    %edx,%eax
  801728:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172b:	c9                   	leave  
  80172c:	c3                   	ret    

0080172d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	6a 00                	push   $0x0
  801737:	ff 75 08             	pushl  0x8(%ebp)
  80173a:	e8 d6 01 00 00       	call   801915 <open>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	85 c0                	test   %eax,%eax
  801746:	78 1b                	js     801763 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801748:	83 ec 08             	sub    $0x8,%esp
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	50                   	push   %eax
  80174f:	e8 5b ff ff ff       	call   8016af <fstat>
  801754:	89 c6                	mov    %eax,%esi
	close(fd);
  801756:	89 1c 24             	mov    %ebx,(%esp)
  801759:	e8 fd fb ff ff       	call   80135b <close>
	return r;
  80175e:	83 c4 10             	add    $0x10,%esp
  801761:	89 f0                	mov    %esi,%eax
}
  801763:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801766:	5b                   	pop    %ebx
  801767:	5e                   	pop    %esi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	56                   	push   %esi
  80176e:	53                   	push   %ebx
  80176f:	89 c6                	mov    %eax,%esi
  801771:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801773:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80177a:	75 12                	jne    80178e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80177c:	83 ec 0c             	sub    $0xc,%esp
  80177f:	6a 01                	push   $0x1
  801781:	e8 9f 0c 00 00       	call   802425 <ipc_find_env>
  801786:	a3 00 40 80 00       	mov    %eax,0x804000
  80178b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80178e:	6a 07                	push   $0x7
  801790:	68 00 50 80 00       	push   $0x805000
  801795:	56                   	push   %esi
  801796:	ff 35 00 40 80 00    	pushl  0x804000
  80179c:	e8 30 0c 00 00       	call   8023d1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a1:	83 c4 0c             	add    $0xc,%esp
  8017a4:	6a 00                	push   $0x0
  8017a6:	53                   	push   %ebx
  8017a7:	6a 00                	push   $0x0
  8017a9:	e8 bc 0b 00 00       	call   80236a <ipc_recv>
}
  8017ae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b1:	5b                   	pop    %ebx
  8017b2:	5e                   	pop    %esi
  8017b3:	5d                   	pop    %ebp
  8017b4:	c3                   	ret    

008017b5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017b5:	55                   	push   %ebp
  8017b6:	89 e5                	mov    %esp,%ebp
  8017b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017c9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017d8:	e8 8d ff ff ff       	call   80176a <fsipc>
}
  8017dd:	c9                   	leave  
  8017de:	c3                   	ret    

008017df <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017eb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8017fa:	e8 6b ff ff ff       	call   80176a <fsipc>
}
  8017ff:	c9                   	leave  
  801800:	c3                   	ret    

00801801 <devfile_stat>:

}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 40 0c             	mov    0xc(%eax),%eax
  801811:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 05 00 00 00       	mov    $0x5,%eax
  801820:	e8 45 ff ff ff       	call   80176a <fsipc>
  801825:	85 c0                	test   %eax,%eax
  801827:	78 2c                	js     801855 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801829:	83 ec 08             	sub    $0x8,%esp
  80182c:	68 00 50 80 00       	push   $0x805000
  801831:	53                   	push   %ebx
  801832:	e8 5d f0 ff ff       	call   800894 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801837:	a1 80 50 80 00       	mov    0x805080,%eax
  80183c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801842:	a1 84 50 80 00       	mov    0x805084,%eax
  801847:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801855:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801858:	c9                   	leave  
  801859:	c3                   	ret    

0080185a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80185a:	55                   	push   %ebp
  80185b:	89 e5                	mov    %esp,%ebp
  80185d:	83 ec 0c             	sub    $0xc,%esp
  801860:	8b 45 10             	mov    0x10(%ebp),%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	// panic("devfile_write not implemented");

	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801863:	8b 55 08             	mov    0x8(%ebp),%edx
  801866:	8b 52 0c             	mov    0xc(%edx),%edx
  801869:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80186f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801874:	50                   	push   %eax
  801875:	ff 75 0c             	pushl  0xc(%ebp)
  801878:	68 08 50 80 00       	push   $0x805008
  80187d:	e8 a4 f1 ff ff       	call   800a26 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801882:	ba 00 00 00 00       	mov    $0x0,%edx
  801887:	b8 04 00 00 00       	mov    $0x4,%eax
  80188c:	e8 d9 fe ff ff       	call   80176a <fsipc>

}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	56                   	push   %esi
  801897:	53                   	push   %ebx
  801898:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a6:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b1:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b6:	e8 af fe ff ff       	call   80176a <fsipc>
  8018bb:	89 c3                	mov    %eax,%ebx
  8018bd:	85 c0                	test   %eax,%eax
  8018bf:	78 4b                	js     80190c <devfile_read+0x79>
		return r;
	assert(r <= n);
  8018c1:	39 c6                	cmp    %eax,%esi
  8018c3:	73 16                	jae    8018db <devfile_read+0x48>
  8018c5:	68 b8 2c 80 00       	push   $0x802cb8
  8018ca:	68 bf 2c 80 00       	push   $0x802cbf
  8018cf:	6a 7c                	push   $0x7c
  8018d1:	68 d4 2c 80 00       	push   $0x802cd4
  8018d6:	e8 5b e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  8018db:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e0:	7e 16                	jle    8018f8 <devfile_read+0x65>
  8018e2:	68 df 2c 80 00       	push   $0x802cdf
  8018e7:	68 bf 2c 80 00       	push   $0x802cbf
  8018ec:	6a 7d                	push   $0x7d
  8018ee:	68 d4 2c 80 00       	push   $0x802cd4
  8018f3:	e8 3e e9 ff ff       	call   800236 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f8:	83 ec 04             	sub    $0x4,%esp
  8018fb:	50                   	push   %eax
  8018fc:	68 00 50 80 00       	push   $0x805000
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	e8 1d f1 ff ff       	call   800a26 <memmove>
	return r;
  801909:	83 c4 10             	add    $0x10,%esp
}
  80190c:	89 d8                	mov    %ebx,%eax
  80190e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801911:	5b                   	pop    %ebx
  801912:	5e                   	pop    %esi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	53                   	push   %ebx
  801919:	83 ec 20             	sub    $0x20,%esp
  80191c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80191f:	53                   	push   %ebx
  801920:	e8 36 ef ff ff       	call   80085b <strlen>
  801925:	83 c4 10             	add    $0x10,%esp
  801928:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192d:	7f 67                	jg     801996 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80192f:	83 ec 0c             	sub    $0xc,%esp
  801932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801935:	50                   	push   %eax
  801936:	e8 a7 f8 ff ff       	call   8011e2 <fd_alloc>
  80193b:	83 c4 10             	add    $0x10,%esp
		return r;
  80193e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801940:	85 c0                	test   %eax,%eax
  801942:	78 57                	js     80199b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	53                   	push   %ebx
  801948:	68 00 50 80 00       	push   $0x805000
  80194d:	e8 42 ef ff ff       	call   800894 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801952:	8b 45 0c             	mov    0xc(%ebp),%eax
  801955:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80195a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195d:	b8 01 00 00 00       	mov    $0x1,%eax
  801962:	e8 03 fe ff ff       	call   80176a <fsipc>
  801967:	89 c3                	mov    %eax,%ebx
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	85 c0                	test   %eax,%eax
  80196e:	79 14                	jns    801984 <open+0x6f>
		fd_close(fd, 0);
  801970:	83 ec 08             	sub    $0x8,%esp
  801973:	6a 00                	push   $0x0
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 5d f9 ff ff       	call   8012da <fd_close>
		return r;
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	89 da                	mov    %ebx,%edx
  801982:	eb 17                	jmp    80199b <open+0x86>
	}

	return fd2num(fd);
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	ff 75 f4             	pushl  -0xc(%ebp)
  80198a:	e8 2c f8 ff ff       	call   8011bb <fd2num>
  80198f:	89 c2                	mov    %eax,%edx
  801991:	83 c4 10             	add    $0x10,%esp
  801994:	eb 05                	jmp    80199b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801996:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80199b:	89 d0                	mov    %edx,%eax
  80199d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ad:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b2:	e8 b3 fd ff ff       	call   80176a <fsipc>
}
  8019b7:	c9                   	leave  
  8019b8:	c3                   	ret    

008019b9 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019b9:	55                   	push   %ebp
  8019ba:	89 e5                	mov    %esp,%ebp
  8019bc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8019bf:	68 eb 2c 80 00       	push   $0x802ceb
  8019c4:	ff 75 0c             	pushl  0xc(%ebp)
  8019c7:	e8 c8 ee ff ff       	call   800894 <strcpy>
	return 0;
}
  8019cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	53                   	push   %ebx
  8019d7:	83 ec 10             	sub    $0x10,%esp
  8019da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019dd:	53                   	push   %ebx
  8019de:	e8 7b 0a 00 00       	call   80245e <pageref>
  8019e3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019e6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019eb:	83 f8 01             	cmp    $0x1,%eax
  8019ee:	75 10                	jne    801a00 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	ff 73 0c             	pushl  0xc(%ebx)
  8019f6:	e8 c0 02 00 00       	call   801cbb <nsipc_close>
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801a00:	89 d0                	mov    %edx,%eax
  801a02:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a0d:	6a 00                	push   $0x0
  801a0f:	ff 75 10             	pushl  0x10(%ebp)
  801a12:	ff 75 0c             	pushl  0xc(%ebp)
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	ff 70 0c             	pushl  0xc(%eax)
  801a1b:	e8 78 03 00 00       	call   801d98 <nsipc_send>
}
  801a20:	c9                   	leave  
  801a21:	c3                   	ret    

00801a22 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a28:	6a 00                	push   $0x0
  801a2a:	ff 75 10             	pushl  0x10(%ebp)
  801a2d:	ff 75 0c             	pushl  0xc(%ebp)
  801a30:	8b 45 08             	mov    0x8(%ebp),%eax
  801a33:	ff 70 0c             	pushl  0xc(%eax)
  801a36:	e8 f1 02 00 00       	call   801d2c <nsipc_recv>
}
  801a3b:	c9                   	leave  
  801a3c:	c3                   	ret    

00801a3d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a43:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a46:	52                   	push   %edx
  801a47:	50                   	push   %eax
  801a48:	e8 e4 f7 ff ff       	call   801231 <fd_lookup>
  801a4d:	83 c4 10             	add    $0x10,%esp
  801a50:	85 c0                	test   %eax,%eax
  801a52:	78 17                	js     801a6b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a54:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a57:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a5d:	39 08                	cmp    %ecx,(%eax)
  801a5f:	75 05                	jne    801a66 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a61:	8b 40 0c             	mov    0xc(%eax),%eax
  801a64:	eb 05                	jmp    801a6b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 1c             	sub    $0x1c,%esp
  801a75:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	e8 62 f7 ff ff       	call   8011e2 <fd_alloc>
  801a80:	89 c3                	mov    %eax,%ebx
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	85 c0                	test   %eax,%eax
  801a87:	78 1b                	js     801aa4 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a89:	83 ec 04             	sub    $0x4,%esp
  801a8c:	68 07 04 00 00       	push   $0x407
  801a91:	ff 75 f4             	pushl  -0xc(%ebp)
  801a94:	6a 00                	push   $0x0
  801a96:	e8 fc f1 ff ff       	call   800c97 <sys_page_alloc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	79 10                	jns    801ab4 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801aa4:	83 ec 0c             	sub    $0xc,%esp
  801aa7:	56                   	push   %esi
  801aa8:	e8 0e 02 00 00       	call   801cbb <nsipc_close>
		return r;
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	89 d8                	mov    %ebx,%eax
  801ab2:	eb 24                	jmp    801ad8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ab4:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abd:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801abf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ac9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	50                   	push   %eax
  801ad0:	e8 e6 f6 ff ff       	call   8011bb <fd2num>
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5d                   	pop    %ebp
  801ade:	c3                   	ret    

00801adf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801adf:	55                   	push   %ebp
  801ae0:	89 e5                	mov    %esp,%ebp
  801ae2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae8:	e8 50 ff ff ff       	call   801a3d <fd2sockid>
		return r;
  801aed:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aef:	85 c0                	test   %eax,%eax
  801af1:	78 1f                	js     801b12 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	ff 75 10             	pushl  0x10(%ebp)
  801af9:	ff 75 0c             	pushl  0xc(%ebp)
  801afc:	50                   	push   %eax
  801afd:	e8 12 01 00 00       	call   801c14 <nsipc_accept>
  801b02:	83 c4 10             	add    $0x10,%esp
		return r;
  801b05:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 07                	js     801b12 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801b0b:	e8 5d ff ff ff       	call   801a6d <alloc_sockfd>
  801b10:	89 c1                	mov    %eax,%ecx
}
  801b12:	89 c8                	mov    %ecx,%eax
  801b14:	c9                   	leave  
  801b15:	c3                   	ret    

00801b16 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1f:	e8 19 ff ff ff       	call   801a3d <fd2sockid>
  801b24:	85 c0                	test   %eax,%eax
  801b26:	78 12                	js     801b3a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801b28:	83 ec 04             	sub    $0x4,%esp
  801b2b:	ff 75 10             	pushl  0x10(%ebp)
  801b2e:	ff 75 0c             	pushl  0xc(%ebp)
  801b31:	50                   	push   %eax
  801b32:	e8 2d 01 00 00       	call   801c64 <nsipc_bind>
  801b37:	83 c4 10             	add    $0x10,%esp
}
  801b3a:	c9                   	leave  
  801b3b:	c3                   	ret    

00801b3c <shutdown>:

int
shutdown(int s, int how)
{
  801b3c:	55                   	push   %ebp
  801b3d:	89 e5                	mov    %esp,%ebp
  801b3f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	e8 f3 fe ff ff       	call   801a3d <fd2sockid>
  801b4a:	85 c0                	test   %eax,%eax
  801b4c:	78 0f                	js     801b5d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b4e:	83 ec 08             	sub    $0x8,%esp
  801b51:	ff 75 0c             	pushl  0xc(%ebp)
  801b54:	50                   	push   %eax
  801b55:	e8 3f 01 00 00       	call   801c99 <nsipc_shutdown>
  801b5a:	83 c4 10             	add    $0x10,%esp
}
  801b5d:	c9                   	leave  
  801b5e:	c3                   	ret    

00801b5f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b65:	8b 45 08             	mov    0x8(%ebp),%eax
  801b68:	e8 d0 fe ff ff       	call   801a3d <fd2sockid>
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 12                	js     801b83 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	ff 75 10             	pushl  0x10(%ebp)
  801b77:	ff 75 0c             	pushl  0xc(%ebp)
  801b7a:	50                   	push   %eax
  801b7b:	e8 55 01 00 00       	call   801cd5 <nsipc_connect>
  801b80:	83 c4 10             	add    $0x10,%esp
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <listen>:

int
listen(int s, int backlog)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8e:	e8 aa fe ff ff       	call   801a3d <fd2sockid>
  801b93:	85 c0                	test   %eax,%eax
  801b95:	78 0f                	js     801ba6 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b97:	83 ec 08             	sub    $0x8,%esp
  801b9a:	ff 75 0c             	pushl  0xc(%ebp)
  801b9d:	50                   	push   %eax
  801b9e:	e8 67 01 00 00       	call   801d0a <nsipc_listen>
  801ba3:	83 c4 10             	add    $0x10,%esp
}
  801ba6:	c9                   	leave  
  801ba7:	c3                   	ret    

00801ba8 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801ba8:	55                   	push   %ebp
  801ba9:	89 e5                	mov    %esp,%ebp
  801bab:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bae:	ff 75 10             	pushl  0x10(%ebp)
  801bb1:	ff 75 0c             	pushl  0xc(%ebp)
  801bb4:	ff 75 08             	pushl  0x8(%ebp)
  801bb7:	e8 3a 02 00 00       	call   801df6 <nsipc_socket>
  801bbc:	83 c4 10             	add    $0x10,%esp
  801bbf:	85 c0                	test   %eax,%eax
  801bc1:	78 05                	js     801bc8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801bc3:	e8 a5 fe ff ff       	call   801a6d <alloc_sockfd>
}
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	53                   	push   %ebx
  801bce:	83 ec 04             	sub    $0x4,%esp
  801bd1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bd3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bda:	75 12                	jne    801bee <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bdc:	83 ec 0c             	sub    $0xc,%esp
  801bdf:	6a 02                	push   $0x2
  801be1:	e8 3f 08 00 00       	call   802425 <ipc_find_env>
  801be6:	a3 04 40 80 00       	mov    %eax,0x804004
  801beb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bee:	6a 07                	push   $0x7
  801bf0:	68 00 60 80 00       	push   $0x806000
  801bf5:	53                   	push   %ebx
  801bf6:	ff 35 04 40 80 00    	pushl  0x804004
  801bfc:	e8 d0 07 00 00       	call   8023d1 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c01:	83 c4 0c             	add    $0xc,%esp
  801c04:	6a 00                	push   $0x0
  801c06:	6a 00                	push   $0x0
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 5b 07 00 00       	call   80236a <ipc_recv>
}
  801c0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c12:	c9                   	leave  
  801c13:	c3                   	ret    

00801c14 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c24:	8b 06                	mov    (%esi),%eax
  801c26:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c2b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c30:	e8 95 ff ff ff       	call   801bca <nsipc>
  801c35:	89 c3                	mov    %eax,%ebx
  801c37:	85 c0                	test   %eax,%eax
  801c39:	78 20                	js     801c5b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c3b:	83 ec 04             	sub    $0x4,%esp
  801c3e:	ff 35 10 60 80 00    	pushl  0x806010
  801c44:	68 00 60 80 00       	push   $0x806000
  801c49:	ff 75 0c             	pushl  0xc(%ebp)
  801c4c:	e8 d5 ed ff ff       	call   800a26 <memmove>
		*addrlen = ret->ret_addrlen;
  801c51:	a1 10 60 80 00       	mov    0x806010,%eax
  801c56:	89 06                	mov    %eax,(%esi)
  801c58:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c5b:	89 d8                	mov    %ebx,%eax
  801c5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    

00801c64 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	53                   	push   %ebx
  801c68:	83 ec 08             	sub    $0x8,%esp
  801c6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c76:	53                   	push   %ebx
  801c77:	ff 75 0c             	pushl  0xc(%ebp)
  801c7a:	68 04 60 80 00       	push   $0x806004
  801c7f:	e8 a2 ed ff ff       	call   800a26 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c84:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c8a:	b8 02 00 00 00       	mov    $0x2,%eax
  801c8f:	e8 36 ff ff ff       	call   801bca <nsipc>
}
  801c94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ca7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801caa:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801caf:	b8 03 00 00 00       	mov    $0x3,%eax
  801cb4:	e8 11 ff ff ff       	call   801bca <nsipc>
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <nsipc_close>:

int
nsipc_close(int s)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801cc9:	b8 04 00 00 00       	mov    $0x4,%eax
  801cce:	e8 f7 fe ff ff       	call   801bca <nsipc>
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	53                   	push   %ebx
  801cd9:	83 ec 08             	sub    $0x8,%esp
  801cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ce7:	53                   	push   %ebx
  801ce8:	ff 75 0c             	pushl  0xc(%ebp)
  801ceb:	68 04 60 80 00       	push   $0x806004
  801cf0:	e8 31 ed ff ff       	call   800a26 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cf5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cfb:	b8 05 00 00 00       	mov    $0x5,%eax
  801d00:	e8 c5 fe ff ff       	call   801bca <nsipc>
}
  801d05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d08:	c9                   	leave  
  801d09:	c3                   	ret    

00801d0a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d0a:	55                   	push   %ebp
  801d0b:	89 e5                	mov    %esp,%ebp
  801d0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d1b:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d20:	b8 06 00 00 00       	mov    $0x6,%eax
  801d25:	e8 a0 fe ff ff       	call   801bca <nsipc>
}
  801d2a:	c9                   	leave  
  801d2b:	c3                   	ret    

00801d2c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	56                   	push   %esi
  801d30:	53                   	push   %ebx
  801d31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d3c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d42:	8b 45 14             	mov    0x14(%ebp),%eax
  801d45:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d4a:	b8 07 00 00 00       	mov    $0x7,%eax
  801d4f:	e8 76 fe ff ff       	call   801bca <nsipc>
  801d54:	89 c3                	mov    %eax,%ebx
  801d56:	85 c0                	test   %eax,%eax
  801d58:	78 35                	js     801d8f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d5a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d5f:	7f 04                	jg     801d65 <nsipc_recv+0x39>
  801d61:	39 c6                	cmp    %eax,%esi
  801d63:	7d 16                	jge    801d7b <nsipc_recv+0x4f>
  801d65:	68 f7 2c 80 00       	push   $0x802cf7
  801d6a:	68 bf 2c 80 00       	push   $0x802cbf
  801d6f:	6a 62                	push   $0x62
  801d71:	68 0c 2d 80 00       	push   $0x802d0c
  801d76:	e8 bb e4 ff ff       	call   800236 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d7b:	83 ec 04             	sub    $0x4,%esp
  801d7e:	50                   	push   %eax
  801d7f:	68 00 60 80 00       	push   $0x806000
  801d84:	ff 75 0c             	pushl  0xc(%ebp)
  801d87:	e8 9a ec ff ff       	call   800a26 <memmove>
  801d8c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	53                   	push   %ebx
  801d9c:	83 ec 04             	sub    $0x4,%esp
  801d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801da2:	8b 45 08             	mov    0x8(%ebp),%eax
  801da5:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801daa:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801db0:	7e 16                	jle    801dc8 <nsipc_send+0x30>
  801db2:	68 18 2d 80 00       	push   $0x802d18
  801db7:	68 bf 2c 80 00       	push   $0x802cbf
  801dbc:	6a 6d                	push   $0x6d
  801dbe:	68 0c 2d 80 00       	push   $0x802d0c
  801dc3:	e8 6e e4 ff ff       	call   800236 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dc8:	83 ec 04             	sub    $0x4,%esp
  801dcb:	53                   	push   %ebx
  801dcc:	ff 75 0c             	pushl  0xc(%ebp)
  801dcf:	68 0c 60 80 00       	push   $0x80600c
  801dd4:	e8 4d ec ff ff       	call   800a26 <memmove>
	nsipcbuf.send.req_size = size;
  801dd9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ddf:	8b 45 14             	mov    0x14(%ebp),%eax
  801de2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801de7:	b8 08 00 00 00       	mov    $0x8,%eax
  801dec:	e8 d9 fd ff ff       	call   801bca <nsipc>
}
  801df1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801e04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e07:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801e0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801e0f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801e14:	b8 09 00 00 00       	mov    $0x9,%eax
  801e19:	e8 ac fd ff ff       	call   801bca <nsipc>
}
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	56                   	push   %esi
  801e24:	53                   	push   %ebx
  801e25:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e28:	83 ec 0c             	sub    $0xc,%esp
  801e2b:	ff 75 08             	pushl  0x8(%ebp)
  801e2e:	e8 98 f3 ff ff       	call   8011cb <fd2data>
  801e33:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e35:	83 c4 08             	add    $0x8,%esp
  801e38:	68 24 2d 80 00       	push   $0x802d24
  801e3d:	53                   	push   %ebx
  801e3e:	e8 51 ea ff ff       	call   800894 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e43:	8b 46 04             	mov    0x4(%esi),%eax
  801e46:	2b 06                	sub    (%esi),%eax
  801e48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e4e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e55:	00 00 00 
	stat->st_dev = &devpipe;
  801e58:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e5f:	30 80 00 
	return 0;
}
  801e62:	b8 00 00 00 00       	mov    $0x0,%eax
  801e67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e6a:	5b                   	pop    %ebx
  801e6b:	5e                   	pop    %esi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    

00801e6e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	53                   	push   %ebx
  801e72:	83 ec 0c             	sub    $0xc,%esp
  801e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e78:	53                   	push   %ebx
  801e79:	6a 00                	push   $0x0
  801e7b:	e8 9c ee ff ff       	call   800d1c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e80:	89 1c 24             	mov    %ebx,(%esp)
  801e83:	e8 43 f3 ff ff       	call   8011cb <fd2data>
  801e88:	83 c4 08             	add    $0x8,%esp
  801e8b:	50                   	push   %eax
  801e8c:	6a 00                	push   $0x0
  801e8e:	e8 89 ee ff ff       	call   800d1c <sys_page_unmap>
}
  801e93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	57                   	push   %edi
  801e9c:	56                   	push   %esi
  801e9d:	53                   	push   %ebx
  801e9e:	83 ec 1c             	sub    $0x1c,%esp
  801ea1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ea4:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ea6:	a1 08 40 80 00       	mov    0x804008,%eax
  801eab:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 e0             	pushl  -0x20(%ebp)
  801eb4:	e8 a5 05 00 00       	call   80245e <pageref>
  801eb9:	89 c3                	mov    %eax,%ebx
  801ebb:	89 3c 24             	mov    %edi,(%esp)
  801ebe:	e8 9b 05 00 00       	call   80245e <pageref>
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	39 c3                	cmp    %eax,%ebx
  801ec8:	0f 94 c1             	sete   %cl
  801ecb:	0f b6 c9             	movzbl %cl,%ecx
  801ece:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ed1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ed7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801eda:	39 ce                	cmp    %ecx,%esi
  801edc:	74 1b                	je     801ef9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ede:	39 c3                	cmp    %eax,%ebx
  801ee0:	75 c4                	jne    801ea6 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ee2:	8b 42 58             	mov    0x58(%edx),%eax
  801ee5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ee8:	50                   	push   %eax
  801ee9:	56                   	push   %esi
  801eea:	68 2b 2d 80 00       	push   $0x802d2b
  801eef:	e8 1b e4 ff ff       	call   80030f <cprintf>
  801ef4:	83 c4 10             	add    $0x10,%esp
  801ef7:	eb ad                	jmp    801ea6 <_pipeisclosed+0xe>
	}
}
  801ef9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801efc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eff:	5b                   	pop    %ebx
  801f00:	5e                   	pop    %esi
  801f01:	5f                   	pop    %edi
  801f02:	5d                   	pop    %ebp
  801f03:	c3                   	ret    

00801f04 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f04:	55                   	push   %ebp
  801f05:	89 e5                	mov    %esp,%ebp
  801f07:	57                   	push   %edi
  801f08:	56                   	push   %esi
  801f09:	53                   	push   %ebx
  801f0a:	83 ec 28             	sub    $0x28,%esp
  801f0d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f10:	56                   	push   %esi
  801f11:	e8 b5 f2 ff ff       	call   8011cb <fd2data>
  801f16:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	bf 00 00 00 00       	mov    $0x0,%edi
  801f20:	eb 4b                	jmp    801f6d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f22:	89 da                	mov    %ebx,%edx
  801f24:	89 f0                	mov    %esi,%eax
  801f26:	e8 6d ff ff ff       	call   801e98 <_pipeisclosed>
  801f2b:	85 c0                	test   %eax,%eax
  801f2d:	75 48                	jne    801f77 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f2f:	e8 44 ed ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f34:	8b 43 04             	mov    0x4(%ebx),%eax
  801f37:	8b 0b                	mov    (%ebx),%ecx
  801f39:	8d 51 20             	lea    0x20(%ecx),%edx
  801f3c:	39 d0                	cmp    %edx,%eax
  801f3e:	73 e2                	jae    801f22 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f43:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f47:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f4a:	89 c2                	mov    %eax,%edx
  801f4c:	c1 fa 1f             	sar    $0x1f,%edx
  801f4f:	89 d1                	mov    %edx,%ecx
  801f51:	c1 e9 1b             	shr    $0x1b,%ecx
  801f54:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f57:	83 e2 1f             	and    $0x1f,%edx
  801f5a:	29 ca                	sub    %ecx,%edx
  801f5c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f60:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f64:	83 c0 01             	add    $0x1,%eax
  801f67:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f6a:	83 c7 01             	add    $0x1,%edi
  801f6d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f70:	75 c2                	jne    801f34 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f72:	8b 45 10             	mov    0x10(%ebp),%eax
  801f75:	eb 05                	jmp    801f7c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f77:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7f:	5b                   	pop    %ebx
  801f80:	5e                   	pop    %esi
  801f81:	5f                   	pop    %edi
  801f82:	5d                   	pop    %ebp
  801f83:	c3                   	ret    

00801f84 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	57                   	push   %edi
  801f88:	56                   	push   %esi
  801f89:	53                   	push   %ebx
  801f8a:	83 ec 18             	sub    $0x18,%esp
  801f8d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f90:	57                   	push   %edi
  801f91:	e8 35 f2 ff ff       	call   8011cb <fd2data>
  801f96:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f98:	83 c4 10             	add    $0x10,%esp
  801f9b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fa0:	eb 3d                	jmp    801fdf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fa2:	85 db                	test   %ebx,%ebx
  801fa4:	74 04                	je     801faa <devpipe_read+0x26>
				return i;
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	eb 44                	jmp    801fee <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801faa:	89 f2                	mov    %esi,%edx
  801fac:	89 f8                	mov    %edi,%eax
  801fae:	e8 e5 fe ff ff       	call   801e98 <_pipeisclosed>
  801fb3:	85 c0                	test   %eax,%eax
  801fb5:	75 32                	jne    801fe9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fb7:	e8 bc ec ff ff       	call   800c78 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fbc:	8b 06                	mov    (%esi),%eax
  801fbe:	3b 46 04             	cmp    0x4(%esi),%eax
  801fc1:	74 df                	je     801fa2 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fc3:	99                   	cltd   
  801fc4:	c1 ea 1b             	shr    $0x1b,%edx
  801fc7:	01 d0                	add    %edx,%eax
  801fc9:	83 e0 1f             	and    $0x1f,%eax
  801fcc:	29 d0                	sub    %edx,%eax
  801fce:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fd6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fd9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fdc:	83 c3 01             	add    $0x1,%ebx
  801fdf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fe2:	75 d8                	jne    801fbc <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  801fe7:	eb 05                	jmp    801fee <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    

00801ff6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ff6:	55                   	push   %ebp
  801ff7:	89 e5                	mov    %esp,%ebp
  801ff9:	56                   	push   %esi
  801ffa:	53                   	push   %ebx
  801ffb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ffe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802001:	50                   	push   %eax
  802002:	e8 db f1 ff ff       	call   8011e2 <fd_alloc>
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	89 c2                	mov    %eax,%edx
  80200c:	85 c0                	test   %eax,%eax
  80200e:	0f 88 2c 01 00 00    	js     802140 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802014:	83 ec 04             	sub    $0x4,%esp
  802017:	68 07 04 00 00       	push   $0x407
  80201c:	ff 75 f4             	pushl  -0xc(%ebp)
  80201f:	6a 00                	push   $0x0
  802021:	e8 71 ec ff ff       	call   800c97 <sys_page_alloc>
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	89 c2                	mov    %eax,%edx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	0f 88 0d 01 00 00    	js     802140 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802033:	83 ec 0c             	sub    $0xc,%esp
  802036:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802039:	50                   	push   %eax
  80203a:	e8 a3 f1 ff ff       	call   8011e2 <fd_alloc>
  80203f:	89 c3                	mov    %eax,%ebx
  802041:	83 c4 10             	add    $0x10,%esp
  802044:	85 c0                	test   %eax,%eax
  802046:	0f 88 e2 00 00 00    	js     80212e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204c:	83 ec 04             	sub    $0x4,%esp
  80204f:	68 07 04 00 00       	push   $0x407
  802054:	ff 75 f0             	pushl  -0x10(%ebp)
  802057:	6a 00                	push   $0x0
  802059:	e8 39 ec ff ff       	call   800c97 <sys_page_alloc>
  80205e:	89 c3                	mov    %eax,%ebx
  802060:	83 c4 10             	add    $0x10,%esp
  802063:	85 c0                	test   %eax,%eax
  802065:	0f 88 c3 00 00 00    	js     80212e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80206b:	83 ec 0c             	sub    $0xc,%esp
  80206e:	ff 75 f4             	pushl  -0xc(%ebp)
  802071:	e8 55 f1 ff ff       	call   8011cb <fd2data>
  802076:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802078:	83 c4 0c             	add    $0xc,%esp
  80207b:	68 07 04 00 00       	push   $0x407
  802080:	50                   	push   %eax
  802081:	6a 00                	push   $0x0
  802083:	e8 0f ec ff ff       	call   800c97 <sys_page_alloc>
  802088:	89 c3                	mov    %eax,%ebx
  80208a:	83 c4 10             	add    $0x10,%esp
  80208d:	85 c0                	test   %eax,%eax
  80208f:	0f 88 89 00 00 00    	js     80211e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802095:	83 ec 0c             	sub    $0xc,%esp
  802098:	ff 75 f0             	pushl  -0x10(%ebp)
  80209b:	e8 2b f1 ff ff       	call   8011cb <fd2data>
  8020a0:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020a7:	50                   	push   %eax
  8020a8:	6a 00                	push   $0x0
  8020aa:	56                   	push   %esi
  8020ab:	6a 00                	push   $0x0
  8020ad:	e8 28 ec ff ff       	call   800cda <sys_page_map>
  8020b2:	89 c3                	mov    %eax,%ebx
  8020b4:	83 c4 20             	add    $0x20,%esp
  8020b7:	85 c0                	test   %eax,%eax
  8020b9:	78 55                	js     802110 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020d0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020de:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020e5:	83 ec 0c             	sub    $0xc,%esp
  8020e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8020eb:	e8 cb f0 ff ff       	call   8011bb <fd2num>
  8020f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020f3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020f5:	83 c4 04             	add    $0x4,%esp
  8020f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8020fb:	e8 bb f0 ff ff       	call   8011bb <fd2num>
  802100:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802103:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802106:	83 c4 10             	add    $0x10,%esp
  802109:	ba 00 00 00 00       	mov    $0x0,%edx
  80210e:	eb 30                	jmp    802140 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802110:	83 ec 08             	sub    $0x8,%esp
  802113:	56                   	push   %esi
  802114:	6a 00                	push   $0x0
  802116:	e8 01 ec ff ff       	call   800d1c <sys_page_unmap>
  80211b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80211e:	83 ec 08             	sub    $0x8,%esp
  802121:	ff 75 f0             	pushl  -0x10(%ebp)
  802124:	6a 00                	push   $0x0
  802126:	e8 f1 eb ff ff       	call   800d1c <sys_page_unmap>
  80212b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80212e:	83 ec 08             	sub    $0x8,%esp
  802131:	ff 75 f4             	pushl  -0xc(%ebp)
  802134:	6a 00                	push   $0x0
  802136:	e8 e1 eb ff ff       	call   800d1c <sys_page_unmap>
  80213b:	83 c4 10             	add    $0x10,%esp
  80213e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802140:	89 d0                	mov    %edx,%eax
  802142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802145:	5b                   	pop    %ebx
  802146:	5e                   	pop    %esi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	50                   	push   %eax
  802153:	ff 75 08             	pushl  0x8(%ebp)
  802156:	e8 d6 f0 ff ff       	call   801231 <fd_lookup>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 18                	js     80217a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802162:	83 ec 0c             	sub    $0xc,%esp
  802165:	ff 75 f4             	pushl  -0xc(%ebp)
  802168:	e8 5e f0 ff ff       	call   8011cb <fd2data>
	return _pipeisclosed(fd, p);
  80216d:	89 c2                	mov    %eax,%edx
  80216f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802172:	e8 21 fd ff ff       	call   801e98 <_pipeisclosed>
  802177:	83 c4 10             	add    $0x10,%esp
}
  80217a:	c9                   	leave  
  80217b:	c3                   	ret    

0080217c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80217f:	b8 00 00 00 00       	mov    $0x0,%eax
  802184:	5d                   	pop    %ebp
  802185:	c3                   	ret    

00802186 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80218c:	68 43 2d 80 00       	push   $0x802d43
  802191:	ff 75 0c             	pushl  0xc(%ebp)
  802194:	e8 fb e6 ff ff       	call   800894 <strcpy>
	return 0;
}
  802199:	b8 00 00 00 00       	mov    $0x0,%eax
  80219e:	c9                   	leave  
  80219f:	c3                   	ret    

008021a0 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021a0:	55                   	push   %ebp
  8021a1:	89 e5                	mov    %esp,%ebp
  8021a3:	57                   	push   %edi
  8021a4:	56                   	push   %esi
  8021a5:	53                   	push   %ebx
  8021a6:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021ac:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021b1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b7:	eb 2d                	jmp    8021e6 <devcons_write+0x46>
		m = n - tot;
  8021b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021bc:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8021be:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8021c1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8021c6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8021c9:	83 ec 04             	sub    $0x4,%esp
  8021cc:	53                   	push   %ebx
  8021cd:	03 45 0c             	add    0xc(%ebp),%eax
  8021d0:	50                   	push   %eax
  8021d1:	57                   	push   %edi
  8021d2:	e8 4f e8 ff ff       	call   800a26 <memmove>
		sys_cputs(buf, m);
  8021d7:	83 c4 08             	add    $0x8,%esp
  8021da:	53                   	push   %ebx
  8021db:	57                   	push   %edi
  8021dc:	e8 fa e9 ff ff       	call   800bdb <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021e1:	01 de                	add    %ebx,%esi
  8021e3:	83 c4 10             	add    $0x10,%esp
  8021e6:	89 f0                	mov    %esi,%eax
  8021e8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021eb:	72 cc                	jb     8021b9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    

008021f5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021f5:	55                   	push   %ebp
  8021f6:	89 e5                	mov    %esp,%ebp
  8021f8:	83 ec 08             	sub    $0x8,%esp
  8021fb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802200:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802204:	74 2a                	je     802230 <devcons_read+0x3b>
  802206:	eb 05                	jmp    80220d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802208:	e8 6b ea ff ff       	call   800c78 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80220d:	e8 e7 e9 ff ff       	call   800bf9 <sys_cgetc>
  802212:	85 c0                	test   %eax,%eax
  802214:	74 f2                	je     802208 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  802216:	85 c0                	test   %eax,%eax
  802218:	78 16                	js     802230 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80221a:	83 f8 04             	cmp    $0x4,%eax
  80221d:	74 0c                	je     80222b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80221f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802222:	88 02                	mov    %al,(%edx)
	return 1;
  802224:	b8 01 00 00 00       	mov    $0x1,%eax
  802229:	eb 05                	jmp    802230 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80222b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802230:	c9                   	leave  
  802231:	c3                   	ret    

00802232 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802232:	55                   	push   %ebp
  802233:	89 e5                	mov    %esp,%ebp
  802235:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802238:	8b 45 08             	mov    0x8(%ebp),%eax
  80223b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80223e:	6a 01                	push   $0x1
  802240:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802243:	50                   	push   %eax
  802244:	e8 92 e9 ff ff       	call   800bdb <sys_cputs>
}
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <getchar>:

int
getchar(void)
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802254:	6a 01                	push   $0x1
  802256:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802259:	50                   	push   %eax
  80225a:	6a 00                	push   $0x0
  80225c:	e8 36 f2 ff ff       	call   801497 <read>
	if (r < 0)
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	85 c0                	test   %eax,%eax
  802266:	78 0f                	js     802277 <getchar+0x29>
		return r;
	if (r < 1)
  802268:	85 c0                	test   %eax,%eax
  80226a:	7e 06                	jle    802272 <getchar+0x24>
		return -E_EOF;
	return c;
  80226c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802270:	eb 05                	jmp    802277 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802272:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802277:	c9                   	leave  
  802278:	c3                   	ret    

00802279 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802279:	55                   	push   %ebp
  80227a:	89 e5                	mov    %esp,%ebp
  80227c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80227f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802282:	50                   	push   %eax
  802283:	ff 75 08             	pushl  0x8(%ebp)
  802286:	e8 a6 ef ff ff       	call   801231 <fd_lookup>
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 11                	js     8022a3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802295:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80229b:	39 10                	cmp    %edx,(%eax)
  80229d:	0f 94 c0             	sete   %al
  8022a0:	0f b6 c0             	movzbl %al,%eax
}
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    

008022a5 <opencons>:

int
opencons(void)
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ae:	50                   	push   %eax
  8022af:	e8 2e ef ff ff       	call   8011e2 <fd_alloc>
  8022b4:	83 c4 10             	add    $0x10,%esp
		return r;
  8022b7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8022b9:	85 c0                	test   %eax,%eax
  8022bb:	78 3e                	js     8022fb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022bd:	83 ec 04             	sub    $0x4,%esp
  8022c0:	68 07 04 00 00       	push   $0x407
  8022c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8022c8:	6a 00                	push   $0x0
  8022ca:	e8 c8 e9 ff ff       	call   800c97 <sys_page_alloc>
  8022cf:	83 c4 10             	add    $0x10,%esp
		return r;
  8022d2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022d4:	85 c0                	test   %eax,%eax
  8022d6:	78 23                	js     8022fb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022d8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022ed:	83 ec 0c             	sub    $0xc,%esp
  8022f0:	50                   	push   %eax
  8022f1:	e8 c5 ee ff ff       	call   8011bb <fd2num>
  8022f6:	89 c2                	mov    %eax,%edx
  8022f8:	83 c4 10             	add    $0x10,%esp
}
  8022fb:	89 d0                	mov    %edx,%eax
  8022fd:	c9                   	leave  
  8022fe:	c3                   	ret    

008022ff <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022ff:	55                   	push   %ebp
  802300:	89 e5                	mov    %esp,%ebp
  802302:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802305:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  80230c:	75 2e                	jne    80233c <set_pgfault_handler+0x3d>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented");

		sys_page_alloc(sys_getenvid(), (void *) (UXSTACKTOP - PGSIZE), PTE_SYSCALL);
  80230e:	e8 46 e9 ff ff       	call   800c59 <sys_getenvid>
  802313:	83 ec 04             	sub    $0x4,%esp
  802316:	68 07 0e 00 00       	push   $0xe07
  80231b:	68 00 f0 bf ee       	push   $0xeebff000
  802320:	50                   	push   %eax
  802321:	e8 71 e9 ff ff       	call   800c97 <sys_page_alloc>
		sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802326:	e8 2e e9 ff ff       	call   800c59 <sys_getenvid>
  80232b:	83 c4 08             	add    $0x8,%esp
  80232e:	68 46 23 80 00       	push   $0x802346
  802333:	50                   	push   %eax
  802334:	e8 a9 ea ff ff       	call   800de2 <sys_env_set_pgfault_upcall>
  802339:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80233c:	8b 45 08             	mov    0x8(%ebp),%eax
  80233f:	a3 00 70 80 00       	mov    %eax,0x807000
}
  802344:	c9                   	leave  
  802345:	c3                   	ret    

00802346 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802346:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802347:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80234c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80234e:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 48(%esp), %eax		// trap-time esp
  802351:	8b 44 24 30          	mov    0x30(%esp),%eax
	movl 40(%esp), %ebx		// trap-time eip
  802355:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// load eip into esp-4
	// in order to return to trap-time eip later, in the meantime not changing trap-time esp
	movl %ebx, -4(%eax)	
  802359:	89 58 fc             	mov    %ebx,-0x4(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.

	addl $8, %esp 			// esp now points to trap-time registers
  80235c:	83 c4 08             	add    $0x8,%esp
	popal					// pop to all registers
  80235f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $4, %esp			// esp now points to trap-time eflags
  802360:	83 c4 04             	add    $0x4,%esp
	popfl					// pop to eflags
  802363:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.

	popl %esp				// pop to esp
  802364:	5c                   	pop    %esp
	// subl $4, %esp		// arithmetic operation will change eflags!!!
	lea -4(%esp), %esp		// subl $4, %esp
  802365:	8d 64 24 fc          	lea    -0x4(%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.

	ret
  802369:	c3                   	ret    

0080236a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80236a:	55                   	push   %ebp
  80236b:	89 e5                	mov    %esp,%ebp
  80236d:	56                   	push   %esi
  80236e:	53                   	push   %ebx
  80236f:	8b 75 08             	mov    0x8(%ebp),%esi
  802372:	8b 45 0c             	mov    0xc(%ebp),%eax
  802375:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	// don't want to recv page
	if (pg == NULL)
  802378:	85 c0                	test   %eax,%eax
		pg = (void *)UTOP;
  80237a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80237f:	0f 44 c2             	cmove  %edx,%eax

	int err = sys_ipc_recv(pg);
  802382:	83 ec 0c             	sub    $0xc,%esp
  802385:	50                   	push   %eax
  802386:	e8 bc ea ff ff       	call   800e47 <sys_ipc_recv>

	if (from_env_store != NULL)
  80238b:	83 c4 10             	add    $0x10,%esp
  80238e:	85 f6                	test   %esi,%esi
  802390:	74 14                	je     8023a6 <ipc_recv+0x3c>
		*from_env_store = err < 0? 0 : thisenv->env_ipc_from;
  802392:	ba 00 00 00 00       	mov    $0x0,%edx
  802397:	85 c0                	test   %eax,%eax
  802399:	78 09                	js     8023a4 <ipc_recv+0x3a>
  80239b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8023a1:	8b 52 74             	mov    0x74(%edx),%edx
  8023a4:	89 16                	mov    %edx,(%esi)
	
	if (perm_store != NULL)
  8023a6:	85 db                	test   %ebx,%ebx
  8023a8:	74 14                	je     8023be <ipc_recv+0x54>
		*perm_store = err < 0? 0 : thisenv->env_ipc_perm;
  8023aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8023af:	85 c0                	test   %eax,%eax
  8023b1:	78 09                	js     8023bc <ipc_recv+0x52>
  8023b3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8023b9:	8b 52 78             	mov    0x78(%edx),%edx
  8023bc:	89 13                	mov    %edx,(%ebx)

	if (err < 0)
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	78 08                	js     8023ca <ipc_recv+0x60>
		return err;
	return thisenv->env_ipc_value;
  8023c2:	a1 08 40 80 00       	mov    0x804008,%eax
  8023c7:	8b 40 70             	mov    0x70(%eax),%eax
}
  8023ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023cd:	5b                   	pop    %ebx
  8023ce:	5e                   	pop    %esi
  8023cf:	5d                   	pop    %ebp
  8023d0:	c3                   	ret    

008023d1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8023d1:	55                   	push   %ebp
  8023d2:	89 e5                	mov    %esp,%ebp
  8023d4:	57                   	push   %edi
  8023d5:	56                   	push   %esi
  8023d6:	53                   	push   %ebx
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	8b 7d 08             	mov    0x8(%ebp),%edi
  8023dd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8023e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");

	// don't want to send page
	if (pg == NULL)
  8023e3:	85 db                	test   %ebx,%ebx
		pg = (void *)UTOP;
  8023e5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8023ea:	0f 44 d8             	cmove  %eax,%ebx
	
	int err = 0;
	
	do {

		err = sys_ipc_try_send(to_env, val, pg, perm);
  8023ed:	ff 75 14             	pushl  0x14(%ebp)
  8023f0:	53                   	push   %ebx
  8023f1:	56                   	push   %esi
  8023f2:	57                   	push   %edi
  8023f3:	e8 2c ea ff ff       	call   800e24 <sys_ipc_try_send>

		if (err < 0) {
  8023f8:	83 c4 10             	add    $0x10,%esp
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	79 1e                	jns    80241d <ipc_send+0x4c>
			if (err == -E_IPC_NOT_RECV)
  8023ff:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802402:	75 07                	jne    80240b <ipc_send+0x3a>
				sys_yield();
  802404:	e8 6f e8 ff ff       	call   800c78 <sys_yield>
  802409:	eb e2                	jmp    8023ed <ipc_send+0x1c>
			else 
				panic("ipc_send: %e", err);
  80240b:	50                   	push   %eax
  80240c:	68 4f 2d 80 00       	push   $0x802d4f
  802411:	6a 49                	push   $0x49
  802413:	68 5c 2d 80 00       	push   $0x802d5c
  802418:	e8 19 de ff ff       	call   800236 <_panic>
		}

	} while (err < 0);

}
  80241d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802420:	5b                   	pop    %ebx
  802421:	5e                   	pop    %esi
  802422:	5f                   	pop    %edi
  802423:	5d                   	pop    %ebp
  802424:	c3                   	ret    

00802425 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802425:	55                   	push   %ebp
  802426:	89 e5                	mov    %esp,%ebp
  802428:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80242b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802430:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802433:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802439:	8b 52 50             	mov    0x50(%edx),%edx
  80243c:	39 ca                	cmp    %ecx,%edx
  80243e:	75 0d                	jne    80244d <ipc_find_env+0x28>
			return envs[i].env_id;
  802440:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802443:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802448:	8b 40 48             	mov    0x48(%eax),%eax
  80244b:	eb 0f                	jmp    80245c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80244d:	83 c0 01             	add    $0x1,%eax
  802450:	3d 00 04 00 00       	cmp    $0x400,%eax
  802455:	75 d9                	jne    802430 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80245c:	5d                   	pop    %ebp
  80245d:	c3                   	ret    

0080245e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80245e:	55                   	push   %ebp
  80245f:	89 e5                	mov    %esp,%ebp
  802461:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802464:	89 d0                	mov    %edx,%eax
  802466:	c1 e8 16             	shr    $0x16,%eax
  802469:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802470:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802475:	f6 c1 01             	test   $0x1,%cl
  802478:	74 1d                	je     802497 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80247a:	c1 ea 0c             	shr    $0xc,%edx
  80247d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802484:	f6 c2 01             	test   $0x1,%dl
  802487:	74 0e                	je     802497 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802489:	c1 ea 0c             	shr    $0xc,%edx
  80248c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802493:	ef 
  802494:	0f b7 c0             	movzwl %ax,%eax
}
  802497:	5d                   	pop    %ebp
  802498:	c3                   	ret    
  802499:	66 90                	xchg   %ax,%ax
  80249b:	66 90                	xchg   %ax,%ax
  80249d:	66 90                	xchg   %ax,%ax
  80249f:	90                   	nop

008024a0 <__udivdi3>:
  8024a0:	55                   	push   %ebp
  8024a1:	57                   	push   %edi
  8024a2:	56                   	push   %esi
  8024a3:	53                   	push   %ebx
  8024a4:	83 ec 1c             	sub    $0x1c,%esp
  8024a7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8024ab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8024af:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8024b3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024b7:	85 f6                	test   %esi,%esi
  8024b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024bd:	89 ca                	mov    %ecx,%edx
  8024bf:	89 f8                	mov    %edi,%eax
  8024c1:	75 3d                	jne    802500 <__udivdi3+0x60>
  8024c3:	39 cf                	cmp    %ecx,%edi
  8024c5:	0f 87 c5 00 00 00    	ja     802590 <__udivdi3+0xf0>
  8024cb:	85 ff                	test   %edi,%edi
  8024cd:	89 fd                	mov    %edi,%ebp
  8024cf:	75 0b                	jne    8024dc <__udivdi3+0x3c>
  8024d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8024d6:	31 d2                	xor    %edx,%edx
  8024d8:	f7 f7                	div    %edi
  8024da:	89 c5                	mov    %eax,%ebp
  8024dc:	89 c8                	mov    %ecx,%eax
  8024de:	31 d2                	xor    %edx,%edx
  8024e0:	f7 f5                	div    %ebp
  8024e2:	89 c1                	mov    %eax,%ecx
  8024e4:	89 d8                	mov    %ebx,%eax
  8024e6:	89 cf                	mov    %ecx,%edi
  8024e8:	f7 f5                	div    %ebp
  8024ea:	89 c3                	mov    %eax,%ebx
  8024ec:	89 d8                	mov    %ebx,%eax
  8024ee:	89 fa                	mov    %edi,%edx
  8024f0:	83 c4 1c             	add    $0x1c,%esp
  8024f3:	5b                   	pop    %ebx
  8024f4:	5e                   	pop    %esi
  8024f5:	5f                   	pop    %edi
  8024f6:	5d                   	pop    %ebp
  8024f7:	c3                   	ret    
  8024f8:	90                   	nop
  8024f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802500:	39 ce                	cmp    %ecx,%esi
  802502:	77 74                	ja     802578 <__udivdi3+0xd8>
  802504:	0f bd fe             	bsr    %esi,%edi
  802507:	83 f7 1f             	xor    $0x1f,%edi
  80250a:	0f 84 98 00 00 00    	je     8025a8 <__udivdi3+0x108>
  802510:	bb 20 00 00 00       	mov    $0x20,%ebx
  802515:	89 f9                	mov    %edi,%ecx
  802517:	89 c5                	mov    %eax,%ebp
  802519:	29 fb                	sub    %edi,%ebx
  80251b:	d3 e6                	shl    %cl,%esi
  80251d:	89 d9                	mov    %ebx,%ecx
  80251f:	d3 ed                	shr    %cl,%ebp
  802521:	89 f9                	mov    %edi,%ecx
  802523:	d3 e0                	shl    %cl,%eax
  802525:	09 ee                	or     %ebp,%esi
  802527:	89 d9                	mov    %ebx,%ecx
  802529:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80252d:	89 d5                	mov    %edx,%ebp
  80252f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802533:	d3 ed                	shr    %cl,%ebp
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e2                	shl    %cl,%edx
  802539:	89 d9                	mov    %ebx,%ecx
  80253b:	d3 e8                	shr    %cl,%eax
  80253d:	09 c2                	or     %eax,%edx
  80253f:	89 d0                	mov    %edx,%eax
  802541:	89 ea                	mov    %ebp,%edx
  802543:	f7 f6                	div    %esi
  802545:	89 d5                	mov    %edx,%ebp
  802547:	89 c3                	mov    %eax,%ebx
  802549:	f7 64 24 0c          	mull   0xc(%esp)
  80254d:	39 d5                	cmp    %edx,%ebp
  80254f:	72 10                	jb     802561 <__udivdi3+0xc1>
  802551:	8b 74 24 08          	mov    0x8(%esp),%esi
  802555:	89 f9                	mov    %edi,%ecx
  802557:	d3 e6                	shl    %cl,%esi
  802559:	39 c6                	cmp    %eax,%esi
  80255b:	73 07                	jae    802564 <__udivdi3+0xc4>
  80255d:	39 d5                	cmp    %edx,%ebp
  80255f:	75 03                	jne    802564 <__udivdi3+0xc4>
  802561:	83 eb 01             	sub    $0x1,%ebx
  802564:	31 ff                	xor    %edi,%edi
  802566:	89 d8                	mov    %ebx,%eax
  802568:	89 fa                	mov    %edi,%edx
  80256a:	83 c4 1c             	add    $0x1c,%esp
  80256d:	5b                   	pop    %ebx
  80256e:	5e                   	pop    %esi
  80256f:	5f                   	pop    %edi
  802570:	5d                   	pop    %ebp
  802571:	c3                   	ret    
  802572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802578:	31 ff                	xor    %edi,%edi
  80257a:	31 db                	xor    %ebx,%ebx
  80257c:	89 d8                	mov    %ebx,%eax
  80257e:	89 fa                	mov    %edi,%edx
  802580:	83 c4 1c             	add    $0x1c,%esp
  802583:	5b                   	pop    %ebx
  802584:	5e                   	pop    %esi
  802585:	5f                   	pop    %edi
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    
  802588:	90                   	nop
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	89 d8                	mov    %ebx,%eax
  802592:	f7 f7                	div    %edi
  802594:	31 ff                	xor    %edi,%edi
  802596:	89 c3                	mov    %eax,%ebx
  802598:	89 d8                	mov    %ebx,%eax
  80259a:	89 fa                	mov    %edi,%edx
  80259c:	83 c4 1c             	add    $0x1c,%esp
  80259f:	5b                   	pop    %ebx
  8025a0:	5e                   	pop    %esi
  8025a1:	5f                   	pop    %edi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
  8025a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025a8:	39 ce                	cmp    %ecx,%esi
  8025aa:	72 0c                	jb     8025b8 <__udivdi3+0x118>
  8025ac:	31 db                	xor    %ebx,%ebx
  8025ae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8025b2:	0f 87 34 ff ff ff    	ja     8024ec <__udivdi3+0x4c>
  8025b8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8025bd:	e9 2a ff ff ff       	jmp    8024ec <__udivdi3+0x4c>
  8025c2:	66 90                	xchg   %ax,%ax
  8025c4:	66 90                	xchg   %ax,%ax
  8025c6:	66 90                	xchg   %ax,%ax
  8025c8:	66 90                	xchg   %ax,%ax
  8025ca:	66 90                	xchg   %ax,%ax
  8025cc:	66 90                	xchg   %ax,%ax
  8025ce:	66 90                	xchg   %ax,%ax

008025d0 <__umoddi3>:
  8025d0:	55                   	push   %ebp
  8025d1:	57                   	push   %edi
  8025d2:	56                   	push   %esi
  8025d3:	53                   	push   %ebx
  8025d4:	83 ec 1c             	sub    $0x1c,%esp
  8025d7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8025db:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8025df:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8025e7:	85 d2                	test   %edx,%edx
  8025e9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8025ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025f1:	89 f3                	mov    %esi,%ebx
  8025f3:	89 3c 24             	mov    %edi,(%esp)
  8025f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8025fa:	75 1c                	jne    802618 <__umoddi3+0x48>
  8025fc:	39 f7                	cmp    %esi,%edi
  8025fe:	76 50                	jbe    802650 <__umoddi3+0x80>
  802600:	89 c8                	mov    %ecx,%eax
  802602:	89 f2                	mov    %esi,%edx
  802604:	f7 f7                	div    %edi
  802606:	89 d0                	mov    %edx,%eax
  802608:	31 d2                	xor    %edx,%edx
  80260a:	83 c4 1c             	add    $0x1c,%esp
  80260d:	5b                   	pop    %ebx
  80260e:	5e                   	pop    %esi
  80260f:	5f                   	pop    %edi
  802610:	5d                   	pop    %ebp
  802611:	c3                   	ret    
  802612:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802618:	39 f2                	cmp    %esi,%edx
  80261a:	89 d0                	mov    %edx,%eax
  80261c:	77 52                	ja     802670 <__umoddi3+0xa0>
  80261e:	0f bd ea             	bsr    %edx,%ebp
  802621:	83 f5 1f             	xor    $0x1f,%ebp
  802624:	75 5a                	jne    802680 <__umoddi3+0xb0>
  802626:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80262a:	0f 82 e0 00 00 00    	jb     802710 <__umoddi3+0x140>
  802630:	39 0c 24             	cmp    %ecx,(%esp)
  802633:	0f 86 d7 00 00 00    	jbe    802710 <__umoddi3+0x140>
  802639:	8b 44 24 08          	mov    0x8(%esp),%eax
  80263d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802641:	83 c4 1c             	add    $0x1c,%esp
  802644:	5b                   	pop    %ebx
  802645:	5e                   	pop    %esi
  802646:	5f                   	pop    %edi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	85 ff                	test   %edi,%edi
  802652:	89 fd                	mov    %edi,%ebp
  802654:	75 0b                	jne    802661 <__umoddi3+0x91>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f7                	div    %edi
  80265f:	89 c5                	mov    %eax,%ebp
  802661:	89 f0                	mov    %esi,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f5                	div    %ebp
  802667:	89 c8                	mov    %ecx,%eax
  802669:	f7 f5                	div    %ebp
  80266b:	89 d0                	mov    %edx,%eax
  80266d:	eb 99                	jmp    802608 <__umoddi3+0x38>
  80266f:	90                   	nop
  802670:	89 c8                	mov    %ecx,%eax
  802672:	89 f2                	mov    %esi,%edx
  802674:	83 c4 1c             	add    $0x1c,%esp
  802677:	5b                   	pop    %ebx
  802678:	5e                   	pop    %esi
  802679:	5f                   	pop    %edi
  80267a:	5d                   	pop    %ebp
  80267b:	c3                   	ret    
  80267c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802680:	8b 34 24             	mov    (%esp),%esi
  802683:	bf 20 00 00 00       	mov    $0x20,%edi
  802688:	89 e9                	mov    %ebp,%ecx
  80268a:	29 ef                	sub    %ebp,%edi
  80268c:	d3 e0                	shl    %cl,%eax
  80268e:	89 f9                	mov    %edi,%ecx
  802690:	89 f2                	mov    %esi,%edx
  802692:	d3 ea                	shr    %cl,%edx
  802694:	89 e9                	mov    %ebp,%ecx
  802696:	09 c2                	or     %eax,%edx
  802698:	89 d8                	mov    %ebx,%eax
  80269a:	89 14 24             	mov    %edx,(%esp)
  80269d:	89 f2                	mov    %esi,%edx
  80269f:	d3 e2                	shl    %cl,%edx
  8026a1:	89 f9                	mov    %edi,%ecx
  8026a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8026a7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8026ab:	d3 e8                	shr    %cl,%eax
  8026ad:	89 e9                	mov    %ebp,%ecx
  8026af:	89 c6                	mov    %eax,%esi
  8026b1:	d3 e3                	shl    %cl,%ebx
  8026b3:	89 f9                	mov    %edi,%ecx
  8026b5:	89 d0                	mov    %edx,%eax
  8026b7:	d3 e8                	shr    %cl,%eax
  8026b9:	89 e9                	mov    %ebp,%ecx
  8026bb:	09 d8                	or     %ebx,%eax
  8026bd:	89 d3                	mov    %edx,%ebx
  8026bf:	89 f2                	mov    %esi,%edx
  8026c1:	f7 34 24             	divl   (%esp)
  8026c4:	89 d6                	mov    %edx,%esi
  8026c6:	d3 e3                	shl    %cl,%ebx
  8026c8:	f7 64 24 04          	mull   0x4(%esp)
  8026cc:	39 d6                	cmp    %edx,%esi
  8026ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026d2:	89 d1                	mov    %edx,%ecx
  8026d4:	89 c3                	mov    %eax,%ebx
  8026d6:	72 08                	jb     8026e0 <__umoddi3+0x110>
  8026d8:	75 11                	jne    8026eb <__umoddi3+0x11b>
  8026da:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8026de:	73 0b                	jae    8026eb <__umoddi3+0x11b>
  8026e0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8026e4:	1b 14 24             	sbb    (%esp),%edx
  8026e7:	89 d1                	mov    %edx,%ecx
  8026e9:	89 c3                	mov    %eax,%ebx
  8026eb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8026ef:	29 da                	sub    %ebx,%edx
  8026f1:	19 ce                	sbb    %ecx,%esi
  8026f3:	89 f9                	mov    %edi,%ecx
  8026f5:	89 f0                	mov    %esi,%eax
  8026f7:	d3 e0                	shl    %cl,%eax
  8026f9:	89 e9                	mov    %ebp,%ecx
  8026fb:	d3 ea                	shr    %cl,%edx
  8026fd:	89 e9                	mov    %ebp,%ecx
  8026ff:	d3 ee                	shr    %cl,%esi
  802701:	09 d0                	or     %edx,%eax
  802703:	89 f2                	mov    %esi,%edx
  802705:	83 c4 1c             	add    $0x1c,%esp
  802708:	5b                   	pop    %ebx
  802709:	5e                   	pop    %esi
  80270a:	5f                   	pop    %edi
  80270b:	5d                   	pop    %ebp
  80270c:	c3                   	ret    
  80270d:	8d 76 00             	lea    0x0(%esi),%esi
  802710:	29 f9                	sub    %edi,%ecx
  802712:	19 d6                	sbb    %edx,%esi
  802714:	89 74 24 04          	mov    %esi,0x4(%esp)
  802718:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80271c:	e9 18 ff ff ff       	jmp    802639 <__umoddi3+0x69>
